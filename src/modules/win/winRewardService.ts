import { createHash, randomBytes } from "node:crypto";

import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { forwardInventoryRequest } from "../../clients/medusaInventoryClient";
import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import {
  buildDiscountCodeRecord,
  discountCodesCollection,
  normalizeDiscountCode,
  previewDiscountCode as previewSharedDiscountCode,
  type PreviewDiscountItem,
  winReferralCodeCategory,
} from "../discountCodes/discountCodeService";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import type { FreebieProduct, WinRewardRecord, WinRewardStatus } from "./winTypes";

const winRewardsCollection = "customer_win_rewards";
const referralCodeIndexCollection = "customer_win_referral_codes";
const orderCompletionsCollection = "customer_win_order_completions";
const defaultCampaign = "nfc-free-vape";
const defaultSource = "nfc-mailer";
const discountPercent = 20;
const minimumSpendCents = 2000;
const usageLimit = 1;
const maxFreebieProducts = 48;

type WinContext = { campaign?: string; nfcTagId?: string; source?: string };
type ClaimFreebieInput = { campaign?: string; claimToken?: string; productId: string; variantId?: string };
type PreviewCustomerDiscountCodeInput = { code: string; items?: PreviewDiscountItem[]; subtotalCents?: number };

type InventorySnapshot = { products?: InventoryProduct[] };
type InventoryProduct = {
  id?: string; title?: string; handle?: string; description?: string; status?: string; category?: string; collectionTitle?: string;
  metadata?: Record<string, unknown>; thumbnail?: string; image?: string; imageUrl?: string; imageUrls?: string[];
  images?: InventoryImageValue[]; productImages?: InventoryImageValue[]; variants?: InventoryVariant[];
};
type InventoryVariant = {
  id?: string; productId?: string; productTitle?: string; title?: string; priceCents?: number; imageUrl?: string; imageUrls?: string[];
  images?: InventoryImageValue[]; metadata?: { availableQuantity?: number | string; brand?: string; inventoryState?: string };
};
type InventoryImageValue = string | { src?: string; url?: string };

export async function startCustomerWinReward(uid: string, context: WinContext) {
  const normalizedContext = normalizeWinContext(context);
  const ref = getRewardRef(uid, normalizedContext.campaign);
  const existing = await ref.get();
  if (existing.exists) {
    const reward = existing.data() as WinRewardRecord;
    await ensureDiscountCodeRecord(reward);
    return serializeReward(await refreshRewardQualification(reward));
  }
  const referralCode = await createUniqueReferralCode(uid, normalizedContext.campaign);
  const now = FieldValue.serverTimestamp();
  const reward: WinRewardRecord = {
    campaign: normalizedContext.campaign, discountCodeCategory: winReferralCodeCategory, discountCodeId: referralCode, discountPercent, minimumSpendCents,
    nfcTagId: normalizedContext.nfcTagId, referralCode, referralUrl: buildReferralUrl(referralCode), source: normalizedContext.source,
    status: "waiting_for_friend_order", uid, createdAt: now, updatedAt: now,
  };
  const codeRecord = buildDiscountCodeRecord({
    campaign: normalizedContext.campaign,
    category: winReferralCodeCategory,
    code: referralCode,
    codeType: "discount",
    discountPercent,
    minimumSpendCents,
    ownerUid: uid,
    referralCode,
    rewardId: ref.id,
    status: "active",
    uid,
    usageLimit,
    usedCount: 0,
  });
  await ref.set(reward);
  await getBayblazeFirestore().collection(referralCodeIndexCollection).doc(referralCode).set(codeRecord);
  await getBayblazeFirestore().collection(discountCodesCollection).doc(referralCode).set(codeRecord);
  return serializeReward(reward);
}

export async function getCustomerWinRewardStatus(uid: string, context: WinContext) {
  const normalizedContext = normalizeWinContext(context);
  const snapshot = await getRewardRef(uid, normalizedContext.campaign).get();
  if (!snapshot.exists) return startCustomerWinReward(uid, normalizedContext);
  const reward = snapshot.data() as WinRewardRecord;
  await ensureDiscountCodeRecord(reward);
  return serializeReward(await refreshRewardQualification(reward));
}

export async function getCustomerWinFreebies() {
  const snapshot = await fetchInventorySnapshot();
  const products = (snapshot.products ?? []).filter((product) => product.status === "published").filter(hasOnVehicleInventory).map(toFreebieProduct).filter(isFreebieProduct).slice(0, maxFreebieProducts);
  return { products };
}

