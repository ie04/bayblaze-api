import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, requireAccountRole, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { accountBadges, accountRoles } from "../accounts/accountTypes";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  createAdminCoverageArea,
  createAdminIsochronePlot,
  createAdminPromoCode,
  deleteAdminCoverageArea,
  deleteAdminPromoCode,
  getAdminDriverMapState,
  getAdminDriverRoutes,
  listAdminCoverageAreas,
  listAdminEmailAutomations,
  listAdminPromoCodes,
  regenerateAdminCoverageArea,
  regenerateDueAdminCoverageAreas,
  searchAdminAccounts,
  sendAdminEmailAutomationTest,
  sendAdminOrderDetail,
  sendAdminOrderDelete,
  sendAdminOrders,
  updateAdminAccount,
  updateAdminCoverageArea,
  updateAdminEmailAutomation,
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
  travelMinutes: z.number(),
});

const promoCodeTypeSchema = z.enum(["discount", "bogo"]);
const emailAutomationEventTypeSchema = z.enum(["order_placed"]);
const emailRecipientModeSchema = z.enum(["customer", "internal", "both"]);

const coverageAreaSchema = z.object({
  active: z.boolean().optional(),
  description: z.string().optional(),
  granularity: z.object({
    binarySearchIterations: z.number().int().min(3).optional(),
    sampleBearings: z.number().int().min(8).optional(),
  }).optional(),
  label: z.string().min(1).optional(),
  maxDriveTimeMinutes: z.number().positive().max(180).optional(),
  schedule: z.object({
    enabled: z.boolean().optional(),
    intervalHours: z.number().positive().max(24 * 30).nullable().optional(),
    nextRunAt: z.string().nullable().optional(),
  }).optional(),
  warehouse: z.object({
    address: z.string().optional(),
    label: z.string().optional(),
    lat: z.number().optional(),
    lng: z.number().optional(),
    warehouseId: z.string().optional(),
  }).optional(),
});

const coverageAreaCreateSchema = coverageAreaSchema.extend({
  label: z.string().min(1),
  maxDriveTimeMinutes: z.number().positive().max(180),
  warehouse: z.object({
    address: z.string().optional(),
    label: z.string().optional(),
    lat: z.number().optional(),
    lng: z.number().optional(),
    warehouseId: z.string().optional(),
  }),
});

const coverageAreaUpdateSchema = coverageAreaSchema.extend({
  regenerate: z.boolean().optional(),
});

const promoCodeCreateSchema = z.object({
  code: z.string().min(1),
  codeType: promoCodeTypeSchema.optional(),
  discountPercent: z.number().positive().max(100).optional(),
  minimumSpendCents: z.number().int().nonnegative().optional(),
  singleUsePerAccount: z.boolean().optional(),
}).refine((value) => value.codeType === "bogo" || value.discountPercent !== undefined, {
  message: "Discount percent is required for percent-off promo codes.",
  path: ["discountPercent"],
});

const promoCodeUpdateSchema = z.object({
  code: z.string().min(1).optional(),
  codeType: promoCodeTypeSchema.optional(),
  discountPercent: z.number().positive().max(100).optional(),
  minimumSpendCents: z.number().int().nonnegative().optional(),
  singleUsePerAccount: z.boolean().optional(),
}).refine((value) => value.code !== undefined || value.codeType !== undefined || value.discountPercent !== undefined || value.minimumSpendCents !== undefined || value.singleUsePerAccount !== undefined, {
  message: "Promo code update requires at least one field.",
});

const orderDeleteSchema = z.object({
  releaseStock: z.boolean().optional().default(false),
});

const emailAutomationUpdateSchema = z.object({
  enabled: z.boolean().optional(),
  fromEmail: z.string().optional(),
  htmlTemplate: z.string().min(1).optional(),
  internalRecipientEmails: z.array(z.string()).optional(),
  recipientMode: emailRecipientModeSchema.optional(),
  replyTo: z.string().optional(),
  subjectTemplate: z.string().min(1).optional(),
  textTemplate: z.string().min(1).optional(),
});

const emailAutomationTestSchema = z.object({
  recipientEmail: z.string().min(1),
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

  router.get("/admin/coverage-areas", async (_req, res, next) => {
    try {
      res.json(await listAdminCoverageAreas());
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/coverage-areas", async (req, res, next) => {
    try {
      const parsed = coverageAreaCreateSchema.parse(req.body ?? {});
      res.json(await createAdminCoverageArea(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/coverage-areas/regenerate-due", async (_req, res, next) => {
    try {
      res.json(await regenerateDueAdminCoverageAreas());
    } catch (caught) {
      next(caught);
    }
  });

  router.patch("/admin/coverage-areas/:coverageAreaId", async (req, res, next) => {
    try {
      const parsed = coverageAreaUpdateSchema.parse(req.body ?? {});
      res.json(await updateAdminCoverageArea(String(req.params.coverageAreaId || ""), parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.delete("/admin/coverage-areas/:coverageAreaId", async (req, res, next) => {
    try {
      res.json(await deleteAdminCoverageArea(String(req.params.coverageAreaId || "")));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/coverage-areas/:coverageAreaId/regenerate", async (req, res, next) => {
    try {
      res.json(await regenerateAdminCoverageArea(String(req.params.coverageAreaId || "")));
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

  router.get("/admin/email-automations", async (_req, res, next) => {
    try {
      res.json(await listAdminEmailAutomations());
    } catch (caught) {
      next(caught);
    }
  });

  router.patch("/admin/email-automations/:eventType", async (req, res, next) => {
    try {
      const eventType = emailAutomationEventTypeSchema.parse(String(req.params.eventType || ""));
      const parsed = emailAutomationUpdateSchema.parse(req.body ?? {});
      res.json(await updateAdminEmailAutomation(eventType, parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/email-automations/:eventType/test", async (req, res, next) => {
    try {
      const eventType = emailAutomationEventTypeSchema.parse(String(req.params.eventType || ""));
      const parsed = emailAutomationTestSchema.parse(req.body ?? {});
      res.json(await sendAdminEmailAutomationTest(eventType, parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/promo-codes", async (req, res, next) => {
    try {
      const parsed = promoCodeCreateSchema.parse(req.body ?? {});
      res.json(await createAdminPromoCode({
        code: parsed.code,
        codeType: parsed.codeType,
        discountPercent: parsed.discountPercent ?? 0,
        minimumSpendCents: parsed.minimumSpendCents,
        singleUsePerAccount: parsed.singleUsePerAccount,
      }));
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

  router.delete("/admin/orders/:orderId", async (req, res, next) => {
    try {
      const parsed = orderDeleteSchema.parse(req.body ?? {});
      await sendAdminOrderDelete(res, String(req.params.orderId || ""), parsed);
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
