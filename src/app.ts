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
import { createInventoryBridgeRouter } from "./modules/inventory/inventoryBridgeRouter";
import { IsochronosRequestError } from "./modules/isochronos/googleMapsService";
import { createOrderBridgeRouter } from "./modules/orders/orderBridgeRouter";

export function createApp() {
  const app = express();

  app.disable("x-powered-by");

  app.use(helmet());

  app.use(
    cors({
      credentials: true,
      origin:
        env.CORS_ORIGINS_LIST.length > 0
          ? env.CORS_ORIGINS_LIST
          : true,
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
  app.use("/v1", createDriverBridgeRouter());
  app.use("/v1", createDriverWorkflowRouter());

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
