import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  claimCustomerWinFreebie,
  getCustomerWinFreebies,
  getCustomerWinRewardStatus,
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

export function createWinRewardRouter() {
  const router = Router();

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
