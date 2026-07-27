import { Router, type NextFunction, type RequestHandler, type Response } from "express";
import { z } from "zod";

import {
  requireAccountAuth,
  requireAccountRole,
  type AccountAuthedRequest,
} from "../../http/middleware/accountAuth";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  getPartnerAccount,
  getPartnerClaimCode,
  getPartnerEarnings,
  getPartnerOverview,
  getPartnerProfile,
  createActivePartnerWithPromo,
  claimPartnerClaimCode,
  createPartnerClaimCode,
  enrollPartnerAccount,
  listAdminPartners,
  listPartnerPayouts,
  listPartnerReferrals,
  recordAdminExternalPayout,
  recordPartnerOrderEvent,
  resolvePartnerAttribution,
  submitPartnerApplication,
  updateAdminPartnerStatus,
} from "./partnerService";
import {
  commissionStatuses,
  partnerOrderEventTypes,
  partnerStatuses,
} from "./partnerTypes";

const attributionSchema = z.object({
  code: z.string().min(1).max(80),
  existingToken: z.string().max(2048).optional(),
  sourcePath: z.string().max(200).optional(),
});

const paginationSchema = z.object({
  cursor: z.string().max(1000).optional(),
  limit: z.coerce.number().int().min(1).max(50).default(20),
});

const referralQuerySchema = paginationSchema.extend({
  q: z.string().max(80).optional(),
  status: z.enum(commissionStatuses).optional(),
});

const partnerStatusSchema = z.object({
  status: z.enum(partnerStatuses),
});

const enrollmentSchema = z.object({
  acceptedTerms: z.literal(true),
});

const claimCodeCreateSchema = z.object({
  code: z.string().min(5).max(40).optional(),
  note: z.string().max(500).optional(),
});

const approvalSchema = z.object({
  code: z.string().min(5).max(40).optional(),
  commissionPercent: z.number().positive().max(100),
  discountPercent: z.number().positive().max(100),
  minimumSpendCents: z.number().int().nonnegative().optional(),
  singleUsePerAccount: z.boolean().optional(),
});

const payoutSchema = z.object({
  idempotencyKey: z.string().min(8).max(120),
  methodLabel: z.string().min(1).max(80),
  reference: z.string().min(1).max(120),
});

const orderEventSchema = z.object({
  eventAt: z.string().datetime().optional(),
  eventId: z.string().min(1).max(240),
  eventType: z.enum(partnerOrderEventTypes),
  order: z.object({
    currencyCode: z.string().max(12).optional(),
    customerName: z.string().max(160).optional(),
    customerUid: z.string().max(180).optional(),
    email: z.string().max(320).optional(),
    fulfillmentStatus: z.string().max(80).optional(),
    id: z.string().min(1).max(180),
    metadata: z.record(z.unknown()).optional(),
    paymentStatus: z.string().max(80).optional(),
    refundedCents: z.number().int().nonnegative().optional(),
    status: z.string().max(80).optional(),
  }),
});

type PartnerRouterDependencies = {
  accountAuth?: RequestHandler;
  serviceAuth?: RequestHandler;
  services?: Partial<PartnerRouterServices>;
};

type PartnerRouterServices = {
  claimPartnerClaimCode: typeof claimPartnerClaimCode;
  createActivePartnerWithPromo: typeof createActivePartnerWithPromo;
  createPartnerClaimCode: typeof createPartnerClaimCode;
  enrollPartnerAccount: typeof enrollPartnerAccount;
  getPartnerAccount: typeof getPartnerAccount;
  getPartnerClaimCode: typeof getPartnerClaimCode;
  getPartnerEarnings: typeof getPartnerEarnings;
  getPartnerOverview: typeof getPartnerOverview;
  getPartnerProfile: typeof getPartnerProfile;
  listAdminPartners: typeof listAdminPartners;
  listPartnerPayouts: typeof listPartnerPayouts;
  listPartnerReferrals: typeof listPartnerReferrals;
  recordAdminExternalPayout: typeof recordAdminExternalPayout;
  recordPartnerOrderEvent: typeof recordPartnerOrderEvent;
  resolvePartnerAttribution: typeof resolvePartnerAttribution;
  submitPartnerApplication: typeof submitPartnerApplication;
  updateAdminPartnerStatus: typeof updateAdminPartnerStatus;
};

