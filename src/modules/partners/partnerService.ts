import { createHash, createHmac, randomBytes } from "node:crypto";

import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import { getAccount } from "../accounts/accountService";
import {
  buildDiscountCodeRecord,
  discountCodesCollection,
  normalizeDiscountCode,
  referralPartnerPromoCodeCategory,
  serializeDiscountCode,
} from "../discountCodes/discountCodeService";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  basisPointsToPercent,
  calculatePayoutSettlement,
  calculatePartnerCommission,
  canAccessPartnerDashboard,
  createAttributionToken,
  getCommissionLifecycleUpdate,
  getEligibilityDate,
  generateUniquePartnerCode,
  normalizePartnerCode,
  percentToBasisPoints,
  validatePartnerCode,
  verifyAttributionToken,
  isSelfReferralIdentity,
} from "./partnerDomain";
import type {
  CommissionStatus,
  PartnerCommissionRecord,
  PartnerOrderEvent,
  PartnerPayoutRecord,
  PartnerRecord,
  PartnerStatus,
} from "./partnerTypes";

export const partnersCollection = "referral_partners";
export const partnerCodeIndexCollection = "referral_partner_codes";
export const partnerAttributionsCollection = "partner_attributions";
export const partnerVisitsCollection = "partner_referral_visits";
const referralsSubcollection = "referrals";
const payoutsSubcollection = "payouts";

export async function submitPartnerApplication(uid: string) {
  return enrollPartnerAccount(uid);
}

export async function enrollPartnerAccount(uid: string, input: { acceptedTerms?: boolean } = {}) {
  if (input.acceptedTerms === false) {
    throw new ApiRequestError(400, "Partner terms must be accepted before enrollment.");
  }
  const account = await requireCustomerAccount(uid);
  const ref = partnerRef(uid);
  const existing = await ref.get();

  if (existing.exists) {
    return { partner: serializePartner(existing.id, existing.data() ?? {}) };
  }

  const now = FieldValue.serverTimestamp();
  await ref.create({
    createdAt: now,
    displayName: account.displayName,
    email: account.email,
    enrolledAt: now,
    referralCode: "",
    status: "pending",
    termsAcceptedAt: input.acceptedTerms ? now : null,
    termsVersion: input.acceptedTerms ? env.PARTNER_TERMS_VERSION : null,
    uid,
    updatedAt: now,
  });

  return { partner: await getPartner(uid) };
}

export async function getPartner(uid: string) {
  const snapshot = await partnerRef(uid).get();
  return snapshot.exists ? serializePartner(snapshot.id, snapshot.data() ?? {}) : null;
}

export async function requireActivePartner(uid: string) {
  const partner = await getPartner(uid);
  if (!partner) throw new ApiRequestError(404, "This account is not enrolled as a BayBlaze partner.");
  if (!canAccessPartnerDashboard(partner.status)) {
    throw new ApiRequestError(403, `This partner account is ${partner.status}.`);
  }
  return partner;
}

export async function createActivePartnerWithPromo(input: {
  code?: string;
  commissionPercent: number;
  discountPercent: number;
  minimumSpendCents?: number;
  ownerUid: string;
  singleUsePerAccount?: boolean;
}) {
  const account = await requireCustomerAccount(input.ownerUid);
  let code: string;
  try {
    code = input.code
      ? validatePartnerCode(input.code)
      : await generateUniquePartnerCode({
          isTaken: async (candidate) => {
            const db = getBayblazeFirestore();
            const [promo, index] = await Promise.all([
              db.collection(discountCodesCollection).doc(candidate).get(),
              db.collection(partnerCodeIndexCollection).doc(candidate).get(),
            ]);
            return promo.exists || index.exists;
          },
          prefix: env.PARTNER_REFERRAL_CODE_PREFIX,
          uid: input.ownerUid,
        });
  } catch (caught) {
    throw new ApiRequestError(400, caught instanceof Error ? caught.message : "Referral code is invalid.");
  }
  const codeRecord = buildDiscountCodeRecord({
    category: referralPartnerPromoCodeCategory,
    code,
    codeType: "discount",
    commissionPercent: input.commissionPercent,
    discountPercent: input.discountPercent,
    minimumSpendCents: input.minimumSpendCents,
    ownerUid: input.ownerUid,
    singleUsePerAccount: input.singleUsePerAccount,
    status: "active",
    usageLimit: 1_000_000,
  });
  const db = getBayblazeFirestore();
  const promoRef = db.collection(discountCodesCollection).doc(code);
  const ownerRef = partnerRef(input.ownerUid);
  const indexRef = db.collection(partnerCodeIndexCollection).doc(code);

  await db.runTransaction(async (transaction) => {
    const partnerSnapshotPromise = transaction.get(ownerRef);
    const [promoSnapshot, partnerSnapshot, indexSnapshot] = await Promise.all([
      transaction.get(promoRef),
      partnerSnapshotPromise,
      transaction.get(indexRef),
    ]);
    if (promoSnapshot.exists || indexSnapshot.exists) {
      throw new ApiRequestError(409, "That referral code already exists.");
    }
    const existing = partnerSnapshot.exists
      ? serializePartner(partnerSnapshot.id, partnerSnapshot.data() ?? {})
      : null;
    let staleIndexRef: FirebaseFirestore.DocumentReference | null = null;
    if (existing?.referralCode && existing.referralCode !== code) {
      const existingIndexRef = db.collection(partnerCodeIndexCollection).doc(existing.referralCode);
      const [existingPromoSnapshot, existingIndexSnapshot] = await Promise.all([
        transaction.get(db.collection(discountCodesCollection).doc(existing.referralCode)),
        transaction.get(existingIndexRef),
      ]);
      const existingIndexPartnerUid = readString((existingIndexSnapshot.data() ?? {}).partnerUid);
      if (existingPromoSnapshot.exists || (existingIndexSnapshot.exists && existingIndexPartnerUid !== input.ownerUid)) {
        throw new ApiRequestError(409, "This account already has a stable referral code.");
      }
      staleIndexRef = existingIndexSnapshot.exists ? existingIndexRef : null;
    }
    const now = FieldValue.serverTimestamp();
    transaction.create(promoRef, codeRecord);
    if (staleIndexRef) transaction.delete(staleIndexRef);
    transaction.set(ownerRef, {
      approvedAt: now,
      createdAt: existing?.createdAt || now,
      displayName: account.displayName,
      email: account.email,
      referralCode: code,
      rejectedAt: null,
      status: "active",
      suspendedAt: null,
      uid: input.ownerUid,
      updatedAt: now,
    }, { merge: true });
    transaction.create(indexRef, {
      code,
      partnerUid: input.ownerUid,
      status: "active",
      createdAt: now,
      updatedAt: now,
    });
  });

  return serializeDiscountCode(code, codeRecord);
}