export async function claimCustomerWinFreebie(uid: string, input: ClaimFreebieInput) {
  const campaign = normalizeToken(input.campaign) || defaultCampaign;
  const rewardRef = getRewardRef(uid, campaign);
  const rewardSnapshot = await rewardRef.get();
  if (!rewardSnapshot.exists) throw new ApiRequestError(404, "Start the win reward flow before claiming a freebie.");
  const reward = await refreshRewardQualification(rewardSnapshot.data() as WinRewardRecord);
  if (!isRewardQualified(reward)) throw new ApiRequestError(409, "Your friend code has not been used on a completed order yet.");
  if (reward.claimToken && input.claimToken && reward.claimToken !== input.claimToken) throw new ApiRequestError(403, "This freebie claim token is not valid.");
  const freebie = await findFreebieProduct(input.productId, input.variantId);
  if (!freebie) throw new ApiRequestError(404, "That freebie is not currently eligible.");
  const claimToken = reward.claimToken || randomBytes(24).toString("base64url");
  await rewardRef.set({ claimToken, claimedAt: FieldValue.serverTimestamp(), claimedProductId: freebie.id, claimedVariantId: freebie.variantId, status: "claimed" satisfies WinRewardStatus, updatedAt: FieldValue.serverTimestamp() }, { merge: true });
  return { claimToken, productId: freebie.id, status: "claimed", variantId: freebie.variantId };
}

export async function previewCustomerDiscountCode(uid: string, input: PreviewCustomerDiscountCodeInput) {
  const preview = await previewSharedDiscountCode(input);
  if (preview.ownerUid && preview.ownerUid === uid) throw new ApiRequestError(409, "Send this friend code to someone else to unlock your freebie.");
  return preview;
}

export async function previewPublicDiscountCode(input: PreviewCustomerDiscountCodeInput) {
  const { ownerUid: _ownerUid, ...preview } = await previewSharedDiscountCode(input);
  return preview;
}

async function refreshRewardQualification(reward: WinRewardRecord) {
  if (isRewardQualified(reward)) return reward;
  const completion = await getBayblazeFirestore().collection(orderCompletionsCollection).doc(reward.referralCode).get();
  if (!completion.exists) return reward;
  const completionData = completion.data() ?? {};
  const completedOrderId = readString(completionData.orderId) || readString(completionData.completedOrderId);
  const nextReward: WinRewardRecord = { ...reward, claimToken: reward.claimToken || randomBytes(24).toString("base64url"), completedOrderId, qualifiedAt: FieldValue.serverTimestamp(), status: "qualified", updatedAt: FieldValue.serverTimestamp() };
  await getRewardRef(reward.uid, reward.campaign).set(nextReward, { merge: true });
  return nextReward;
}

async function createUniqueReferralCode(uid: string, campaign: string) {
  const prefix = "BLAZE20";
  const stable = createHash("sha256").update(`${uid}:${campaign}`).digest("base64url").replace(/[^A-Z0-9]/gi, "").slice(0, 5).toUpperCase();
  const firestore = getBayblazeFirestore();
  for (let attempt = 0; attempt < 5; attempt += 1) {
    const suffix = attempt === 0 ? stable : randomBytes(4).toString("hex").slice(0, 5).toUpperCase();
    const code = `${prefix}-${suffix}`;
    const [indexSnapshot, discountCodeSnapshot] = await Promise.all([
      firestore.collection(referralCodeIndexCollection).doc(code).get(),
      firestore.collection(discountCodesCollection).doc(code).get(),
    ]);
    if (!indexSnapshot.exists && !discountCodeSnapshot.exists) return code;
  }
  throw new ApiRequestError(409, "Could not generate a unique BayBlaze friend code.");
}

async function ensureDiscountCodeRecord(reward: WinRewardRecord) {
  const referralCode = normalizeReferralCode(reward.referralCode);
  if (!referralCode) return;
  const firestore = getBayblazeFirestore();
  const discountCodeRef = firestore.collection(discountCodesCollection).doc(referralCode);
  const discountCodeSnapshot = await discountCodeRef.get();
  if (discountCodeSnapshot.exists) return;
  const used = Boolean(reward.completedOrderId) || reward.status === "qualified" || reward.status === "claimed";
  const codeRecord = removeUndefinedValues({
    ...buildDiscountCodeRecord({
      campaign: reward.campaign,
      category: reward.discountCodeCategory ?? winReferralCodeCategory,
      code: referralCode,
      codeType: "discount",
      discountPercent: reward.discountPercent,
      minimumSpendCents: reward.minimumSpendCents,
      ownerUid: reward.uid,
      referralCode,
      rewardId: `${reward.uid}_${reward.campaign}`,
      status: used ? "used" : "active",
      uid: reward.uid,
      usageLimit,
      usedCount: used ? 1 : 0,
    }),
    createdAt: reward.createdAt ?? FieldValue.serverTimestamp(),
    usedByOrderId: reward.completedOrderId,
  });
  await discountCodeRef.set(codeRecord, { merge: true });
  await firestore.collection(referralCodeIndexCollection).doc(referralCode).set(codeRecord, { merge: true });
}

