import { FieldValue } from "firebase-admin/firestore";
import { createHash } from "node:crypto";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";

const geocodingEndpoint = "https://maps.googleapis.com/maps/api/geocode/json";
const routesEndpoint = "https://routes.googleapis.com/directions/v2:computeRoutes";
const geocodeCacheCollection = "geocode_cache";
const geocodeCacheTtlMs = 30 * 24 * 60 * 60 * 1000;

export type LatLng = {
  lat: number;
  lng: number;
};

export type RouteMode = "BASIC_ROUTE" | "LIVE_DELIVERY_ETA";

export type CalculatedRoute = {
  calculatedAt: string;
  destination: LatLng;
  distanceMeters: number | null;
  duration: string | null;
  durationSeconds: number | null;
  encodedPolyline?: string | null;
  origin: LatLng;
};

type CachedGeocode = LatLng & {
  placeId?: string | null;
  source?: string;
};

export async function geocodeAddress(address: string) {
  const normalizedAddress = normalizeAddress(address);

  if (!normalizedAddress) {
    throw new IsochronosRequestError(400, "A non-empty address is required.");
  }

  const cached = await getCachedGeocode(normalizedAddress);
  if (cached) {
    return { ...cached, cacheHit: true };
  }

  const apiKey = requireGoogleMapsApiKey();
  const url = new URL(geocodingEndpoint);
  url.searchParams.set("address", normalizedAddress);
  url.searchParams.set("key", apiKey);

  const response = await fetch(url);
  const payload = (await response.json().catch(() => ({}))) as {
    error_message?: string;
    results?: Array<{
      geometry?: { location?: { lat?: number; lng?: number } };
      place_id?: string;
    }>;
    status?: string;
  };
  const result = payload.results?.[0];
  const location = result?.geometry?.location;

  if (!response.ok || payload.status !== "OK" || !isLatLng(location)) {
    throw new IsochronosRequestError(
      502,
      payload.error_message || "Google Geocoding API did not return a usable result.",
    );
  }

  const geocode = {
    lat: location.lat,
    lng: location.lng,
    placeId: result?.place_id ?? null,
    source: "google_geocoding",
  };

  await storeCachedGeocode(normalizedAddress, geocode);
  await logApiUsage("google_maps", "geocoding", {
    normalizedAddressHash: hashValue(normalizedAddress),
  });

  return { ...geocode, cacheHit: false };
}

export async function calculateRoute(
  origin: LatLng,
  destination: LatLng,
  options: {
    includePolyline?: boolean;
    includeTravelAdvisory?: boolean;
    mode?: RouteMode;
    useTrafficAware?: boolean;
  } = {},
): Promise<CalculatedRoute> {
  if (!isLatLng(origin) || !isLatLng(destination)) {
    throw new IsochronosRequestError(400, "Route origin and destination must include numeric lat/lng.");
  }

  const apiKey = requireGoogleMapsApiKey();
  const useTrafficAware = options.mode === "LIVE_DELIVERY_ETA" && options.useTrafficAware === true;
  const fieldMask = buildRouteFieldMask(options);
  const body: Record<string, unknown> = {
    computeAlternativeRoutes: false,
    destination: { location: { latLng: toGoogleLatLng(destination) } },
    origin: { location: { latLng: toGoogleLatLng(origin) } },
    travelMode: "DRIVE",
    units: "IMPERIAL",
  };

  if (useTrafficAware) {
    body.routingPreference = "TRAFFIC_AWARE";
  }

  const response = await fetch(routesEndpoint, {
    body: JSON.stringify(body),
    headers: {
      "content-type": "application/json",
      "x-goog-api-key": apiKey,
      "x-goog-fieldmask": fieldMask,
    },
    method: "POST",
  });
  const payload = (await response.json().catch(() => ({}))) as {
    error?: { message?: string };
    routes?: Array<{
      distanceMeters?: number;
      duration?: string;
      polyline?: { encodedPolyline?: string };
    }>;
  };
  const route = payload.routes?.[0];

  if (!response.ok || !route) {
    throw new IsochronosRequestError(
      502,
      payload.error?.message || "Google Routes API did not return a usable route.",
    );
  }

  await logApiUsage("google_maps", useTrafficAware ? "traffic_aware_route" : "route", {
    fieldMask,
  });

  return {
    calculatedAt: new Date().toISOString(),
    destination,
    distanceMeters: readFiniteNumber(route.distanceMeters),
    duration: route.duration ?? null,
    durationSeconds: parseDurationSeconds(route.duration),
    encodedPolyline: route.polyline?.encodedPolyline ?? null,
    origin,
  };
}