export async function deleteUnusedPartnerReferralPromo(codeInput: string) {
  const code = normalizePartnerCode(codeInput);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const db = getBayblazeFirestore();
  const promoRef = db.collection(discountCodesCollection).doc(code);
  const indexRef = db.collection(partnerCodeIndexCollection).doc(code);

  await db.runTransaction(async (transaction) => {
    const [promoSnapshot, indexSnapshot] = await Promise.all([
      transaction.get(promoRef),
      transaction.get(indexRef),
    ]);

    if (!promoSnapshot.exists) {
      throw new ApiRequestError(404, "That promo code was not found.");
    }

    const promo = serializeDiscountCode(code, promoSnapshot.data() ?? {});

    if (promo.category !== referralPartnerPromoCodeCategory) {
      throw new ApiRequestError(409, "That promo code is not managed by the referral partner tool.");
    }

    if (promo.usedCount > 0) {
      throw new ApiRequestError(409, "A referral promo with tracked purchases cannot be deleted.");
    }

    const partnerUid = promo.ownerUid || readString((indexSnapshot.data() ?? {}).partnerUid);
    const partnerDoc = partnerUid ? db.collection(partnersCollection).doc(partnerUid) : null;
    const partnerSnapshot = partnerDoc ? await transaction.get(partnerDoc) : null;
    const partner = partnerSnapshot?.exists
      ? serializePartner(partnerSnapshot.id, partnerSnapshot.data() ?? {})
      : null;
    const now = FieldValue.serverTimestamp();

    transaction.delete(promoRef);
    if (indexSnapshot.exists) transaction.delete(indexRef);

    if (partnerDoc && partner?.referralCode === code) {
      transaction.set(partnerDoc, {
        approvedAt: null,
        referralCode: "",
        rejectedAt: null,
        status: "pending",
        suspendedAt: null,
        updatedAt: now,
      }, { merge: true });
    }
  });

  return { ok: true };
}

export async function listAdminPartners() {
  const snapshot = await getBayblazeFirestore().collection(partnersCollection).get();
  return {
    partners: snapshot.docs
      .map((doc) => serializePartner(doc.id, doc.data() ?? {}))
      .sort((left, right) => right.createdAt.localeCompare(left.createdAt)),
  };
}

export async function updateAdminPartnerStatus(uid: string, status: PartnerStatus) {
  const partner = await getPartner(uid);
  if (!partner) throw new ApiRequestError(404, "Referral partner was not found.");
  if (status === "active" && !partner.referralCode) {
    throw new ApiRequestError(409, "Create the partner's referral promo before approving the account.");
  }
  const now = FieldValue.serverTimestamp();
  const updates = {
    status,
    updatedAt: now,
    ...(status === "active" ? { approvedAt: now, rejectedAt: null, suspendedAt: null } : {}),
    ...(status === "suspended" ? { suspendedAt: now } : {}),
    ...(status === "rejected" ? { rejectedAt: now } : {}),
  };
  const db = getBayblazeFirestore();
  const batch = db.batch();
  batch.set(partnerRef(uid), updates, { merge: true });
  if (partner.referralCode) {
    batch.set(db.collection(partnerCodeIndexCollection).doc(partner.referralCode), {
      status,
      updatedAt: now,
    }, { merge: true });
    batch.set(db.collection(discountCodesCollection).doc(partner.referralCode), {
      status: status === "active" ? "active" : status,
      updatedAt: now,
    }, { merge: true });
  }
  await batch.commit();
  return { partner: await getPartner(uid) };
}

