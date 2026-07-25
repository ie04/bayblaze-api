import assert from "node:assert/strict";
import test from "node:test";

import { getBayblazeFirestore } from "../src/clients/firebaseAdminClient";
import {
  adminPromoCodeCategory,
  createDiscountCode,
  discountCodesCollection,
  recordAdminDiscountCodeUse,
  referralPartnerPromoCodeCategory,
} from "../src/modules/discountCodes/discountCodeService";
import { ApiRequestError } from "../src/modules/drivers/driverWorkflowService";
import {
  previewCustomerDiscountCode,
  recordCustomerDiscountCodeUse,
  startCustomerWinReward,
} from "../src/modules/win/winRewardService";

const runIntegration = Boolean(process.env.FIRESTORE_EMULATOR_HOST);

test("single-use promo toggle blocks repeated account use", { skip: !runIntegration }, async () => {
  const suffix = Date.now().toString(36).toUpperCase();
  const code = `ONCE-${suffix}`;

  await createDiscountCode({
    category: adminPromoCodeCategory,
    code,
    codeType: "discount",
    discountPercent: 20,
    singleUsePerAccount: true,
    usageLimit: 1_000_000,
  });

  const firstUse = await recordAdminDiscountCodeUse({
    code,
    orderId: `order-${suffix}-1`,
    uid: `customer-${suffix}`,
  });
  assert.equal(firstUse.alreadyRecorded, false);

  await assert.rejects(() => recordAdminDiscountCodeUse({
    code,
    orderId: `order-${suffix}-2`,
    uid: `customer-${suffix}`,
  }), (error: unknown) =>
    error instanceof ApiRequestError &&
    error.status === 409 &&
    error.message === "That promo code has already been used by this account.",
  );
});

test("owned promos cannot be used by the owner account", { skip: !runIntegration }, async () => {
  const suffix = Date.now().toString(36).toUpperCase();
  const code = `OWNER-${suffix}`;

  await createDiscountCode({
    category: referralPartnerPromoCodeCategory,
    code,
    codeType: "discount",
    commissionPercent: 20,
    discountPercent: 20,
    ownerUid: `owner-${suffix}`,
    singleUsePerAccount: true,
    usageLimit: 1_000_000,
  });

  await assert.rejects(() => recordAdminDiscountCodeUse({
    code,
    orderId: `order-${suffix}`,
    uid: `owner-${suffix}`,
  }), (error: unknown) =>
    error instanceof ApiRequestError &&
    error.status === 409 &&
    error.message === "You cannot use your own referral partner promo code.",
  );
});

test("win referrals default to single-use and block self use", { skip: !runIntegration }, async () => {
  const suffix = Date.now().toString(36).toUpperCase();
  const ownerUid = `win-owner-${suffix}`;
  const customerUid = `win-customer-${suffix}`;
  const reward = await startCustomerWinReward(ownerUid, {
    campaign: `campaign-${suffix}`,
    source: "test",
  });
  const code = reward.referralCode;

  const promoSnapshot = await getBayblazeFirestore()
    .collection(discountCodesCollection)
    .doc(code)
    .get();
  assert.equal(promoSnapshot.data()?.singleUsePerAccount, true);

  await assert.rejects(() => previewCustomerDiscountCode(ownerUid, {
    code,
    subtotalCents: 2_500,
  }), (error: unknown) =>
    error instanceof ApiRequestError &&
    error.status === 409 &&
    error.message === "Send this friend code to someone else to unlock your freebie.",
  );

  const completed = await recordCustomerDiscountCodeUse(customerUid, {
    code,
    customerEmail: `friend-${suffix}@example.com`,
    customerId: `customer-${suffix}`,
    isCustomerFirstOrder: true,
    orderId: `order-${suffix}`,
  });
  assert.equal(completed.status, "qualified");

  const accountUsage = await getBayblazeFirestore()
    .collection(discountCodesCollection)
    .doc(code)
    .collection("account_usages")
    .doc(customerUid)
    .get();
  assert.equal(accountUsage.data()?.usedCount, 1);

  await assert.rejects(() => recordCustomerDiscountCodeUse(customerUid, {
    code,
    customerEmail: `friend-${suffix}@example.com`,
    customerId: `customer-${suffix}`,
    isCustomerFirstOrder: true,
    orderId: `order-${suffix}-again`,
  }), (error: unknown) =>
    error instanceof ApiRequestError &&
    error.status === 409,
  );
});
