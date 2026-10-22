import assert from "node:assert/strict";
import { createHmac } from "node:crypto";
import test from "node:test";
import { planAccountRoles } from "../src/migrations/accountRolesPlan";
import { requireAccountRole } from "../src/http/middleware/accountAuth";
import { createAccountSessionToken, verifyAccountSessionToken } from "../src/modules/accounts/accountSession";
import { env } from "../src/config/env";

test("migration preserves staff roles and restrictions without deriving privileges from badges", () => {
  assert.deepEqual(planAccountRoles({ badges: ["employee"], roles: ["driver", "admin", "driver"], disabled: true,
    settings: { ageVerificationDisabled: true } }), { roles: ["driver", "admin"], disabled: true });
  assert.deepEqual(planAccountRoles({ badges: ["employee"] }), {
    roles: [], disabled: false, settings: { ageVerificationDisabled: false },
  });
  assert.deepEqual(planAccountRoles({}, { uid: "new", email: "NEW@EXAMPLE.COM", disabled: true }), {
    uid: "new", email: "new@example.com", roles: [], disabled: true,
    settings: { ageVerificationDisabled: false },
  });
  const migrated = { roles: ["inventory"], disabled: false, settings: { ageVerificationDisabled: false } };
  assert.deepEqual(planAccountRoles(migrated), { roles: ["inventory"], disabled: false });
  assert.throws(() => planAccountRoles({ roles: ["superuser"] }), /Unknown/);
  assert.throws(() => planAccountRoles({ roles: "admin" }), /array/);
});

test("staff roles work without badges and customer-only accounts cannot enter staff routes", () => {
  for (const role of ["admin", "driver", "inventory"] as const) {
    for (const roles of [[], [role]]) {
      let allowed = false; let status = 0;
      requireAccountRole(role)({ accountAuth: { roles } } as never,
        { status(code: number) { status = code; return this; }, json() {} } as never,
        () => { allowed = true; });
      assert.equal(allowed, roles.length > 0);
      assert.equal(status, roles.length ? 0 : 403);
    }
  }
});

test("new sessions omit badges and existing signed sessions remain compatible", () => {
  const saved = env.ACCOUNT_SESSION_SECRET;
  env.ACCOUNT_SESSION_SECRET = "account-role-test-signing-secret";
  try {
    const token = createAccountSessionToken({ email: "staff@example.com", roles: ["admin"],
      settings: { ageVerificationDisabled: false }, uid: "staff" });
    assert.equal("badges" in JSON.parse(Buffer.from(token.split(".")[0]!, "base64url").toString()), false);
    const legacyPayload = { ...verifyAccountSessionToken(token), badges: ["employee"] };
    const encoded = Buffer.from(JSON.stringify(legacyPayload)).toString("base64url");
    const signature = createHmac("sha256", env.ACCOUNT_SESSION_SECRET).update(encoded).digest("base64url");
    const verified = verifyAccountSessionToken(`${encoded}.${signature}`);
    assert.deepEqual(verified?.roles, ["admin"]);
    assert.equal("badges" in verified!, false);
  } finally { env.ACCOUNT_SESSION_SECRET = saved; }
});
