import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireDriverAuth, type DriverAuthedRequest } from "../../http/middleware/driverAuth";
import {
  ApiRequestError,
  clockInDriver,
  clockOutDriver,
  deleteDriverNotificationToken,
  getDriverDeliveryQueue,
  getDriverProfile,
  linkVehicleToDriver,
  listAvailableVehicles,
  logDeliveryAttempt,
  registerDriverNotificationToken,
  saveDriverProfile,
  syncDriverDeliveryQueue,
  writeDriverLocationSnapshot,
} from "./driverWorkflowService";

const profileSchema = z.object({
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  phoneNumber: z.string().optional(),
  bio: z.string().optional(),
  profilePhotoPath: z.string().optional(),
  profilePhotoUrl: z.string().optional(),
});

const vehicleLinkSchema = z.object({
  vehicleId: z.string().min(1),
});

const locationSchema = z.object({
  lat: z.number(),
  lng: z.number(),
  accuracy: z.number(),
  heading: z.number().nullable().optional(),
  speed: z.number().nullable().optional(),
  clientCapturedAt: z.number(),
});

const deliveryAttemptSchema = z.object({
  orderId: z.string().min(1),
  type: z.enum([
    "warehouse_arrival",
    "out_for_delivery",
    "customer_arrival",
    "id_photo",
    "merchant_invoice_photo",
    "cancelled",
    "completed",
  ]),
  note: z.string().optional().nullable(),
  photoPath: z.string().optional().nullable(),
  photoUrl: z.string().optional().nullable(),
});

const notificationTokenSchema = z.object({
  tokenId: z.string().min(1),
  token: z.string().min(1),
  platform: z.string().optional(),
  userAgent: z.string().optional(),
});

export function createDriverWorkflowRouter() {
  const router = Router();

  router.use("/driver/me", requireDriverAuth);

  router.get("/driver/me/profile", async (req: DriverAuthedRequest, res, next) => {
    try {
      res.json({ profile: await getDriverProfile(readUid(req)) });
    } catch (caught) {
      next(caught);
    }
  });

  router.put("/driver/me/profile", async (req: DriverAuthedRequest, res, next) => {
    try {
      const parsed = profileSchema.parse(req.body);
      const auth = readDriverAuth(req);
      res.json({ profile: await saveDriverProfile(auth.uid, auth.email, parsed) });
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/driver/me/vehicles/available", async (_req, res, next) => {
    try {
      res.json({ vehicles: await listAvailableVehicles() });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/vehicles/link", async (req: DriverAuthedRequest, res, next) => {
    try {
      const parsed = vehicleLinkSchema.parse(req.body);
      await linkVehicleToDriver(readUid(req), parsed.vehicleId);
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/clock-in", async (req: DriverAuthedRequest, res, next) => {
    try {
      await clockInDriver(readUid(req));
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/clock-out", async (req: DriverAuthedRequest, res, next) => {
    try {
      await clockOutDriver(readUid(req));
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/driver/me/queue", async (req: DriverAuthedRequest, res, next) => {
    try {
      res.json({ queue: await getDriverDeliveryQueue(readUid(req)) });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/queue/sync", async (req: DriverAuthedRequest, res, next) => {
    try {
      const queue = await syncDriverDeliveryQueue(readUid(req));
      res.json({ queue, stopCount: queue.stops.length });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/location", async (req: DriverAuthedRequest, res, next) => {
    try {
      const parsed = locationSchema.parse(req.body);
      await writeDriverLocationSnapshot(readUid(req), {
        vehicleId: "",
        clockedIn: true,
        source: "driver-pwa",
        ...parsed,
        heading: parsed.heading ?? null,
        speed: parsed.speed ?? null,
      });
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/delivery-attempts", async (req: DriverAuthedRequest, res, next) => {
    try {
      const parsed = deliveryAttemptSchema.parse(req.body);
      await logDeliveryAttempt(readUid(req), parsed);
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/notification-tokens", async (req: DriverAuthedRequest, res, next) => {
    try {
      const parsed = notificationTokenSchema.parse(req.body);
      await registerDriverNotificationToken(readUid(req), parsed.tokenId, parsed);
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.delete("/driver/me/notification-tokens/:tokenId", async (req: DriverAuthedRequest, res, next) => {
    try {
      await deleteDriverNotificationToken(readUid(req), readRouteParam(req.params.tokenId));
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: DriverAuthedRequest, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        message: "Invalid driver API payload.",
        details: err.flatten(),
      });
    }

    if (err instanceof ApiRequestError) {
      return res.status(err.status).json({
        message: err.message,
      });
    }

    return next(err);
  });

  return router;
}

function readUid(req: DriverAuthedRequest) {
  return readDriverAuth(req).uid;
}

function readDriverAuth(req: DriverAuthedRequest) {
  if (!req.driverAuth) {
    throw new ApiRequestError(401, "Driver sign-in is required.");
  }

  return req.driverAuth;
}

function readRouteParam(value: string | string[] | undefined) {
  return Array.isArray(value) ? value[0] ?? "" : value ?? "";
}
