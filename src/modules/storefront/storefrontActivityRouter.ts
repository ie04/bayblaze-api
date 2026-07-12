import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, requireAccountRole, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import {
  listStorefrontAbandonmentSessions,
  recordStorefrontActivity,
} from "./storefrontActivityService";

const activityEventTypeSchema = z.enum([
  "activity",
  "beforeunload",
  "cart",
  "checkout",
  "page_view",
  "pagehide",
  "visibility_hidden",
]);

const activityEventSchema = z.object({
  cart: z.object({
    itemCount: z.number().int().nonnegative().optional(),
    valueCents: z.number().int().nonnegative().optional(),
  }).optional(),
  eventId: z.string().min(8).max(140),
  eventType: activityEventTypeSchema,
  occurredAt: z.string().min(1),
  page: z.object({
    path: z.string().min(1).max(300),
    referrer: z.string().max(500).optional(),
    title: z.string().max(200).optional(),
    url: z.string().max(700).optional(),
  }),
  sessionId: z.string().min(8).max(140),
  userAgent: z.string().max(500).optional(),
  visitorId: z.string().min(8).max(140),
});

export function createStorefrontActivityRouter() {
  const router = Router();

  router.post("/storefront/activity/events", async (req, res, next) => {
    try {
      const parsed = activityEventSchema.parse(req.body ?? {});
      res.json(await recordStorefrontActivity(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.use("/admin/storefront-activity", requireAccountAuth, requireAccountRole("admin"));

  router.get("/admin/storefront-activity/sessions", async (req, res, next) => {
    try {
      const limit = Number(req.query.limit) || 100;
      res.json(await listStorefrontAbandonmentSessions(limit));
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: AccountAuthedRequest, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        message: "Invalid storefront activity payload.",
        details: err.flatten(),
      });
    }

    return next(err);
  });

  return router;
}
