import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { ApiRequestError } from "../drivers/driverWorkflowService";

export const discountCodesCollection = "customer_discount_codes";
export const adminPromoCodeCategory = "admin_promo";
export const referralPartnerPromoCodeCategory = "referral_partner";
export const winReferralCodeCategory = "win_referral";

export type DiscountCodeCategory =
  | typeof adminPromoCodeCategory
  | typeof referralPartnerPromoCodeCategory
  | typeof winReferralCodeCategory;

export type DiscountCodeType = "discount" | "bogo";

export type DiscountCodeInput = {
  bogoBuyQuantity?: number;
  bogoFreeQuantity?: number;
  campaign?: string;
  category: DiscountCodeCategory;
  code: string;
  codeType?: DiscountCodeType;
  commissionPercent?: number;
  discountPercent?: number;
  minimumSpendCents?: number;
  ownerUid?: string;
  referralCode?: string;
  rewardId?: string;
  singleUsePerAccount?: boolean;
  status?: string;
  uid?: string;
  usageLimit?: number;
  usedCount?: number;
};

export type DiscountCodeUpdateInput = {
  bogoBuyQuantity?: number;
  bogoFreeQuantity?: number;
  code?: string;
  codeType?: DiscountCodeType;
  commissionPercent?: number;
  discountPercent?: number;
  minimumSpendCents?: number;
  singleUsePerAccount?: boolean;
};

export type DiscountCodePreviewInput = {
  code: string;
  items?: PreviewDiscountItem[];
  subtotalCents?: number;
};

export type PreviewDiscountItem = {
  quantity?: number;
  unitPriceCents?: number;
};

export async function listDiscountCodes(categories: DiscountCodeCategory[]) {
  const firestore = getBayblazeFirestore();
  const snapshots = await Promise.all(
    categories.map((category) =>
      firestore.collection(discountCodesCollection).where("category", "==", category).get(),
    ),
  );
  const discountCodes = snapshots
    .flatMap((snapshot) => snapshot.docs)
    .map((doc) => serializeDiscountCode(doc.id, doc.data()))
    .sort((left, right) => right.createdAt.localeCompare(left.createdAt));

  return discountCodes;
}

export async function getDiscountCode(codeInput: string) {
  const code = normalizeDiscountCode(codeInput);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const snapshot = await getBayblazeFirestore().collection(discountCodesCollection).doc(code).get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "That promo code was not found.");
  }

  return serializeDiscountCode(snapshot.id, snapshot.data() ?? {});
}

export async function listDiscountCodeOrderUsages(codeInput: string) {
  const code = normalizeDiscountCode(codeInput);

  if (!code) {
    return [];
  }

  const snapshot = await getBayblazeFirestore()
    .collection(discountCodesCollection)
    .doc(code)
    .collection("order_usages")
    .get();

  return snapshot.docs
    .map((doc) => serializeDiscountCodeOrderUsage(doc.id, doc.data() ?? {}))
    .sort((left, right) => right.recordedAt.localeCompare(left.recordedAt));
}

export async function createDiscountCode(input: DiscountCodeInput) {
  const code = normalizeDiscountCode(input.code);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const ref = getBayblazeFirestore().collection(discountCodesCollection).doc(code);
  const existing = await ref.get();

  if (existing.exists) {
    throw new ApiRequestError(409, "That promo code already exists.");
  }

  const record = buildDiscountCodeRecord(input);
  await ref.set(record);

  return serializeDiscountCode(code, {
    ...record,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  });
}

