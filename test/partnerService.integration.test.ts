import assert from "node:assert/strict";
import test from "node:test";

import { getBayblazeFirestore } from "../src/clients/firebaseAdminClient";
import { referralPartnerPromoCodeCategory } from "../src/modules/discountCodes/discountCodeService";
import { ApiRequestError } from "../src/modules/drivers/driverWorkflowService";
import {
  createActivePartnerWithPromo,
  getPartnerEarnings,
  getPartnerOverview,
  getPartnerProfile,
  listPartnerReferrals,
  recordAdminExternalPayout,
  recordPartnerOrderEvent,
  resolvePartnerAttribution,
  submitPartnerApplication,
  updateAdminPartnerStatus,
} from "../src/modules/partners/partnerService";

const runIntegration = Boolean(process.env.FIRESTORE_EMULATOR_HOST);

test("persistent partner authorization, attribution, commissions, refunds, and payouts", { skip: !runIntegration }, async () => {
  const suffix = Date.now().toString(36).toUpperCase();
  const partnerUid = `partner-${suffix}`;
  const secondPartnerUid = `partner-two-${suffix}`;
  const collisionUid = `partner-collision-${suffix}`;
  const customerUid = `customer-${suffix}`;
  const db = getBayblazeFirestore();

  await Promise.all([
    seedCustomerAccount(partnerUid, `partner-${suffix}@example.com`, "Neighborhood Partner"),
    seedCustomerAccount(secondPartnerUid, `partner-two-${suffix}@example.com`, "Second Partner"),
    seedCustomerAccount(collisionUid, `partner-collision-${suffix}@example.com`, "Collision Partner"),
    seedCustomerAccount(customerUid, `customer-${suffix}@example.com`, "Customer"),
  ]);

  const application = await submitPartnerApplication(partnerUid);
  assert.equal(application.partner?.status, "pending");
  await assert.rejects(() => getPartnerOverview(partnerUid), (error: unknown) =>
    error instanceof ApiRequestError && error.status === 403,
  );

  const promo = await createActivePartnerWithPromo({
    commissionPercent: 30,
    discountPercent: 20,
    minimumSpendCents: 2_500,
    ownerUid: partnerUid,
  });
  assert.match(promo.code, /^LOCAL-/);
  assert.equal((await getPartnerProfile(partnerUid)).partner?.status, "active");

  await submitPartnerApplication(secondPartnerUid);
  const secondPromo = await createActivePartnerWithPromo({
    code: `CREW-${suffix}`,
    commissionPercent: 25,
    discountPercent: 15,
    ownerUid: secondPartnerUid,
  });
  await submitPartnerApplication(collisionUid);
  await assert.rejects(() => createActivePartnerWithPromo({
    code: promo.code,
    commissionPercent: 10,
    discountPercent: 10,
    ownerUid: collisionUid,
  }), (error: unknown) => error instanceof ApiRequestError && error.status === 409);

  await assert.rejects(() => resolvePartnerAttribution({ code: "NOT-A-PARTNER" }), (error: unknown) =>
    error instanceof ApiRequestError && error.status === 404,
  );
  const attribution = await resolvePartnerAttribution({ code: promo.code.toLowerCase(), sourcePath: "/shop" });
  assert.equal(attribution.code, promo.code);
  const firstTouch = await resolvePartnerAttribution({
    code: secondPromo.code,
    existingToken: attribution.attributionToken,
    sourcePath: "/products/example",
  });
  assert.equal(firstTouch.code, promo.code);

  const metadata = {
    checkout_promo_category: referralPartnerPromoCodeCategory,
    checkout_promo_code: promo.code,
    checkout_promo_status: "applied",
    checkout_promo_subtotal: 100,
    checkout_promo_total_after_discount: 80,
    partner_attribution_token: attribution.attributionToken,
  };
  const order = {
    currencyCode: "usd",
    customerUid,
    email: `customer-${suffix}@example.com`,
    id: `order-${suffix}`,
    metadata,
  };
  const tracked = await recordPartnerOrderEvent({ eventId: `placed-${suffix}`, eventType: "order_placed", order });
  assert.equal(tracked.status, "tracked");
  const duplicate = await recordPartnerOrderEvent({ eventId: `placed-${suffix}`, eventType: "order_placed", order });
  assert.equal(duplicate.duplicate, true);
  const captured = await recordPartnerOrderEvent({ eventId: `captured-${suffix}`, eventType: "payment_captured", order });
  assert.equal(captured.status, "eligible");

  const referrals = await listPartnerReferrals(partnerUid, { limit: 10, query: "", status: "eligible" });
  assert.equal(referrals.total, 1);
  assert.equal(referrals.items[0]?.earnedCents, 2_400);
  assert.equal("email" in (referrals.items[0] ?? {}), false);

  const selfReferral = await recordPartnerOrderEvent({
    eventId: `self-${suffix}`,
    eventType: "payment_captured",
    order: { ...order, customerUid: partnerUid, id: `self-order-${suffix}` },
  });
  assert.deepEqual(selfReferral, { ignored: true, reason: "self_referral" });

  const firstPayout = await recordAdminExternalPayout(partnerUid, {
    idempotencyKey: `payout-first-${suffix}`,
    methodLabel: "External ACH",
    reference: `ACH-${suffix}`,
  });
  assert.equal(firstPayout.payout.amountCents, 2_400);
  const duplicatePayout = await recordAdminExternalPayout(partnerUid, {
    idempotencyKey: `payout-first-${suffix}`,
    methodLabel: "External ACH",
    reference: `ACH-${suffix}`,
  });
  assert.equal(duplicatePayout.alreadyRecorded, true);

  const partialRefund = await recordPartnerOrderEvent({
    eventId: `refund-${suffix}`,
    eventType: "payment_refunded",
    order: { ...order, refundedCents: 4_000 },
  });
  assert.equal(partialRefund.status, "reversed");

  const nextOrder = { ...order, id: `order-next-${suffix}` };
  await recordPartnerOrderEvent({ eventId: `captured-next-${suffix}`, eventType: "payment_captured", order: nextOrder });
  const earningsWithClawback = await getPartnerEarnings(partnerUid);
  assert.equal(earningsWithClawback.earnings.availableCents, 1_200);
  const offsetPayout = await recordAdminExternalPayout(partnerUid, {
    idempotencyKey: `payout-offset-${suffix}`,
    methodLabel: "External ACH",
    reference: `ACH-OFFSET-${suffix}`,
  });
  assert.equal(offsetPayout.payout.amountCents, 1_200);
  assert.equal(offsetPayout.payout.offsetClawbackCents, 1_200);

  const canceled = await recordPartnerOrderEvent({
    eventId: `cancel-${suffix}`,
    eventType: "order_canceled",
    order: nextOrder,
  });
  assert.equal(canceled.status, "reversed");

  await updateAdminPartnerStatus(partnerUid, "suspended");
  await assert.rejects(() => getPartnerEarnings(partnerUid), (error: unknown) =>
    error instanceof ApiRequestError && error.status === 403,
  );
  const eventAfterSuspension = await recordPartnerOrderEvent({
    eventId: `refund-after-suspension-${suffix}`,
    eventType: "payment_refunded",
    order: { ...nextOrder, refundedCents: 8_000 },
  });
  assert.equal(eventAfterSuspension.status, "reversed");
  const newOrderWhileSuspended = await recordPartnerOrderEvent({
    eventId: `new-suspended-${suffix}`,
    eventType: "payment_captured",
    order: { ...order, id: `new-suspended-${suffix}` },
  });
  assert.deepEqual(newOrderWhileSuspended, { ignored: true, reason: "partner_not_active" });

  await updateAdminPartnerStatus(secondPartnerUid, "rejected");
  await assert.rejects(() => getPartnerOverview(secondPartnerUid), (error: unknown) =>
    error instanceof ApiRequestError && error.status === 403,
  );

  const partnerDoc = await db.collection("referral_partners").doc(partnerUid).get();
  assert.equal(partnerDoc.data()?.status, "suspended");
});

async function seedCustomerAccount(uid: string, email: string, displayName: string) {
  await getBayblazeFirestore().collection("accounts").doc(uid).set({
    badges: ["customer"],
    disabled: false,
    displayName,
    email,
    roles: [],
    settings: { ageVerificationDisabled: false },
  });
}