export async function resolvePartnerAttribution(input: {
  code: string;
  existingToken?: string;
  sourcePath?: string;
}) {
  const now = new Date();
  const secret = getAttributionSecret();
  const existing = verifyAttributionToken(input.existingToken, secret, now);
  const requestedCode = normalizePartnerCode(input.code);
  if (existing) {
    const attributed = await resolveActivePartnerCode(existing.code);
    if (attributed?.partner.uid === existing.partnerUid) {
      const clicked = requestedCode === existing.code
        ? attributed
        : await resolveActivePartnerCode(requestedCode);
      if (!clicked) throw new ApiRequestError(404, "That partner referral code is not active.");
      await trackPartnerVisit({ code: clicked.code, partnerUid: clicked.partner.uid, sourcePath: input.sourcePath });
      return buildAttributionResponse(existing, attributed.promo.discountPercent, input.existingToken!);
    }
  }

  const code = requestedCode;
  const db = getBayblazeFirestore();
  const resolved = await resolveActivePartnerCode(code);
  if (!resolved) {
    throw new ApiRequestError(404, "That partner referral code is not active.");
  }
  const { partner, promo } = resolved;
  const partnerUid = partner.uid;

  const attributionId = randomBytes(18).toString("base64url");
  const expiresAt = new Date(now.getTime() + env.PARTNER_ATTRIBUTION_WINDOW_DAYS * 86_400_000);
  const payload = {
    attributionId,
    code,
    exp: Math.floor(expiresAt.getTime() / 1000),
    partnerUid,
  };
  const token = createAttributionToken(payload, secret);
  await db.collection(partnerAttributionsCollection).doc(attributionId).create({
    attributionId,
    code,
    createdAt: Timestamp.fromDate(now),
    expiresAt: Timestamp.fromDate(expiresAt),
    partnerUid,
    source: "promo_query",
    sourcePath: normalizeSourcePath(input.sourcePath),
    status: "active",
  });
  await trackPartnerVisit({ code, partnerUid, sourcePath: input.sourcePath });
  return buildAttributionResponse(payload, promo.discountPercent, token);
}

export async function getPartnerProfile(uid: string) {
  const partner = await getPartner(uid);
  return { partner };
}

export async function getPartnerOverview(uid: string) {
  const partner = await requireActivePartner(uid);
  await reconcileEligibleCommissions(uid);
  const [promo, referrals] = await Promise.all([
    getReferralPromo(partner.referralCode),
    listAllCommissions(uid),
  ]);
  if (!promo) throw new ApiRequestError(409, "This partner's referral promo is not configured.");
  const customerRefs = new Set(referrals.map((referral) => referral.customerRef).filter(Boolean));
  const earnings = calculateEarnings(referrals);

  return {
    earnings,
    eligibilityDays: env.PARTNER_COMMISSION_ELIGIBILITY_DAYS,
    metrics: {
      clicks: await readPartnerClickCount(uid),
      completedOrders: referrals.filter((item) => ["completed", "delivered"].includes(item.orderStatus)).length,
      referredCustomers: customerRefs.size,
    },
    partner,
    program: {
      commissionPercent: promo.commissionPercent,
      discountPercent: promo.discountPercent,
      minimumPurchaseCents: promo.minimumSpendCents,
    },
    referralCode: partner.referralCode,
    referralLink: buildReferralLink(partner.referralCode),
  };
}

export async function listPartnerReferrals(uid: string, input: {
  cursor?: string;
  limit: number;
  query?: string;
  status?: CommissionStatus;
}) {
  await requireActivePartner(uid);
  await reconcileEligibleCommissions(uid);
  const all = await listAllCommissions(uid);
  const query = readString(input.query).toLowerCase();
  const filtered = all.filter((item) => {
    return (!input.status || item.status === input.status) &&
      (!query || item.customerLabel.toLowerCase().includes(query) || item.orderId.toLowerCase().includes(query));
  });
  const offset = decodeCursor(input.cursor);
  const page = filtered.slice(offset, offset + input.limit);
  const nextOffset = offset + page.length;
  return {
    items: page.map(serializePartnerReferralActivity),
    nextCursor: nextOffset < filtered.length ? encodeCursor(nextOffset) : null,
    total: filtered.length,
  };
}

export async function getPartnerEarnings(uid: string) {
  await requireActivePartner(uid);
  await reconcileEligibleCommissions(uid);
  return { earnings: calculateEarnings(await listAllCommissions(uid)) };
}

export async function listPartnerPayouts(uid: string, input: { cursor?: string; limit: number }) {
  await requireActivePartner(uid);
  const snapshot = await partnerRef(uid).collection(payoutsSubcollection).orderBy("createdAt", "desc").get();
  const all = snapshot.docs.map((doc) => serializePayout(doc.id, doc.data() ?? {}));
  const offset = decodeCursor(input.cursor);
  const page = all.slice(offset, offset + input.limit);
  const nextOffset = offset + page.length;
  return { items: page, nextCursor: nextOffset < all.length ? encodeCursor(nextOffset) : null, total: all.length };
}

export async function getPartnerAccount(uid: string) {
  const partner = await requireActivePartner(uid);
  return {
    account: {
      displayName: partner.displayName,
      email: partner.email,
      joinedAt: partner.approvedAt || partner.createdAt,
      payoutMethodLabel: "Not connected",
      payoutStatus: "not_set" as const,
      status: partner.status,
    },
  };
}

