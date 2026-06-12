import { randomUUID } from "node:crypto";
import Busboy from "busboy";
import { Router, type NextFunction, type Request, type Response } from "express";
import { z } from "zod";

import { getBayblazeStorage } from "../../clients/firebaseAdminClient";
import { requireDriverAuth, type DriverAuthedRequest } from "../../http/middleware/driverAuth";
import {
  createAllowedDriverAccount,
  loginDriver,
  prepareDriverAccess,
} from "./driverAuthService";
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

const authEmailSchema = z.object({
  email: z.string().min(1),
});

const authCreateSchema = z.object({
  code: z.string().min(1),
  email: z.string().min(1),
  password: z.string().min(1),
});

const authLoginSchema = z.object({
  email: z.string().min(1),
  password: z.string().min(1),
});

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

  router.post("/driver/auth/access", async (req, res, next) => {
    try {
      const parsed = authEmailSchema.parse(req.body);
      res.json(await prepareDriverAccess(parsed.email));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/auth/accounts", async (req, res, next) => {
    try {
      const parsed = authCreateSchema.parse(req.body);
      res.json(await createAllowedDriverAccount(parsed.email, parsed.code, parsed.password));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/auth/login", async (req, res, next) => {
    try {
      const parsed = authLoginSchema.parse(req.body);
      res.json(await loginDriver(parsed.email, parsed.password));
    } catch (caught) {
      next(caught);
    }
  });

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

  router.post("/driver/me/profile-photo", async (req: DriverAuthedRequest, res, next) => {
    try {
      const auth = readDriverAuth(req);
      const upload = await readMultipartImageUpload(req, "photo");
      const extension = readImageExtension(upload.fileName, upload.mimeType);
      const path = `driver-profile-photos/${auth.uid}/profile.${extension}`;
      const photoUrl = await uploadDriverImage(path, upload);

      res.json({
        profilePhotoPath: path,
        profilePhotoUrl: photoUrl,
      });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/driver/me/delivery-attempt-photos", async (req: DriverAuthedRequest, res, next) => {
    try {
      const auth = readDriverAuth(req);
      const upload = await readMultipartImageUpload(req, "photo");
      const fields = upload.fields;
      const orderId = readSafePathSegment(fields.orderId);
      const type = fields.type === "id_photo" ? "id_photo" : "merchant_invoice_photo";

      if (!orderId) {
        throw new ApiRequestError(400, "Order ID is required for delivery attempt photo upload.");
      }

      const extension = readImageExtension(upload.fileName, upload.mimeType);
      const path = `delivery-attempt-photos/${auth.uid}/${orderId}/${type}-${Date.now()}.${extension}`;
      const photoUrl = await uploadDriverImage(path, upload);

      res.json({
        photoPath: path,
        photoUrl,
      });
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

type ParsedImageUpload = {
  buffer: Buffer;
  fields: Record<string, string>;
  fileName: string;
  mimeType: string;
};

function readMultipartImageUpload(req: Request, fieldName: string) {
  return new Promise<ParsedImageUpload>((resolve, reject) => {
    const contentType = readHeader(req.headers["content-type"]);

    if (!contentType.includes("multipart/form-data")) {
      reject(new ApiRequestError(400, "Driver image upload must be multipart/form-data."));
      return;
    }

    const parser = Busboy({
      headers: { "content-type": contentType },
      limits: {
        files: 1,
        fileSize: 4 * 1024 * 1024,
      },
    });
    const chunks: Buffer[] = [];
    const fields: Record<string, string> = {};
    let fileName = "driver-photo.jpg";
    let mimeType = "image/jpeg";
    let sawImage = false;
    let settled = false;

    function fail(error: Error) {
      if (!settled) {
        settled = true;
        reject(error);
      }
    }

    parser.on("field", (name, value) => {
      fields[name] = value;
    });

    parser.on("file", (name, file, info) => {
      if (name !== fieldName) {
        file.resume();
        return;
      }

      sawImage = true;
      fileName = info.filename || fileName;
      mimeType = info.mimeType || mimeType;

      file.on("data", (chunk: Buffer) => {
        chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
      });
      file.on("limit", () => fail(new ApiRequestError(413, "Driver image is too large.")));
      file.on("error", (error) => fail(error instanceof Error ? error : new Error("Driver image upload failed.")));
    });

    parser.on("error", (error) => fail(error instanceof Error ? error : new Error("Driver image upload parsing failed.")));
    parser.on("finish", () => {
      if (settled) return;
      if (!sawImage || chunks.length === 0) {
        fail(new ApiRequestError(400, "Driver image upload is required."));
        return;
      }

      settled = true;
      resolve({
        buffer: Buffer.concat(chunks),
        fields,
        fileName,
        mimeType,
      });
    });

    req.pipe(parser);
  });
}

async function uploadDriverImage(path: string, upload: ParsedImageUpload) {
  const bucket = getBayblazeStorage().bucket();
  const file = bucket.file(path);
  const token = randomUUID();

  await file.save(upload.buffer, {
    contentType: upload.mimeType,
    metadata: {
      metadata: {
        firebaseStorageDownloadTokens: token,
      },
    },
    resumable: false,
  });

  return `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

function readHeader(value: unknown) {
  if (Array.isArray(value)) {
    return value[0] ?? "";
  }

  return typeof value === "string" ? value : "";
}

function readImageExtension(fileName: string, mimeType: string) {
  const fileExtension = fileName.split(".").pop()?.toLowerCase();
  if (fileExtension && ["jpg", "jpeg", "png", "webp"].includes(fileExtension)) {
    return fileExtension === "jpeg" ? "jpg" : fileExtension;
  }

  if (mimeType === "image/png") return "png";
  if (mimeType === "image/webp") return "webp";
  return "jpg";
}

function readSafePathSegment(value: unknown) {
  return typeof value === "string" ? value.replace(/[^a-zA-Z0-9._-]/g, "_") : "";
}
