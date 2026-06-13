import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";

export function assertBayblazeServiceToken(
  req: MedusaRequest,
  res: MedusaResponse,
) {
  const expectedToken =
    process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN?.trim();
  const providedToken = (
    req.get("x-bayblaze-service-token") ||
    req.get("authorization")?.match(/^Bearer\s+(.+)$/i)?.[1] ||
    ""
  ).trim();

  if (!expectedToken) {
    res.status(503).json({
      message:
        "BAYBLAZE_MEDUSA_SERVICE_TOKEN is not configured on Medusa.",
    });
    return false;
  }

  if (!providedToken || providedToken !== expectedToken) {
    res.status(401).json({
      message: "BayBlaze API-to-Medusa service authentication failed.",
    });
    return false;
  }

  return true;
}
