import Busboy from "busboy";
import { Router, type NextFunction, type Request, type Response } from "express";
import { z } from "zod";

import { requireAccountAuth, requireAccountRole, type AccountAuthedRequest } from "../../http/middleware/accountAuth";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  createNfcOrder,
  getNfcOrder,
  handleNfcStripeWebhook,
  listNfcAdminSummary,
  quoteNfcOrder,
  recordNfcAdminAudit,
  resolveNfcAttribution,
  storeNfcUpload,
} from "./nfcService";
import { nfcAttributionSchema, nfcOrderCreateSchema, nfcQuoteSchema } from "./nfcValidation";

export function createNfcRouter() {
  const router = Router();

  router.post("/nfc/attributions", async (req, res, next) => {
    try {
      const parsed = nfcAttributionSchema.parse(req.body ?? {});
      res.status(201).json(await resolveNfcAttribution(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/nfc/orders/quote", async (req, res, next) => {
    try {
      const parsed = nfcQuoteSchema.parse(req.body ?? {});
      res.json(await quoteNfcOrder(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/nfc/orders", async (req, res, next) => {
    try {
      const parsed = nfcOrderCreateSchema.parse(req.body ?? {});
      res.status(201).json(await createNfcOrder(parsed));
    } catch (caught) {
      next(caught);
    }
  });

  router.get("/nfc/orders/:orderId", async (req, res, next) => {
    try {
      res.json(await getNfcOrder(String(req.params.orderId || "")));
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/nfc/uploads", async (req, res, next) => {
    const busboy = Busboy({
      headers: req.headers,
      limits: { fileSize: 8 * 1024 * 1024, files: 1, fields: 0 },
    });
    const chunks: Buffer[] = [];
    let filename = "upload";
    let mimeType = "";
    let failed = false;

    busboy.on("file", (_name, file, info) => {
      filename = info.filename || filename;
      mimeType = info.mimeType || "";
      file.on("data", (chunk: Buffer) => chunks.push(chunk));
      file.on("limit", () => {
        failed = true;
      });
    });
    busboy.on("error", next);
    busboy.on("finish", async () => {
      try {
        if (failed) throw new ApiRequestError(413, "Image uploads must be 8 MB or smaller.");
        res.status(201).json(await storeNfcUpload({ buffer: Buffer.concat(chunks), filename, mimeType }));
      } catch (caught) {
        next(caught);
      }
    });
    req.pipe(busboy);
  });

  router.post("/nfc/stripe/webhook", async (req, res, next) => {
    try {
      const body = Buffer.isBuffer(req.body) ? req.body : Buffer.from(JSON.stringify(req.body ?? {}));
      res.json(await handleNfcStripeWebhook({
        body,
        signature: Array.isArray(req.headers["stripe-signature"])
          ? req.headers["stripe-signature"][0]
          : req.headers["stripe-signature"],
      }));
    } catch (caught) {
      next(caught);
    }
  });

  router.use("/admin/nfc", requireAccountAuth, requireAccountRole("admin"));

  router.get("/admin/nfc/summary", async (_req, res, next) => {
    try {
      res.json(await listNfcAdminSummary());
    } catch (caught) {
      next(caught);
    }
  });

  router.post("/admin/nfc/audit-events", async (req: AccountAuthedRequest, res, next) => {
    try {
      const parsed = z.object({
        action: z.string().min(1).max(120),
        reason: z.string().min(1).max(500),
        subjectId: z.string().min(1).max(180),
      }).parse(req.body ?? {});
      res.status(201).json(await recordNfcAdminAudit({
        ...parsed,
        adminUid: req.accountAuth?.uid || "",
      }));
    } catch (caught) {
      next(caught);
    }
  });

  router.use((err: unknown, _req: Request, res: Response, next: NextFunction) => {
    if (err instanceof z.ZodError) {
      return res.status(400).json({ message: "Invalid NFC API payload.", details: err.flatten() });
    }
    if (err instanceof ApiRequestError) {
      return res.status(err.status).json({ message: err.message });
    }
    return next(err);
  });

  return router;
}
