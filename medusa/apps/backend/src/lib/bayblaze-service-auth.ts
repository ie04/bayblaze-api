import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";

export function assertBayblazeServiceToken(
  req: MedusaRequest,
  res: MedusaResponse,
) {
  const expectedToken =
    process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN ||
    process.env.BAYBLAZE_INVENTORY_SERVICE_TOKEN ||
    process.env.BAYBLAZE_DRIVER_SERVICE_TOKEN ||
    process.env.MEDUSA_ADMIN_API_TOKEN;
  const providedToken =
    req.get("x-bayblaze-service-token") ||
    req.get("authorization")?.match(/^Bearer\s+(.+)$/i)?.[1];

  if (!expectedToken) {
    res.status(503).json({ message: "BayBlaze service token is not configured." });
    return false;
  }

  if (!providedToken || providedToken !== expectedToken) {
    res.status(401).json({ message: "Unauthorized" });
    return false;
  }

  return true;
}
