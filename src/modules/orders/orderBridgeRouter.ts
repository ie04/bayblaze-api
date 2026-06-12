import { Router } from "express";
import { z } from "zod";

import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { getOrderLiveTracking } from "../isochronos/orderLiveTrackingService";

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
