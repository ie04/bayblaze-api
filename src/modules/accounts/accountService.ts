import { FieldValue } from "firebase-admin/firestore";

import { getBayblazeAuth, getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { createAccountSessionToken } from "./accountSession";
import {
  accountBadges,
  accountRoles,
  type AccountBadge,
  type AccountRecord,
  type AccountRole,
} from "./accountTypes";

const accountCollection = "accounts";

export async function loginAccount(email: string, password: string) {
  const normalizedEmail = parseEmail(email);
  return loginExistingAccount(normalizedEmail, password);
}

export async function loginCustomerAccount(email: string, password: string) {
  const response = await loginExistingAccount(parseEmail(email), password);

  if (!response.account.badges.includes("customer")) {
    const account = await ensureAccountRecord(response.account.uid, response.account.email, {
      badges: ["customer"],
    });

    return createSessionResponse(account);
  }

  return response;
}

export async function createCustomerAccount(input: {
  displayName?: string;
  email: string;
  firstName?: string;
  lastName?: string;
  password: string;
}) {
  const email = parseEmail(input.email);
  const password = parsePassword(input.password);

  if (await authAccountExists(email)) {
    throw new ApiRequestError(409, "A BayBlaze account already exists for this email.");
  }

  const displayName = input.displayName?.trim() ||
    [input.firstName, input.lastName].map((value) => value?.trim()).filter(Boolean).join(" ");
  const user = await getBayblazeAuth().createUser({
    disabled: false,
    displayName: displayName || undefined,
    email,
    emailVerified: true,
    password,
  });
  const account = await ensureAccountRecord(user.uid, email, {
    badges: ["customer"],
    displayName,
  });

  return createSessionResponse(account);
}

async function loginExistingAccount(normalizedEmail: string, password: string) {
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
    badges?: AccountBadge[];
    displayName?: string;
    settings?: Partial<AccountRecord["settings"]>;
  } = {},
) {
  const accountRef = getBayblazeFirestore().collection(accountCollection).doc(uid);
  const snapshot = await accountRef.get();
  const existing = snapshot.exists ? normalizeAccountRecord(uid, snapshot.data() ?? {}) : null;
  const roles = normalizeRoles([...(existing?.roles ?? []), ...(options.roles ?? [])]);
  const badges = normalizeBadges([
    ...(existing?.badges ?? []),
    ...(options.badges ?? []),
    ...(roles.length > 0 ? ["employee" as const] : []),
  ]);
  const settings = {
    ageVerificationDisabled:
      options.settings?.ageVerificationDisabled ?? existing?.settings.ageVerificationDisabled ?? false,
  };
  const authUser = await getBayblazeAuth().getUser(uid).catch(() => null);
  const record = {
    uid,
    email: parseEmail(email),
    disabled: authUser?.disabled === true || existing?.disabled === true,
    displayName: options.displayName || authUser?.displayName || existing?.displayName || "",
    badges,
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
      badges: account?.badges ?? [],
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
    badges?: AccountBadge[];
    roles?: AccountRole[];
    settings?: Partial<AccountRecord["settings"]>;
  },
) {
  const user = await getBayblazeAuth().getUser(uid);
  const existing = await getAccount(uid);
  const roles = input.roles ? normalizeRoles(input.roles) : existing?.roles ?? [];
  const badges = input.badges ? normalizeBadges(input.badges) : existing?.badges ?? inferBadges(roles);
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
      badges,
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
        badges: account.badges,
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
    badges: account.badges,
    roles: account.roles,
    settings: account.settings,
    uid: account.uid,
  };
}

export function normalizeRoles(values: unknown[]): AccountRole[] {
  const validRoles = new Set<AccountRole>(accountRoles);
  return [...new Set(values.filter((role): role is AccountRole => validRoles.has(role as AccountRole)))];
}

export function normalizeBadges(values: unknown[]): AccountBadge[] {
  const validBadges = new Set<AccountBadge>(accountBadges);
  const badges = [...new Set(values.filter((badge): badge is AccountBadge => validBadges.has(badge as AccountBadge)))];

  return badges.length > 0 ? badges : ["customer"];
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

function parsePassword(value: unknown) {
  if (typeof value !== "string") {
    throw new ApiRequestError(400, "Password is required.");
  }

  if (value.length < 12 || !/[a-z]/i.test(value) || !/\d/.test(value) || !/[^a-z0-9]/i.test(value)) {
    throw new ApiRequestError(400, "Password must be at least 12 characters and include letters, numbers, and a symbol.");
  }

  return value;
}

function normalizeAccountRecord(uid: string, data: FirebaseFirestore.DocumentData): AccountRecord {
  const roles = normalizeRoles(Array.isArray(data.roles) ? data.roles : []);

  return {
    createdAt: data.createdAt ?? null,
    disabled: data.disabled === true,
    displayName: typeof data.displayName === "string" ? data.displayName : "",
    email: typeof data.email === "string" ? data.email : "",
    badges: normalizeBadges(Array.isArray(data.badges) ? data.badges : inferBadges(roles)),
    lastLoginAt: data.lastLoginAt ?? null,
    roles,
    settings: {
      ageVerificationDisabled: data.settings?.ageVerificationDisabled === true,
    },
    uid,
    updatedAt: data.updatedAt ?? null,
  };
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

function inferBadges(roles: AccountRole[]): AccountBadge[] {
  return roles.length > 0 ? ["employee" as const] : ["customer" as const];
}
