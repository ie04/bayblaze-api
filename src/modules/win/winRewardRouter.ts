import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { requireApiServiceToken } from "../../http/middleware/apiServiceAuth";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { completeWinReferral } from "./winReferralCompletionService";
import {
  claimCustomerWinFreebie,
  claimCustomerWinFreebieByToken,
  getCustomerWinFreebies,
  getCustomerWinRewardStatus,
  previewCustomerDiscountCode,
  previewPublicDiscountCode,
  recordCustomerDiscountCodeUse,
  startCustomerWinReward,
} from "./winRewardService";

const winContextSchema = z.object({
  campaign: z.string().optional(),
  nfcTagId: z.string().optional(),
  source: z.string().optional(),
  tag: z.string().optional(),
});

const freebieClaimSchema = z.object({
  campaign: z.string().optional(),
  claimToken: z.string().optional(),
  productId: z.string().min(1),
  variantId: z.string().optional(),
});

const serviceFreebieClaimSchema = z.object({
  claimToken: z.string().min(1),
  orderId: z.string().min(1),
  productId: z.string().min(1),
  variantId: z.string().optional(),
});

const completionSchema = z.object({
  completedOrderId: z.string().optional(),
  customerEmail: z.string().optional(),
  customerId: z.string().optional(),
  customerUid: z.string().optional(),
  isCustomerFirstOrder: z.boolean().optional(),
  orderId: z.string().optional(),
  referralCode: z.string().min(1),
});

const discountPreviewSchema = z.object({
  code: z.string().min(1),
  items: z.array(z.object({
    quantity: z.number().int().positive().optional(),
    unitPriceCents: z.number().int().nonnegative().optional(),
  })).optional(),
  subtotalCents: z.number().int().nonnegative().optional(),
});

const discountUseSchema = z.object({
  code: z.string().min(1),
  customerEmail: z.string().optional(),
  customerId: z.string().optional(),
  isCustomerFirstOrder: z.boolean().optional(),
  orderId: z.string().min(1),
});

export function createWinRewardRouter() {
  const router = Router();

  router.post("/win/referrals/complete", requireApiServiceToken, async (req, res, next) => {
    try {
      const parsed = completionSchema.parse(req.body ?? {});
      res.json(await completeWinReferral(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/win/freebies/claim", requireApiServiceToken, async (req, res, next) => {
    try {
      const parsed = serviceFreebieClaimSchema.parse(req.body ?? {});
      res.json(await claimCustomerWinFreebieByToken(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/discount-codes/preview", async (req, res, next) => {
    try {
      const parsed = discountPreviewSchema.parse(req.body ?? {});

      res.json(await previewPublicDiscountCode(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.use("/customer/win", requireAccountAuth, requireCustomerBadge);

  router.post("/customer/win/start", async (req: AccountAuthedRequest, res, next) => {
    try {
      const uid = readRequiredUid(req);
      const parsed = winContextSchema.parse(req.body ?? {});

      res.json(await startCustomerWinReward(uid, {
        campaign: parsed.campaign,
        nfcTagId: parsed.nfcTagId || parsed.tag,
        source: parsed.source,
      }));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/customer/win/status", async (req: AccountAuthedRequest, res, next) => {
    try {
      const uid = readRequiredUid(req);
      const parsed = winContextSchema.parse(req.query ?? {});

      res.json(await getCustomerWinRewardStatus(uid, {
        campaign: parsed.campaign,
        nfcTagId: parsed.nfcTagId || parsed.tag,
        source: parsed.source,
      }));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/customer/win/freebies", async (_req: AccountAuthedRequest, res, next) => {
    try {
      res.json(await getCustomerWinFreebies());
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/customer/win/freebies/claim", async (req: AccountAuthedRequest, res, next) => {
    try {
      const uid = readRequiredUid(req);
      const parsed = freebieClaimSchema.parse(req.body ?? {});

      res.json(await claimCustomerWinFreebie(uid, parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post(
    "/customer/discount-codes/preview",
    requireAccountAuth,
    requireCustomerBadge,
    async (req: AccountAuthedRequest, res, next) => {
      try {
        const uid = readRequiredUid(req);
        const parsed = discountPreviewSchema.parse(req.body ?? {});

        res.json(await previewCustomerDiscountCode(uid, parsed));
      } catch (caught) {
        next(caught);
      }
    },
  );

  router.post(
    "/customer/discount-codes/use",
    requireAccountAuth,
    requireCustomerBadge,
    async (req: AccountAuthedRequest, res, next) => {
      try {
        const uid = readRequiredUid(req);
        const parsed = discountUseSchema.parse(req.body ?? {});

        res.json(await recordCustomerDiscountCodeUse(uid, parsed));
      } catch (caught) {
        next(caught);
      }
    },
  );

  router.use((err: unknown, _req: AccountAuthedRequest, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        message: "Invalid win reward API payload.",
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

function requireCustomerBadge(req: AccountAuthedRequest, res: Response, next: NextFunction) {
  if (!req.accountAuth?.badges.includes("customer")) {
    return res.status(403).json({
      message: "Customer account access is required.",
    });
  }

  return next();
}

function readRequiredUid(req: AccountAuthedRequest) {
  const uid = req.accountAuth?.uid;

  if (!uid) {
    throw new ApiRequestError(401, "BayBlaze account sign-in is required.");
  }

  return uid;
}
