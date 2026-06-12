import { env } from "../config/env";

function getMedusaBackendUrl() {
  const value = env.MEDUSA_BACKEND_URL?.replace(/\/$/, "");

  if (!value) {
    throw new Error("MEDUSA_BACKEND_URL is not configured.");
  }

  return value;
}

function getMedusaAdminToken() {
  const value =
    env.BAYBLAZE_INVENTORY_SERVICE_TOKEN ||
    env.BAYBLAZE_DRIVER_SERVICE_TOKEN ||
    env.MEDUSA_ADMIN_API_TOKEN;

  if (!value) {
    throw new Error("BayBlaze Medusa service token is not configured.");
  }

  return value;
}

export function forwardAdminOrdersRequest(query: URLSearchParams) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const serviceToken = getMedusaAdminToken();
  const url = new URL(env.MEDUSA_ADMIN_ORDERS_PATH, medusaBackendUrl);

  for (const [key, value] of query.entries()) {
    url.searchParams.append(key, value);
  }

  return fetch(url, {
    headers: {
      accept: "application/json",
      authorization: `Bearer ${serviceToken}`,
      "x-bayblaze-service-token": serviceToken,
    },
    method: "GET",
  });
}

export function forwardAdminOrderDetailRequest(orderId: string) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const serviceToken = getMedusaAdminToken();
  const basePath = env.MEDUSA_ADMIN_ORDERS_PATH.replace(/\/$/, "");
  const url = new URL(`${basePath}/${encodeURIComponent(orderId)}`, medusaBackendUrl);

  return fetch(url, {
    headers: {
      accept: "application/json",
      authorization: `Bearer ${serviceToken}`,
      "x-bayblaze-service-token": serviceToken,
    },
    method: "GET",
  });
}