export async function calculateRouteDuration(stops: LatLng[]) {
  if (stops.length < 2) {
    throw new IsochronosRequestError(400, "At least two route stops are required.");
  }

  let distanceMeters = 0;
  let durationSeconds = 0;

  for (let index = 0; index < stops.length - 1; index += 1) {
    const leg = await calculateRoute(stops[index], stops[index + 1], {
      mode: "BASIC_ROUTE",
      useTrafficAware: false,
    });
    distanceMeters += leg.distanceMeters ?? 0;
    durationSeconds += leg.durationSeconds ?? 0;
  }

  return {
    distanceMeters,
    durationMinutes: Math.round(durationSeconds / 60),
    durationSeconds,
  };
}

export class IsochronosRequestError extends Error {
  constructor(
    public readonly status: number,
    message: string,
  ) {
    super(message);
  }
}

async function getCachedGeocode(normalizedAddress: string): Promise<CachedGeocode | null> {
  const snapshot = await getBayblazeFirestore()
    .collection(geocodeCacheCollection)
    .doc(hashValue(normalizedAddress))
    .get();

  if (!snapshot.exists) {
    return null;
  }

  const data = snapshot.data() ?? {};
  const expiresAtMillis = data.expiresAt?.toMillis?.() ?? 0;
  const latLng = readLatLng(data);

  if (!latLng || expiresAtMillis < Date.now()) {
    return null;
  }

  return {
    ...latLng,
    placeId: typeof data.placeId === "string" ? data.placeId : null,
    source: typeof data.source === "string" ? data.source : "geocode_cache",
  };
}

async function storeCachedGeocode(normalizedAddress: string, geocode: CachedGeocode) {
  await getBayblazeFirestore()
    .collection(geocodeCacheCollection)
    .doc(hashValue(normalizedAddress))
    .set(
      {
        address: normalizedAddress,
        expiresAt: new Date(Date.now() + geocodeCacheTtlMs),
        lat: geocode.lat,
        lng: geocode.lng,
        placeId: geocode.placeId ?? null,
        source: geocode.source ?? "google_geocoding",
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
}

async function logApiUsage(service: string, requestType: string, metadata: Record<string, unknown>) {
  await getBayblazeFirestore()
    .collection("api_usage_events")
    .add({
      createdAt: FieldValue.serverTimestamp(),
      metadata,
      requestType,
      service,
    })
    .catch(() => undefined);
}

function requireGoogleMapsApiKey() {
  if (!env.GOOGLE_MAPS_API_KEY) {
    throw new IsochronosRequestError(503, "GOOGLE_MAPS_API_KEY is required for routing.");
  }

  return env.GOOGLE_MAPS_API_KEY;
}

function buildRouteFieldMask(options: { includePolyline?: boolean; includeTravelAdvisory?: boolean }) {
  const fields = new Set(["routes.duration", "routes.distanceMeters"]);

  if (options.includePolyline) fields.add("routes.polyline");
  if (options.includeTravelAdvisory) fields.add("routes.travelAdvisory");

  return [...fields].join(",");
}

function normalizeAddress(address: string) {
  return address.trim().replace(/\s+/g, " ");
}

function hashValue(value: string) {
  return createHash("sha256").update(value.toLowerCase()).digest("hex");
}

function isLatLng(value: unknown): value is LatLng {
  return (
    typeof value === "object" &&
    value !== null &&
    Number.isFinite((value as LatLng).lat) &&
    Number.isFinite((value as LatLng).lng)
  );
}

function readLatLng(value: unknown) {
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

function toGoogleLatLng(value: LatLng) {
  return {
    latitude: value.lat,
    longitude: value.lng,
  };
}

function parseDurationSeconds(duration: unknown) {
  if (typeof duration === "number") return duration;
  if (typeof duration === "string" && duration.endsWith("s")) {
    const seconds = Number(duration.slice(0, -1));
    return Number.isFinite(seconds) ? seconds : null;
  }

  return null;
}