export function createPartnerRouter(dependencies: PartnerRouterDependencies = {}) {
  const router = Router();
  const accountAuth = dependencies.accountAuth ?? requireAccountAuth;
  const serviceAuth = dependencies.serviceAuth ?? requirePartnerEventServiceToken;
  const services: PartnerRouterServices = {
    claimPartnerClaimCode,
    createActivePartnerWithPromo,
    createPartnerClaimCode,
    enrollPartnerAccount,
    getPartnerAccount,
    getPartnerClaimCode,
    getPartnerEarnings,
    getPartnerOverview,
    getPartnerProfile,
    listAdminPartners,
    listPartnerPayouts,
    listPartnerReferrals,
    recordAdminExternalPayout,
    recordPartnerOrderEvent,
    resolvePartnerAttribution,
    submitPartnerApplication,
    updateAdminPartnerStatus,
    ...dependencies.services,
  };

  router.post("/partners/attributions", async (req, res, next) => {
    try {
      const parsed = attributionSchema.parse(req.body ?? {});
      res.status(201).json(await services.resolvePartnerAttribution(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/partners/order-events", serviceAuth, async (req, res, next) => {
    try {
      const parsed = orderEventSchema.parse(req.body ?? {});
      res.json(await services.recordPartnerOrderEvent(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/partners/claim-codes/:code", async (req, res, next) => {
    try {
      res.json(await services.getPartnerClaimCode(readParam(req.params.code)));
    } catch (caught) {
      next(caught);
    }
  });

  router.use("/partners/me", accountAuth, requireCustomerBadge);

  router.post("/partners/me/claim-codes/:code/claim", async (req: AccountAuthedRequest, res, next) => {
    try {
      res.status(201).json(await services.claimPartnerClaimCode(readUid(req), readParam(req.params.code)));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/partners/me/application", async (req: AccountAuthedRequest, res, next) => {
    try {
      res.status(201).json(await services.submitPartnerApplication(readUid(req)));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/partners/me/enrollment", async (req: AccountAuthedRequest, res, next) => {
    try {
      const parsed = enrollmentSchema.parse(req.body ?? {});
      res.status(201).json(await services.enrollPartnerAccount(readUid(req), parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/partners/me", async (req: AccountAuthedRequest, res, next) => {
    try {
      res.json(await services.getPartnerProfile(readUid(req)));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/partners/me/overview", async (req: AccountAuthedRequest, res, next) => {
    try {
      res.json(await services.getPartnerOverview(readUid(req)));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/partners/me/referrals", async (req: AccountAuthedRequest, res, next) => {
    try {
      const parsed = referralQuerySchema.parse(req.query ?? {});
      res.json(await services.listPartnerReferrals(readUid(req), {
        cursor: parsed.cursor,
        limit: parsed.limit,
        query: parsed.q,
        status: parsed.status,
      }));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/partners/me/earnings", async (req: AccountAuthedRequest, res, next) => {
    try {
      res.json(await services.getPartnerEarnings(readUid(req)));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/partners/me/payouts", async (req: AccountAuthedRequest, res, next) => {
    try {
      const parsed = paginationSchema.parse(req.query ?? {});
      res.json(await services.listPartnerPayouts(readUid(req), parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/partners/me/account", async (req: AccountAuthedRequest, res, next) => {
    try {
      res.json(await services.getPartnerAccount(readUid(req)));
    } catch (caught) {
      next(caught);
    }
  });

  router.use("/admin/partners", accountAuth, requireAccountRole("admin"));

  router.get("/admin/partners", async (_req, res, next) => {
    try {
      res.json(await services.listAdminPartners());
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/partners/claim-codes", async (req: AccountAuthedRequest, res, next) => {
    try {
      const parsed = claimCodeCreateSchema.parse(req.body ?? {});
      res.status(201).json({ claimCode: await services.createPartnerClaimCode({
        ...parsed,
        createdByUid: readUid(req),
      }) });
    } catch (caught) {
      next(caught);
    }
  });

  router.patch("/admin/partners/:uid", async (req, res, next) => {
    try {
      const parsed = partnerStatusSchema.parse(req.body ?? {});
      res.json(await services.updateAdminPartnerStatus(readParam(req.params.uid), parsed.status));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/partners/:uid/approve", async (req, res, next) => {
    try {
      const parsed = approvalSchema.parse(req.body ?? {});
      const uid = readParam(req.params.uid);
      const promoCode = await services.createActivePartnerWithPromo({ ...parsed, ownerUid: uid });
      res.status(201).json({ partner: (await services.getPartnerProfile(uid)).partner, promoCode });
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/partners/:uid/payouts/record", async (req, res, next) => {
    try {
      const parsed = payoutSchema.parse(req.body ?? {});
      res.status(201).json(await services.recordAdminExternalPayout(readParam(req.params.uid), parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: AccountAuthedRequest, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        details: err.flatten(),
        message: "Invalid partner API request.",
      });
    }
    if (err instanceof ApiRequestError) {
      return res.status(err.status).json({ message: err.message });
    }
    return next(err);
  });

  return router;
}

function requireCustomerBadge(req: AccountAuthedRequest, res: Response, next: NextFunction) {
  if (!req.accountAuth?.badges.includes("customer")) {
    return res.status(403).json({ message: "Customer account access is required." });
  }
  return next();
}

function readUid(req: AccountAuthedRequest) {
  const uid = req.accountAuth?.uid;
  if (!uid) throw new ApiRequestError(401, "BayBlaze account sign-in is required.");
  return uid;
}

function readParam(value: unknown) {
  const result = Array.isArray(value) ? value[0] : value;
  if (typeof result !== "string" || !result.trim()) throw new ApiRequestError(400, "Partner account UID is required.");
  return result.trim();
}

function requirePartnerEventServiceToken(req: AccountAuthedRequest, res: Response, next: NextFunction) {
  const allowedTokens = [
    process.env.BAYBLAZE_API_SERVICE_TOKEN,
    process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN,
  ].map(readOptionalString).filter(Boolean);
  const authorization = typeof req.headers.authorization === "string" ? req.headers.authorization.trim() : "";
  const bearer = authorization.toLowerCase().startsWith("bearer ") ? authorization.slice(7).trim() : "";
  const provided = bearer || readOptionalString(req.headers["x-bayblaze-api-token"]) || readOptionalString(req.headers["x-bayblaze-service-token"]);

  if (!allowedTokens.length) return res.status(503).json({ message: "Partner event service auth is not configured." });
  if (!allowedTokens.includes(provided)) return res.status(401).json({ message: "Unauthorized partner event request." });
  return next();
}

function readOptionalString(value: unknown) {
  const result = Array.isArray(value) ? value[0] : value;
  return typeof result === "string" ? result.trim() : "";
}
