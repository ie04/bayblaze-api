import { FieldValue } from "firebase-admin/firestore";

import { getBayblazeAuth, getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { createAccountSessionToken } from "./accountSession";
import { accountRoles, type AccountRecord, type AccountRole } from "./accountTypes";

const accountCollection = "accounts";

export async function loginAccount(email: string, password: string) {
  const normalizedEmail = parseEmail(email);
  const apiKey = env.FIREBASE_WEB_API_KEY;

  if (!apiKey) {
    throw new ApiRequestError(503, "BayBlaze account login is not configured.");
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
  const payload = (await response.json().catch(() => ({}))) as {
    email?: string;
    error?: { message?: string };
    localId?: string;
  };

  if (!response.ok || !payload.localId) {
    throw new ApiRequestError(401, "Email or password is not valid.");
  }

  const account = await ensureAccountRecord(payload.localId, payload.email ?? normalizedEmail);

  if (account.disabled) {
    throw new ApiRequestError(403, "This BayBlaze account is disabled.");
  }

  await getBayblazeFirestore().collection(accountCollection).doc(account.uid).set(
    {
      email: account.email,
      lastLoginAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  return createSessionResponse(account);
}

export async function getAccount(uid: string) {
  const snapshot = await getBayblazeFirestore().collection(accountCollection).doc(uid).get();
  return snapshot.exists ? normalizeAccountRecord(snapshot.id, snapshot.data() ?? {}) : null;
}

export async function ensureAccountRecord(
  uid: string,
  email: string,
  options: {
    roles?: AccountRole[];
    settings?: Partial<AccountRecord["settings"]>;
  } = {},
) {
  const accountRef = getBayblazeFirestore().collection(accountCollection).doc(uid);
  const snapshot = await accountRef.get();
  const existing = snapshot.exists ? normalizeAccountRecord(uid, snapshot.data() ?? {}) : null;
  const roles = normalizeRoles([...(existing?.roles ?? []), ...(options.roles ?? [])]);
  const settings = {
    ageVerificationDisabled:
      options.settings?.ageVerificationDisabled ?? existing?.settings.ageVerificationDisabled ?? false,
  };
  const authUser = await getBayblazeAuth().getUser(uid).catch(() => null);
  const record = {
    uid,
    email: parseEmail(email),
    disabled: authUser?.disabled === true || existing?.disabled === true,
    displayName: authUser?.displayName || existing?.displayName || "",
    roles,
    settings,
    createdAt: existing?.createdAt ?? FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await accountRef.set(record, { merge: true });

  return {
    ...record,
    createdAt: existing?.createdAt,
    updatedAt: existing?.updatedAt,
  } as AccountRecord;
}

export async function searchAccounts(query: string, limit: number) {
  const normalizedQuery = query.trim().toLowerCase();
  const authUsers = await getBayblazeAuth().listUsers(Math.min(Math.max(limit * 4, 25), 500));
  const authMatches = authUsers.users
    .filter((user) => {
      const haystack = [user.email, user.displayName, user.uid].filter(Boolean).join(" ").toLowerCase();
      return !normalizedQuery || haystack.includes(normalizedQuery);
    })
    .slice(0, limit);

  const accountSnapshots = await Promise.all(
    authMatches.map((user) => getBayblazeFirestore().collection(accountCollection).doc(user.uid).get()),
  );

  return authMatches.map((user, index) => {
    const account = accountSnapshots[index]?.exists
      ? normalizeAccountRecord(user.uid, accountSnapshots[index]?.data() ?? {})
      : null;

    return {
      createdAt: user.metadata.creationTime,
      disabled: user.disabled || account?.disabled === true,
      displayName: account?.displayName || user.displayName || "",
      email: user.email || account?.email || "",
      lastLoginAt: account?.lastLoginAt ?? user.metadata.lastSignInTime,
      roles: account?.roles ?? [],
      settings: account?.settings ?? { ageVerificationDisabled: false },
      uid: user.uid,
      updatedAt: account?.updatedAt ?? null,
    };
  });
}

export async function updateAccountAccess(
  uid: string,
  input: {
    disabled?: boolean;
    displayName?: string;
    roles?: AccountRole[];
    settings?: Partial<AccountRecord["settings"]>;
  },
) {
  const user = await getBayblazeAuth().getUser(uid);
  const existing = await getAccount(uid);
  const roles = input.roles ? normalizeRoles(input.roles) : existing?.roles ?? [];
  const settings = {
    ageVerificationDisabled:
      input.settings?.ageVerificationDisabled ?? existing?.settings.ageVerificationDisabled ?? false,
  };
  const disabled = input.disabled ?? user.disabled;

  await getBayblazeAuth().updateUser(uid, {
    disabled,
    displayName: input.displayName ?? user.displayName,
  });

  await getBayblazeFirestore().collection(accountCollection).doc(uid).set(
    {
      uid,
      email: parseEmail(user.email ?? existing?.email ?? ""),
      disabled,
      displayName: input.displayName ?? user.displayName ?? existing?.displayName ?? "",
      roles,
      settings,
      createdAt: existing?.createdAt ?? FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );

  const account = await getAccount(uid);
  if (!account) {
    throw new ApiRequestError(500, "Unable to read updated account.");
  }

  return account;
}

export function createSessionResponse(account: AccountRecord) {
  return {
    account: sanitizeAccount(account),
    session: {
      email: account.email,
      token: createAccountSessionToken({
        email: account.email,
        roles: account.roles,
        settings: account.settings,
        uid: account.uid,
      }),
      uid: account.uid,
    },
  };
}

export function sanitizeAccount(account: AccountRecord) {
  return {
    disabled: account.disabled,
    displayName: account.displayName ?? "",
    email: account.email,
    roles: account.roles,
    settings: account.settings,
    uid: account.uid,
  };
}

export function normalizeRoles(values: unknown[]) {
  const validRoles = new Set<AccountRole>(accountRoles);
  return [...new Set(values.filter((role): role is AccountRole => validRoles.has(role as AccountRole)))];
}

export function parseEmail(value: unknown) {
  if (typeof value !== "string") {
    throw new ApiRequestError(400, "Email is required.");
  }

  const email = value.trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new ApiRequestError(400, "Enter a valid email address.");
  }

  return email;
}

function normalizeAccountRecord(uid: string, data: FirebaseFirestore.DocumentData): AccountRecord {
  return {
    createdAt: data.createdAt ?? null,
    disabled: data.disabled === true,
    displayName: typeof data.displayName === "string" ? data.displayName : "",
    email: typeof data.email === "string" ? data.email : "",
    lastLoginAt: data.lastLoginAt ?? null,
    roles: normalizeRoles(Array.isArray(data.roles) ? data.roles : []),
    settings: {
      ageVerificationDisabled: data.settings?.ageVerificationDisabled === true,
    },
    uid,
    updatedAt: data.updatedAt ?? null,
  };
}
