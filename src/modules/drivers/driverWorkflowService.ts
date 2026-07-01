import { FieldValue } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { forwardDeliveryAttempt, forwardDriverQueueRequest, forwardReprintLabelsRequest } from "../../clients/medusaDriverClient";
import { lockQueueHead, normalizeDriverQueuePayload, removeUndefinedValues } from "./driverQueueNormalizer";
import { scoreDriverDeliveryQueue } from "../isochronos/driverQueueScoringService";
import { sendDriverAssignmentAlerts } from "./driverAssignmentAlertService";
import type {
  DeliveryAttemptLog,
  DriverDeliveryQueue,
  DriverLocationSnapshot,
  DriverProfile,
  VehicleRecord,
} from "./driverWorkflowTypes";

export async function getDriverProfile(uid: string) {
  const snapshot = await getBayblazeFirestore().collection("driver_profiles").doc(uid).get();
  return snapshot.exists ? (snapshot.data() as DriverProfile) : null;
}

export async function saveDriverProfile(uid: string, email: string, input: Partial<DriverProfile>) {
  const profileRef = getBayblazeFirestore().collection("driver_profiles").doc(uid);
  const existing = await profileRef.get();

  if (!readString(input.profilePhotoPath) || !readString(input.profilePhotoUrl)) {
    const existingProfile = existing.exists ? (existing.data() as DriverProfile) : null;
    if (!existingProfile?.profilePhotoPath || !existingProfile.profilePhotoUrl) {
      throw new ApiRequestError(400, "Profile photo is required.");
    }
  }

  const nextProfile = removeUndefinedValues({
      uid,
      email,
      firstName: readString(input.firstName),
      lastName: readString(input.lastName),
      phoneNumber: readString(input.phoneNumber),
      bio: readString(input.bio),
      profilePhotoPath: input.profilePhotoPath,
      profilePhotoUrl: input.profilePhotoUrl,
      onboardingComplete: true,
      clockedIn: existing.exists ? (existing.data() as DriverProfile).clockedIn === true : false,
      createdAt: existing.exists ? existing.data()?.createdAt : FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }) as Record<string, unknown>;

  await profileRef.set(nextProfile, { merge: true });

  return getDriverProfile(uid);
}

export async function listAvailableVehicles() {
  const snapshot = await getBayblazeFirestore()
    .collection("vehicles")
    .where("active", "==", true)
    .get();

  return snapshot.docs
    .map((vehicleDoc) => vehicleDoc.data() as VehicleRecord)
    .filter((vehicle) => !vehicle.linkedDriverUid)
    .sort((first, second) => first.label.localeCompare(second.label));
}