export async function recordPartnerOrderEvent(event: PartnerOrderEvent) {
  const eventAt = parseDate(event.eventAt) ?? new Date();
  const metadata = event.order.metadata ?? {};
  const code = normalizePartnerCode(metadata.checkout_promo_code);
  if (readString(metadata.checkout_promo_category) !== referralPartnerPromoCodeCategory || !code) {
    return { ignored: true, reason: "not_partner_promo" };
  }
  const promo = await getReferralPromo(code, { includeInactive: true });
  if (!promo?.ownerUid) return { ignored: true, reason: "partner_promo_missing" };
  const partner = await getPartner(promo.ownerUid);
  if (!partner || partner.referralCode !== code) {
    return { ignored: true, reason: "partner_not_active" };
  }
  if (isSelfReferralIdentity({
    customerEmail: event.order.email,
    customerUid: event.order.customerUid,
    partnerEmail: partner.email,
    partnerUid: partner.uid,
  })) {
    return { ignored: true, reason: "self_referral" };
  }
  const originalBasis = readDollarCents(metadata.checkout_promo_total_after_discount);
  if (originalBasis <= 0 || readString(metadata.checkout_promo_status) !== "applied") {
    return { ignored: true, reason: "invalid_qualifying_basis" };
  }
  const customerRef = createCustomerRef(event.order.customerUid || event.order.email || event.order.id);
  const customerLabel = `Customer ··${customerRef.slice(-4).toUpperCase()}`;
  const rateBps = percentToBasisPoints(promo.commissionPercent);
  const baseCalculation = calculatePartnerCommission({
    commissionRateBps: rateBps,
    originalQualifyingSubtotalCents: originalBasis,
    refundedCents: event.order.refundedCents,
  });
  const isTerminalReversal = ["chargeback", "order_canceled", "payment_failed"].includes(event.eventType);
  const calculation = isTerminalReversal
    ? { commissionCents: 0, qualifyingSubtotalCents: 0, refundedCents: originalBasis }
    : baseCalculation;
  const db = getBayblazeFirestore();
  const commissionRef = partnerRef(partner.uid).collection(referralsSubcollection).doc(event.order.id);
  const historyRef = commissionRef.collection("history").doc(hashId(event.eventId));
  const ownerRef = partnerRef(partner.uid);
  const promoRef = db.collection(discountCodesCollection).doc(code);
  const legacyOrderUsageRef = promoRef.collection("order_usages").doc(event.order.id);
  const legacyAccountUsageRef = promoRef.collection("account_usages").doc(event.order.customerUid || customerRef);
  const attribution = await resolveOrderAttribution(metadata.partner_attribution_token, partner.uid, code, event.order.id, eventAt);
  const attributionRef = db.collection(partnerAttributionsCollection).doc(attribution.id);

  return db.runTransaction(async (transaction) => {
    const [partnerSnapshot, commissionSnapshot, historySnapshot, accountUsageSnapshot, legacyOrderUsageSnapshot] = await Promise.all([
      transaction.get(ownerRef),
      transaction.get(commissionRef),
      transaction.get(historyRef),
      transaction.get(legacyAccountUsageRef),
      transaction.get(legacyOrderUsageRef),
    ]);
    if (historySnapshot.exists) return { duplicate: true, orderId: event.order.id };
    const currentPartner = partnerSnapshot.exists
      ? serializePartner(partnerSnapshot.id, partnerSnapshot.data() ?? {})
      : null;
    const existing = commissionSnapshot.exists
      ? serializeCommission(commissionSnapshot.id, commissionSnapshot.data() ?? {})
      : null;
    if (currentPartner?.status !== "active" && !existing) {
      return { ignored: true, reason: "partner_not_active" };
    }
    const paymentCapturedAt = event.eventType === "payment_captured" || isPaidDeliveryCompletion(event, existing)
      ? eventAt
      : parseDate(existing?.paymentCapturedAt);
    const orderCompletedAt = event.eventType === "order_completed"
      ? eventAt
      : parseDate(existing?.orderCompletedAt);
    const isQualified = Boolean(paymentCapturedAt && orderCompletedAt);
    const qualifiedAt = paymentCapturedAt && orderCompletedAt
      ? new Date(Math.max(paymentCapturedAt.getTime(), orderCompletedAt.getTime()))
      : null;
    const eligibilityAt = qualifiedAt
      ? getEligibilityDate(qualifiedAt, env.PARTNER_COMMISSION_ELIGIBILITY_DAYS)
      : existing?.eligibilityAt
        ? new Date(existing.eligibilityAt)
        : getEligibilityDate(eventAt, env.PARTNER_COMMISSION_ELIGIBILITY_DAYS);
    const initialStatus: CommissionStatus = isQualified
      ? eventAt >= eligibilityAt ? "eligible" : "pending"
      : "tracked";
    const lifecycleEventType = isQualified || ["chargeback", "order_canceled", "payment_failed", "payment_refunded"].includes(event.eventType)
      ? event.eventType
      : "order_placed";
    const lifecycle = getCommissionLifecycleUpdate({
      commissionCents: calculation.commissionCents,
      currentStatus: existing?.status ?? initialStatus,
      eligibilityAt,
      eventAt,
      eventType: lifecycleEventType,
      paidCommissionCents: existing?.paidCommissionCents,
    });
    const now = FieldValue.serverTimestamp();
    const commissionRecord = {
      attributedAt: existing?.attributedAt || attribution.attributedAt.toISOString(),
      attributionId: existing?.attributionId || attribution.id,
      attributionSource: existing?.attributionSource || attribution.source,
      clawbackCents: lifecycle.clawbackCents,
      clawbackSettledCents: existing?.clawbackSettledCents ?? 0,
      commissionCents: calculation.commissionCents,
      commissionRateBps: existing?.commissionRateBps || rateBps,
      createdAt: existing?.createdAt || now,
      currency: (event.order.currencyCode || existing?.currency || "usd").toLowerCase(),
      customerLabel: existing?.customerLabel || customerLabel,
      customerRef: existing?.customerRef || customerRef,
      eligibilityAt: Timestamp.fromDate(eligibilityAt),
      eligibleAt: lifecycle.status === "eligible" ? existing?.eligibleAt || now : existing?.eligibleAt || null,
      orderId: event.order.id,
      orderCompletedAt: orderCompletedAt ? Timestamp.fromDate(orderCompletedAt) : null,
      orderStatus: getOrderStatus(event),
      originalCommissionCents: existing?.originalCommissionCents ?? calculation.commissionCents,
      originalQualifyingSubtotalCents: existing?.originalQualifyingSubtotalCents ?? originalBasis,
      paidCommissionCents: existing?.paidCommissionCents ?? 0,
      partnerUid: partner.uid,
      paymentCapturedAt: paymentCapturedAt ? Timestamp.fromDate(paymentCapturedAt) : null,
      payoutId: existing?.payoutId || "",
      qualifyingSubtotalCents: calculation.qualifyingSubtotalCents,
      referralCode: code,
      refundedCents: calculation.refundedCents,
      status: lifecycle.status,
      updatedAt: now,
    };
    transaction.set(commissionRef, commissionRecord, { merge: true });
    transaction.create(historyRef, {
      commissionCents: calculation.commissionCents,
      createdAt: now,
      eventAt: Timestamp.fromDate(eventAt),
      eventId: event.eventId,
      eventType: event.eventType,
      fromStatus: existing?.status || null,
      refundedCents: calculation.refundedCents,
      toStatus: lifecycle.status,
    });
    transaction.set(attributionRef, {
      attributionId: attribution.id,
      code,
      convertedAt: now,
      convertedOrderId: event.order.id,
      createdAt: Timestamp.fromDate(attribution.attributedAt),
      expiresAt: Timestamp.fromDate(attribution.expiresAt),
      partnerUid: partner.uid,
      source: attribution.source,
      status: "converted",
    }, { merge: true });
    if (!existing && !legacyOrderUsageSnapshot.exists) {
      transaction.create(legacyOrderUsageRef, {
        code,
        commissionCents: calculation.commissionCents,
        commissionPercent: basisPointsToPercent(rateBps),
        customerRef,
        orderId: event.order.id,
        recordedAt: now,
        referredSpendCents: calculation.qualifyingSubtotalCents,
        subtotalCents: readDollarCents(metadata.checkout_promo_subtotal),
        uid: event.order.customerUid || customerRef,
      });
      transaction.set(legacyAccountUsageRef, {
        code,
        customerRef,
        ...(!accountUsageSnapshot.exists ? { firstOrderId: event.order.id } : {}),
        lastOrderId: event.order.id,
        lastUsedAt: now,
        totalCommissionCents: FieldValue.increment(calculation.commissionCents),
        totalReferredSpendCents: FieldValue.increment(calculation.qualifyingSubtotalCents),
        uid: event.order.customerUid || customerRef,
        usedCount: FieldValue.increment(1),
      }, { merge: true });
      transaction.set(promoRef, {
        totalCommissionCents: FieldValue.increment(calculation.commissionCents),
        totalReferredSpendCents: FieldValue.increment(calculation.qualifyingSubtotalCents),
        uniqueReferredCustomers: !accountUsageSnapshot.exists ? FieldValue.increment(1) : FieldValue.increment(0),
        updatedAt: now,
        usedCount: FieldValue.increment(1),
      }, { merge: true });
    } else if (existing) {
      transaction.set(promoRef, {
        totalCommissionCents: FieldValue.increment(calculation.commissionCents - existing.commissionCents),
        totalReferredSpendCents: FieldValue.increment(calculation.qualifyingSubtotalCents - existing.qualifyingSubtotalCents),
        updatedAt: now,
      }, { merge: true });
    }
    return { duplicate: false, orderId: event.order.id, status: lifecycle.status };
  });
}

