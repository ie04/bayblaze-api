import type { DriverDeliveryQueue, DriverDeliveryStop } from "../drivers/driverWorkflowTypes";
import { lockQueueHead } from "../drivers/driverQueueNormalizer";

const earthRadiusMeters = 6_371_000;

type LatLng = {
  lat: number;
  lng: number;
};

export async function scoreDriverDeliveryQueue(queue: DriverDeliveryQueue) {
  if (queue.stops.length <= 2) {
    return {
      ...queue,
      activeOrderId: queue.stops[0]?.orderId ?? queue.activeOrderId,
      stops: lockQueueHead(queue.stops),
    };
  }

  const lockedStops = queue.stops.slice(0, 2);
  const reorderableStops = queue.stops.slice(2);
  const orderedTail: DriverDeliveryStop[] = [];
  let cursor = readStopLocation(lockedStops[1]) ?? readStopLocation(lockedStops[0]);
  const remaining = reorderableStops.map((stop, originalIndex) => ({
    originalIndex,
    stop,
    location: readStopLocation(stop),
  }));

  while (remaining.length > 0) {
    const selected = remaining
      .map((candidate) => ({
        ...candidate,
        legDistanceMeters: distanceMeters(cursor, candidate.location),
      }))
      .sort((left, right) => {
        if (left.legDistanceMeters !== right.legDistanceMeters) {
          return left.legDistanceMeters - right.legDistanceMeters;
        }

        return left.originalIndex - right.originalIndex;
      })[0];

    const selectedIndex = remaining.findIndex(
      (candidate) => candidate.originalIndex === selected.originalIndex,
    );
    remaining.splice(selectedIndex, 1);
    cursor = selected.location ?? cursor;
    orderedTail.push({
      ...selected.stop,
      score: Number.isFinite(selected.legDistanceMeters)
        ? Math.round(selected.legDistanceMeters)
        : selected.stop.score,
    });
  }

  const stops = lockQueueHead([...lockedStops, ...orderedTail]);
  return {
    ...queue,
    activeOrderId: stops[0]?.orderId ?? queue.activeOrderId,
    stops,
  };
}

function readStopLocation(stop?: DriverDeliveryStop): LatLng | null {
  const record = stop as (DriverDeliveryStop & {
    location?: unknown;
    coordinates?: unknown;
    destination?: unknown;
  }) | undefined;

  return readLocation(record?.location) ?? readLocation(record?.coordinates) ?? readLocation(record?.destination);
}

function readLocation(value: unknown): LatLng | null {
  if (typeof value !== "object" || value === null) {
    return null;
  }

  const record = value as { lat?: unknown; latitude?: unknown; lng?: unknown; longitude?: unknown };
  const lat = readFiniteNumber(record.lat ?? record.latitude);
  const lng = readFiniteNumber(record.lng ?? record.longitude);

  return lat === null || lng === null ? null : { lat, lng };
}

function readFiniteNumber(value: unknown) {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

function distanceMeters(origin: LatLng | null, destination: LatLng | null) {
  if (!origin || !destination) {
    return Number.POSITIVE_INFINITY;
  }

  const latDelta = toRadians(destination.lat - origin.lat);
  const lngDelta = toRadians(destination.lng - origin.lng);
  const originLat = toRadians(origin.lat);
  const destinationLat = toRadians(destination.lat);
  const haversine =
    Math.sin(latDelta / 2) ** 2 +
    Math.cos(originLat) *
      Math.cos(destinationLat) *
      Math.sin(lngDelta / 2) ** 2;

  return 2 * earthRadiusMeters * Math.atan2(Math.sqrt(haversine), Math.sqrt(1 - haversine));
}

function toRadians(degrees: number) {
  return degrees * (Math.PI / 180);
}
