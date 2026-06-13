import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { forwardAdminOrderDetailRequest, forwardAdminOrdersRequest } from "../../clients/medusaAdminClient";
import { sendUpstreamJson } from "../../http/upstream";
import { searchAccounts, updateAccountAccess } from "../accounts/accountService";
import type { AccountBadge, AccountRole } from "../accounts/accountTypes";
import type { DriverDeliveryQueue, DriverLocationSnapshot, DriverProfile, VehicleRecord } from "../drivers/driverWorkflowTypes";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { geocodeAddress, type LatLng } from "../isochronos/googleMapsService";
import type { Response as ExpressResponse } from "express";

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
  origin: { address?: string; lat?: number; lng?: number };
  speedMph?: number;
  travelMinutes: number;
}) {
  const origin = await resolveOrigin(input.origin);
  const travelMinutes = clamp(input.travelMinutes, 1, 180);
  const speedMph = clamp(input.speedMph ?? 30, 5, 70);
  const radiusMeters = speedMph * 1609.344 * (travelMinutes / 60);

  return {
    center: origin,
    method: "estimated_drive_radius",
    polygon: createCirclePolygon(origin, radiusMeters, 72),
    radiusMeters: Math.round(radiusMeters),
    speedMph,
    travelMinutes,
  };
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

function createCirclePolygon(center: LatLng, radiusMeters: number, points: number) {
  const earthRadiusMeters = 6_371_000;
  const latRadians = toRadians(center.lat);
  const lngRadians = toRadians(center.lng);
  const angularDistance = radiusMeters / earthRadiusMeters;

  return Array.from({ length: points + 1 }, (_, index) => {
    const bearing = (2 * Math.PI * index) / points;
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
  });
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