export async function updateDiscountCode(
  currentCode: string,
  input: DiscountCodeUpdateInput,
  options: { category: DiscountCodeCategory },
) {
  const code = normalizeDiscountCode(currentCode);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const nextCode = input.code === undefined ? code : normalizeDiscountCode(input.code);

  if (!nextCode) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const firestore = getBayblazeFirestore();
  const currentRef = firestore.collection(discountCodesCollection).doc(code);
  const nextRef = firestore.collection(discountCodesCollection).doc(nextCode);

  return firestore.runTransaction(async (transaction) => {
    const currentSnapshot = await transaction.get(currentRef);

    if (!currentSnapshot.exists) {
      throw new ApiRequestError(404, "That promo code was not found.");
    }

    const currentData = currentSnapshot.data() ?? {};

    if (readString(currentData.category) !== options.category) {
      throw new ApiRequestError(409, "That promo code is not managed by this promo tool.");
    }

    if (nextCode !== code) {
      const nextSnapshot = await transaction.get(nextRef);

      if (nextSnapshot.exists) {
        throw new ApiRequestError(409, "That promo code already exists.");
      }
    }

    const nextCodeType = input.codeType === undefined
      ? normalizeDiscountCodeType(currentData.codeType)
      : normalizeDiscountCodeType(input.codeType);
    const nextDiscountPercent = input.discountPercent === undefined
      ? readDiscountPercent(currentData.discountPercent, nextCodeType)
      : normalizeDiscountPercentForType(input.discountPercent, nextCodeType);
    const nextCommissionPercent = options.category === referralPartnerPromoCodeCategory
      ? input.commissionPercent === undefined
        ? normalizeCommissionPercent(currentData.commissionPercent)
        : normalizeCommissionPercent(input.commissionPercent)
      : 0;

    if (options.category === referralPartnerPromoCodeCategory && nextCodeType !== "discount") {
      throw new ApiRequestError(400, "Referral partner promos must be percent-off promo codes.");
    }
    const nextMinimumSpendCents = input.minimumSpendCents === undefined
      ? normalizeInteger(currentData.minimumSpendCents)
      : normalizeMinimumSpendCents(input.minimumSpendCents);
    const nextSingleUsePerAccount = input.singleUsePerAccount === undefined
      ? currentData.singleUsePerAccount === true
      : input.singleUsePerAccount === true;
    const nextData = removeUndefinedValues({
      ...currentData,
      code: nextCode,
      codeType: nextCodeType,
      commissionPercent: nextCommissionPercent,
      discountPercent: nextDiscountPercent,
      minimumSpendCents: nextMinimumSpendCents,
      singleUsePerAccount: nextSingleUsePerAccount,
      ...(nextCodeType === "bogo" ? { bogoBuyQuantity: 1, bogoFreeQuantity: 1 } : {}),
      updatedAt: FieldValue.serverTimestamp(),
    });

    if (nextCode !== code) {
      transaction.set(nextRef, nextData);
      transaction.delete(currentRef);
    } else {
      transaction.set(currentRef, nextData, { merge: true });
    }

    return serializeDiscountCode(nextCode, {
      ...nextData,
      updatedAt: new Date().toISOString(),
    });
  });
}

export async function deleteDiscountCode(
  codeInput: string,
  options: { category: DiscountCodeCategory },
) {
  const code = normalizeDiscountCode(codeInput);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const ref = getBayblazeFirestore().collection(discountCodesCollection).doc(code);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "That promo code was not found.");
  }

  const data = snapshot.data() ?? {};

  if (readString(data.category) !== options.category) {
    throw new ApiRequestError(409, "That promo code is not managed by this promo tool.");
  }

  await ref.delete();
}

