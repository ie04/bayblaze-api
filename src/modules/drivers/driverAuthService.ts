import { createHash, randomBytes, randomInt, timingSafeEqual } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { Resend } from "resend";

import { getBayblazeAuth, getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import { ApiRequestError } from "./driverWorkflowService";
import { createDriverSessionToken } from "./driverSession";

const codeAttemptLimit = 5;

type SignupCodeRecord = {
  attempts?: number;
  codeHash: string;
  email: string;
  expiresAt?: Timestamp;
  salt: string;
  usedAt?: Timestamp;
};

export async function prepareDriverAccess(email: string) {
  const normalizedEmail = parseEmail(email);
  await assertAllowlisted(normalizedEmail);

  if (await authAccountExists(normalizedEmail)) {
    return { mode: "login" as const };
  }

  const code = randomInt(100_000, 1_000_000).toString();
  const salt = randomBytes(16).toString("hex");
  const emailKey = emailToFirestoreKey(normalizedEmail);
  const ttlMinutes = env.DRIVER_SIGNUP_CODE_TTL_MINUTES;
  const expiresAt = Timestamp.fromDate(new Date(Date.now() + ttlMinutes * 60_000));

  await getBayblazeFirestore().collection("driver_signup_codes").doc(emailKey).set(
    {
      email: normalizedEmail,
      salt,
      codeHash: hashCode(code, salt),
      attempts: 0,
      expiresAt,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      usedAt: FieldValue.delete(),
    },
    { merge: true },
  );

  await sendSignupCode(normalizedEmail, code, ttlMinutes);
  return { mode: "code_sent" as const };
}

export async function createAllowedDriverAccount(email: string, code: string, password: string) {
  const normalizedEmail = parseEmail(email);
  const parsedCode = parseCode(code);
  const parsedPassword = parsePassword(password);
  const emailKey = emailToFirestoreKey(normalizedEmail);

  await assertAllowlisted(normalizedEmail);

  if (await authAccountExists(normalizedEmail)) {
    throw new ApiRequestError(409, "A driver account already exists for this email.");
  }

  const verification = await getBayblazeFirestore().runTransaction(async (transaction) => {
    const codeRef = getBayblazeFirestore().collection("driver_signup_codes").doc(emailKey);
    const codeSnapshot = await transaction.get(codeRef);

    if (!codeSnapshot.exists) {
      return { ok: false as const, code: "missing" as const };
    }

    const record = codeSnapshot.data() as SignupCodeRecord;
    const expiresAtMillis = record.expiresAt?.toMillis?.() ?? 0;

    if (record.usedAt) return { ok: false as const, code: "used" as const };
    if (Date.now() > expiresAtMillis) return { ok: false as const, code: "expired" as const };
    if ((record.attempts ?? 0) >= codeAttemptLimit) return { ok: false as const, code: "locked" as const };

    if (!safeEquals(record.codeHash, hashCode(parsedCode, record.salt))) {
      transaction.update(codeRef, {
        attempts: FieldValue.increment(1),
        updatedAt: FieldValue.serverTimestamp(),
      });
      return { ok: false as const, code: "invalid" as const };
    }

    return { ok: true as const };
  });

  if (!verification.ok) {
    throw verificationError(verification.code);
  }

  const user = await getBayblazeAuth().createUser({
    disabled: false,
    email: normalizedEmail,
    emailVerified: true,
    password: parsedPassword,
  });

  await Promise.all([
    getBayblazeFirestore().collection("driver_signup_codes").doc(emailKey).set(
      {
        usedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    ),
    getBayblazeFirestore().collection("driver_profiles").doc(user.uid).set(
      {
        uid: user.uid,
        email: normalizedEmail,
        firstName: "",
        lastName: "",
        phoneNumber: "",
        bio: "",
        onboardingComplete: false,
        clockedIn: false,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    ),
  ]);

  return createSessionResponse(user.uid, normalizedEmail);
}

export async function loginDriver(email: string, password: string) {
  const normalizedEmail = parseEmail(email);
  await assertAllowlisted(normalizedEmail);

  const apiKey = env.FIREBASE_WEB_API_KEY;
  if (!apiKey) {
    throw new ApiRequestError(503, "Driver password login is not configured.");
  }

  const response = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${encodeURIComponent(apiKey)}`,
    {
      body: JSON.stringify({
        email: normalizedEmail,
        password,
        returnSecureToken: true,
      }),
      headers: { "content-type": "application/json" },
      method: "POST",
    },
  );
  const payload = (await response.json().catch(() => ({}))) as { localId?: string; email?: string; error?: { message?: string } };

  if (!response.ok || !payload.localId) {
    throw new ApiRequestError(401, "Driver email or password is not valid.");
  }

  return createSessionResponse(payload.localId, payload.email ?? normalizedEmail);
}

export function createSessionResponse(uid: string, email: string) {
  return {
    session: {
      email,
      token: createDriverSessionToken({ email, uid }),
      uid,
    },
  };
}

async function assertAllowlisted(email: string) {
  const snapshot = await getBayblazeFirestore()
    .collection("driver_allowlist")
    .doc(emailToFirestoreKey(email))
    .get();
  const record = snapshot.data();

  if (!snapshot.exists || record?.active !== true) {
    throw new ApiRequestError(403, "This email has not been approved for BayBlaze driver access.");
  }
}

async function authAccountExists(email: string) {
  try {
    await getBayblazeAuth().getUserByEmail(email);
    return true;
  } catch (caught) {
    if (typeof caught === "object" && caught !== null && "code" in caught && caught.code === "auth/user-not-found") {
      return false;
    }

    throw caught;
  }
}

async function sendSignupCode(email: string, code: string, ttlMinutes: number) {
  if (!env.RESEND_API_KEY || !env.DRIVER_EMAIL_FROM) {
    throw new ApiRequestError(503, "Driver email verification is not configured.");
  }

  const resend = new Resend(env.RESEND_API_KEY);
  await resend.emails.send({
    from: env.DRIVER_EMAIL_FROM,
    html: [
      "<div style=\"font-family:Arial,sans-serif;color:#11130f;line-height:1.5\">",
      "<h1 style=\"font-size:22px;margin:0 0 12px\">BayBlaze Driver</h1>",
      "<p>Your verification code is:</p>",
      `<p style="font-size:32px;font-weight:800;letter-spacing:6px;margin:16px 0">${code}</p>`,
      `<p>This code expires in ${ttlMinutes} minutes.</p>`,
      "</div>",
    ].join(""),
    replyTo: env.DRIVER_EMAIL_REPLY_TO || undefined,
    subject: "Your BayBlaze driver code",
    text: `Your BayBlaze driver verification code is ${code}. It expires in ${ttlMinutes} minutes.`,
    to: email,
  });
}

function verificationError(code: "missing" | "used" | "expired" | "locked" | "invalid") {
  switch (code) {
    case "missing":
      return new ApiRequestError(412, "Request a new verification code.");
    case "used":
      return new ApiRequestError(412, "This verification code has already been used.");
    case "expired":
      return new ApiRequestError(410, "This verification code has expired.");
    case "locked":
      return new ApiRequestError(429, "Request a new verification code.");
    case "invalid":
      return new ApiRequestError(403, "Verification code is not valid.");
  }
}

function parseEmail(value: unknown) {
  if (typeof value !== "string") {
    throw new ApiRequestError(400, "Email is required.");
  }

  const email = value.trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new ApiRequestError(400, "Enter a valid email address.");
  }

  return email;
}

function parseCode(value: unknown) {
  if (typeof value !== "string" || !/^\d{6}$/.test(value.trim())) {
    throw new ApiRequestError(400, "Enter the 6-digit verification code.");
  }

  return value.trim();
}

function parsePassword(value: unknown) {
  if (typeof value !== "string") {
    throw new ApiRequestError(400, "Password is required.");
  }

  if (value.length < 12 || !/[a-z]/i.test(value) || !/\d/.test(value) || !/[^a-z0-9]/i.test(value)) {
    throw new ApiRequestError(400, "Password must be at least 12 characters and include letters, numbers, and a symbol.");
  }

  return value;
}

function emailToFirestoreKey(email: string) {
  return email.trim().toLowerCase().replace(/[/?#[\]]/g, "_");
}

function hashCode(code: string, salt: string) {
  return createHash("sha256").update(`${salt}:${code}`).digest("hex");
}

function safeEquals(first: string, second: string) {
  const firstBuffer = Buffer.from(first);
  const secondBuffer = Buffer.from(second);

  return firstBuffer.length === secondBuffer.length && timingSafeEqual(firstBuffer, secondBuffer);
}
