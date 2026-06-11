import { Router } from "express";

import { forwardIsoChronosJson } from "../../clients/isochronosClient";
import {
  forwardDeliveryAttempt,
  forwardDriverQueueRequest,
} from "../../clients/medusaDriverClient";
import { env } from "../../config/env";
import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { sendUpstreamJson } from "../../http/upstream";

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
      const upstream = await forwardIsoChronosJson(env.ISOCHRONOS_QUEUE_SCORE_PATH, req.body);

      await sendUpstreamJson(res, upstream, {
        fallbackMessage: "IsoChronos queue scoring API returned a non-JSON response.",
        upstreamName: "IsoChronos queue scoring",
      });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/drivers/location", requireApiServiceToken, async (req, res, next) => {
    try {
      const upstream = await forwardIsoChronosJson(env.ISOCHRONOS_DRIVER_LOCATION_PATH, req.body);

      await sendUpstreamJson(res, upstream, {
        fallbackMessage: "IsoChronos driver location API returned a non-JSON response.",
        upstreamName: "IsoChronos driver location",
      });
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
