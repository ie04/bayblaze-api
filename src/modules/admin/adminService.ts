import { forwardAdminOrderDeleteRequest, forwardAdminOrderDetailRequest, forwardAdminOrdersRequest } from "../../clients/medusaAdminClient";
import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { sendUpstreamJson } from "../../http/upstream";
import { searchAccounts, updateAccountAccess } from "../accounts/accountService";
import type { AccountBadge, AccountRole } from "../accounts/accountTypes";
import {
  adminPromoCodeCategory,
  createDiscountCode,
  deleteDiscountCode,
  listDiscountCodes,
  normalizeDiscountCode,
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
import { geocodeAddress } from "../isochronos/googleMapsService";
import type { Response as ExpressResponse } from "express";

type AdminPromoCodeType = DiscountCodeType;

type AdminPromoCodeInput = {
  code: string;
  codeType?: AdminPromoCodeType;
  discountPercent?: number;
  minimumSpendCents?: number;
};

type AdminPromoCodeUpdateInput = {
  code?: string;
  codeType?: AdminPromoCodeType;
  discountPercent?: number;
  minimumSpendCents?: number;
};

export async function searchAdminAccounts(query: string, limit: number) {
  return {
    accounts: await searchAccounts(query, limit),
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
  return {
    account: await updateAccountAccess(uid, input),
  };
}

export async function listAdminPromoCodes() {
  return {
    promoCodes: await listDiscountCodes([adminPromoCodeCategory, winReferralCodeCategory]),
  };
}

export async function createAdminPromoCode(input: AdminPromoCodeInput) {
  const code = normalizeDiscountCode(input.code);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const promoCode = await createDiscountCode({
    category: adminPromoCodeCategory,
    code,
    codeType: input.codeType,
    discountPercent: input.discountPercent,
    minimumSpendCents: input.minimumSpendCents,
    usageLimit: 1000000,
  });

  return {
    promoCode,
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

  const promoCode = await updateDiscountCode(code, input, {
    category: adminPromoCodeCategory,
  });

  return { promoCode };
}

export async function deleteAdminPromoCode(codeInput: string) {
  const code = normalizeDiscountCode(codeInput);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  await deleteDiscountCode(code, { category: adminPromoCodeCategory });

  return { ok: true };
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
