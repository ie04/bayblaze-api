import { forwardAdminOrderDeleteRequest, forwardAdminOrderDetailRequest, forwardAdminOrdersRequest } from "../../clients/medusaAdminClient";
import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { sendUpstreamJson } from "../../http/upstream";
import { getAccount, searchAccounts, updateAccountAccess } from "../accounts/accountService";
import type { AccountBadge, AccountRole } from "../accounts/accountTypes";
import {
  adminPromoCodeCategory,
  createDiscountCode,
  deleteDiscountCode,
  getDiscountCode,
  listDiscountCodeOrderUsages,
  listDiscountCodes,
  normalizeDiscountCode,
  referralPartnerPromoCodeCategory,
  serializeDiscountCode,
  updateDiscountCode,
  winReferralCodeCategory,
  type DiscountCodeType,
} from "../discountCodes/discountCodeService";
import type { DriverDeliveryQueue, DriverLocationSnapshot, DriverProfile, VehicleRecord } from "../drivers/driverWorkflowTypes";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  createCoverageArea,
  createStandaloneIsochronePlot,
  deleteCoverageArea,
  listCoverageAreas,
  regenerateCoverageArea,
  regenerateDueCoverageAreas,
  updateCoverageArea,
  type CoverageAreaInput,
} from "../isochronos/coverageAreaService";
import {
  listEmailAutomations,
  sendEmailAutomationTest,
  updateEmailAutomation,
  type EmailAutomationEventType,
  type EmailAutomationTestInput,
  type EmailAutomationUpdateInput,
} from "../email/emailAutomationService";
import { createActivePartnerWithPromo, updateAdminPartnerStatus } from "../partners/partnerService";
import { geocodeAddress } from "../isochronos/googleMapsService";
import type { Response as ExpressResponse } from "express";

type AdminPromoCodeType = DiscountCodeType;

type AdminPromoCodeInput = {
  category?: typeof adminPromoCodeCategory | typeof referralPartnerPromoCodeCategory;
  code: string;
  codeType?: AdminPromoCodeType;
  commissionPercent?: number;
  discountPercent?: number;
  minimumSpendCents?: number;
  ownerUid?: string;
  singleUsePerAccount?: boolean;
};

type AdminPromoCodeUpdateInput = {
  code?: string;
  codeType?: AdminPromoCodeType;
  commissionPercent?: number;
  discountPercent?: number;
  minimumSpendCents?: number;
  ownerUid?: string;
  singleUsePerAccount?: boolean;
};

export async function searchAdminAccounts(query: string, limit: number) {
  const accounts = await searchAccounts(query, limit);

  return {
    accounts: await attachAccountReferralSummaries(accounts),
  };
}

export async function updateAdminAccount(
  uid: string,
  input: {
    disabled?: boolean;
    displayName?: string;
    badges?: AccountBadge[];
    roles?: AccountRole[];
    settings?: { ageVerificationDisabled?: boolean };
  },
) {
  const account = await updateAccountAccess(uid, input);

  return {
    account: (await attachAccountReferralSummaries([account]))[0],
  };
}

async function attachAccountReferralSummaries<T extends { uid: string }>(accounts: T[]) {
  const summaries = await Promise.all(
    accounts.map(async (account) => {
      const [referralPromos, winReferrals] = await Promise.all([
        listPartnerReferralPromoSummaries(account.uid),
        listWinReferralSummaries(account.uid),
      ]);

      return { referralPromos, uid: account.uid, winReferrals };
    }),
  );
  const summariesByUid = new Map(summaries.map((summary) => [summary.uid, summary]));

  return accounts.map((account) => ({
    ...account,
    referralPromos: summariesByUid.get(account.uid)?.referralPromos ?? [],
    winReferrals: summariesByUid.get(account.uid)?.winReferrals ?? [],
  }));
}