export async function previewDiscountCode(
  input: DiscountCodePreviewInput,
  options: { categories?: DiscountCodeCategory[] } = {},
) {
  const code = normalizeDiscountCode(input.code);
  const categories = options.categories ?? [
    adminPromoCodeCategory,
    referralPartnerPromoCodeCategory,
    winReferralCodeCategory,
  ];
  const hasSubtotal = input.subtotalCents !== undefined;
  const subtotalCents = normalizeMoneyCents(input.subtotalCents);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const snapshot = await getBayblazeFirestore().collection(discountCodesCollection).doc(code).get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "That promo code was not found.");
  }

  const discountCode = serializeDiscountCode(snapshot.id, snapshot.data() ?? {});

  if (
    discountCode.category === referralPartnerPromoCodeCategory &&
    discountCode.status !== "active"
  ) {
    throw new ApiRequestError(409, "That partner promo code is not active.");
  }

  if (!categories.includes(discountCode.category)) {
    throw new ApiRequestError(409, "That promo code is not available for checkout.");
  }

  if (discountCode.status === "used" || discountCode.usedCount >= discountCode.usageLimit) {
    throw new ApiRequestError(409, "That promo code has already been used.");
  }

  if (discountCode.codeType === "discount" && discountCode.discountPercent <= 0) {
    throw new ApiRequestError(409, "That promo code is not configured correctly.");
  }

  if (hasSubtotal && discountCode.minimumSpendCents > subtotalCents) {
    return {
      amountNeededCents: discountCode.minimumSpendCents - subtotalCents,
      bogoBuyQuantity: discountCode.codeType === "bogo" ? 1 : 0,
      bogoDiscountedQuantity: 0,
      bogoFreeQuantity: discountCode.codeType === "bogo" ? 1 : 0,
      category: discountCode.category,
      code: discountCode.code,
      codeType: discountCode.codeType,
      commissionPercent: discountCode.commissionPercent,
      discountAmountCents: 0,
      discountPercent: discountCode.discountPercent,
      eligible: false,
      ineligibilityReason: "minimum_spend",
      message: `That promo code requires at least ${formatCents(discountCode.minimumSpendCents)} in products.`,
      minimumSpendCents: discountCode.minimumSpendCents,
      ownerUid: discountCode.ownerUid,
      singleUsePerAccount: discountCode.singleUsePerAccount,
      subtotalCents,
      usageLimit: discountCode.usageLimit,
      usedCount: discountCode.usedCount,
    };
  }

  const previewItems = normalizePreviewDiscountItems(input.items);
  const bogoDiscount = discountCode.codeType === "bogo"
    ? calculateBogoDiscountCents(previewItems, subtotalCents)
    : { amountCents: 0, discountedQuantity: 0 };
  const discountAmountCents = discountCode.codeType === "bogo"
    ? Math.min(subtotalCents, bogoDiscount.amountCents)
    : subtotalCents > 0
      ? Math.min(subtotalCents, Math.round(subtotalCents * (discountCode.discountPercent / 100)))
      : 0;

  return {
    bogoBuyQuantity: discountCode.codeType === "bogo" ? 1 : 0,
    bogoDiscountedQuantity: bogoDiscount.discountedQuantity,
    bogoFreeQuantity: discountCode.codeType === "bogo" ? 1 : 0,
    category: discountCode.category,
    code: discountCode.code,
    codeType: discountCode.codeType,
    commissionPercent: discountCode.commissionPercent,
    discountAmountCents,
    discountPercent: discountCode.discountPercent,
    eligible: true,
    minimumSpendCents: discountCode.minimumSpendCents,
    ownerUid: discountCode.ownerUid,
    singleUsePerAccount: discountCode.singleUsePerAccount,
    subtotalCents,
    usageLimit: discountCode.usageLimit,
    usedCount: discountCode.usedCount,
  };
}

