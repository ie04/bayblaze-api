import { Router, type NextFunction, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { getAccount, loginAccount, sanitizeAccount } from "./accountService";

const loginSchema = z.object({
  email: z.string().min(1),
  password: z.string().min(1),
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
