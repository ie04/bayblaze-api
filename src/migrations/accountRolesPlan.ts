import { accountRoles } from "../modules/accounts/accountTypes";

/** No badge grants authority. Existing staff roles and disabled restrictions survive. */
export function planAccountRoles(data: Record<string, unknown>, auth?: {
  uid: string; email?: string; displayName?: string; disabled: boolean;
}) {
  if (data.roles !== undefined && !Array.isArray(data.roles)) {
    throw new Error("Account roles must be an array; manual reconciliation required.");
  }
  const roles = data.roles ?? [];
  if ((roles as unknown[]).some((role) => !accountRoles.includes(role as never))) {
    throw new Error("Unknown account role; manual reconciliation required.");
  }
  return {
    roles: [...new Set(roles as string[])],
    disabled: data.disabled === true || auth?.disabled === true,
    ...(data.uid === undefined && auth ? { uid: auth.uid } : {}),
    ...(data.email === undefined && auth?.email ? { email: auth.email.trim().toLowerCase() } : {}),
    ...(data.displayName === undefined && auth?.displayName ? { displayName: auth.displayName } : {}),
    ...(data.settings === undefined ? { settings: { ageVerificationDisabled: false } } : {}),
  };
}
