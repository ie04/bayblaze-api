import type { Request } from "express";

import { createBayblazeMedusaHeaders, getMedusaBackendUrl } from "./medusaServiceClient";

export async function forwardInventoryRequest(req: Request) {
  const medusaBackendUrl = getMedusaBackendUrl();

  return fetch(`${medusaBackendUrl}/admin/bayblaze/inventory`, {
    body: req.method === "POST" ? JSON.stringify(req.body ?? {}) : undefined,
    headers: createBayblazeMedusaHeaders({ contentTypeJson: true }),
    method: req.method,
  });
}

export async function forwardInventoryImageUpload(formData: FormData) {
  const medusaBackendUrl = getMedusaBackendUrl();

  return fetch(`${medusaBackendUrl}/admin/bayblaze/inventory-images`, {
    body: formData,
    headers: createBayblazeMedusaHeaders(),
    method: "POST",
  });
}

export async function forwardInventoryImageRead(filename: string) {
  const medusaBackendUrl = getMedusaBackendUrl();

  return fetch(`${medusaBackendUrl}/bayblaze/inventory-images/${encodeURIComponent(filename)}`, {
    method: "GET",
  });
}

export async function forwardInventoryImageCleanup(rawBody: string) {
  const medusaBackendUrl = getMedusaBackendUrl();

  return fetch(`${medusaBackendUrl}/admin/bayblaze/inventory-images`, {
    body: rawBody || "{}",
    headers: createBayblazeMedusaHeaders({ contentTypeJson: true }),
    method: "DELETE",
  });
}
