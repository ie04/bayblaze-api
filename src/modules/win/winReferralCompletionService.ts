import { randomBytes } from "node:crypto";

import { FieldValue } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import {
  discountCodesCollection,
  normalizeDiscountCode,
  winReferralCodeCategory,
} from "../discountCodes/discountCodeService";
import { ApiRequestError } from "../drivers/driverWorkflowService";

const winRewardsCollection = "customer_win_rewards";
const referralCodeIndexCollection = "customer_win_referral_codes";
const orderCompletionsCollection = "customer_win_order_completions";
const usageLimit = 1;

type CompleteWinReferralInput = {
  completedOrderId?: string;
  customerEmail?: string;
  customerId?: string;
  isCustomerFirstOrder?: boolean;
  orderId?: string;
  referralCode: string;
};

export async function completeWinReferral(input: CompleteWinReferralInput) {
  const referralCode = normalizeReferralCode(input.referralCode);
  const completedOrderId = readString(input.completedOrderId) || readString(input.orderId);
  const completedCustomerId = readString(input.customerId);
  const completedCustomerEmail = readString(input.customerEmail).toLowerCase();
  const isCustomerFirstOrder = input.isCustomerFirstOrder === true;

  if (!referralCode) {
    throw new ApiRequestError(400, "Referral code is required.");
  }

  if (!completedOrderId) {
    throw new ApiRequestError(400, "Completed order ID is required.");
  }

  const firestore = getBayblazeFirestore();
  const indexRef = firestore.collection(referralCodeIndexCollection).doc(referralCode);
  const discountCodeRef = firestore.collection(discountCodesCollection).doc(referralCode);
  const completionRef = firestore.collection(orderCompletionsCollection).doc(referralCode);
  const ignoredCompletionRef = firestore
    .collection(orderCompletionsCollection)
    .doc(referralCode)
    .collection("ignored_orders")
    .doc(completedOrderId);
  const claimToken = randomBytes(24).toString("base64url");
  const result = await firestore.runTransaction(async (transaction) => {
    const [indexSnapshot, discountCodeSnapshot, completionSnapshot, ignoredCompletionSnapshot] = await Promise.all([
      transaction.get(indexRef),
      transaction.get(discountCodeRef),
      transaction.get(completionRef),
      transaction.get(ignoredCompletionRef),
    ]);

    if (!indexSnapshot.exists) {
      throw new ApiRequestError(404, "BayBlaze win referral code was not found.");
    }

    const index = indexSnapshot.data() ?? {};
    const existingCompletion = completionSnapshot.exists ? completionSnapshot.data() ?? {} : null;
    const uid = readString(index.uid) || readString(index.ownerUid);
    const campaign = readString(index.campaign);
    const rewardId = readString(index.rewardId) || (uid && campaign ? `${uid}_${campaign}` : "");

    if (!rewardId || !uid) {
      throw new ApiRequestError(409, "BayBlaze win referral record is incomplete.");
    }

    if (!isCustomerFirstOrder) {
      const now = FieldValue.serverTimestamp();
      const ignoredRecord = removeUndefinedValues({
        category: winReferralCodeCategory,
        completedAt: now,
        completedCustomerEmail: completedCustomerEmail || undefined,
        completedCustomerId: completedCustomerId || undefined,
        completedOrderId,
        firstOrderRequired: true,
        ignoredReason: "customer_not_first_order",
        isCustomerFirstOrder: false,
        orderId: completedOrderId,
        ownerUid: uid,
        referralCode,
        rewardId,
        uid,
        updatedAt: now,
      });

      if (!ignoredCompletionSnapshot.exists) {
        transaction.create(ignoredCompletionRef, ignoredRecord);
      }

      transaction.set(
        discountCodeRef.collection("order_usages").doc(completedOrderId),
        ignoredRecord,
        { merge: true },
      );

      return {
        claimToken: "",
        completedOrderId,
        rewardId,
        uid,
        alreadyCompleted: ignoredCompletionSnapshot.exists,
        ignored: true,
        ignoredReason: "customer_not_first_order",
      };
    }

    if (existingCompletion) {
      const existingOrderId =
        readString(existingCompletion.completedOrderId) ||
        readString(existingCompletion.orderId);

      if (existingOrderId === completedOrderId) {
        return {
          claimToken: readString(existingCompletion.claimToken) || claimToken,
          completedOrderId,
          rewardId,
          uid,
          alreadyCompleted: true,
        };
      }

      throw new ApiRequestError(409, "This BayBlaze win referral code has already been used.");
    }

    const discountCode = discountCodeSnapshot.exists ? discountCodeSnapshot.data() ?? {} : {};
    const usedCount = Math.max(readInteger(discountCode.usedCount), readInteger(index.usedCount));
    const storedUsageLimit = readInteger(discountCode.usageLimit) || readInteger(index.usageLimit) || usageLimit;

    if (
      usedCount >= storedUsageLimit ||
      readString(discountCode.status) === "used" ||
      readString(index.status) === "used"
    ) {
      throw new ApiRequestError(409, "This BayBlaze win referral code has already been used.");
    }

    const now = FieldValue.serverTimestamp();
    const completionRecord = removeUndefinedValues({
      category: winReferralCodeCategory,
      claimToken,
      completedAt: now,
      completedCustomerEmail: completedCustomerEmail || undefined,
      completedCustomerId: completedCustomerId || undefined,
      completedOrderId,
      firstOrderRequired: true,
      isCustomerFirstOrder: true,
      orderId: completedOrderId,
      ownerUid: uid,
      referralCode,
      rewardId,
      uid,
      updatedAt: now,
    });
    const usageRecord = removeUndefinedValues({
      category: winReferralCodeCategory,
      code: referralCode,
      codeType: "discount",
      completedCustomerEmail: completedCustomerEmail || undefined,
      completedCustomerId: completedCustomerId || undefined,
      firstOrderRequired: true,
      isCustomerFirstOrder: true,
      ownerUid: uid,
      rewardId,
      status: "used",
      usedAt: now,
      usedByOrderId: completedOrderId,
      usedCount: 1,
      usageLimit: storedUsageLimit,
      updatedAt: now,
    });

    transaction.create(completionRef, completionRecord);
    transaction.set(indexRef, usageRecord, { merge: true });
    transaction.set(discountCodeRef, usageRecord, { merge: true });
    transaction.set(
      firestore.collection(winRewardsCollection).doc(rewardId),
      {
        claimToken,
        completedOrderId,
        qualifiedAt: now,
        status: "qualified",
        updatedAt: now,
      },
      { merge: true },
    );

    return {
      claimToken,
      completedOrderId,
      rewardId,
      uid,
      alreadyCompleted: false,
    };
  });

  if (result.ignored) {
    return {
      completedOrderId: result.completedOrderId,
      ignored: true,
      ignoredReason: result.ignoredReason,
      referralCode,
      rewardId: result.rewardId,
      status: "waiting_for_friend_order",
    };
  }

  return {
    claimToken: result.claimToken,
    completedOrderId: result.completedOrderId,
    referralCode,
    rewardId: result.rewardId,
    status: "qualified",
  };
}

function normalizeReferralCode(value: unknown) {
  return normalizeDiscountCode(value);
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function readInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isInteger(number) && number >= 0 ? number : 0;
}

function removeUndefinedValues<T extends Record<string, unknown>>(value: T) {
  return Object.fromEntries(Object.entries(value).filter((entry) => entry[1] !== undefined)) as T;
}
