import { createAccountSessionToken, verifyAccountSessionToken } from "../accounts/accountSession";

type DriverSessionPayload = {
  email: string;
  exp: number;
  uid: string;
};

export function createDriverSessionToken(input: {
  badges?: Array<"customer" | "employee">;
  email: string;
  roles?: Array<"admin" | "driver" | "inventory">;
  settings?: { ageVerificationDisabled: boolean };
  uid: string;
}) {
  return createAccountSessionToken({
    badges: input.badges ?? ["employee"],
    email: input.email,
    roles: input.roles ?? ["driver"],
    settings: input.settings ?? { ageVerificationDisabled: false },
    uid: input.uid,
  });
}

export function verifyDriverSessionToken(token: string) {
  const payload = verifyAccountSessionToken(token);

  if (!payload?.roles.includes("driver")) {
    return null;
  }

  return payload as DriverSessionPayload;
}