async function listPartnerReferralPromoSummaries(uid: string) {
  const snapshot = await getBayblazeFirestore()
    .collection("customer_discount_codes")
    .where("ownerUid", "==", uid)
    .get();

  return snapshot.docs
    .map((doc) => serializeDiscountCode(doc.id, doc.data() ?? {}))
    .filter((promo) => promo.category === referralPartnerPromoCodeCategory)
    .map((promo) => ({
      code: promo.code,
      commissionPercent: promo.commissionPercent,
      discountPercent: promo.discountPercent,
      minimumSpendCents: promo.minimumSpendCents,
      status: promo.status,
      totalCommissionCents: promo.totalCommissionCents,
      totalReferredSpendCents: promo.totalReferredSpendCents,
      uniqueReferredCustomers: promo.uniqueReferredCustomers,
      usedCount: promo.usedCount,
    }));
}

async function listWinReferralSummaries(uid: string) {
  const snapshot = await getBayblazeFirestore()
    .collection("customer_win_rewards")
    .where("uid", "==", uid)
    .get();

  return snapshot.docs
    .map((doc) => {
      const reward = doc.data() ?? {};
      const referralCode = readString(reward.referralCode);
      const completedOrderId = readString(reward.completedOrderId);
      const claimedProductId = readString(reward.claimedProductId);
      const claimedVariantId = readString(reward.claimedVariantId);
      const status = readString(reward.status) || "waiting_for_friend_order";
      const qualifiedAt = serializeAdminTimestamp(reward.qualifiedAt);
      const claimedAt = serializeAdminTimestamp(reward.claimedAt);

      return {
        campaign: readString(reward.campaign),
        claimTokenIssued: Boolean(readString(reward.claimToken)),
        claimedAt,
        claimedProductId,
        claimedVariantId,
        completedOrderId,
        createdAt: serializeAdminTimestamp(reward.createdAt),
        freebieConsumed: status === "claimed" || Boolean(claimedAt || claimedProductId || claimedVariantId),
        id: doc.id,
        qualifiedAt,
        referralCode,
        referralConsumed: status === "qualified" || status === "claimed" || Boolean(completedOrderId || qualifiedAt),
        referralUrl: readString(reward.referralUrl),
        status,
        updatedAt: serializeAdminTimestamp(reward.updatedAt),
      };
    })
    .sort((left, right) => right.createdAt.localeCompare(left.createdAt));
}

