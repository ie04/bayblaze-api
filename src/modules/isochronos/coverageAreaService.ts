import { createHash } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { calculateRouteDuration, geocodeAddress, type LatLng } from "./googleMapsService";

const coverageAreasCollection = "coverage_areas";
const isochroneCacheCollection = "coverage_isochrones";
const isochroneCacheTtlMs = 6 * 60 * 60 * 1000;
const coverageAlgorithmVersion = "bidirectional_route_isochrone_v1";
const coverageSearchSpeedMph = 30;

const defaultCoverageAreaId = "wh1";
const defaultCoverageArea = {
  active: true,
  description: "Default BayBlaze warehouse delivery coverage area.",
  label: "WH1 Coverage",
  maxDriveTimeMinutes: 30,
  warehouse: {
    address: "13702 42nd St Tampa, FL, 33613",
    label: "BayBlaze Warehouse 1",
    warehouseId: "WH1",
  },
};

export type CoverageAreaSchedule = {
  enabled: boolean;
  intervalHours: number | null;
  nextRunAt: string | null;
};

export type CoverageArea = {
  active: boolean;
  algorithmVersion: string;
  createdAt: string;
  description: string;
  granularity: {
    binarySearchIterations: number;
    sampleBearings: number;
  };
  id: string;
  label: string;
  lastGeneratedAt: string;
  lastGenerationError: string;
  maxDriveTimeMinutes: number;
  polygon: LatLng[];
  radiusMeters: number;
  schedule: CoverageAreaSchedule;
  updatedAt: string;
  warehouse: CoverageWarehouse;
};

export type CoverageWarehouse = {
  address: string;
  label: string;
  location: LatLng;
  warehouseId: string;
};

export type CoverageAreaInput = {
  active?: boolean;
  description?: string;
  granularity?: {
    binarySearchIterations?: number;
    sampleBearings?: number;
  };
  label?: string;
  maxDriveTimeMinutes?: number;
  schedule?: {
    enabled?: boolean;
    intervalHours?: number | null;
    nextRunAt?: string | null;
  };
  warehouse?: {
    address?: string;
    label?: string;
    lat?: number;
    lng?: number;
    warehouseId?: string;
  };
};

export async function listCoverageAreas() {
  await ensureDefaultCoverageArea();
  const snapshot = await getBayblazeFirestore().collection(coverageAreasCollection).get();
  const coverageAreas = snapshot.docs
    .map((doc) => serializeCoverageArea(doc.id, doc.data()))
    .sort((left, right) => left.label.localeCompare(right.label));

  return { coverageAreas };
}

export async function createCoverageArea(input: CoverageAreaInput) {
  const base = await normalizeCoverageAreaInput(input);
  const ref = getBayblazeFirestore().collection(coverageAreasCollection).doc();
  const generated = await generateCoveragePolygon(base);
  const now = new Date();
  const record = {
    ...base,
    ...generated,
    algorithmVersion: coverageAlgorithmVersion,
    createdAt: FieldValue.serverTimestamp(),
    lastGeneratedAt: now,
    lastGenerationError: "",
    schedule: {
      ...base.schedule,
      nextRunAt: calculateNextRunAt(base.schedule, now),
    },
    updatedAt: FieldValue.serverTimestamp(),
  };

  await ref.set(record);

  return {
    coverageArea: serializeCoverageArea(ref.id, {
      ...record,
      createdAt: now,
      updatedAt: now,
    }),
  };
}

