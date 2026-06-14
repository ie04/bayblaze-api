import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, requireAccountRole, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { accountBadges, accountRoles } from "../accounts/accountTypes";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  createAdminIsochronePlot,
  getAdminDriverMapState,
  getAdminDriverRoutes,
  searchAdminAccounts,
  sendAdminOrderDetail,
  sendAdminOrders,
  updateAdminAccount,
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