export async function recordAdminExternalPayout(uid: string, input: {
  idempotencyKey: string;
  methodLabel: string;
  reference: string;
}) {
  await requireActivePartner(uid);
  const idempotencyKey = readString(input.idempotencyKey).slice(0, 120);
  const methodLabel = readString(input.methodLabel).slice(0, 80);
  const reference = readString(input.reference).slice(0, 120);
  if (!idempotencyKey || !methodLabel || !reference) {
    throw new ApiRequestError(400, "Payout idempotency key, method, and external reference are required.");
  }
  const payoutId = hashId(idempotencyKey);
  const payoutRef = partnerRef(uid).collection(payoutsSubcollection).doc(payoutId);
  const existingPayout = await payoutRef.get();
  if (existingPayout.exists) {
    return { alreadyRecorded: true, payout: serializePayout(existingPayout.id, existingPayout.data() ?? {}) };
  }
  await reconcileEligibleCommissions(uid);
  const eligibleSnapshot = await partnerRef(uid).collection(referralsSubcollection)
    .where("status", "==", "eligible").limit(100).get();
  if (eligibleSnapshot.empty) throw new ApiRequestError(409, "This partner has no eligible commissions.");
  const commissionRefs = eligibleSnapshot.docs.map((doc) => doc.ref);
  const reversalSnapshot = await partnerRef(uid).collection(referralsSubcollection)
    .where("status", "==", "reversed").limit(100).get();
  if (reversalSnapshot.size === 100) {
    throw new ApiRequestError(409, "Outstanding reversal history requires an administrator review before payout.");
  }
  const reversalRefs = reversalSnapshot.docs.map((doc) => doc.ref);
  const db = getBayblazeFirestore();

  return db.runTransaction(async (transaction) => {
    const [payoutSnapshot, ...allSnapshots] = await Promise.all([
      transaction.get(payoutRef),
      ...commissionRefs.map((ref) => transaction.get(ref)),
      ...reversalRefs.map((ref) => transaction.get(ref)),
    ]);
    if (payoutSnapshot.exists) {
      return { alreadyRecorded: true, payout: serializePayout(payoutSnapshot.id, payoutSnapshot.data() ?? {}) };
    }
    const commissionSnapshots = allSnapshots.slice(0, commissionRefs.length);
    const reversalSnapshots = allSnapshots.slice(commissionRefs.length);
    const payable = commissionSnapshots
      .filter((snapshot) => snapshot.exists)
      .map((snapshot) => ({ commission: serializeCommission(snapshot.id, snapshot.data() ?? {}), snapshot }))
      .filter(({ commission }) => commission.status === "eligible" && !commission.payoutId);
    if (!payable.length) throw new ApiRequestError(409, "Eligible commissions were already reserved.");
    const commissions = payable.map(({ commission }) => commission);
    const currencies = new Set(commissions.map((commission) => commission.currency));
    if (currencies.size !== 1) throw new ApiRequestError(409, "Mixed-currency commissions require separate payout review.");
    const reversals = reversalSnapshots
      .filter((snapshot) => snapshot.exists)
      .map((snapshot) => ({ commission: serializeCommission(snapshot.id, snapshot.data() ?? {}), snapshot }))
      .filter(({ commission }) => commission.clawbackCents > commission.clawbackSettledCents);
    const settlement = calculatePayoutSettlement({
      eligibleCommissionCents: commissions.map((commission) => commission.commissionCents),
      outstandingClawbackCents: reversals.map(({ commission }) => commission.clawbackCents - commission.clawbackSettledCents),
    });
    const { grossCommissionCents, offsetClawbackCents: outstandingClawbackCents } = settlement;
    const amountCents = settlement.payableCents;
    if (amountCents <= 0) {
      throw new ApiRequestError(409, "Eligible earnings do not yet exceed outstanding reversals.");
    }
    const now = FieldValue.serverTimestamp();
    const record = {
      amountCents,
      grossCommissionCents,
      offsetClawbackCents: outstandingClawbackCents,
      commissionIds: commissions.map((commission) => commission.orderId),
      createdAt: now,
      currency: commissions[0]?.currency || "usd",
      id: payoutId,
      idempotencyKey,
      methodLabel,
      paidAt: now,
      reference,
      status: "paid",
      updatedAt: now,
    };
    transaction.create(payoutRef, record);
    transaction.create(payoutRef.collection("history").doc(hashId(`paid:${idempotencyKey}`)), {
      createdAt: now,
      status: "paid",
    });
    payable.forEach(({ commission, snapshot }) => {
      transaction.set(snapshot.ref, {
        paidCommissionCents: commission.commissionCents,
        payoutId,
        status: "paid",
        updatedAt: now,
      }, { merge: true });
      transaction.create(snapshot.ref.collection("history").doc(hashId(`paid:${idempotencyKey}`)), {
        commissionCents: commission.commissionCents,
        createdAt: now,
        eventAt: now,
        eventId: `payout:${payoutId}`,
        eventType: "payout_paid",
        fromStatus: "eligible",
        payoutId,
        toStatus: "paid",
      });
    });
    reversals.forEach(({ commission, snapshot }) => {
      transaction.set(snapshot.ref, {
        clawbackSettledCents: commission.clawbackCents,
        updatedAt: now,
      }, { merge: true });
      transaction.create(snapshot.ref.collection("history").doc(hashId(`clawback-offset:${idempotencyKey}`)), {
        amountCents: commission.clawbackCents - commission.clawbackSettledCents,
        createdAt: now,
        eventAt: now,
        eventId: `payout:${payoutId}`,
        eventType: "clawback_offset",
        payoutId,
      });
    });
    return { alreadyRecorded: false, payout: { ...record, createdAt: new Date().toISOString(), paidAt: new Date().toISOString(), updatedAt: new Date().toISOString() } };
  });
}