function serializeReward(reward: WinRewardRecord) {
  return { campaign: reward.campaign, claimToken: reward.claimToken ?? null, claimedProductId: reward.claimedProductId ?? null, claimedVariantId: reward.claimedVariantId ?? null, completedOrderId: reward.completedOrderId ?? null, discountCodeCategory: reward.discountCodeCategory ?? winReferralCodeCategory, discountCodeId: reward.discountCodeId ?? reward.referralCode, discountPercent: reward.discountPercent, minimumSpendCents: reward.minimumSpendCents, nfcTagId: reward.nfcTagId ?? null, qualifiedAt: serializeTimestamp(reward.qualifiedAt), referralCode: reward.referralCode, referralUrl: reward.referralUrl, source: reward.source, status: reward.status };
}

async function findFreebieProduct(productId: string, variantId?: string) {
  const freebies = (await getCustomerWinFreebies()).products;
  return freebies.find((product) => product.id === productId && (!variantId || product.variantId === variantId));
}

async function fetchInventorySnapshot() {
  const upstream = await forwardInventoryRequest({ method: "GET" } as Parameters<typeof forwardInventoryRequest>[0]);
  const text = await upstream.text();
  if (!upstream.ok) throw new ApiRequestError(upstream.status, text || "Unable to load BayBlaze inventory.");
  try { return (text ? JSON.parse(text) : {}) as InventorySnapshot; } catch { throw new ApiRequestError(502, "BayBlaze inventory returned a non-JSON response."); }
}

function toFreebieProduct(product: InventoryProduct): FreebieProduct | null {
  const variant = product.variants?.find(isAvailableOnVehicleVariant) ?? product.variants?.[0];
  const id = readString(product.id);
  const variantId = readString(variant?.id);
  if (!id || !variantId) return null;
  return { id, variantId, name: readString(product.title) || readString(variant?.productTitle) || "BayBlaze product", brand: readBrand(product, variant), image: readImage(product, variant), price: formatPrice(variant?.priceCents), categories: [readString(product.category) || readString(product.collectionTitle) || "Vapes"], description: readString(product.description) || "BayBlaze freebie eligible for local Tampa delivery." };
}

function isFreebieProduct(product: FreebieProduct | null): product is FreebieProduct { return product !== null; }
function hasOnVehicleInventory(product: InventoryProduct) { return product.variants?.some(isAvailableOnVehicleVariant) ?? false; }
function isAvailableOnVehicleVariant(variant: InventoryVariant) { return variant.metadata?.inventoryState === "ON_VEHICLE" && normalizeQuantity(variant.metadata?.availableQuantity) > 0; }
function readBrand(product: InventoryProduct, variant?: InventoryVariant) { return readString(product.metadata?.brand) || readString(variant?.metadata?.brand) || "BayBlaze"; }
function readImage(product: InventoryProduct, variant?: InventoryVariant) {
  const candidates = [product.image, product.thumbnail, product.imageUrl, product.imageUrls?.[0], readInventoryImage(product.images?.[0]), readInventoryImage(product.productImages?.[0]), variant?.imageUrl, variant?.imageUrls?.[0], readInventoryImage(variant?.images?.[0])];
  return candidates.map(readString).find(Boolean) ?? "";
}
function readInventoryImage(value: InventoryImageValue | undefined) { return typeof value === "string" ? value : value?.url || value?.src || ""; }
function normalizeQuantity(value: unknown) { const quantity = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN; return Number.isInteger(quantity) && quantity >= 0 ? quantity : 0; }
function formatPrice(cents?: number) { if (!Number.isFinite(cents ?? Number.NaN)) return "Freebie"; return new Intl.NumberFormat("en-US", { currency: "USD", style: "currency" }).format((cents ?? 0) / 100); }
function getRewardRef(uid: string, campaign: string) { return getBayblazeFirestore().collection(winRewardsCollection).doc(`${uid}_${campaign}`); }
function normalizeWinContext(context: WinContext) { return { campaign: normalizeToken(context.campaign) || defaultCampaign, nfcTagId: normalizeToken(context.nfcTagId), source: normalizeToken(context.source) || defaultSource }; }
function normalizeToken(value: unknown) { return readString(value).replace(/[^a-zA-Z0-9_-]/g, "").slice(0, 80); }
function normalizeReferralCode(value: unknown) { return normalizeDiscountCode(value); }
function buildReferralUrl(referralCode: string) { const storefrontUrl = (env.BAYBLAZE_STOREFRONT_URL || "https://bayblaze.net").replace(/\/$/, ""); const params = new URLSearchParams({ promo: referralCode }); return `${storefrontUrl}/?${params.toString()}`; }
function isRewardQualified(reward: WinRewardRecord) { return reward.status === "qualified" || reward.status === "claimed" || Boolean(reward.completedOrderId); }
function serializeTimestamp(value: unknown) { if (value instanceof Timestamp) return value.toDate().toISOString(); if (typeof value === "string") return value; return null; }
function readString(value: unknown) { return typeof value === "string" ? value.trim() : ""; }
function removeUndefinedValues<T extends Record<string, unknown>>(value: T) { return Object.fromEntries(Object.entries(value).filter((entry) => entry[1] !== undefined)) as T; }
