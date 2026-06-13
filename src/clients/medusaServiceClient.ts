import { env } from "../config/env";

export function getMedusaBackendUrl() {
  const value = env.MEDUSA_BACKEND_URL?.replace(/\/$/, "");

  if (!value) {
    throw new Error("MEDUSA_BACKEND_URL is not configured.");
  }

  return value;
}

export function getBayblazeMedusaServiceToken() {
  const value = env.BAYBLAZE_MEDUSA_SERVICE_TOKEN?.trim();

  if (!value) {
    throw new Error(
      "BAYBLAZE_MEDUSA_SERVICE_TOKEN is not configured on bayblaze-api.",
    );
  }

  return value;
}

export function createBayblazeMedusaHeaders(options: {
  acceptJson?: boolean;
  contentTypeJson?: boolean;
} = {}) {
  const serviceToken = getBayblazeMedusaServiceToken();

  return {
    ...(options.acceptJson ? { accept: "application/json" } : {}),
    ...(options.contentTypeJson ? { "content-type": "application/json" } : {}),
    authorization: `Bearer ${serviceToken}`,
    "x-bayblaze-service-token": serviceToken,
  };
}
