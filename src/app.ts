import cors from "cors";
import express, { type NextFunction, type Request, type Response } from "express";
import helmet from "helmet";
import pinoHttp from "pino-http";

import { env } from "./config/env";
import { registerRoutes } from "./http/routes";
import { createAccountRouter } from "./modules/accounts/accountRouter";
import { createAdminRouter } from "./modules/admin/adminRouter";
import { createCheckoutBridgeRouter } from "./modules/checkout/checkoutBridgeRouter";
import { createDriverBridgeRouter } from "./modules/drivers/driverBridgeRouter";
import { createDriverWorkflowRouter } from "./modules/drivers/driverWorkflowRouter";
import { createEmailAutomationRouter } from "./modules/email/emailAutomationRouter";
import { createInventoryBridgeRouter } from "./modules/inventory/inventoryBridgeRouter";
import { IsochronosRequestError } from "./modules/isochronos/googleMapsService";
import { createOrderBridgeRouter } from "./modules/orders/orderBridgeRouter";
import { createPartnerRouter } from "./modules/partners/partnerRouter";
import { createStorefrontActivityRouter } from "./modules/storefront/storefrontActivityRouter";
import { createStorefrontSettingsRouter } from "./modules/storefront/storefrontSettingsRouter";
import { createWinRewardRouter } from "./modules/win/winRewardRouter";

const bayblazeAppOriginPatterns = [
  /^https:\/\/(?:www\.)?bayblaze\.net$/i,
  /^https:\/\/admin\.bayblaze\.net$/i,
  /^https:\/\/driver\.bayblaze\.net$/i,
  /^https:\/\/stock\.bayblaze\.net$/i,
  /^https:\/\/inventory\.bayblaze\.net$/i,
  /^https:\/\/win\.bayblaze\.net$/i,
  /^https:\/\/bayblaze-(?:admin|storefront|driver|inventory|win)(?:-[a-z0-9-]+)?\.vercel\.app$/i,
];

export function createApp() {
  const app = express();

  app.disable("x-powered-by");

  app.use(helmet());

  app.use(
    cors({
      credentials: true,
      origin: isAllowedCorsOrigin,
    }),
  );

  app.use(
    express.json({
      limit: "2mb",
    }),
  );

  app.use(
    pinoHttp({
      redact: {
        paths: ["req.headers.authorization", "req.headers.cookie"],
        remove: true,
      },
    }),
  );

  app.get("/health", (_req, res) => {
    res.status(200).json({
      ok: true,
      service: "bayblaze-api",
    });
  });

  app.use("/v1", registerRoutes());

  app.use("/v1", createAccountRouter());
  app.use("/v1", createAdminRouter());
  app.use("/v1", createInventoryBridgeRouter());
  app.use("/v1", createCheckoutBridgeRouter());
  app.use("/v1", createOrderBridgeRouter());
  app.use("/v1", createPartnerRouter());
  app.use("/v1", createDriverBridgeRouter());
  app.use("/v1", createDriverWorkflowRouter());
  app.use("/v1", createEmailAutomationRouter());
  app.use("/v1", createStorefrontActivityRouter());
  app.use("/v1", createStorefrontSettingsRouter());
  app.use("/v1", createWinRewardRouter());

  app.use((_req, res) => {
    res.status(404).json({
      message: "Route not found.",
    });
  });

  app.use((err: unknown, _req: Request, res: Response, _next: NextFunction) => {
    console.error("Unhandled BayBlaze API error:", err);

    if (err instanceof IsochronosRequestError) {
      return res.status(err.status).json({
        message: err.message,
      });
    }

    res.status(500).json({
      message: err instanceof Error ? err.message : "Unexpected API error.",
    });
  });

  return app;
}

function isAllowedCorsOrigin(origin: string | undefined, callback: (err: Error | null, origin?: boolean) => void) {
  if (!origin) {
    return callback(null, true);
  }

  if (env.CORS_ORIGINS_LIST.length === 0) {
    return callback(null, true);
  }

  if (
    env.CORS_ORIGINS_LIST.includes(origin) ||
    bayblazeAppOriginPatterns.some((pattern) => pattern.test(origin))
  ) {
    return callback(null, true);
  }

  return callback(null, false);
}
