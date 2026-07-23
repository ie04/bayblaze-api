import { createHash, createHmac } from "node:crypto";

import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../clients/firebaseAdminClient";
import { env } from "../config/env";
import { getAccount } from "../modules/accounts/accountService";
import {
  discountCodesCollection,
  referralPartnerPromoCodeCategory,
  serializeDiscountCode,
} from "../modules/discountCodes/discountCodeService";
import { percentToBasisPoints, validatePartnerCode } from "../modules/partners/partnerDomain";
import {
  partnerCodeIndexCollection,
  partnersCollection,
} from "../modules/partners/partnerService";

const migrationId = "20260722_referral_partners_v1";

export async function migrateReferralPartners(options: { apply: boolean }) {
  const db = getBayblazeFirestore();
  const promoSnapshot = await db.collection(discountCodesCollection)
    .where("category", "==", referralPartnerPromoCodeCategory)
    .get();
  const promos = promoSnapshot.docs.map((doc) => serializeDiscountCode(doc.id, doc.data() ?? {}));
  const byOwner = new Map<string, typeof promos>();

  for (const promo of promos) {
    if (!promo.ownerUid) throw new Error(`Referral promo ${promo.code} has no owner UID.`);
    const current = byOwner.get(promo.ownerUid) ?? [];
    current.push(promo);
    byOwner.set(promo.ownerUid, current);
  }

  const conflicts = [...byOwner.entries()].filter(([, ownerPromos]) => ownerPromos.length > 1);
  if (conflicts.length) {
    throw new Error(
      `One-to-one partner migration blocked: ${conflicts.map(([uid, ownerPromos]) => `${uid}=[${ownerPromos.map((promo) => promo.code).join(",")}]`).join("; ")}`,
    );
  }

  const plan = [];
  for (const [uid, [promo]] of byOwner.entries()) {
    const account = await getAccount(uid);
    if (!account || account.disabled) throw new Error(`Referral promo ${promo.code} owner ${uid} is missing or disabled.`);
    const code = validatePartnerCode(promo.code, { allowLegacyReserved: true });
    const usages = await db.collection(discountCodesCollection).doc(code).collection("order_usages").get();
    plan.push({ account, code, promo, usages });
  }

  if (!options.apply) {
    return {
      apply: false,
      migrationId,
      partners: plan.map((item) => ({ code: item.code, referralCount: item.usages.size, uid: item.account.uid })),
    };
  }

  let migratedPartners = 0;
  let migratedReferrals = 0;
  for (const item of plan) {
    const partnerRef = db.collection(partnersCollection).doc(item.account.uid);
    const indexRef = db.collection(partnerCodeIndexCollection).doc(item.code);
    const migrationRef = db.collection("system_migrations").doc(`${migrationId}_${item.account.uid}`);
    const createdPartner = await db.runTransaction(async (transaction) => {
      const migrationSnapshot = await transaction.get(migrationRef);
      if (migrationSnapshot.exists) return false;
      const now = FieldValue.serverTimestamp();
      const status = item.promo.status === "active" ? "active" : "suspended";
      transaction.set(partnerRef, {
        approvedAt: item.promo.createdAt ? Timestamp.fromDate(new Date(item.promo.createdAt)) : now,
        createdAt: item.promo.createdAt ? Timestamp.fromDate(new Date(item.promo.createdAt)) : now,
        displayName: item.account.displayName,
        email: item.account.email,
        referralCode: item.code,
        status,
        uid: item.account.uid,
        updatedAt: now,
      }, { merge: true });
      transaction.set(indexRef, {
        code: item.code,
        createdAt: item.promo.createdAt ? Timestamp.fromDate(new Date(item.promo.createdAt)) : now,
        partnerUid: item.account.uid,
        status,
        updatedAt: now,
      }, { merge: true });
      transaction.create(migrationRef, {
        appliedAt: now,
        code: item.code,
        migrationId,
        uid: item.account.uid,
      });
      return true;
    });
    if (createdPartner) migratedPartners += 1;

    for (const usageDoc of item.usages.docs) {
      const usage = usageDoc.data() ?? {};
      const orderId = readString(usage.orderId) || usageDoc.id;
      const ref = partnerRef.collection("referrals").doc(orderId);
      const existing = await ref.get();
      if (existing.exists) continue;
      const attributedAt = readDate(usage.recordedAt) ?? new Date();
      const customerSeed = readString(usage.uid) || readString(usage.customerId) || orderId;
      const customerRef = createHmac(
        "sha256",
        env.PARTNER_CUSTOMER_HASH_SECRET || env.PARTNER_ATTRIBUTION_TOKEN_SECRET || "development-only-partner-migration",
      ).update(customerSeed.trim().toLowerCase()).digest("hex").slice(0, 24);
      const rateBps = percentToBasisPoints(usage.commissionPercent || item.promo.commissionPercent);
      const commissionCents = readInteger(usage.commissionCents);
      const qualifyingSubtotalCents = readInteger(usage.referredSpendCents);
      const eligibilityAt = new Date(
        attributedAt.getTime() + env.PARTNER_COMMISSION_ELIGIBILITY_DAYS * 86_400_000,
      );
      const now = FieldValue.serverTimestamp();
      const batch = db.batch();
      batch.create(ref, {
        attributedAt: Timestamp.fromDate(attributedAt),
        attributionId: `migration_${createHash("sha256").update(orderId).digest("hex").slice(0, 20)}`,
        attributionSource: "promo_code_checkout",
        clawbackCents: 0,
        clawbackSettledCents: 0,
        commissionCents,
        commissionRateBps: rateBps,
        createdAt: Timestamp.fromDate(attributedAt),
        currency: "usd",
        customerLabel: `Customer ··${customerRef.slice(-4).toUpperCase()}`,
        customerRef,
        eligibilityAt: Timestamp.fromDate(eligibilityAt),
        eligibleAt: null,
        orderId,
        orderCompletedAt: null,
        orderStatus: "historical",
        originalCommissionCents: commissionCents,
        originalQualifyingSubtotalCents: qualifyingSubtotalCents,
        paidCommissionCents: 0,
        partnerUid: item.account.uid,
        paymentCapturedAt: null,
        payoutId: "",
        qualifyingSubtotalCents,
        referralCode: item.code,
        refundedCents: 0,
        status: "tracked",
        updatedAt: now,
      });
      batch.create(ref.collection("history").doc("migration"), {
        createdAt: now,
        eventAt: Timestamp.fromDate(attributedAt),
        eventId: migrationId,
        eventType: "migrated_unverified",
        fromStatus: null,
        toStatus: "tracked",
      });
      await batch.commit();
      migratedReferrals += 1;
    }
  }

  return { apply: true, migrationId, migratedPartners, migratedReferrals, scannedPartners: plan.length };
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function readInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;
  return Number.isInteger(number) && number >= 0 ? number : 0;
}

function readDate(value: unknown) {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  if (value && typeof value === "object" && "toDate" in value && typeof value.toDate === "function") return value.toDate();
  if (typeof value === "string") {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }
  return null;
}

if (process.argv[1]?.includes("20260722ReferralPartners")) {
  migrateReferralPartners({ apply: process.argv.includes("--apply") })
    .then((result) => {
      console.log(JSON.stringify(result, null, 2));
      process.exit(0);
    })
    .catch((error) => {
      console.error(error instanceof Error ? error.message : error);
      process.exit(1);
    });
}
