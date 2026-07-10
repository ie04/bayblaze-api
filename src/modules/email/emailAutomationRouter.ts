import { Router, type NextFunction, type Request, type Response } from "express";
import { z } from "zod";

import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  triggerEmailAutomationEvent,
  type EmailAutomationEventInput,
} from "./emailAutomationService";

const emailEventTypeSchema = z.enum(["order_placed"]);

const emailEventSchema = z.object({
  eventId: z.string().optional(),
  eventType: emailEventTypeSchema,
  order: z.record(z.unknown()).optional(),
  payload: z.record(z.unknown()).optional(),
});

export function createEmailAutomationRouter() {
  const router = Router();

  router.post("/email/events", requireEmailEventServiceToken, async (req, res, next) => {
    try {
      const parsed = emailEventSchema.parse(req.body ?? {});
      res.json(await triggerEmailAutomationEvent(parsed as EmailAutomationEventInput));
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: Request, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({
        details: err.flatten(),
        message: "Invalid email automation event payload.",
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

function requireEmailEventServiceToken(req: Request, res: Response, next: NextFunction) {
  const allowedTokens = [
    process.env.BAYBLAZE_API_SERVICE_TOKEN,
    process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN,
  ]
    .map(readString)
    .filter(Boolean);

  if (allowedTokens.length === 0) {
    return res.status(503).json({
      message: "BayBlaze email event service auth is not configured.",
    });
  }

  const providedToken =
    readBearerToken(req.headers.authorization) ||
    readString(req.headers["x-bayblaze-api-token"]) ||
    readString(req.headers["x-bayblaze-service-token"]);

  if (!allowedTokens.includes(providedToken)) {
    return res.status(401).json({
      message: "Unauthorized BayBlaze email event request.",
    });
  }

  return next();
}

function readBearerToken(value: unknown) {
  const header = readString(value);

  if (!header.toLowerCase().startsWith("bearer ")) {
    return "";
  }

  return header.slice("bearer ".length).trim();
}

function readString(value: unknown) {
  if (Array.isArray(value)) {
    return typeof value[0] === "string" ? value[0].trim() : "";
  }

  return typeof value === "string" ? value.trim() : "";
}
