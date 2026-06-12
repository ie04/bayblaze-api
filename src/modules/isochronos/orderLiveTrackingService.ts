import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { calculateRoute } from "./googleMapsService";

const driverLocationMaxAgeMs = 5 * 60 * 1000;

type LiveTrackingInput = {
  customerAddress?: unknown;
  destination?: unknown;
  driverUid?: unknown;
  orderId?: unknown;
  orderReference?: unknown;
};

export async function getOrderLiveTracking(input: LiveTrackingInput) {
  const db = getBayblazeFirestore();
  const orderId = readString(input.orderId);
  const orderReference = readString(input.orderReference) || orderId;
  const resolvedDriverUid =
    readString(input.driverUid) || await resolveDriverUidForOrder(orderId, orderReference);
  const driverLocation = await readDriverLocation(resolvedDriverUid);
  const customerLocation = readCustomerLocation(input.destination, readString(input.customerAddress));
  const route =
    driverLocation && !driverLocation.isStale && customerLocation
      ? await calculateLiveRoute(driverLocation, customerLocation)
      : null;

  return {
    tracking: {
      customerLocation,
      driverLocation,
      driverUid: resolvedDriverUid || null,
      orderId,
      orderReference,
      refreshedAt: new Date().toISOString(),
      route,
      status: getTrackingStatus(resolvedDriverUid, driverLocation, customerLocation, route),
    },
  };

  async function resolveDriverUidForOrder(targetOrderId: string, targetOrderReference: string) {
    const orderKeys = new Set([targetOrderId, targetOrderReference].map(normalizeTrackingKey).filter(Boolean));
    if (orderKeys.size === 0) return "";

    const queues = await db.collection("driver_delivery_queues").get();

    for (const queueDoc of queues.docs) {
      const queue = queueDoc.data() ?? {};
      const queueIdentifiers = collectIdentifierValues(queue, [
        "activeOrderId",
        "active_order_id",
        "activeOrderReference",
        "active_order_reference",
        "activeMedusaOrderId",
        "active_medusa_order_id",
      ]);

      if (hasMatchingIdentifier(queueIdentifiers, orderKeys)) {
        return readString(queue.uid) || queueDoc.id;
      }

      const stops = Array.isArray(queue.stops) ? queue.stops : [];
      const hasOrder = stops.some((stop) => {
        const stopRecord = readRecord(stop);
        const stopIdentifiers = collectIdentifierValues(stopRecord, [
          "orderId",
          "order_id",
          "orderReference",
          "order_reference",
          "medusaOrderId",
          "medusa_order_id",
          "custom_display_id",
          "display_id",
          "id",
        ]);

        return hasMatchingIdentifier(stopIdentifiers, orderKeys);
      });

      if (hasOrder) {
        return readString(queue.uid) || queueDoc.id;
      }
    }

    return "";
  }
}

async function readDriverLocation(driverUid: string) {
  if (!driverUid) {
    return null;
  }

  const snapshot = await getBayblazeFirestore()
    .collection("driver_location_snapshots")
    .doc(driverUid)
    .get();

  if (!snapshot.exists) {
    return null;
  }

  const data = snapshot.data() ?? {};
  const lat = readNumber(data.lat);
  const lng = readNumber(data.lng);

  if (lat === null || lng === null) {
    return null;
  }

  const updatedAtMillis =
    data.updatedAt?.toMillis?.() ??
    readNumber(data.clientCapturedAt) ??
    null;
  const updatedAt = updatedAtMillis ? new Date(updatedAtMillis).toISOString() : null;
  const ageMs = updatedAtMillis ? Date.now() - updatedAtMillis : Number.POSITIVE_INFINITY;

  return {
    accuracy: readNumber(data.accuracy),
    ageSeconds: Number.isFinite(ageMs) ? Math.max(0, Math.round(ageMs / 1000)) : null,
    clientCapturedAt: readNumber(data.clientCapturedAt),
    heading: readNumber(data.heading),
    isStale: !Number.isFinite(ageMs) || ageMs > driverLocationMaxAgeMs,
    lat,
    lng,
    source: readString(data.source) || "driver-pwa",
    speed: readNumber(data.speed),
    uid: driverUid,
    updatedAt,
    vehicleId: readString(data.vehicleId),
  };
}

async function calculateLiveRoute(
  driverLocation: { lat: number; lng: number },
  customerLocation: { lat: number; lng: number },
) {
  const origin = { lat: driverLocation.lat, lng: driverLocation.lng };
  const destination = { lat: customerLocation.lat, lng: customerLocation.lng };

  try {
    return await calculateRoute(origin, destination, {
      includePolyline: true,
      includeTravelAdvisory: true,
      mode: "LIVE_DELIVERY_ETA",
      useTrafficAware: true,
    });
  } catch {
    return calculateRoute(origin, destination, {
      includePolyline: true,
      mode: "BASIC_ROUTE",
      useTrafficAware: false,
    }).catch(() => null);
  }
}

function readCustomerLocation(destination: unknown, customerAddress: string) {
  const record = readRecord(destination);
  const lat = readNumber(record.lat ?? record.latitude);
  const lng = readNumber(record.lng ?? record.longitude);

  if (lat === null || lng === null) {
    return null;
  }

  return {
    address: customerAddress || readString(record.address),
    lat,
    lng,
  };
}

function getTrackingStatus(
  driverUid: string,
  driverLocation: { isStale?: boolean } | null,
  customerLocation: unknown,
  route: unknown,
) {
  if (!customerLocation) return "missing_customer_location";
  if (!driverUid) return "awaiting_assignment";
  if (!driverLocation) return "awaiting_driver_location";
  if (driverLocation.isStale) return "stale_driver_location";
  if (!route) return "driver_location_only";
  return "en_route";
}

function collectIdentifierValues(record: Record<string, unknown>, fields: string[]) {
  return fields.map((field) => record[field]).filter((value) => value !== undefined && value !== null);
}

function hasMatchingIdentifier(values: unknown[], orderKeys: Set<string>) {
  return values.some((value) => orderKeys.has(normalizeTrackingKey(value)));
}

function normalizeTrackingKey(value: unknown) {
  if (typeof value === "number") return String(value).toLowerCase();
  if (typeof value === "string" && value.trim()) return value.trim().toLowerCase();
  return "";
}

function readRecord(value: unknown) {
  return typeof value === "object" && value !== null ? value as Record<string, unknown> : {};
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function readNumber(value: unknown) {
  const number = typeof value === "number" ? value : Number(value);
  return Number.isFinite(number) ? number : null;
}
