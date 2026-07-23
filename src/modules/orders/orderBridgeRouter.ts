import { Router } from "express";
import { z } from "zod";

import { forwardAdminOrderCancelRequest, getAdminOrderDetail } from "../../clients/medusaAdminClient";
import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { getOrderLiveTracking } from "../isochronos/orderLiveTrackingService";
import { recordPartnerOrderEvent } from "../partners/partnerService";

const coordinateSchema = z.object({
  address: z.string().optional(),
  lat: z.number(),
  lng: z.number(),
});

const liveTrackingSchema = z.object({
  customerAddress: z.string().optional(),
  destination: coordinateSchema.optional(),
  driverUid: z.string().optional(),
  orderId: z.string().min(1),
  orderReference: z.string().optional(),
});

export function createOrderBridgeRouter() {
  const router = Router();

  router.post("/orders/:orderId/cancel", requireApiServiceToken, async (req, res, next) => {
    try {
      const orderId = readParamString(req.params.orderId);

      if (!orderId) {
        return res.status(400).json({ message: "Order ID is required." });
      }

      const order = await getAdminOrderDetail(orderId);
      const upstream = await forwardAdminOrderCancelRequest(orderId);
      if (upstream.ok) {
        await recordPartnerOrderEvent({
          eventAt: new Date().toISOString(),
          eventId: `order_cancel_bridge:${readString(order.id) || orderId}`,
          eventType: "order_canceled",
          order: {
            currencyCode: readString(order.currency_code),
            customerUid: readString(asRecord(order.metadata).bayblaze_account_uid),
            email: readString(order.email),
            id: readString(order.id) || orderId,
            metadata: asRecord(order.metadata),
            status: "cancelled",
          },
        });
      }
      await sendUpstreamJson(res, upstream, "Medusa order cancellation returned a non-JSON response.");
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/orders/live-tracking", requireApiServiceToken, async (req, res, next) => {
    try {
      const parsed = liveTrackingSchema.parse(req.body);
      res.json(await getOrderLiveTracking(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  return router;
}

function readParamString(value: unknown) {
  if (Array.isArray(value)) {
    return typeof value[0] === "string" ? value[0].trim() : "";
  }

  return typeof value === "string" ? value.trim() : "";
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function asRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

async function sendUpstreamJson(
  res: {
    status: (status: number) => {
      json: (body: unknown) => void;
      send: (body: string) => void;
    };
  },
  upstream: Response,
  fallbackMessage: string,
) {
  const text = await upstream.text();

  if (!text.trim()) {
    return res.status(upstream.status).send("");
  }

  try {
    return res.status(upstream.status).json(JSON.parse(text));
  } catch {
    return res.status(upstream.ok ? 502 : upstream.status).json({
      message: fallbackMessage,
      upstreamStatus: upstream.status,
    });
  }
}
