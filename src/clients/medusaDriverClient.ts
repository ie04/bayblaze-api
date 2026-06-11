import { env } from "../config/env";

function getMedusaBackendUrl() {
  const value = env.MEDUSA_BACKEND_URL?.replace(/\/$/, "");

  if (!value) {
    throw new Error("MEDUSA_BACKEND_URL is not configured.");
  }

  return value;
}

function getDriverServiceToken() {
  const value =
    env.BAYBLAZE_DRIVER_SERVICE_TOKEN ||
    env.MEDUSA_ADMIN_API_TOKEN ||
    env.BAYBLAZE_INVENTORY_SERVICE_TOKEN;

  if (!value) {
    throw new Error("BAYBLAZE_DRIVER_SERVICE_TOKEN is not configured.");
  }

  return value;
}

export function forwardDriverQueueRequest(uid: string, includeUnassigned: boolean) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const serviceToken = getDriverServiceToken();
  const path = env.MEDUSA_DRIVER_QUEUE_PATH.replace("{uid}", encodeURIComponent(uid));
  const url = new URL(path, medusaBackendUrl);

  if (includeUnassigned) {
    url.searchParams.set("include_unassigned", "true");
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

export function forwardDeliveryAttempt(body: unknown) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const serviceToken = getDriverServiceToken();

  return fetch(new URL(env.MEDUSA_DELIVERY_ATTEMPT_PATH, medusaBackendUrl), {
    body: JSON.stringify(body ?? {}),
    headers: {
      authorization: `Bearer ${serviceToken}`,
      "content-type": "application/json",
      "x-bayblaze-service-token": serviceToken,
    },
    method: "POST",
  });
}