export function buildDiscountCodeRecord(input: DiscountCodeInput) {
  const code = normalizeDiscountCode(input.code);
  const codeType = normalizeDiscountCodeType(input.codeType);
  const discountPercent = normalizeDiscountPercentForType(input.discountPercent, codeType);
  const usageLimit = normalizeInteger(input.usageLimit) || 1;
  const ownerUid = readString(input.ownerUid) || readString(input.uid);
  const commissionPercent = input.category === referralPartnerPromoCodeCategory
    ? normalizeCommissionPercent(input.commissionPercent)
    : 0;

  if (input.category === referralPartnerPromoCodeCategory && !ownerUid) {
    throw new ApiRequestError(400, "A referral partner account is required.");
  }

  if (input.category === referralPartnerPromoCodeCategory && codeType !== "discount") {
    throw new ApiRequestError(400, "Referral partner promos must be percent-off promo codes.");
  }

  return removeUndefinedValues({
    bogoBuyQuantity: codeType === "bogo" ? input.bogoBuyQuantity ?? 1 : undefined,
    bogoFreeQuantity: codeType === "bogo" ? input.bogoFreeQuantity ?? 1 : undefined,
    campaign: normalizeToken(input.campaign) || undefined,
    category: input.category,
    code,
    codeType,
    commissionPercent,
    discountPercent,
    minimumSpendCents: normalizeMinimumSpendCents(input.minimumSpendCents),
    ownerUid: ownerUid || undefined,
    referralCode: normalizeDiscountCode(input.referralCode) || undefined,
    rewardId: readString(input.rewardId) || undefined,
    singleUsePerAccount: input.singleUsePerAccount === true,
    status: readString(input.status) || "active",
    uid: readString(input.uid) || undefined,
    usageLimit,
    usedCount: normalizeInteger(input.usedCount),
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

export function serializeDiscountCode(id: string, data: Record<string, unknown>) {
  const codeType = normalizeDiscountCodeType(data.codeType);
  const category = normalizeDiscountCodeCategory(data.category);

  return {
    campaign: normalizeToken(data.campaign),
    category,
    code: normalizeDiscountCode(data.code) || normalizeDiscountCode(id),
    codeType,
    commissionPercent: category === referralPartnerPromoCodeCategory
      ? readCommissionPercent(data.commissionPercent)
      : 0,
    discountPercent: readDiscountPercent(data.discountPercent, codeType),
    minimumSpendCents: normalizeInteger(data.minimumSpendCents),
    ownerUid: readString(data.ownerUid) || readString(data.uid),
    referralCode: normalizeDiscountCode(data.referralCode),
    rewardId: readString(data.rewardId),
    singleUsePerAccount: data.singleUsePerAccount === true,
    status: readString(data.status) || "active",
    uid: readString(data.uid),
    usageLimit: normalizeInteger(data.usageLimit) || 1,
    usedCount: normalizeInteger(data.usedCount),
    totalCommissionCents: normalizeInteger(data.totalCommissionCents),
    totalDiscountCents: normalizeInteger(data.totalDiscountCents),
    totalReferredSpendCents: normalizeInteger(data.totalReferredSpendCents),
    totalReferredSubtotalCents: normalizeInteger(data.totalReferredSubtotalCents),
    uniqueReferredCustomers: normalizeInteger(data.uniqueReferredCustomers),
    createdAt: serializeTimestamp(data.createdAt),
    updatedAt: serializeTimestamp(data.updatedAt),
  };
}

export async function hasCustomerUsedDiscountCode(uid: string, codeInput: string) {
  const uidKey = readString(uid);
  const code = normalizeDiscountCode(codeInput);

  if (!uidKey || !code) {
    return false;
  }

  const snapshot = await getBayblazeFirestore()
    .collection(discountCodesCollection)
    .doc(code)
    .collection("account_usages")
    .doc(uidKey)
    .get();
  const data = snapshot.data() ?? {};

  return normalizeInteger(data.usedCount) > 0;
}

export async function recordAdminDiscountCodeUse(input: {
  code: string;
  commissionCents?: number;
  commissionPercent?: number;
  customerEmail?: string;
  customerId?: string;
  discountCents?: number;
  orderId: string;
  referredSpendCents?: number;
  subtotalCents?: number;
  uid: string;
}) {
  const code = normalizeDiscountCode(input.code);
  const uid = readString(input.uid);
  const orderId = readString(input.orderId);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  if (!uid) {
    throw new ApiRequestError(401, "BayBlaze account sign-in is required.");
  }

  if (!orderId) {
    throw new ApiRequestError(400, "Completed order ID is required.");
  }

  const firestore = getBayblazeFirestore();
  const codeRef = firestore.collection(discountCodesCollection).doc(code);
  const accountUsageRef = codeRef.collection("account_usages").doc(uid);
  const orderUsageRef = codeRef.collection("order_usages").doc(orderId);

  return firestore.runTransaction(async (transaction) => {
    const [codeSnapshot, accountUsageSnapshot, orderUsageSnapshot] = await Promise.all([
      transaction.get(codeRef),
      transaction.get(accountUsageRef),
      transaction.get(orderUsageRef),
    ]);

    if (!codeSnapshot.exists) {
      throw new ApiRequestError(404, "That promo code was not found.");
    }

    if (orderUsageSnapshot.exists) {
      return {
        alreadyRecorded: true,
        code,
      };
    }

    const discountCode = serializeDiscountCode(codeSnapshot.id, codeSnapshot.data() ?? {});

    if (![adminPromoCodeCategory, referralPartnerPromoCodeCategory].includes(discountCode.category)) {
      throw new ApiRequestError(409, "That promo code is not managed by this promo tool.");
    }

    if (discountCode.status !== "active" || discountCode.usedCount >= discountCode.usageLimit) {
      throw new ApiRequestError(409, "That promo code has already been used.");
    }

    const existingAccountUseCount = normalizeInteger(accountUsageSnapshot.data()?.usedCount);

    if (discountCode.singleUsePerAccount && existingAccountUseCount > 0) {
      throw new ApiRequestError(409, "That promo code has already been used by this account.");
    }

    const now = FieldValue.serverTimestamp();
    const nextUsedCount = discountCode.usedCount + 1;
    const isReferralPartner = discountCode.category === referralPartnerPromoCodeCategory;
    const subtotalCents = isReferralPartner ? normalizeMoneyCents(input.subtotalCents) : 0;
    const discountCents = isReferralPartner ? normalizeMoneyCents(input.discountCents) : 0;
    const referredSpendCents = isReferralPartner ? normalizeMoneyCents(input.referredSpendCents) : 0;
    const commissionPercent = isReferralPartner
      ? normalizeCommissionPercent(input.commissionPercent ?? discountCode.commissionPercent)
      : 0;
    const expectedCommissionCents = Math.round(referredSpendCents * (commissionPercent / 100));
    const commissionCents = isReferralPartner
      ? normalizeMoneyCents(input.commissionCents ?? expectedCommissionCents)
      : 0;

    if (isReferralPartner && commissionCents !== expectedCommissionCents) {
      throw new ApiRequestError(409, "Referral commission does not match the completed order.");
    }

    const usageRecord = removeUndefinedValues({
      code,
      commissionCents,
      commissionPercent,
      customerEmail: readString(input.customerEmail).toLowerCase() || undefined,
      customerId: readString(input.customerId) || undefined,
      discountCents,
      orderId,
      recordedAt: now,
      referredSpendCents,
      subtotalCents,
      uid,
    });

    transaction.create(orderUsageRef, usageRecord);
    transaction.set(
      accountUsageRef,
      removeUndefinedValues({
        code,
        customerEmail: readString(input.customerEmail).toLowerCase() || undefined,
        customerId: readString(input.customerId) || undefined,
        firstOrderId: accountUsageSnapshot.exists ? undefined : orderId,
        lastOrderId: orderId,
        lastUsedAt: now,
        ...(isReferralPartner ? {
          totalCommissionCents: FieldValue.increment(commissionCents),
          totalReferredSpendCents: FieldValue.increment(referredSpendCents),
        } : {}),
        uid,
        usedCount: FieldValue.increment(1),
      }),
      { merge: true },
    );
    transaction.set(
      codeRef,
      {
        status: nextUsedCount >= discountCode.usageLimit ? "used" : "active",
        ...(isReferralPartner ? {
          totalCommissionCents: FieldValue.increment(commissionCents),
          totalDiscountCents: FieldValue.increment(discountCents),
          totalReferredSpendCents: FieldValue.increment(referredSpendCents),
          totalReferredSubtotalCents: FieldValue.increment(subtotalCents),
          ...(!accountUsageSnapshot.exists ? {
            uniqueReferredCustomers: FieldValue.increment(1),
          } : {}),
        } : {}),
        updatedAt: now,
        usedCount: FieldValue.increment(1),
      },
      { merge: true },
    );

    return {
      alreadyRecorded: false,
      code,
    };
  });
}

export async function releaseDiscountCodeOrderUse(input: {
  code?: string;
  orderId: string;
}) {
  const code = normalizeDiscountCode(input.code);
  const orderId = readString(input.orderId);

  if (!code || !orderId) {
    return { ignored: true, reason: "missing_code_or_order" };
  }

  const firestore = getBayblazeFirestore();
  const codeRef = firestore.collection(discountCodesCollection).doc(code);
  const orderUsageRef = codeRef.collection("order_usages").doc(orderId);

  return firestore.runTransaction(async (transaction) => {
    const [codeSnapshot, orderUsageSnapshot] = await Promise.all([
      transaction.get(codeRef),
      transaction.get(orderUsageRef),
    ]);

    if (!codeSnapshot.exists || !orderUsageSnapshot.exists) {
      return { ignored: true, reason: "usage_not_found" };
    }

    const discountCode = serializeDiscountCode(codeSnapshot.id, codeSnapshot.data() ?? {});
    const usage = serializeDiscountCodeOrderUsage(orderUsageSnapshot.id, orderUsageSnapshot.data() ?? {});
    const uid = readString(usage.uid);
    const accountUsageRef = uid ? codeRef.collection("account_usages").doc(uid) : null;
    const accountUsageSnapshot = accountUsageRef ? await transaction.get(accountUsageRef) : null;
    const accountUsedCount = normalizeInteger(accountUsageSnapshot?.data()?.usedCount);
    const nextCodeUsedCount = Math.max(0, discountCode.usedCount - 1);
    const isReferralPartner = discountCode.category === referralPartnerPromoCodeCategory;
    const now = FieldValue.serverTimestamp();

    transaction.delete(orderUsageRef);

    if (accountUsageRef && accountUsageSnapshot?.exists) {
      if (accountUsedCount <= 1) {
        transaction.delete(accountUsageRef);
      } else {
        transaction.set(accountUsageRef, removeUndefinedValues({
          totalCommissionCents: isReferralPartner ? FieldValue.increment(-usage.commissionCents) : undefined,
          totalReferredSpendCents: isReferralPartner ? FieldValue.increment(-usage.referredSpendCents) : undefined,
          updatedAt: now,
          usedCount: FieldValue.increment(-1),
        }), { merge: true });
      }
    }

    transaction.set(codeRef, removeUndefinedValues({
      status: nextCodeUsedCount >= discountCode.usageLimit ? "used" : "active",
      totalCommissionCents: isReferralPartner ? FieldValue.increment(-usage.commissionCents) : undefined,
      totalDiscountCents: isReferralPartner ? FieldValue.increment(-usage.discountCents) : undefined,
      totalReferredSpendCents: isReferralPartner ? FieldValue.increment(-usage.referredSpendCents) : undefined,
      totalReferredSubtotalCents: isReferralPartner ? FieldValue.increment(-usage.subtotalCents) : undefined,
      uniqueReferredCustomers: isReferralPartner && accountUsedCount <= 1 ? FieldValue.increment(-1) : undefined,
      updatedAt: now,
      usedCount: nextCodeUsedCount,
    }), { merge: true });

    return {
      code,
      orderId,
      released: true,
    };
  });
}

export function normalizeDiscountCode(value: unknown) {
  return readString(value)
    .replace(/[^a-zA-Z0-9_-]/g, "")
    .slice(0, 80)
    .toUpperCase();
}

export function normalizeDiscountCodeType(value: unknown): DiscountCodeType {
  return value === "bogo" ? "bogo" : "discount";
}

export function normalizeDiscountPercentForType(value: unknown, codeType: DiscountCodeType) {
  if (codeType === "bogo") {
    return 0;
  }

  return normalizeDiscountPercent(value);
}

export function normalizeMinimumSpendCents(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  if (!Number.isFinite(number) || number <= 0) {
    return 0;
  }

  if (!Number.isInteger(number)) {
    throw new ApiRequestError(400, "Minimum basket size must be a whole cent amount.");
  }

  return Math.min(number, 1_000_000_00);
}

export function normalizeInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isInteger(number) && number >= 0 ? number : 0;
}

export function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

export function removeUndefinedValues<T extends Record<string, unknown>>(value: T) {
  return Object.fromEntries(Object.entries(value).filter((entry) => entry[1] !== undefined)) as T;
}

function normalizeDiscountCodeCategory(value: unknown): DiscountCodeCategory {
  if (value === winReferralCodeCategory) {
    return winReferralCodeCategory;
  }

  return value === referralPartnerPromoCodeCategory
    ? referralPartnerPromoCodeCategory
    : adminPromoCodeCategory;
}

function normalizeCommissionPercent(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  if (!Number.isFinite(number) || number <= 0 || number > 100) {
    throw new ApiRequestError(400, "Commission percent must be between 1 and 100.");
  }

  return Math.round(number * 100) / 100;
}

function readCommissionPercent(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isFinite(number) && number > 0 && number <= 100
    ? Math.round(number * 100) / 100
    : 0;
}

function normalizeDiscountPercent(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  if (!Number.isFinite(number) || number <= 0 || number > 100) {
    throw new ApiRequestError(400, "Discount percent must be between 1 and 100.");
  }

  return Math.round(number * 100) / 100;
}

function readDiscountPercent(value: unknown, codeType: DiscountCodeType) {
  if (codeType === "bogo") {
    return 0;
  }

  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isFinite(number) && number > 0 && number <= 100
    ? Math.round(number * 100) / 100
    : 30;
}

function normalizeMoneyCents(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isInteger(number) && number >= 0 ? number : 0;
}

function normalizePreviewDiscountItems(value: unknown): Array<{ quantity: number; unitPriceCents: number }> {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => {
      if (!item || typeof item !== "object") {
        return null;
      }

      const quantity = normalizeInteger((item as PreviewDiscountItem).quantity);
      const unitPriceCents = normalizeMoneyCents((item as PreviewDiscountItem).unitPriceCents);

      if (quantity <= 0 || unitPriceCents <= 0) {
        return null;
      }

      return { quantity, unitPriceCents };
    })
    .filter((item): item is { quantity: number; unitPriceCents: number } => item !== null);
}

function calculateBogoDiscountCents(
  items: Array<{ quantity: number; unitPriceCents: number }>,
  subtotalCents: number,
) {
  const unitPrices = items.flatMap((item) =>
    Array.from({ length: item.quantity }, () => item.unitPriceCents),
  );

  if (!unitPrices.length) {
    return {
      amountCents: Math.floor(subtotalCents / 2),
      discountedQuantity: subtotalCents > 0 ? 1 : 0,
    };
  }

  const discountedQuantity = Math.floor(unitPrices.length / 2);

  if (discountedQuantity <= 0) {
    return { amountCents: 0, discountedQuantity: 0 };
  }

  unitPrices.sort((left, right) => left - right);

  return {
    amountCents: unitPrices.slice(0, discountedQuantity).reduce((total, price) => total + price, 0),
    discountedQuantity,
  };
}

function normalizeToken(value: unknown) {
  return readString(value).replace(/[^a-zA-Z0-9_-]/g, "").slice(0, 80);
}

function formatCents(cents: number) {
  return new Intl.NumberFormat("en-US", { currency: "USD", style: "currency" }).format(cents / 100);
}

function serializeTimestamp(value: unknown) {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  if (typeof value === "string") {
    return value;
  }

  return "";
}

function serializeDiscountCodeOrderUsage(id: string, data: Record<string, unknown>) {
  return {
    code: normalizeDiscountCode(data.code),
    commissionCents: normalizeInteger(data.commissionCents),
    commissionPercent: readCommissionPercent(data.commissionPercent),
    customerEmail: readString(data.customerEmail).toLowerCase(),
    customerId: readString(data.customerId),
    discountCents: normalizeInteger(data.discountCents),
    orderId: readString(data.orderId) || id,
    recordedAt: serializeTimestamp(data.recordedAt),
    referredSpendCents: normalizeInteger(data.referredSpendCents),
    subtotalCents: normalizeInteger(data.subtotalCents),
    uid: readString(data.uid),
  };
}