function serializeAdminTimestamp(value: unknown) {
  if (typeof value === "string") {
    return value;
  }

  if (
    value &&
    typeof value === "object" &&
    "toDate" in value &&
    typeof value.toDate === "function"
  ) {
    return value.toDate().toISOString();
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  return "";
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

export async function listAdminPromoCodes() {
  const promoCodes = await listDiscountCodes([
    adminPromoCodeCategory,
    referralPartnerPromoCodeCategory,
    winReferralCodeCategory,
  ]);

  return {
    promoCodes: await Promise.all(promoCodes.map(enrichAdminPromoCode)),
  };
}

export async function createAdminPromoCode(input: AdminPromoCodeInput) {
  const code = normalizeDiscountCode(input.code);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  if (input.category === referralPartnerPromoCodeCategory) {
    const owner = input.ownerUid ? await getAccount(input.ownerUid) : null;

    if (!owner) {
      throw new ApiRequestError(400, "Select an existing BayBlaze account for this referral promo.");
    }

    if (owner.disabled) {
      throw new ApiRequestError(409, "The selected referral partner account is disabled.");
    }

    const promoCode = await createActivePartnerWithPromo({
      code,
      commissionPercent: input.commissionPercent ?? 0,
      discountPercent: input.discountPercent ?? 0,
      minimumSpendCents: input.minimumSpendCents,
      ownerUid: input.ownerUid!,
      singleUsePerAccount: input.singleUsePerAccount,
    });

    return { promoCode: await enrichAdminPromoCode(promoCode) };
  }

  const promoCode = await createDiscountCode({
    category: input.category ?? adminPromoCodeCategory,
    code,
    codeType: input.codeType,
    commissionPercent: input.commissionPercent,
    discountPercent: input.discountPercent,
    minimumSpendCents: input.minimumSpendCents,
    ownerUid: input.ownerUid,
    singleUsePerAccount: input.singleUsePerAccount,
    usageLimit: 1000000,
  });

  return {
    promoCode: await enrichAdminPromoCode(promoCode),
  };
}

export async function updateAdminPromoCode(
  currentCode: string,
  input: AdminPromoCodeUpdateInput,
) {
  const code = normalizeDiscountCode(currentCode);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const currentPromoCode = await getDiscountCode(code);

  if (![adminPromoCodeCategory, referralPartnerPromoCodeCategory].includes(currentPromoCode.category)) {
    throw new ApiRequestError(409, "That promo code is managed by an automated rewards flow.");
  }

  if (
    currentPromoCode.category === referralPartnerPromoCodeCategory &&
    input.ownerUid &&
    input.ownerUid !== currentPromoCode.ownerUid
  ) {
    throw new ApiRequestError(409, "A referral promo cannot be transferred to another account after creation.");
  }

  if (
    currentPromoCode.category === referralPartnerPromoCodeCategory &&
    input.code &&
    normalizeDiscountCode(input.code) !== code
  ) {
    throw new ApiRequestError(409, "A partner referral code is stable and cannot be renamed.");
  }

  const promoCode = await updateDiscountCode(code, input, {
    category: currentPromoCode.category,
  });

  return { promoCode: await enrichAdminPromoCode(promoCode) };
}

export async function deleteAdminPromoCode(codeInput: string) {
  const code = normalizeDiscountCode(codeInput);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const promoCode = await getDiscountCode(code);

  if (![adminPromoCodeCategory, referralPartnerPromoCodeCategory].includes(promoCode.category)) {
    throw new ApiRequestError(409, "That promo code is managed by an automated rewards flow.");
  }

  if (promoCode.category === referralPartnerPromoCodeCategory && promoCode.usedCount > 0) {
    throw new ApiRequestError(409, "A referral promo with tracked purchases cannot be deleted.");
  }

  if (promoCode.category === referralPartnerPromoCodeCategory && promoCode.ownerUid) {
    await updateAdminPartnerStatus(promoCode.ownerUid, "rejected");
  }

  await deleteDiscountCode(code, { category: promoCode.category });

  return { ok: true };
}

async function enrichAdminPromoCode(
  promoCode: Awaited<ReturnType<typeof getDiscountCode>>,
) {
  if (promoCode.category !== referralPartnerPromoCodeCategory) {
    return promoCode;
  }

  const [owner, referrals] = await Promise.all([
    promoCode.ownerUid ? getAccount(promoCode.ownerUid) : null,
    listDiscountCodeOrderUsages(promoCode.code),
  ]);

  return {
    ...promoCode,
    ownerDisplayName: owner?.displayName ?? "",
    ownerEmail: owner?.email ?? "",
    referrals,
  };
}

export async function getAdminDriverMapState() {
  const db = getBayblazeFirestore();
  const [profilesSnapshot, locationsSnapshot, vehiclesSnapshot, queuesSnapshot] = await Promise.all([
    db.collection("driver_profiles").get(),
    db.collection("driver_location_snapshots").get(),
    db.collection("vehicles").get(),
    db.collection("driver_delivery_queues").get(),
  ]);
  const locations = new Map(locationsSnapshot.docs.map((doc) => [doc.id, doc.data() as DriverLocationSnapshot]));
  const vehicles = new Map(vehiclesSnapshot.docs.map((doc) => [doc.id, doc.data() as VehicleRecord]));
  const queues = new Map(queuesSnapshot.docs.map((doc) => [doc.id, doc.data() as DriverDeliveryQueue]));

  return {
    drivers: profilesSnapshot.docs.map((doc) => {
      const profile = doc.data() as DriverProfile;
      const queue = queues.get(doc.id);

      return {
        activeVehicle: profile.activeVehicleId ? vehicles.get(profile.activeVehicleId) ?? null : null,
        clockedIn: profile.clockedIn === true,
        displayName: [profile.firstName, profile.lastName].filter(Boolean).join(" ").trim() || profile.email,
        email: profile.email,
        location: locations.get(doc.id) ?? null,
        onboardingComplete: profile.onboardingComplete === true,
        queue: queue
          ? {
              activeOrderId: queue.activeOrderId ?? null,
              stopCount: queue.stops.length,
              updatedAt: queue.updatedAt ?? null,
            }
          : null,
        uid: doc.id,
      };
    }),
  };
}

export async function getAdminDriverRoutes() {
  const snapshot = await getBayblazeFirestore().collection("driver_delivery_queues").get();
  const routes = await Promise.all(
    snapshot.docs.map(async (doc) => {
      const queue = doc.data() as DriverDeliveryQueue;
      const stops = await Promise.all(
        queue.stops.map(async (stop, index) => {
          const geocode = stop.customerAddress ? await geocodeAddress(stop.customerAddress).catch(() => null) : null;

          return {
            customerAddress: stop.customerAddress,
            customerName: stop.customerName,
            index,
            locked: stop.locked,
            orderId: stop.orderId,
            orderReference: stop.orderReference ?? "",
            position: geocode ? { lat: geocode.lat, lng: geocode.lng } : null,
            score: stop.score ?? null,
            status: stop.status,
          };
        }),
      );

      return {
        activeOrderId: queue.activeOrderId ?? null,
        stops,
        uid: doc.id,
        updatedAt: queue.updatedAt ?? null,
      };
    }),
  );

  return { routes };
}

export function listAdminCoverageAreas() {
  return listCoverageAreas();
}

export function createAdminCoverageArea(input: CoverageAreaInput) {
  return createCoverageArea(input);
}

export function updateAdminCoverageArea(id: string, input: CoverageAreaInput & { regenerate?: boolean }) {
  return updateCoverageArea(id, input);
}

export function deleteAdminCoverageArea(id: string) {
  return deleteCoverageArea(id);
}

export function regenerateAdminCoverageArea(id: string) {
  return regenerateCoverageArea(id);
}

export function regenerateDueAdminCoverageAreas() {
  return regenerateDueCoverageAreas();
}

export function listAdminEmailAutomations() {
  return listEmailAutomations();
}

export function updateAdminEmailAutomation(eventType: EmailAutomationEventType, input: EmailAutomationUpdateInput) {
  return updateEmailAutomation(eventType, input);
}

export function sendAdminEmailAutomationTest(eventType: EmailAutomationEventType, input: EmailAutomationTestInput) {
  return sendEmailAutomationTest(eventType, input);
}

export async function createAdminIsochronePlot(input: {
  force?: boolean;
  origin: { address?: string; lat?: number; lng?: number };
  travelMinutes: number;
}) {
  return createStandaloneIsochronePlot(input);
}

export async function sendAdminOrders(res: ExpressResponse, query: URLSearchParams) {
  const upstream = await forwardAdminOrdersRequest(query);
  return sendUpstreamJson(res, upstream, {
    fallbackMessage: "Medusa orders API returned a non-JSON response.",
    upstreamName: "Medusa orders",
  });
}

export async function sendAdminOrderDetail(res: ExpressResponse, orderId: string) {
  if (!orderId.trim()) {
    throw new ApiRequestError(400, "Order ID is required.");
  }

  const upstream = await forwardAdminOrderDetailRequest(orderId);
  return sendUpstreamJson(res, upstream, {
    fallbackMessage: "Medusa order detail API returned a non-JSON response.",
    upstreamName: "Medusa order detail",
  });
}

export async function sendAdminOrderDelete(res: ExpressResponse, orderId: string, input: { releaseStock: boolean }) {
  if (!orderId.trim()) {
    throw new ApiRequestError(400, "Order ID is required.");
  }

  const upstream = await forwardAdminOrderDeleteRequest(orderId, input);
  return sendUpstreamJson(res, upstream, {
    fallbackMessage: "Medusa order delete API returned a non-JSON response.",
    upstreamName: "Medusa order delete",
  });
}