export async function updateCoverageArea(id: string, input: CoverageAreaInput & { regenerate?: boolean }) {
  const ref = getBayblazeFirestore().collection(coverageAreasCollection).doc(normalizeCoverageAreaId(id));
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "Coverage area not found.");
  }

  const current = serializeCoverageArea(snapshot.id, snapshot.data() ?? {});
  const nextBase = await normalizeCoverageAreaInput(input, current);
  const rulesChanged = didCoverageRulesChange(current, nextBase);
  const shouldRegenerate = input.regenerate === true || rulesChanged;
  const now = new Date();
  const generated = shouldRegenerate
    ? await generateCoveragePolygon(nextBase).then((plot) => ({
        ...plot,
        algorithmVersion: coverageAlgorithmVersion,
        lastGeneratedAt: now,
        lastGenerationError: "",
      }))
    : {};
  const nextRecord = {
    ...nextBase,
    ...generated,
    schedule: {
      ...nextBase.schedule,
      nextRunAt: shouldRegenerate ? calculateNextRunAt(nextBase.schedule, now) : nextBase.schedule.nextRunAt,
    },
    updatedAt: FieldValue.serverTimestamp(),
  };

  await ref.set(nextRecord, { merge: true });

  return {
    coverageArea: serializeCoverageArea(snapshot.id, {
      ...current,
      ...nextRecord,
      updatedAt: now,
    }),
  };
}

export async function deleteCoverageArea(id: string) {
  const ref = getBayblazeFirestore().collection(coverageAreasCollection).doc(normalizeCoverageAreaId(id));
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "Coverage area not found.");
  }

  await ref.delete();
  return { ok: true };
}

export async function regenerateCoverageArea(id: string) {
  const ref = getBayblazeFirestore().collection(coverageAreasCollection).doc(normalizeCoverageAreaId(id));
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "Coverage area not found.");
  }

  const coverageArea = serializeCoverageArea(snapshot.id, snapshot.data() ?? {});
  const now = new Date();
  const generated = await generateCoveragePolygon(coverageArea);
  const update = {
    ...generated,
    algorithmVersion: coverageAlgorithmVersion,
    lastGeneratedAt: now,
    lastGenerationError: "",
    schedule: {
      ...coverageArea.schedule,
      nextRunAt: calculateNextRunAt(coverageArea.schedule, now),
    },
    updatedAt: FieldValue.serverTimestamp(),
  };

  await ref.set(update, { merge: true });

  return {
    coverageArea: serializeCoverageArea(snapshot.id, {
      ...coverageArea,
      ...update,
      updatedAt: now,
    }),
  };
}

export async function regenerateDueCoverageAreas() {
  const { coverageAreas } = await listCoverageAreas();
  const now = Date.now();
  const due = coverageAreas.filter((coverageArea) => {
    if (!coverageArea.active || !coverageArea.schedule.enabled || !coverageArea.schedule.nextRunAt) {
      return false;
    }

    return Date.parse(coverageArea.schedule.nextRunAt) <= now;
  });
  const regenerated = [];
  const failed = [];

  for (const coverageArea of due) {
    try {
      regenerated.push((await regenerateCoverageArea(coverageArea.id)).coverageArea);
    } catch (caught) {
      const message = caught instanceof Error ? caught.message : "Coverage regeneration failed.";
      failed.push({ id: coverageArea.id, message });
      await getBayblazeFirestore()
        .collection(coverageAreasCollection)
        .doc(coverageArea.id)
        .set(
          {
            lastGenerationError: message,
            updatedAt: FieldValue.serverTimestamp(),
          },
          { merge: true },
        );
    }
  }

  return { failed, regenerated };
}

