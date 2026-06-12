import { Router } from "express";
import { z } from "zod";

import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { evaluatePreCheckoutEligibility } from "../isochronos/checkoutEligibilityService";

const preCheckoutEligibilitySchema = z.object({
  checkoutId: z.string().optional(),
  createdAt: z.string().optional(),
  customerId: z.string().optional(),
  destination: z.record(z.string(), z.any()).optional(),
  items: z.array(z.record(z.string(), z.any())).min(1),
  priority: z.enum(["LOW", "NORMAL", "HIGH"]).optional(),
  promisedWindowMinutes: z.number().int().positive().optional(),
  requestedDeliveryMode: z.enum(["NOW", "SCHEDULED"]).optional(),
});

export function createCheckoutBridgeRouter() {
  const router = Router();

  router.post("/checkout/eligibility", requireApiServiceToken, async (req, res, next) => {
    try {
      const parsed = preCheckoutEligibilitySchema.parse(req.body);
      const eligibility = await evaluatePreCheckoutEligibility(parsed);

      res.json({
        evaluationType: "pre-checkout delivery eligibility evaluation",
        ...eligibility,
      });
    } catch (caught) {
      next(caught);
    }
  });

  return router;
}