export async function reconcileEligibleCommissions(uid: string, now = new Date()) {
  const snapshot = await partnerRef(uid).collection(referralsSubcollection).where("status", "==", "pending").get();
  const due = snapshot.docs.filter((doc) => {
    const date = readDate(doc.data().eligibilityAt);
    return date && date <= now;
  });
  if (!due.length) return 0;
  const batch = getBayblazeFirestore().batch();
  due.forEach((doc) => {
    batch.set(doc.ref, { eligibleAt: Timestamp.fromDate(now), status: "eligible", updatedAt: FieldValue.serverTimestamp() }, { merge: true });
    batch.create(doc.ref.collection("history").doc(hashId(`eligible:${now.toISOString()}:${doc.id}`)), {
      createdAt: FieldValue.serverTimestamp(),
      eventAt: Timestamp.fromDate(now),
      eventId: `eligibility:${doc.id}`,
      eventType: "eligibility_reached",
      fromStatus: "pending",
      toStatus: "eligible",
    });
  });
  await batch.commit();
  return due.length;
}

async function resolveOrderAttribution(token: unknown, partnerUid: string, code: string, orderId: string, eventAt: Date) {
  const payload = verifyAttributionToken(token, getAttributionSecret(), eventAt);
  if (payload && payload.partnerUid === partnerUid && payload.code === code) {
    const snapshot = await getBayblazeFirestore().collection(partnerAttributionsCollection).doc(payload.attributionId).get();
    const data = snapshot.data() ?? {};
    const createdAt = readDate(data.createdAt);
    const expiresAt = readDate(data.expiresAt);
    if (snapshot.exists && createdAt && expiresAt && createdAt <= eventAt && expiresAt > eventAt) {
      return { id: payload.attributionId, attributedAt: createdAt, expiresAt, source: "promo_query" as const };
    }
  }
  return {
    id: `order_${hashId(orderId)}`,
    attributedAt: eventAt,
    expiresAt: new Date(eventAt.getTime() + env.PARTNER_ATTRIBUTION_WINDOW_DAYS * 86_400_000),
    source: "promo_code_checkout" as const,
  };
}

