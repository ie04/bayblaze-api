import { Router } from "express";

import { forwardIsoChronosJson } from "../../clients/isochronosClient";
import { env } from "../../config/env";
import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { sendUpstreamJson } from "../../http/upstream";

export function createCheckoutBridgeRouter() {
  const router = Router();

  router.post("/checkout/eligibility", requireApiServiceToken, async (req, res, next) => {
    try {
      const upstream = await forwardIsoChronosJson(
        env.ISOCHRONOS_PRECHECKOUT_ELIGIBILITY_PATH,
        req.body,
      );

      await sendUpstreamJson(res, upstream, {
        fallbackMessage: "IsoChronos eligibility API returned a non-JSON response.",
        upstreamName: "IsoChronos eligibility",
      });
    } catch (caught) {
      next(caught);
    }
  });

  return router;
}
