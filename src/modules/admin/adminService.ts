import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { forwardAdminOrderDeleteRequest, forwardAdminOrderDetailRequest, forwardAdminOrdersRequest } from "../../clients/medusaAdminClient";
import { sendUpstreamJson } from "../../http/upstream";
import { searchAccounts, updateAccountAccess } from "../accounts/accountService";
import type { AccountBadge, AccountRole } from "../accounts/accountTypes";
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

const discountCodesCollection = "customer_discount_codes";
const adminPromoCodeCategory = "admin_promo";

type AdminPromoCodeType = "discount" | "bogo";

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
  const snapshot = await getBayblazeFirestore()
    .collection(discountCodesCollection)
    .where("category", "==", adminPromoCodeCategory)
    .get();
  const promoCodes = snapshot.docs
    .map((doc) => serializeAdminPromoCode(doc.id, doc.data()))
    .sort((left, right) => right.createdAt.localeCompare(left.createdAt));

  return { promoCodes };
}

export async function createAdminPromoCode(input: AdminPromoCodeInput) {
  const code = normalizePromoCode(input.code);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const codeType = normalizePromoCodeType(input.codeType);
  const discountPercent = normalizePromoDiscountPercent(input.discountPercent, codeType);
  const minimumSpendCents = normalizeMinimumSpendCents(input.minimumSpendCents);
  const ref = getBayblazeFirestore().collection(discountCodesCollection).doc(code);
  const existing = await ref.get();

  if (existing.exists) {
    throw new ApiRequestError(409, "That promo code already exists.");
  }

  const record = {
    category: adminPromoCodeCategory,
    code,
    codeType,
    discountPercent,
    minimumSpendCents,
    status: "active",
    usageLimit: 1000000,
    usedCount: 0,
    ...(codeType === "bogo" ? { bogoBuyQuantity: 1, bogoFreeQuantity: 1 } : {}),
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await ref.set(record);

  return {
    promoCode: serializeAdminPromoCode(code, {
      ...record,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }),
  };
}

export async function updateAdminPromoCode(
  currentCode: string,
  input: AdminPromoCodeUpdateInput,
) {
  const code = normalizePromoCode(currentCode);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const nextCode = input.code === undefined ? code : normalizePromoCode(input.code);

  if (!nextCode) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const firestore = getBayblazeFirestore();
  const currentRef = firestore.collection(discountCodesCollection).doc(code);
  const nextRef = firestore.collection(discountCodesCollection).doc(nextCode);
  const promoCode = await firestore.runTransaction(async (transaction) => {
    const currentSnapshot = await transaction.get(currentRef);

    if (!currentSnapshot.exists) {
      throw new ApiRequestError(404, "That promo code was not found.");
    }

    const currentData = currentSnapshot.data() ?? {};

    if (String(currentData.category || "") !== adminPromoCodeCategory) {
      throw new ApiRequestError(409, "That promo code is not managed by Admin Promo.");
    }

    if (nextCode !== code) {
      const nextSnapshot = await transaction.get(nextRef);

      if (nextSnapshot.exists) {
        throw new ApiRequestError(409, "That promo code already exists.");
      }
    }

    const nextCodeType = input.codeType === undefined
      ? normalizePromoCodeType(currentData.codeType)
      : normalizePromoCodeType(input.codeType);
    const nextDiscountPercent = normalizePromoDiscountPercent(
      input.discountPercent === undefined ? currentData.discountPercent : input.discountPercent,
      nextCodeType,
    );
    const nextMinimumSpendCents = input.minimumSpendCents === undefined
      ? normalizeMinimumSpendCents(currentData.minimumSpendCents)
      : normalizeMinimumSpendCents(input.minimumSpendCents);
    const nextData = {
      ...currentData,
      code: nextCode,
      codeType: nextCodeType,
      discountPercent: nextDiscountPercent,
      minimumSpendCents: nextMinimumSpendCents,
      ...(nextCodeType === "bogo" ? { bogoBuyQuantity: 1, bogoFreeQuantity: 1 } : {}),
      updatedAt: FieldValue.serverTimestamp(),
    };

    if (nextCode !== code) {
      transaction.set(nextRef, nextData);
      transaction.delete(currentRef);
    } else {
      transaction.set(currentRef, nextData, { merge: true });
    }

    return serializeAdminPromoCode(nextCode, {
      ...nextData,
      updatedAt: new Date().toISOString(),
    });
  });

  return { promoCode };
}

export async function deleteAdminPromoCode(codeInput: string) {
  const code = normalizePromoCode(codeInput);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const ref = getBayblazeFirestore().collection(discountCodesCollection).doc(code);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "That promo code was not found.");
  }

  const data = snapshot.data() ?? {};

  if (String(data.category || "") !== adminPromoCodeCategory) {
    throw new ApiRequestError(409, "That promo code is not managed by Admin Promo.");
  }

  await ref.delete();

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

function serializeAdminPromoCode(id: string, data: Record<string, unknown>) {
  const codeType = normalizePromoCodeType(data.codeType);

  return {
    code: normalizePromoCode(data.code) || normalizePromoCode(id),
    codeType,
    discountPercent: readPromoDiscountPercent(data.discountPercent, codeType),
    minimumSpendCents: normalizeInteger(data.minimumSpendCents),
    status: typeof data.status === "string" && data.status ? data.status : "active",
    usageLimit: normalizeInteger(data.usageLimit),
    usedCount: normalizeInteger(data.usedCount),
    createdAt: serializeTimestamp(data.createdAt),
    updatedAt: serializeTimestamp(data.updatedAt),
  };
}

function normalizePromoCode(value: unknown) {
  return String(value || "")
    .trim()
    .replace(/[^a-zA-Z0-9_-]/g, "")
    .slice(0, 80)
    .toUpperCase();
}

function normalizePromoCodeType(value: unknown): AdminPromoCodeType {
  return value === "bogo" ? "bogo" : "discount";
}

function normalizePromoDiscountPercent(value: unknown, codeType: AdminPromoCodeType) {
  if (codeType === "bogo") {
    return 0;
  }

  return normalizeDiscountPercent(value);
}

function normalizeDiscountPercent(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  if (!Number.isFinite(number) || number <= 0 || number > 100) {
    throw new ApiRequestError(400, "Discount percent must be between 1 and 100.");
  }

  return Math.round(number * 100) / 100;
}

function readPromoDiscountPercent(value: unknown, codeType: AdminPromoCodeType) {
  if (codeType === "bogo") {
    return 0;
  }

  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isFinite(number) && number > 0 && number <= 100
    ? Math.round(number * 100) / 100
    : 30;
}

function normalizeInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isInteger(number) && number >= 0 ? number : 0;
}

function normalizeMinimumSpendCents(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  if (!Number.isFinite(number) || number <= 0) {
    return 0;
  }

  if (!Number.isInteger(number)) {
    throw new ApiRequestError(400, "Minimum basket size must be a whole cent amount.");
  }

  return Math.min(number, 1_000_000_00);
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
