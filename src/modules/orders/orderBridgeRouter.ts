import { Router } from "express";

import { forwardIsoChronosJson } from "../../clients/isochronosClient";
import { env } from "../../config/env";
import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { sendUpstreamJson } from "../../http/upstream";

export function createOrderBridgeRouter() {
  const router = Router();

  router.post("/orders/live-tracking", requireApiServiceToken, async (req, res, next) => {
    try {
      const upstream = await forwardIsoChronosJson(
        env.ISOCHRONOS_ORDER_TRACKING_PATH,
        req.body,
      );

      await sendUpstreamJson(res, upstream, {
        fallbackMessage: "IsoChronos order tracking API returned a non-JSON response.",
        upstreamName: "IsoChronos order tracking",
      });
    } catch (caught) {
      next(caught);
    }
  });

  return router;
}
