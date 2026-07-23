import assert from "node:assert/strict";
import test from "node:test";

import {
  calculatePartnerCommission,
  calculatePayoutSettlement,
  canAccessPartnerDashboard,
  createAttributionToken,
  generateUniquePartnerCode,
  getCommissionLifecycleUpdate,
  isSelfReferralIdentity,
  normalizePartnerCode,
  validatePartnerCode,
  verifyAttributionToken,
} from "../src/modules/partners/partnerDomain";

test("partner codes normalize case and reject unsafe or misleading values", () => {
  assert.equal(normalizePartnerCode("  local-smoke_20! "), "LOCAL-SMOKE_20");
  assert.equal(validatePartnerCode("neighborhood-20"), "NEIGHBORHOOD-20");
  assert.throws(() => validatePartnerCode("ADMIN-DEAL"), /reserved/i);
  assert.throws(() => validatePartnerCode("x"), /5 to 40/i);
});

test("generated partner codes are stable and retry collisions", async () => {
  const first = await generateUniquePartnerCode({ isTaken: async () => false, prefix: "local", uid: "account-a" });
  const second = await generateUniquePartnerCode({ isTaken: async () => false, prefix: "local", uid: "account-a" });
  assert.equal(first, second);

  const checked: string[] = [];
  const collisionResult = await generateUniquePartnerCode({
    isTaken: async (code) => {
      checked.push(code);
      return checked.length === 1;
    },
    prefix: "local",
    uid: "account-a",
  });
  assert.notEqual(collisionResult, first);
  assert.equal(checked.length, 2);
});

test("attribution tokens accept valid data and reject expired or tampered data", () => {
  const secret = "test-attribution-secret";
  const payload = { attributionId: "attribution-1", code: "LOCAL-12345", exp: 2_000_000_000, partnerUid: "partner-a" };
  const token = createAttributionToken(payload, secret);
  assert.deepEqual(verifyAttributionToken(token, secret, new Date("2030-01-01T00:00:00Z")), payload);
  assert.equal(verifyAttributionToken(`${token.slice(0, -1)}x`, secret, new Date("2030-01-01T00:00:00Z")), null);
  assert.equal(verifyAttributionToken(token, secret, new Date("2040-01-01T00:00:00Z")), null);
  assert.equal(verifyAttributionToken(token, "wrong-secret", new Date("2030-01-01T00:00:00Z")), null);
});

test("commission calculations use integer cents and reduce product basis for refunds", () => {
  assert.deepEqual(calculatePartnerCommission({
    commissionRateBps: 3_000,
    originalQualifyingSubtotalCents: 10_000,
    refundedCents: 2_500,
  }), {
    commissionCents: 2_250,
    qualifyingSubtotalCents: 7_500,
    refundedCents: 2_500,
  });
  assert.equal(calculatePartnerCommission({
    commissionRateBps: 3_333,
    originalQualifyingSubtotalCents: 101,
  }).commissionCents, 34);
});

test("commission lifecycle handles eligibility, cancellation, refunds, and chargebacks", () => {
  const eventAt = new Date("2026-07-01T00:00:00Z");
  const eligibilityAt = new Date("2026-07-08T00:00:00Z");
  assert.equal(getCommissionLifecycleUpdate({
    commissionCents: 3_000, currentStatus: "tracked", eligibilityAt, eventAt,
    eventType: "order_completed",
  }).status, "pending");
  assert.equal(getCommissionLifecycleUpdate({
    commissionCents: 3_000, currentStatus: "pending", eligibilityAt,
    eventAt: new Date("2026-07-09T00:00:00Z"), eventType: "order_completed",
  }).status, "eligible");
  assert.deepEqual(getCommissionLifecycleUpdate({
    commissionCents: 0, currentStatus: "eligible", eligibilityAt, eventAt,
    eventType: "order_canceled",
  }), { clawbackCents: 0, status: "reversed" });
  assert.deepEqual(getCommissionLifecycleUpdate({
    commissionCents: 2_000, currentStatus: "paid", eligibilityAt, eventAt,
    eventType: "payment_refunded", paidCommissionCents: 3_000,
  }), { clawbackCents: 1_000, status: "reversed" });
  assert.deepEqual(getCommissionLifecycleUpdate({
    commissionCents: 0, currentStatus: "paid", eligibilityAt, eventAt,
    eventType: "chargeback", paidCommissionCents: 3_000,
  }), { clawbackCents: 3_000, status: "reversed" });
});

test("only active partners have dashboard access and self-referrals are excluded", () => {
  assert.equal(canAccessPartnerDashboard("active"), true);
  for (const status of ["pending", "suspended", "rejected"]) {
    assert.equal(canAccessPartnerDashboard(status), false);
  }
  assert.equal(isSelfReferralIdentity({ customerUid: "p1", partnerUid: "p1" }), true);
  assert.equal(isSelfReferralIdentity({ customerEmail: "Partner@Example.com", partnerEmail: "partner@example.com", partnerUid: "p1" }), true);
  assert.equal(isSelfReferralIdentity({ customerUid: "c1", customerEmail: "customer@example.com", partnerEmail: "partner@example.com", partnerUid: "p1" }), false);
});

test("payout settlements offset reversals and never return a negative payable amount", () => {
  assert.deepEqual(calculatePayoutSettlement({
    eligibleCommissionCents: [2_000, 1_500],
    outstandingClawbackCents: [1_000],
  }), { grossCommissionCents: 3_500, offsetClawbackCents: 1_000, payableCents: 2_500 });
  assert.equal(calculatePayoutSettlement({
    eligibleCommissionCents: [500],
    outstandingClawbackCents: [1_000],
  }).payableCents, 0);
});
