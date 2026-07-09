import { env } from "../config/env";
import { createBayblazeMedusaHeaders, getMedusaBackendUrl } from "./medusaServiceClient";

export function forwardAdminOrdersRequest(query: URLSearchParams) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const url = new URL(env.MEDUSA_ADMIN_ORDERS_PATH, medusaBackendUrl);

  for (const [key, value] of query.entries()) {
    url.searchParams.append(key, value);
  }

  return fetch(url, {
    headers: createBayblazeMedusaHeaders({ acceptJson: true }),
    method: "GET",
  });
}

export function forwardAdminOrderDetailRequest(orderId: string) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const basePath = env.MEDUSA_ADMIN_ORDERS_PATH.replace(/\/$/, "");
  const url = new URL(`${basePath}/${encodeURIComponent(orderId)}`, medusaBackendUrl);

  return fetch(url, {
    headers: createBayblazeMedusaHeaders({ acceptJson: true }),
    method: "GET",
  });
}

export function forwardAdminOrderCancelRequest(orderId: string) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const basePath = env.MEDUSA_ADMIN_ORDERS_PATH.replace(/\/$/, "");
  const url = new URL(`${basePath}/${encodeURIComponent(orderId)}`, medusaBackendUrl);

  return fetch(url, {
    headers: createBayblazeMedusaHeaders({
      acceptJson: true,
      contentTypeJson: true,
    }),
    method: "POST",
    body: JSON.stringify({ action: "cancel" }),
  });
}

export function forwardAdminOrderDeleteRequest(orderId: string, input: { releaseStock: boolean }) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const basePath = env.MEDUSA_ADMIN_ORDERS_PATH.replace(/\/$/, "");
  const url = new URL(`${basePath}/${encodeURIComponent(orderId)}`, medusaBackendUrl);

  return fetch(url, {
    headers: createBayblazeMedusaHeaders({
      acceptJson: true,
      contentTypeJson: true,
    }),
    method: "DELETE",
    body: JSON.stringify(input),
  });
}
