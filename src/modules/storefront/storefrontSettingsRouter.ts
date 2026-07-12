import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, requireAccountRole, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import {
  getStorefrontSettings,
  updateStorefrontSettings,
} from "./storefrontSettingsService";

const storefrontSettingsUpdateSchema = z.object({
  priceAdjustmentCents: z.number().int().nonnegative().max(1_000_000_00),
});

export function createStorefrontSettingsRouter() {
  const router = Router();

  router.get("/storefront/settings", async (_req, res, next) => {
    try {
      res.json({ settings: await getStorefrontSettings() });
    } catch (caught) {
      next(caught);
    }
  });

  router.use("/admin/storefront-settings", requireAccountAuth, requireAccountRole("admin"));

  router.get("/admin/storefront-settings", async (_req, res, next) => {
    try {
      res.json({ settings: await getStorefrontSettings() });
    } catch (caught) {
      next(caught);
    }
  });

  router.patch("/admin/storefront-settings", async (req, res, next) => {
    try {
      const parsed = storefrontSettingsUpdateSchema.parse(req.body ?? {});
      res.json({ settings: await updateStorefrontSettings(parsed) });
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: AccountAuthedRequest, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        message: "Invalid storefront settings payload.",
        details: err.flatten(),
      });
    }

    return next(err);
  });

  return router;
}
