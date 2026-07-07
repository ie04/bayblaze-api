import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, requireAccountRole, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { accountBadges, accountRoles } from "../accounts/accountTypes";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  createAdminIsochronePlot,
  createAdminPromoCode,
  deleteAdminPromoCode,
  getAdminDriverMapState,
  getAdminDriverRoutes,
  listAdminPromoCodes,
  searchAdminAccounts,
  sendAdminOrderDetail,
  sendAdminOrders,
  updateAdminAccount,
  updateAdminPromoCode,
} from "./adminService";

const accountUpdateSchema = z.object({
  badges: z.array(z.enum(accountBadges)).optional(),
  disabled: z.boolean().optional(),
  displayName: z.string().optional(),
  roles: z.array(z.enum(accountRoles)).optional(),
  settings: z.object({
    ageVerificationDisabled: z.boolean().optional(),
  }).optional(),
});

const isochroneSchema = z.object({
  force: z.boolean().optional(),
  origin: z.object({
    address: z.string().optional(),
    lat: z.number().optional(),
    lng: z.number().optional(),
  }),
  speedMph: z.number().optional(),
  travelMinutes: z.number(),
});

const promoCodeCreateSchema = z.object({
  code: z.string().min(1),
  discountPercent: z.number().positive().max(100),
});

const promoCodeUpdateSchema = z.object({
  code: z.string().min(1).optional(),
  discountPercent: z.number().positive().max(100).optional(),
}).refine((value) => value.code !== undefined || value.discountPercent !== undefined, {
  message: "Promo code update requires at least one field.",
});

export function createAdminRouter() {
  const router = Router();

  router.use("/admin", requireAccountAuth, requireAccountRole("admin"));

  router.get("/admin/accounts", async (req, res, next) => {
    try {
      const query = typeof req.query.q === "string" ? req.query.q : "";
      const limit = Math.min(Math.max(Number(req.query.limit) || 25, 1), 100);
      res.json(await searchAdminAccounts(query, limit));
    } catch (caught) {
      next(caught);
    }
  });

  router.patch("/admin/accounts/:uid", async (req, res, next) => {
    try {
      const parsed = accountUpdateSchema.parse(req.body);
      res.json(await updateAdminAccount(String(req.params.uid || ""), parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/admin/drivers/map", async (_req, res, next) => {
    try {
      res.json(await getAdminDriverMapState());
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/admin/drivers/routes", async (_req, res, next) => {
    try {
      res.json(await getAdminDriverRoutes());
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/isochrones", async (req, res, next) => {
    try {
      const parsed = isochroneSchema.parse(req.body);
      res.json({ plot: await createAdminIsochronePlot(parsed) });
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/admin/promo-codes", async (_req, res, next) => {
    try {
      res.json(await listAdminPromoCodes());
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/promo-codes", async (req, res, next) => {
    try {
      const parsed = promoCodeCreateSchema.parse(req.body ?? {});
      res.json(await createAdminPromoCode(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.patch("/admin/promo-codes/:code", async (req, res, next) => {
    try {
      const parsed = promoCodeUpdateSchema.parse(req.body ?? {});
      res.json(await updateAdminPromoCode(String(req.params.code || ""), parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.delete("/admin/promo-codes/:code", async (req, res, next) => {
    try {
      res.json(await deleteAdminPromoCode(String(req.params.code || "")));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/admin/orders", async (req, res, next) => {
    try {
      const query = new URLSearchParams();

      for (const [key, value] of Object.entries(req.query)) {
        if (Array.isArray(value)) {
          value.forEach((item) => query.append(key, String(item)));
        } else if (value !== undefined) {
          query.append(key, String(value));
        }
      }

      await sendAdminOrders(res, query);
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/admin/orders/:orderId", async (req, res, next) => {
    try {
      await sendAdminOrderDetail(res, String(req.params.orderId || ""));
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: AccountAuthedRequest, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        message: "Invalid admin API payload.",
        details: err.flatten(),
      });
    }

    if (err instanceof ApiRequestError) {
      return res.status(err.status).json({
        message: err.message,
      });
    }

    return next(err);
  });

  return router;
}