async function listAllCommissions(uid: string) {
  const snapshot = await partnerRef(uid).collection(referralsSubcollection).orderBy("attributedAt", "desc").get();
  return snapshot.docs.map((doc) => serializeCommission(doc.id, doc.data() ?? {}));
}

function calculateEarnings(referrals: PartnerCommissionRecord[]) {
  const outstandingClawbacks = referrals.reduce(
    (sum, item) => sum + Math.max(0, item.clawbackCents - item.clawbackSettledCents),
    0,
  );
  const eligible = referrals.filter((item) => item.status === "eligible").reduce((sum, item) => sum + item.commissionCents, 0);
  const netEarned = referrals.reduce((sum, item) => sum + item.commissionCents, 0);
  return {
    availableCents: Math.max(0, eligible - outstandingClawbacks),
    lifetimeCents: Math.max(0, netEarned),
    pendingCents: referrals.filter((item) => item.status === "pending" || item.status === "tracked").reduce((sum, item) => sum + item.commissionCents, 0),
  };
}

async function getReferralPromo(code: string, options: { includeInactive?: boolean } = {}) {
  const snapshot = await getBayblazeFirestore().collection(discountCodesCollection).doc(normalizeDiscountCode(code)).get();
  if (!snapshot.exists) return null;
  const promo = serializeDiscountCode(snapshot.id, snapshot.data() ?? {});
  return promo.category === referralPartnerPromoCodeCategory && (options.includeInactive || promo.status === "active") ? promo : null;
}

async function resolveActivePartnerCode(code: string) {
  const normalizedCode = normalizePartnerCode(code);
  if (!normalizedCode) return null;
  const db = getBayblazeFirestore();
  const [indexSnapshot, promo] = await Promise.all([
    db.collection(partnerCodeIndexCollection).doc(normalizedCode).get(),
    getReferralPromo(normalizedCode),
  ]);
  const index = indexSnapshot.data() ?? {};
  const partnerUid = readString(index.partnerUid);
  const partner = partnerUid ? await getPartner(partnerUid) : null;
  if (!partner || partner.status !== "active" || index.status !== "active" || promo?.ownerUid !== partner.uid) return null;
  return { code: normalizedCode, partner, promo };
}

async function requireCustomerAccount(uid: string) {
  const account = await getAccount(uid);
  if (!account || account.disabled || !account.badges.includes("customer")) {
    throw new ApiRequestError(403, "An enabled BayBlaze customer account is required.");
  }
  return account;
}

function partnerRef(uid: string) {
  return getBayblazeFirestore().collection(partnersCollection).doc(uid);
}

function serializePartner(uid: string, data: Record<string, unknown>): PartnerRecord {
  const status = ["pending", "active", "suspended", "rejected"].includes(readString(data.status))
    ? readString(data.status) as PartnerStatus
    : "pending";
  return {
    approvedAt: serializeDate(data.approvedAt),
    createdAt: serializeDate(data.createdAt),
    displayName: readString(data.displayName),
    email: readString(data.email).toLowerCase(),
    referralCode: normalizePartnerCode(data.referralCode),
    rejectedAt: serializeDate(data.rejectedAt),
    status,
    suspendedAt: serializeDate(data.suspendedAt),
    uid,
    updatedAt: serializeDate(data.updatedAt),
  };
}

function serializeCommission(id: string, data: Record<string, unknown>): PartnerCommissionRecord {
  const status = ["tracked", "pending", "eligible", "paid", "reversed"].includes(readString(data.status))
    ? readString(data.status) as CommissionStatus
    : "tracked";
  return {
    attributedAt: serializeDate(data.attributedAt),
    attributionId: readString(data.attributionId),
    attributionSource: data.attributionSource === "promo_query" ? "promo_query" : "promo_code_checkout",
    clawbackCents: readInteger(data.clawbackCents),
    clawbackSettledCents: readInteger(data.clawbackSettledCents),
    commissionCents: readInteger(data.commissionCents),
    commissionRateBps: readInteger(data.commissionRateBps),
    createdAt: serializeDate(data.createdAt),
    currency: readString(data.currency) || "usd",
    customerLabel: readString(data.customerLabel),
    customerRef: readString(data.customerRef),
    eligibilityAt: serializeDate(data.eligibilityAt),
    eligibleAt: serializeDate(data.eligibleAt),
    orderId: readString(data.orderId) || id,
    orderCompletedAt: serializeDate(data.orderCompletedAt),
    orderStatus: readString(data.orderStatus),
    originalCommissionCents: readInteger(data.originalCommissionCents),
    originalQualifyingSubtotalCents: readInteger(data.originalQualifyingSubtotalCents),
    paidCommissionCents: readInteger(data.paidCommissionCents),
    partnerUid: readString(data.partnerUid),
    paymentCapturedAt: serializeDate(data.paymentCapturedAt),
    payoutId: readString(data.payoutId),
    qualifyingSubtotalCents: readInteger(data.qualifyingSubtotalCents),
    referralCode: normalizePartnerCode(data.referralCode),
    refundedCents: readInteger(data.refundedCents),
    status,
    updatedAt: serializeDate(data.updatedAt),
  };
}