export async function linkVehicleToDriver(uid: string, vehicleId: string) {
  const db = getBayblazeFirestore();

  await db.runTransaction(async (transaction) => {
    const profileRef = db.collection("driver_profiles").doc(uid);
    const vehicleRef = db.collection("vehicles").doc(vehicleId);
    const vehicleSnapshot = await transaction.get(vehicleRef);

    if (!vehicleSnapshot.exists) {
      throw new ApiRequestError(404, "Vehicle is no longer available.");
    }

    const vehicle = vehicleSnapshot.data() as VehicleRecord;
    if (!vehicle.active || vehicle.linkedDriverUid) {
      throw new ApiRequestError(409, "Vehicle is already linked.");
    }

    transaction.update(vehicleRef, {
      linkedDriverUid: uid,
      linkedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    transaction.update(profileRef, {
      activeVehicleId: vehicleId,
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}

export async function clockInDriver(uid: string) {
  const profile = await requireProfile(uid);

  if (!profile.activeVehicleId) {
    throw new ApiRequestError(400, "Select a vehicle before clocking in.");
  }

  await getBayblazeFirestore().collection("driver_profiles").doc(uid).update({
    clockedIn: true,
    clockedInAt: FieldValue.serverTimestamp(),
    clockedOutAt: FieldValue.delete(),
    updatedAt: FieldValue.serverTimestamp(),
  });
}

export async function clockOutDriver(uid: string) {
  const db = getBayblazeFirestore();

  await db.runTransaction(async (transaction) => {
    const profileRef = db.collection("driver_profiles").doc(uid);
    const profileSnapshot = await transaction.get(profileRef);

    if (!profileSnapshot.exists) {
      throw new ApiRequestError(404, "Driver profile was not found.");
    }

    const profile = profileSnapshot.data() as DriverProfile;
    const vehicleId = profile.activeVehicleId;

    if (vehicleId) {
      const vehicleRef = db.collection("vehicles").doc(vehicleId);
      const vehicleSnapshot = await transaction.get(vehicleRef);

      if (vehicleSnapshot.exists) {
        const vehicle = vehicleSnapshot.data() as VehicleRecord;
        if (vehicle.linkedDriverUid === uid) {
          transaction.update(vehicleRef, {
            linkedDriverUid: FieldValue.delete(),
            linkedAt: FieldValue.delete(),
            updatedAt: FieldValue.serverTimestamp(),
          });
        }
      }
    }

    transaction.update(profileRef, {
      activeVehicleId: FieldValue.delete(),
      clockedIn: false,
      clockedOutAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}

export async function syncDriverDeliveryQueue(uid: string) {
  const existingQueue = await getDriverDeliveryQueue(uid);
  const includeUnassigned = await shouldIncludeUnassignedOrders(uid);
  const medusaResponse = await forwardDriverQueueRequest(uid, includeUnassigned);
  const payload = await readJsonResponse(medusaResponse, "Medusa driver queue");
  const medusaQueue = normalizeDriverQueuePayload(uid, payload);
  const scoredQueue = await scoreDriverDeliveryQueue(medusaQueue);
  const newStops = findNewDeliveryStops(existingQueue, scoredQueue);

  await writeDriverQueue(uid, scoredQueue);

  if (newStops.length > 0) {
    void sendDriverAssignmentAlerts(uid, newStops).catch((caught) => {
      console.warn("Driver assignment alerts failed.", caught);
    });
  }

  return scoredQueue;
}

export async function getDriverDeliveryQueue(uid: string) {
  const snapshot = await getBayblazeFirestore().collection("driver_delivery_queues").doc(uid).get();
  return snapshot.exists ? (snapshot.data() as DriverDeliveryQueue) : null;
}

export async function getDriverDeliveryQueueForClient(uid: string) {
  return toClientDriverDeliveryQueue(await getDriverDeliveryQueue(uid));
}

export async function reprintDriverDeliveryLabels(uid: string, orderId: string) {
  const safeOrderId = readString(orderId);
  const queue = await getDriverDeliveryQueue(uid);
  const stop = queue?.stops.find((candidate) =>
    candidate.orderId === safeOrderId ||
    candidate.medusaOrderId === safeOrderId ||
    candidate.orderReference === safeOrderId,
  );

  if (!safeOrderId) {
    throw new ApiRequestError(400, "Order ID is required.");
  }

  if (!stop) {
    throw new ApiRequestError(404, "That delivery is not in your active route.");
  }

  const upstream = await forwardReprintLabelsRequest(stop.medusaOrderId || stop.orderId, {
    requestedBy: "driver",
    uid,
  });
  await readJsonResponse(upstream, "Medusa label reprint");
}

export function toClientDriverDeliveryQueue(queue: DriverDeliveryQueue | null) {
  if (!queue) {
    return null;
  }

  return {
    ...queue,
    stops: queue.stops.map((stop) => {
      const {
        medusaOrderId: _medusaOrderId,
        orderReference: _orderReference,
        ...clientStop
      } = stop;

      return clientStop;
    }),
  };
}

export async function writeDriverLocationSnapshot(uid: string, snapshot: Omit<DriverLocationSnapshot, "uid">) {
  const profile = await requireProfile(uid);

  if (!profile.activeVehicleId) {
    throw new ApiRequestError(400, "A linked vehicle is required before sharing live location.");
  }

  await getBayblazeFirestore()
    .collection("driver_location_snapshots")
    .doc(uid)
    .set(
      {
        ...snapshot,
        uid,
        vehicleId: profile.activeVehicleId,
        clockedIn: true,
        source: "driver-pwa",
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
}

export async function logDeliveryAttempt(uid: string, input: Omit<DeliveryAttemptLog, "uid">) {
  const log: DeliveryAttemptLog = {
    uid,
    orderId: readString(input.orderId),
    type: input.type,
    note: input.note?.trim() || null,
    photoPath: input.photoPath ?? null,
    photoUrl: input.photoUrl ?? null,
  };

  if (!log.orderId) {
    throw new ApiRequestError(400, "Order ID is required.");
  }

  await getBayblazeFirestore().collection("delivery_attempt_logs").add({
    ...log,
    createdAt: FieldValue.serverTimestamp(),
  });

  if (log.type === "out_for_delivery" || log.type === "completed" || log.type === "cancelled") {
    const medusaResponse = await forwardDeliveryAttempt(log);
    await readJsonResponse(medusaResponse, "Medusa delivery attempt");

    if (log.type === "completed" || log.type === "cancelled") {
      await rescoreExistingDriverQueue(uid);
    }
  }
}

export async function registerDriverNotificationToken(
  uid: string,
  tokenId: string,
  input: { token?: string; platform?: string; userAgent?: string },
) {
  const token = readString(input.token);

  if (!token || !tokenId) {
    throw new ApiRequestError(400, "Notification token is required.");
  }

  await getBayblazeFirestore()
    .collection("driver_notification_tokens")
    .doc(uid)
    .collection("tokens")
    .doc(tokenId)
    .set(
      {
        uid,
        token,
        platform: input.platform || "web",
        userAgent: input.userAgent || "",
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
}

export async function deleteDriverNotificationToken(uid: string, tokenId: string) {
  if (!tokenId) {
    throw new ApiRequestError(400, "Notification token ID is required.");
  }

  await getBayblazeFirestore()
    .collection("driver_notification_tokens")
    .doc(uid)
    .collection("tokens")
    .doc(tokenId)
    .delete();
}

export class ApiRequestError extends Error {
  constructor(
    public readonly status: number,
    message: string,
  ) {
    super(message);
  }
}

async function requireProfile(uid: string) {
  const profile = await getDriverProfile(uid);

  if (!profile) {
    throw new ApiRequestError(404, "Driver profile was not found.");
  }

  return profile;
}

async function writeDriverQueue(uid: string, queue: DriverDeliveryQueue) {
  const data: Record<string, unknown> = {
    ...queue,
    uid,
    stops: removeUndefinedValues(lockQueueHead(queue.stops)),
    updatedAt: FieldValue.serverTimestamp(),
  };

  data.activeOrderId = queue.stops[0]?.orderId ?? FieldValue.delete();

  await getBayblazeFirestore().collection("driver_delivery_queues").doc(uid).set(data, { merge: true });
}

async function shouldIncludeUnassignedOrders(uid: string) {
  const snapshot = await getBayblazeFirestore()
    .collection("driver_profiles")
    .where("clockedIn", "==", true)
    .get();
  const activeDrivers = snapshot.docs
    .map((driverSnapshot) => {
      const profile = driverSnapshot.data() as Partial<DriverProfile>;

      return {
        uid: driverSnapshot.id,
        activeVehicleId: profile.activeVehicleId,
        onboardingComplete: profile.onboardingComplete,
      };
    })
    .filter(
      (profile) =>
        profile.onboardingComplete === true &&
        typeof profile.activeVehicleId === "string" &&
        profile.activeVehicleId.trim(),
    );

  return activeDrivers.length === 1 && activeDrivers[0]?.uid === uid;
}

async function rescoreExistingDriverQueue(uid: string) {
  const queue = await getDriverDeliveryQueue(uid);

  if (!queue) {
    return;
  }

  const [, nextStop, ...reorderableStops] = queue.stops;

  if (!nextStop) {
    await writeDriverQueue(uid, { uid, stops: [] });
    return;
  }

  const scoredQueue = await scoreDriverDeliveryQueue({
    uid,
    stops: [nextStop, ...reorderableStops],
  });
  await writeDriverQueue(uid, scoredQueue);
}

function findNewDeliveryStops(
  existingQueue: DriverDeliveryQueue | null,
  nextQueue: DriverDeliveryQueue,
) {
  if (!existingQueue) {
    return [];
  }

  const existingOrderIds = new Set(existingQueue.stops.map((stop) => stop.orderId));
  return nextQueue.stops.filter((stop) => !existingOrderIds.has(stop.orderId));
}

async function readJsonResponse(response: globalThis.Response, upstreamName: string) {
  const text = await response.text();
  const payload = text ? JSON.parse(text) : {};

  if (!response.ok) {
    const message =
      typeof payload.message === "string"
        ? payload.message
        : typeof payload.error === "string"
          ? payload.error
        : `${upstreamName} request failed with HTTP ${response.status}.`;
    throw new ApiRequestError(response.status, message);
  }

  return payload;
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}
