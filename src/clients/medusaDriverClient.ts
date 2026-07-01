import { env } from "../config/env";
import { createBayblazeMedusaHeaders, getMedusaBackendUrl } from "./medusaServiceClient";

export function forwardDriverQueueRequest(uid: string, includeUnassigned: boolean) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const path = env.MEDUSA_DRIVER_QUEUE_PATH.replace("{uid}", encodeURIComponent(uid));
  const url = new URL(path, medusaBackendUrl);

  if (includeUnassigned) {
    url.searchParams.set("include_unassigned", "true");
  }

  return fetch(url, {
    headers: createBayblazeMedusaHeaders({ acceptJson: true }),
    method: "GET",
  });
}

export function forwardDeliveryAttempt(body: unknown) {
  const medusaBackendUrl = getMedusaBackendUrl();

  return fetch(new URL(env.MEDUSA_DELIVERY_ATTEMPT_PATH, medusaBackendUrl), {
    body: JSON.stringify(body ?? {}),
    headers: createBayblazeMedusaHeaders({ contentTypeJson: true }),
    method: "POST",
  });
}

export function forwardReprintLabelsRequest(orderId: string, body: unknown) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const path = env.MEDUSA_REPRINT_LABELS_PATH.replace("{orderId}", encodeURIComponent(orderId));

  return fetch(new URL(path, medusaBackendUrl), {
    body: JSON.stringify(body ?? {}),
    headers: createBayblazeMedusaHeaders({
      acceptJson: true,
      contentTypeJson: true,
    }),
    method: "POST",
  });
}