function serializePayout(id: string, data: Record<string, unknown>): PartnerPayoutRecord {
  const status = ["processing", "paid", "failed", "canceled"].includes(readString(data.status))
    ? readString(data.status) as PartnerPayoutRecord["status"]
    : "processing";
  return {
    amountCents: readInteger(data.amountCents),
    commissionIds: Array.isArray(data.commissionIds) ? data.commissionIds.map(readString).filter(Boolean) : [],
    createdAt: serializeDate(data.createdAt),
    currency: readString(data.currency) || "usd",
    id,
    idempotencyKey: readString(data.idempotencyKey),
    methodLabel: readString(data.methodLabel),
    paidAt: serializeDate(data.paidAt),
    reference: readString(data.reference),
    status,
    updatedAt: serializeDate(data.updatedAt),
  };
}

export function serializePartnerReferralActivity(item: PartnerCommissionRecord) {
  return {
    commissionStatus: item.status,
    customerLabel: item.customerLabel,
    date: item.attributedAt,
    earnedCents: item.commissionCents,
    id: item.orderId,
    orderStatus: item.orderStatus,
    orderTotalCents: item.qualifyingSubtotalCents,
  };
}

function buildAttributionResponse(payload: { attributionId: string; code: string; exp: number; partnerUid: string }, discountPercent: number, token: string) {
  return {
    attributionToken: token,
    code: payload.code,
    discountPercent,
    expiresAt: new Date(payload.exp * 1000).toISOString(),
  };
}

function getAttributionSecret() {
  const secret = env.PARTNER_ATTRIBUTION_TOKEN_SECRET || env.ACCOUNT_SESSION_SECRET || env.DRIVER_SESSION_SECRET;
  if (!secret) throw new Error("Partner attribution token signing is not configured.");
  return secret;
}

function createCustomerRef(value: string) {
  const secret = env.PARTNER_CUSTOMER_HASH_SECRET || getAttributionSecret();
  return createHmac("sha256", secret).update(value.trim().toLowerCase()).digest("hex").slice(0, 24);
}

async function readPartnerClickCount(uid: string) {
  const snapshot = await partnerRef(uid).get();
  return readInteger(snapshot.data()?.clickCount);
}

function getOrderStatus(event: PartnerOrderEvent) {
  if (["chargeback", "order_canceled", "payment_failed"].includes(event.eventType)) return "cancelled";
  if (event.eventType === "order_completed") return "completed";
  if (event.eventType === "payment_captured") return "processing";
  if (event.eventType === "payment_refunded") return event.order.refundedCents ? "refunded" : "processing";
  return event.order.status || event.order.fulfillmentStatus || "processing";
}

function isPaidDeliveryCompletion(
  event: PartnerOrderEvent,
  existing?: PartnerCommissionRecord | null,
) {
  if (event.eventType !== "order_completed" || existing?.paymentCapturedAt) {
    return false;
  }

  const paymentStatus = readString(event.order.paymentStatus).toLowerCase();

  return !["canceled", "cancelled", "failed", "refunded"].includes(paymentStatus);
}

function readDollarCents(value: unknown) {
  const amount = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;
  return Number.isFinite(amount) && amount >= 0 ? Math.round(amount * 100) : 0;
}

function readInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;
  return Number.isInteger(number) && number >= 0 ? number : 0;
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function readDate(value: unknown) {
  if (value instanceof Timestamp) return value.toDate();
  if (value instanceof Date) return value;
  if (typeof value === "string") {
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? null : date;
  }
  if (value && typeof value === "object" && "toDate" in value && typeof value.toDate === "function") {
    return value.toDate();
  }
  return null;
}

function parseDate(value: unknown) {
  return readDate(value);
}

function serializeDate(value: unknown) {
  return readDate(value)?.toISOString() ?? "";
}

function normalizeSourcePath(value: unknown) {
  const path = readString(value);
  return path.startsWith("/") && !path.startsWith("//") ? path.slice(0, 200) : "/";
}

function buildReferralLink(code: string) {
  const url = new URL(env.BAYBLAZE_STOREFRONT_URL || "https://bayblaze.net");
  url.searchParams.set("promo", code);
  return url.toString();
}

async function trackPartnerVisit(input: { code: string; partnerUid: string; sourcePath?: string }) {
  try {
    const db = getBayblazeFirestore();
    const visitRef = db.collection(partnerVisitsCollection).doc();
    const batch = db.batch();
    batch.create(visitRef, {
      code: input.code,
      createdAt: FieldValue.serverTimestamp(),
      partnerUid: input.partnerUid,
      source: "promo_query",
      sourcePath: normalizeSourcePath(input.sourcePath),
    });
    batch.set(partnerRef(input.partnerUid), {
      clickCount: FieldValue.increment(1),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await batch.commit();
  } catch (caught) {
    console.warn("Partner visit analytics could not be recorded:", caught instanceof Error ? caught.message : caught);
  }
}

function encodeCursor(offset: number) {
  return Buffer.from(JSON.stringify({ offset }), "utf8").toString("base64url");
}

function decodeCursor(cursor: unknown) {
  if (!cursor) return 0;
  try {
    const value = JSON.parse(Buffer.from(String(cursor), "base64url").toString("utf8"));
    if (!Number.isInteger(value.offset) || value.offset < 0 || value.offset > 1_000_000) throw new Error();
    return value.offset;
  } catch {
    throw new ApiRequestError(400, "Pagination cursor is invalid.");
  }
}

function hashId(value: string) {
  return createHash("sha256").update(value).digest("hex").slice(0, 32);
}
