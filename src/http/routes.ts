import { Router } from "express";

export function registerRoutes() {
  const router = Router();

  router.get("/health", (_req, res) => {
    res.status(200).json({
      ok: true,
      service: "bayblaze-api",
    });
  });

  router.get("/isochronos/health", (_req, res) => {
    res.status(200).json({
      ok: true,
      module: "isochronos",
      status: "mounted",
    });
  });

  router.get("/inventory/health", (_req, res) => {
    res.status(200).json({
      ok: true,
      module: "inventory",
      status: "mounted",
    });
  });

  router.get("/drivers/health", (_req, res) => {
    res.status(200).json({
      ok: true,
      module: "drivers",
      status: "mounted",
    });
  });

  return router;
}
