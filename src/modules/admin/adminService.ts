import { createHash } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { forwardAdminOrderDetailRequest, forwardAdminOrdersRequest } from "../../clients/medusaAdminClient";
import { sendUpstreamJson } from "../../http/upstream";
import { searchAccounts, updateAccountAccess } from "../accounts/accountService";
import type { AccountBadge, AccountRole } from "../accounts/accountTypes";
import type { DriverDeliveryQueue, DriverLocationSnapshot, DriverProfile, VehicleRecord } from "../drivers/driverWorkflowTypes";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { calculateRouteDuration, geocodeAddress, type LatLng } from "../isochronos/googleMapsService";
import type { Response as ExpressResponse } from "express";

const isochroneCacheCollection = "coverage_isochrones";
const discountCodesCollection = "customer_discount_codes";
const adminPromoCodeCategory = "admin_promo";
const isochroneCacheTtlMs = 6 * 60 * 60 * 1000;
const isochroneSampleBearings = 24;
const isochroneBinarySearchIterations = 5;
const isochroneAlgorithmVersion = "route_round_trip_radial_v1";

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

export async function createAdminPromoCode(input: {
  code: string;
  discountPercent: number;
}) {
  const code = normalizePromoCode(input.code);

  if (!code) {
    throw new ApiRequestError(400, "Promo code is required.");
  }

  const discountPercent = normalizeDiscountPercent(input.discountPercent);
  const ref = getBayblazeFirestore().collection(discountCodesCollection).doc(code);
  const existing = await ref.get();

  if (existing.exists) {
    throw new ApiRequestError(409, "That promo code already exists.");
  }

  const record = {
    category: adminPromoCodeCategory,
    code,
    codeType: "discount",
    discountPercent,
    minimumSpendCents: 0,
    status: "active",
    usageLimit: 1000000,
    usedCount: 0,
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
  input: {
    code?: string;
    discountPercent?: number;
  },
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

    const nextData = {
      ...currentData,
      code: nextCode,
      discountPercent:
        input.discountPercent === undefined
          ? normalizeDiscountPercent(currentData.discountPercent)
          : normalizeDiscountPercent(input.discountPercent),
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

export async function createAdminIsochronePlot(input: {
  force?: boolean;
  origin: { address?: string; lat?: number; lng?: number };
  speedMph?: number;
  travelMinutes: number;
}) {
  const origin = await resolveOrigin(input.origin);
  const travelMinutes = clamp(input.travelMinutes, 1, 180);
  const speedMph = clamp(input.speedMph ?? 30, 5, 70);
  const cacheKey = createIsochroneCacheKey(origin, speedMph, travelMinutes);
  const cached = input.force ? null : await getCachedIsochronePlot(cacheKey);

  if (cached) {
    return cached;
  }

  const maxOutboundMeters = speedMph * 1609.344 * (travelMinutes / 120);
  const boundary = await mapWithConcurrency(
    Array.from({ length: isochroneSampleBearings }, (_, index) => (360 / isochroneSampleBearings) * index),
    4,
    (bearing) => findRoundTripBoundaryPoint(origin, bearing, maxOutboundMeters, travelMinutes),
  );
  const polygon = closePolygon(boundary.filter(Boolean) as LatLng[]);
  const radiusMeters = Math.max(...polygon.map((point) => distanceMeters(origin, point)), 0);
  const plot = {
    center: origin,
    method: isochroneAlgorithmVersion,
    polygon,
    radiusMeters: Math.round(radiusMeters),
    speedMph,
    travelMinutes,
  };

  await storeCachedIsochronePlot(cacheKey, plot);

  return plot;
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

async function resolveOrigin(origin: { address?: string; lat?: number; lng?: number }): Promise<LatLng & { address?: string }> {
  if (Number.isFinite(origin.lat) && Number.isFinite(origin.lng)) {
    return {
      address: origin.address?.trim() || undefined,
      lat: origin.lat as number,
      lng: origin.lng as number,
    };
  }

  if (!origin.address?.trim()) {
    throw new ApiRequestError(400, "Isochrone origin requires an address or lat/lng.");
  }

  const geocode = await geocodeAddress(origin.address);
  return {
    address: origin.address.trim(),
    lat: geocode.lat,
    lng: geocode.lng,
  };
}

async function findRoundTripBoundaryPoint(origin: LatLng, bearingDegrees: number, maxMeters: number, maxMinutes: number) {
  let accepted = origin;
  let lowMeters = 0;
  let highMeters = maxMeters;

  for (let index = 0; index < isochroneBinarySearchIterations; index += 1) {
    const candidateMeters = (lowMeters + highMeters) / 2;
    const candidate = destinationPoint(origin, bearingDegrees, candidateMeters);
    const durationMinutes = await calculateRoundTripMinutes(origin, candidate).catch(() => Number.POSITIVE_INFINITY);

    if (durationMinutes <= maxMinutes) {
      accepted = candidate;
      lowMeters = candidateMeters;
    } else {
      highMeters = candidateMeters;
    }
  }

  return accepted;
}

async function calculateRoundTripMinutes(origin: LatLng, destination: LatLng) {
  const [outbound, inbound] = await Promise.all([
    calculateRouteDuration([origin, destination]),
    calculateRouteDuration([destination, origin]),
  ]);

  return (outbound.durationSeconds + inbound.durationSeconds) / 60;
}

function destinationPoint(center: LatLng, bearingDegrees: number, distanceMeters: number) {
  const earthRadiusMeters = 6_371_000;
  const latRadians = toRadians(center.lat);
  const lngRadians = toRadians(center.lng);
  const bearing = toRadians(bearingDegrees);
  const angularDistance = distanceMeters / earthRadiusMeters;
  const lat = Math.asin(
    Math.sin(latRadians) * Math.cos(angularDistance) +
      Math.cos(latRadians) * Math.sin(angularDistance) * Math.cos(bearing),
  );
  const lng =
    lngRadians +
    Math.atan2(
      Math.sin(bearing) * Math.sin(angularDistance) * Math.cos(latRadians),
      Math.cos(angularDistance) - Math.sin(latRadians) * Math.sin(lat),
    );

  return {
    lat: toDegrees(lat),
    lng: toDegrees(lng),
  };
}

function distanceMeters(origin: LatLng, destination: LatLng) {
  const earthRadiusMeters = 6_371_000;
  const latDelta = toRadians(destination.lat - origin.lat);
  const lngDelta = toRadians(destination.lng - origin.lng);
  const originLat = toRadians(origin.lat);
  const destinationLat = toRadians(destination.lat);
  const a =
    Math.sin(latDelta / 2) ** 2 +
    Math.cos(originLat) * Math.cos(destinationLat) * Math.sin(lngDelta / 2) ** 2;

  return 2 * earthRadiusMeters * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function closePolygon(points: LatLng[]) {
  if (points.length === 0) {
    return [];
  }

  const first = points[0];
  const last = points[points.length - 1];

  if (first.lat === last.lat && first.lng === last.lng) {
    return points;
  }

  return [...points, first];
}

async function getCachedIsochronePlot(cacheKey: string) {
  const snapshot = await getBayblazeFirestore().collection(isochroneCacheCollection).doc(cacheKey).get();

  if (!snapshot.exists) {
    return null;
  }

  const data = snapshot.data() ?? {};
  const expiresAtMillis = data.expiresAt?.toMillis?.() ?? 0;

  if (expiresAtMillis < Date.now() || !Array.isArray(data.polygon)) {
    return null;
  }

  return {
    center: data.center as LatLng & { address?: string },
    method: String(data.method || isochroneAlgorithmVersion),
    polygon: data.polygon as LatLng[],
    radiusMeters: Number(data.radiusMeters) || 0,
    speedMph: Number(data.speedMph) || 0,
    travelMinutes: Number(data.travelMinutes) || 0,
  };
}

async function storeCachedIsochronePlot(cacheKey: string, plot: {
  center: LatLng & { address?: string };
  method: string;
  polygon: LatLng[];
  radiusMeters: number;
  speedMph: number;
  travelMinutes: number;
}) {
  await getBayblazeFirestore().collection(isochroneCacheCollection).doc(cacheKey).set({
    ...plot,
    algorithmVersion: isochroneAlgorithmVersion,
    expiresAt: new Date(Date.now() + isochroneCacheTtlMs),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

function createIsochroneCacheKey(origin: LatLng, speedMph: number, travelMinutes: number) {
  return createHash("sha256")
    .update([
      isochroneAlgorithmVersion,
      origin.lat.toFixed(6),
      origin.lng.toFixed(6),
      String(speedMph),
      String(travelMinutes),
      String(isochroneSampleBearings),
      String(isochroneBinarySearchIterations),
    ].join(":"))
    .digest("hex");
}

async function mapWithConcurrency<T, R>(
  items: T[],
  concurrency: number,
  mapper: (item: T) => Promise<R>,
) {
  const results: R[] = [];
  let nextIndex = 0;

  async function worker() {
    while (nextIndex < items.length) {
      const index = nextIndex;
      nextIndex += 1;
      results[index] = await mapper(items[index]);
    }
  }

  await Promise.all(Array.from({ length: Math.min(concurrency, items.length) }, () => worker()));
  return results;
}

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function toRadians(value: number) {
  return (value * Math.PI) / 180;
}

function toDegrees(value: number) {
  return (value * 180) / Math.PI;
}

function serializeAdminPromoCode(id: string, data: Record<string, unknown>) {
  return {
    code: normalizePromoCode(data.code) || normalizePromoCode(id),
    discountPercent: normalizeDiscountPercent(data.discountPercent),
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

function normalizeDiscountPercent(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  if (!Number.isFinite(number) || number <= 0 || number > 100) {
    throw new ApiRequestError(400, "Discount percent must be between 1 and 100.");
  }

  return Math.round(number * 100) / 100;
}

function normalizeInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isInteger(number) && number >= 0 ? number : 0;
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
