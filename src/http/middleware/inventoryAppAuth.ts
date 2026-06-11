import type { NextFunction, Request, Response } from "express";

export function requireInventoryAppToken(req: Request, res: Response, next: NextFunction) {
  const expectedToken = readString(process.env.BAYBLAZE_API_SERVICE_TOKEN);

  if (!expectedToken) {
    return res.status(503).json({
      message: "BayBlaze API inventory auth is not configured.",
    });
  }

  const providedToken =
    readBearerToken(req.headers.authorization) ||
    readString(req.headers["x-bayblaze-api-token"]);

  if (providedToken !== expectedToken) {
    return res.status(401).json({
      message: "Unauthorized BayBlaze inventory API request.",
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
