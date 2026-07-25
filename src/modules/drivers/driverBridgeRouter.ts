import { Router } from "express";

import {
  forwardDeliveryAttempt,
  forwardDriverQueueRequest,
} from "../../clients/medusaDriverClient";
import { getAdminOrderDetail } from "../../clients/medusaAdminClient";
import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { sendUpstreamJson } from "../../http/upstream";
import { normalizeDriverQueuePayload } from "./driverQueueNormalizer";
import { writeDriverLocationSnapshot } from "./driverWorkflowService";
import { scoreDriverDeliveryQueue } from "../isochronos/driverQueueScoringService";
import { recordPartnerOrderEvent } from "../partners/partnerService";

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
      const responseBody = await upstream.clone().json().catch(() => ({})) as Record<string, unknown>;

      if (upstream.ok) {
        await recordBridgeDeliveryPartnerOrderEvent(req.body, responseBody);
      }

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

async function recordBridgeDeliveryPartnerOrderEvent(
  body: unknown,
  responseBody: Record<string, unknown>,
) {
  const record = body && typeof body === "object" && !Array.isArray(body)
    ? body as Record<string, unknown>
    : {};
  const type = readString(record.type);

  if (type !== "completed" && type !== "cancelled") {
    return;
  }

  const orderId = readString(responseBody.orderId) || readString(record.orderId);

  if (!orderId) {
    return;
  }

  const order = await getAdminOrderDetail(orderId);
  const metadata = asRecord(order.metadata);
  const eventType = type === "completed" ? "order_completed" : "order_canceled";
  const eventAt = readString(metadata.bayblaze_delivery_event_at) || new Date().toISOString();

  await recordPartnerOrderEvent({
    eventAt,
    eventId: `delivery_bridge:${eventType}:${readString(order.id) || orderId}:${eventAt}`,
    eventType,
    order: {
      currencyCode: readString(order.currency_code),
      customerUid: readString(metadata.bayblaze_account_uid),
      email: readString(order.email),
      fulfillmentStatus: readString(order.fulfillment_status),
      id: readString(order.id) || orderId,
      metadata,
      paymentStatus: readString(order.payment_status),
      status: type,
    },
  });
}

function asRecord(value: unknown) {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function readNumber(value: unknown, fallback?: number) {
  return typeof value === "number" && Number.isFinite(value) ? value : fallback ?? 0;
}

function readNullableNumber(value: unknown) {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}