export async function resolveCoverageAreaForDestination(destination: LatLng) {
  await ensureDefaultCoverageArea();
  const { coverageAreas } = await listCoverageAreas();
  const activeCoverageAreas = coverageAreas.filter((coverageArea) => coverageArea.active);
  const candidates = activeCoverageAreas.filter((coverageArea) => {
    if (coverageArea.polygon.length < 4) {
      return true;
    }

    return pointInPolygon(destination, coverageArea.polygon);
  });
  const resolutions = await Promise.all(
    candidates.map(async (coverageArea) => {
      const driveTime = await calculateBidirectionalDriveTime(coverageArea.warehouse.location, destination).catch(() => null);

      if (!driveTime) {
        return null;
      }

      if (
        driveTime.outboundSeconds > coverageArea.maxDriveTimeMinutes * 60 ||
        driveTime.inboundSeconds > coverageArea.maxDriveTimeMinutes * 60
      ) {
        return null;
      }

      return {
        coverageArea,
        driveTime,
      };
    }),
  );
  const accepted = resolutions
    .filter(Boolean)
    .sort((left, right) => {
      if (!left || !right) return 0;
      return left.driveTime.totalSeconds - right.driveTime.totalSeconds;
    })[0];

  if (!accepted) {
    return {
      accepted: false as const,
      activeCoverageAreaCount: activeCoverageAreas.length,
      coverageArea: null,
      driveTime: null,
    };
  }

  return {
    accepted: true as const,
    activeCoverageAreaCount: activeCoverageAreas.length,
    coverageArea: summarizeCoverageArea(accepted.coverageArea),
    driveTime: {
      inboundMinutes: Math.round(accepted.driveTime.inboundSeconds / 60),
      maxDriveTimeMinutes: accepted.coverageArea.maxDriveTimeMinutes,
      outboundMinutes: Math.round(accepted.driveTime.outboundSeconds / 60),
      totalMinutes: Math.round(accepted.driveTime.totalSeconds / 60),
    },
  };
}

export async function createStandaloneIsochronePlot(input: {
  force?: boolean;
  origin: { address?: string; lat?: number; lng?: number };
  travelMinutes: number;
}) {
  const origin = await resolveOrigin(input.origin);
  const base = {
    active: true,
    description: "",
    granularity: normalizeGranularity(),
    label: "Coverage preview",
    maxDriveTimeMinutes: clamp(input.travelMinutes / 2, 1, 180),
    schedule: normalizeSchedule(),
    warehouse: {
      address: origin.address || "",
      label: "Coverage preview origin",
      location: { lat: origin.lat, lng: origin.lng },
      warehouseId: "preview",
    },
  };
  const generated = await generateCoveragePolygon(base, input.force === true);

  return {
    center: {
      address: base.warehouse.address || undefined,
      ...base.warehouse.location,
    },
    method: coverageAlgorithmVersion,
    polygon: generated.polygon,
    radiusMeters: generated.radiusMeters,
    travelMinutes: Math.round(base.maxDriveTimeMinutes * 2),
  };
}

function summarizeCoverageArea(coverageArea: CoverageArea) {
  return {
    id: coverageArea.id,
    label: coverageArea.label,
    maxDriveTimeMinutes: coverageArea.maxDriveTimeMinutes,
    warehouse: coverageArea.warehouse,
  };
}

async function ensureDefaultCoverageArea() {
  const collection = getBayblazeFirestore().collection(coverageAreasCollection);
  const existing = await collection.limit(1).get();

  if (!existing.empty) {
    await backfillDefaultCoverageAreaPolygon();
    return;
  }

  const base = await normalizeCoverageAreaInput(defaultCoverageArea);
  const now = new Date();

  await collection.doc(defaultCoverageAreaId).set({
    ...base,
    algorithmVersion: coverageAlgorithmVersion,
    createdAt: FieldValue.serverTimestamp(),
    lastGeneratedAt: null,
    lastGenerationError: "",
    polygon: [],
    radiusMeters: 0,
    updatedAt: FieldValue.serverTimestamp(),
  });

  await collection.doc(defaultCoverageAreaId).set(
    {
      createdAtFallback: now.toISOString(),
      updatedAtFallback: now.toISOString(),
    },
    { merge: true },
  );

  await backfillDefaultCoverageAreaPolygon();
}

