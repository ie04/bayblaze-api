import { randomBytes } from "node:crypto";

import { FieldValue } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { ApiRequestError } from "../drivers/driverWorkflowService";

const winRewardsCollection = "customer_win_rewards";
const referralCodeIndexCollection = "customer_win_referral_codes";
const orderCompletionsCollection = "customer_win_order_completions";

type CompleteWinReferralInput = {
  completedOrderId?: string;
  orderId?: string;
  referralCode: string;
};

export async function completeWinReferral(input: CompleteWinReferralInput) {
  const referralCode = normalizeReferralCode(input.referralCode);
  const completedOrderId = readString(input.completedOrderId) || readString(input.orderId);

  if (!referralCode) {
    throw new ApiRequestError(400, "Referral code is required.");
  }

  if (!completedOrderId) {
    throw new ApiRequestError(400, "Completed order ID is required.");
  }

  const firestore = getBayblazeFirestore();
  const indexSnapshot = await firestore.collection(referralCodeIndexCollection).doc(referralCode).get();

  if (!indexSnapshot.exists) {
    throw new ApiRequestError(404, "BayBlaze win referral code was not found.");
  }

  const index = indexSnapshot.data() ?? {};
  const uid = readString(index.uid);
  const campaign = readString(index.campaign);
  const rewardId = readString(index.rewardId) || (uid && campaign ? `${uid}_${campaign}` : "");

  if (!rewardId) {
    throw new ApiRequestError(409, "BayBlaze win referral record is incomplete.");
  }

  const now = FieldValue.serverTimestamp();
  const claimToken = randomBytes(24).toString("base64url");

  await firestore.collection(orderCompletionsCollection).doc(referralCode).set(
    {
      completedAt: now,
      completedOrderId,
      orderId: completedOrderId,
      referralCode,
      rewardId,
      uid,
      updatedAt: now,
    },
    { merge: true },
  );

  await firestore.collection(winRewardsCollection).doc(rewardId).set(
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
    referralCode,
    rewardId,
    status: "qualified",
  };
}

function normalizeReferralCode(value: unknown) {
  return readString(value)
    .replace(/[^a-zA-Z0-9_-]/g, "")
    .slice(0, 80)
    .toUpperCase();
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}
