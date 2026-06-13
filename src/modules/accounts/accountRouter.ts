import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  createCustomerAccount,
  getAccount,
  loginAccount,
  loginCustomerAccount,
  sanitizeAccount,
} from "./accountService";
import {
  completeGoogleOAuth,
  createGoogleOAuthStart,
} from "./googleOAuthService";

const loginSchema = z.object({
  email: z.string().min(1),
  password: z.string().min(1),
});

const customerCreateSchema = z.object({
  displayName: z.string().optional(),
  email: z.string().min(1),
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  password: z.string().min(1),
});

const googleOAuthStartSchema = z.object({
  callbackUrl: z.string().min(1),
  redirectTo: z.string().optional(),
});

const googleOAuthCallbackSchema = z.object({
  callbackUrl: z.string().min(1),
  code: z.string().min(1),
  state: z.string().min(1),
});

export function createAccountRouter() {
  const router = Router();

  router.post("/auth/login", async (req, res, next) => {
    try {
      const parsed = loginSchema.parse(req.body);
      res.json(await loginAccount(parsed.email, parsed.password));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/customer/auth/login", async (req, res, next) => {
    try {
      const parsed = loginSchema.parse(req.body);
      res.json(await loginCustomerAccount(parsed.email, parsed.password));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/customer/auth/accounts", async (req, res, next) => {
    try {
      const parsed = customerCreateSchema.parse(req.body);
      res.json(await createCustomerAccount(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/customer/auth/google/start", async (req, res, next) => {
    try {
      const parsed = googleOAuthStartSchema.parse(req.body);
      res.json(createGoogleOAuthStart(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/customer/auth/google/callback", async (req, res, next) => {
    try {
      const parsed = googleOAuthCallbackSchema.parse(req.body);
      res.json(await completeGoogleOAuth(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/auth/me", requireAccountAuth, async (req: AccountAuthedRequest, res, next) => {
    try {
      const uid = req.accountAuth?.uid;
      const account = uid ? await getAccount(uid) : null;

      if (!account) {
        throw new ApiRequestError(404, "BayBlaze account was not found.");
      }

      res.json({ account: sanitizeAccount(account) });
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: AccountAuthedRequest, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        message: "Invalid account API payload.",
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