async function backfillDefaultCoverageAreaPolygon() {
  const ref = getBayblazeFirestore().collection(coverageAreasCollection).doc(defaultCoverageAreaId);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    return;
  }

  const coverageArea = serializeCoverageArea(snapshot.id, snapshot.data() ?? {});

  if (coverageArea.polygon.length > 0 || coverageArea.lastGeneratedAt) {
    return;
  }

  try {
    const now = new Date();
    const generated = await generateCoveragePolygon(coverageArea);

    await ref.set(
      {
        ...generated,
        algorithmVersion: coverageAlgorithmVersion,
        lastGeneratedAt: now,
        lastGenerationError: "",
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  } catch (caught) {
    await ref.set(
      {
        lastGenerationError: caught instanceof Error ? caught.message : "Coverage polygon generation failed.",
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }
}

async function normalizeCoverageAreaInput(input: CoverageAreaInput, current?: CoverageArea) {
  const label = normalizeText(input.label, current?.label || defaultCoverageArea.label);
  const warehouse = await normalizeWarehouse(input.warehouse, current?.warehouse);

  if (!label) {
    throw new ApiRequestError(400, "Coverage area label is required.");
  }

  return {
    active: input.active ?? current?.active ?? true,
    description: normalizeText(input.description, current?.description || ""),
    granularity: normalizeGranularity(input.granularity, current?.granularity),
    label,
    maxDriveTimeMinutes: clamp(input.maxDriveTimeMinutes ?? current?.maxDriveTimeMinutes ?? 30, 1, 180),
    schedule: normalizeSchedule(input.schedule, current?.schedule),
    warehouse,
  };
}

async function normalizeWarehouse(input?: CoverageAreaInput["warehouse"], current?: CoverageWarehouse): Promise<CoverageWarehouse> {
  const warehouseId = normalizeText(input?.warehouseId, current?.warehouseId || defaultCoverageArea.warehouse.warehouseId);
  const label = normalizeText(input?.label, current?.label || defaultCoverageArea.warehouse.label);
  const address = normalizeText(input?.address, current?.address || defaultCoverageArea.warehouse.address);
  const explicitLocation = readLatLng(input);
  const location = explicitLocation ?? current?.location ?? (address ? await geocodeAddress(address) : null);

  if (!warehouseId) {
    throw new ApiRequestError(400, "Coverage warehouse ID is required.");
  }

  if (!label) {
    throw new ApiRequestError(400, "Coverage warehouse label is required.");
  }

  if (!location) {
    throw new ApiRequestError(400, "Coverage warehouse requires an address or lat/lng.");
  }

  return {
    address,
    label,
    location: { lat: location.lat, lng: location.lng },
    warehouseId,
  };
}

function normalizeGranularity(input?: CoverageAreaInput["granularity"], current?: CoverageArea["granularity"]) {
  return {
    binarySearchIterations: Math.round(clamp(
      input?.binarySearchIterations ?? current?.binarySearchIterations ?? 5,
      3,
      10,
    )),
    sampleBearings: Math.round(clamp(input?.sampleBearings ?? current?.sampleBearings ?? 24, 8, 144)),
  };
}

function normalizeSchedule(input?: CoverageAreaInput["schedule"], current?: CoverageAreaSchedule): CoverageAreaSchedule {
  const enabled = input?.enabled ?? current?.enabled ?? false;
  const intervalHours = input?.intervalHours === null
    ? null
    : input?.intervalHours === undefined
      ? current?.intervalHours ?? null
      : Math.round(clamp(input.intervalHours, 1, 24 * 30));
  const nextRunAt = normalizeText(input?.nextRunAt, current?.nextRunAt || "");

  return {
    enabled,
    intervalHours,
    nextRunAt: nextRunAt || null,
  };
}

async function generateCoveragePolygon(
  coverageArea: Pick<CoverageArea, "granularity" | "maxDriveTimeMinutes" | "warehouse">,
  force = false,
) {
  const origin = coverageArea.warehouse.location;
  const cacheKey = createIsochroneCacheKey(coverageArea);
  const cached = force ? null : await getCachedIsochronePlot(cacheKey);

  if (cached) {
    return cached;
  }

  const maxOutboundMeters = coverageSearchSpeedMph * 1609.344 * (coverageArea.maxDriveTimeMinutes / 60);
  const bearings = Array.from(
    { length: coverageArea.granularity.sampleBearings },
    (_, index) => (360 / coverageArea.granularity.sampleBearings) * index,
  );
  const boundary = await mapWithConcurrency(
    bearings,
    4,
    (bearing) => findBidirectionalBoundaryPoint(
      origin,
      bearing,
      maxOutboundMeters,
      coverageArea.maxDriveTimeMinutes,
      coverageArea.granularity.binarySearchIterations,
    ),
  );
  const polygon = closePolygon(boundary.filter(Boolean) as LatLng[]);
  const radiusMeters = Math.max(...polygon.map((point) => distanceMeters(origin, point)), 0);
  const plot = {
    polygon,
    radiusMeters: Math.round(radiusMeters),
  };

  await storeCachedIsochronePlot(cacheKey, plot);

  return plot;
}

async function findBidirectionalBoundaryPoint(
  origin: LatLng,
  bearingDegrees: number,
  maxMeters: number,
  maxMinutes: number,
  iterations: number,
) {
  let accepted = origin;
  let lowMeters = 0;
  let highMeters = maxMeters;

  for (let index = 0; index < iterations; index += 1) {
    const candidateMeters = (lowMeters + highMeters) / 2;
    const candidate = destinationPoint(origin, bearingDegrees, candidateMeters);
    const driveTime = await calculateBidirectionalDriveTime(origin, candidate).catch(() => null);

    if (
      driveTime &&
      driveTime.outboundSeconds <= maxMinutes * 60 &&
      driveTime.inboundSeconds <= maxMinutes * 60
    ) {
      accepted = candidate;
      lowMeters = candidateMeters;
    } else {
      highMeters = candidateMeters;
    }
  }

  return accepted;
}

async function calculateBidirectionalDriveTime(origin: LatLng, destination: LatLng) {
  const [outbound, inbound] = await Promise.all([
    calculateRouteDuration([origin, destination]),
    calculateRouteDuration([destination, origin]),
  ]);
  const outboundSeconds = outbound.durationSeconds;
  const inboundSeconds = inbound.durationSeconds;

  return {
    inboundSeconds,
    outboundSeconds,
    totalSeconds: outboundSeconds + inboundSeconds,
  };
}

function pointInPolygon(point: LatLng, polygon: LatLng[]) {
  let inside = false;

  for (let index = 0, previousIndex = polygon.length - 1; index < polygon.length; previousIndex = index, index += 1) {
    const current = polygon[index];
    const previous = polygon[previousIndex];
    const intersects =
      current.lng > point.lng !== previous.lng > point.lng &&
      point.lat <
        ((previous.lat - current.lat) * (point.lng - current.lng)) / (previous.lng - current.lng || Number.EPSILON) +
          current.lat;

    if (intersects) {
      inside = !inside;
    }
  }

  return inside;
}

function didCoverageRulesChange(
  current: CoverageArea,
  next: Awaited<ReturnType<typeof normalizeCoverageAreaInput>>,
) {
  return (
    current.maxDriveTimeMinutes !== next.maxDriveTimeMinutes ||
    current.granularity.binarySearchIterations !== next.granularity.binarySearchIterations ||
    current.granularity.sampleBearings !== next.granularity.sampleBearings ||
    current.warehouse.address !== next.warehouse.address ||
    current.warehouse.location.lat !== next.warehouse.location.lat ||
    current.warehouse.location.lng !== next.warehouse.location.lng
  );
}

function calculateNextRunAt(schedule: CoverageAreaSchedule, from: Date) {
  if (!schedule.enabled) {
    return null;
  }

  if (schedule.nextRunAt && Date.parse(schedule.nextRunAt) > from.getTime()) {
    return schedule.nextRunAt;
  }

  if (!schedule.intervalHours) {
    return null;
  }

  return new Date(from.getTime() + schedule.intervalHours * 60 * 60 * 1000).toISOString();
}

async function resolveOrigin(origin: { address?: string; lat?: number; lng?: number }): Promise<LatLng & { address?: string }> {
  const explicitLocation = readLatLng(origin);

  if (explicitLocation) {
    return {
      address: origin.address?.trim() || undefined,
      ...explicitLocation,
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
    polygon: data.polygon as LatLng[],
    radiusMeters: Number(data.radiusMeters) || 0,
  };
}

async function storeCachedIsochronePlot(cacheKey: string, plot: {
  polygon: LatLng[];
  radiusMeters: number;
}) {
  await getBayblazeFirestore().collection(isochroneCacheCollection).doc(cacheKey).set({
    ...plot,
    algorithmVersion: coverageAlgorithmVersion,
    expiresAt: new Date(Date.now() + isochroneCacheTtlMs),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

function createIsochroneCacheKey(coverageArea: Pick<CoverageArea, "granularity" | "maxDriveTimeMinutes" | "warehouse">) {
  return createHash("sha256")
    .update([
      coverageAlgorithmVersion,
      coverageArea.warehouse.location.lat.toFixed(6),
      coverageArea.warehouse.location.lng.toFixed(6),
      String(coverageSearchSpeedMph),
      String(coverageArea.maxDriveTimeMinutes),
      String(coverageArea.granularity.sampleBearings),
      String(coverageArea.granularity.binarySearchIterations),
    ].join(":"))
    .digest("hex");
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

function serializeCoverageArea(id: string, data: Record<string, unknown>): CoverageArea {
  const warehouseRecord = readRecord(data.warehouse);
  const granularityRecord = readRecord(data.granularity);
  const scheduleRecord = readRecord(data.schedule);
  const warehouseLocation = readLatLng(warehouseRecord.location) ?? readLatLng(warehouseRecord) ?? {
    lat: 0,
    lng: 0,
  };

  return {
    active: data.active !== false,
    algorithmVersion: normalizeText(data.algorithmVersion, coverageAlgorithmVersion),
    createdAt: serializeTimestamp(data.createdAt) || normalizeText(data.createdAtFallback),
    description: normalizeText(data.description),
    granularity: {
      binarySearchIterations: Math.round(clamp(readNumber(granularityRecord.binarySearchIterations) ?? 5, 3, 10)),
      sampleBearings: Math.round(clamp(readNumber(granularityRecord.sampleBearings) ?? 24, 8, 144)),
    },
    id,
    label: normalizeText(data.label, id),
    lastGeneratedAt: serializeTimestamp(data.lastGeneratedAt),
    lastGenerationError: normalizeText(data.lastGenerationError),
    maxDriveTimeMinutes: clamp(readNumber(data.maxDriveTimeMinutes) ?? 30, 1, 180),
    polygon: Array.isArray(data.polygon) ? data.polygon.map(readLatLng).filter(Boolean) as LatLng[] : [],
    radiusMeters: Math.round(Math.max(readNumber(data.radiusMeters) ?? 0, 0)),
    schedule: {
      enabled: scheduleRecord.enabled === true,
      intervalHours: readNumber(scheduleRecord.intervalHours),
      nextRunAt: normalizeText(scheduleRecord.nextRunAt) || null,
    },
    updatedAt: serializeTimestamp(data.updatedAt) || normalizeText(data.updatedAtFallback),
    warehouse: {
      address: normalizeText(warehouseRecord.address),
      label: normalizeText(warehouseRecord.label, "Warehouse"),
      location: warehouseLocation,
      warehouseId: normalizeText(warehouseRecord.warehouseId, "warehouse"),
    },
  };
}

function normalizeCoverageAreaId(id: string) {
  const normalized = id.trim();

  if (!normalized) {
    throw new ApiRequestError(400, "Coverage area ID is required.");
  }

  return normalized;
}

function readRecord(value: unknown) {
  return typeof value === "object" && value !== null && !Array.isArray(value) ? value as Record<string, unknown> : {};
}

function readLatLng(value: unknown): LatLng | null {
  const record = readRecord(value);
  const lat = readNumber(record.lat ?? record.latitude);
  const lng = readNumber(record.lng ?? record.longitude);

  return lat === null || lng === null ? null : { lat, lng };
}

function readNumber(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

  return Number.isFinite(number) ? number : null;
}

function normalizeText(value: unknown, fallback = "") {
  return typeof value === "string" && value.trim() ? value.trim() : fallback;
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

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function toRadians(value: number) {
  return (value * Math.PI) / 180;
}

function toDegrees(value: number) {
  return (value * 180) / Math.PI;
}
