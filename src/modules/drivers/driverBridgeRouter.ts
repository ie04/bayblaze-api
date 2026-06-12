import { Router } from "express";

import {
  forwardDeliveryAttempt,
  forwardDriverQueueRequest,
} from "../../clients/medusaDriverClient";
import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { sendUpstreamJson } from "../../http/upstream";
import { normalizeDriverQueuePayload } from "./driverQueueNormalizer";
import { writeDriverLocationSnapshot } from "./driverWorkflowService";
import { scoreDriverDeliveryQueue } from "../isochronos/driverQueueScoringService";

export function createDriverBridgeRouter() {
  const router = Router();

  router.get("/drivers/:uid/queue", requireApiServiceToken, async (req, res, next) => {
    try {
      const uid = readString(req.params.uid);

      if (!uid) {
        return res.status(400).json({ message: "Driver UID is required." });
      }

      const upstream = await forwardDriverQueueRequest(
        uid,
        isTruthyQuery(req.query.include_unassigned),
      );

      await sendUpstreamJson(res, upstream, {
        fallbackMessage: "Medusa driver queue API returned a non-JSON response.",
        upstreamName: "Medusa driver queue",
      });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/drivers/queues/score", requireApiServiceToken, async (req, res, next) => {
    try {
      const body = req.body as { uid?: unknown; queue?: unknown };
      const uid = readString(body.uid);
      const queue = normalizeDriverQueuePayload(uid, body.queue ?? {});
      const scoredQueue = await scoreDriverDeliveryQueue(queue);

      res.json({ queue: scoredQueue });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/drivers/location", requireApiServiceToken, async (req, res, next) => {
    try {
      const body = req.body as {
        uid?: unknown;
        lat?: unknown;
        lng?: unknown;
        accuracy?: unknown;
        heading?: unknown;
        speed?: unknown;
        clientCapturedAt?: unknown;
      };
      const uid = readString(body.uid);

      if (!uid) {
        return res.status(400).json({ message: "Driver UID is required." });
      }

      await writeDriverLocationSnapshot(uid, {
        vehicleId: "",
        lat: readNumber(body.lat),
        lng: readNumber(body.lng),
        accuracy: readNumber(body.accuracy),
        heading: readNullableNumber(body.heading),
        speed: readNullableNumber(body.speed),
        clockedIn: true,
        source: "driver-pwa",
        clientCapturedAt: readNumber(body.clientCapturedAt, Date.now()),
      });
      res.json({ ok: true });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/delivery-attempts", requireApiServiceToken, async (req, res, next) => {
    try {
      const upstream = await forwardDeliveryAttempt(req.body);

      await sendUpstreamJson(res, upstream, {
        fallbackMessage: "Medusa delivery attempt API returned a non-JSON response.",
        upstreamName: "Medusa delivery attempt",
      });
    } catch (caught) {
      next(caught);
    }
  });

  return router;
}

function isTruthyQuery(value: unknown) {
  if (Array.isArray(value)) {
    return value.some(isTruthyQuery);
  }

  return typeof value === "string" && ["1", "true", "yes"].includes(value.toLowerCase());
}

function readString(value: unknown) {
  if (Array.isArray(value)) {
    return typeof value[0] === "string" ? value[0].trim() : "";
  }

  return typeof value === "string" ? value.trim() : "";
}

function readNumber(value: unknown, fallback?: number) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback ?? 0;
}

function readNullableNumber(value: unknown) {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}
