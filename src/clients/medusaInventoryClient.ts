import type { Request } from "express";

function getMedusaBackendUrl() {
  const value = process.env.MEDUSA_BACKEND_URL?.replace(/\/$/, "");

  if (!value) {
    throw new Error("MEDUSA_BACKEND_URL is not configured.");
  }

  return value;
}

function getInventoryServiceToken() {
  const value =
    process.env.BAYBLAZE_INVENTORY_SERVICE_TOKEN ||
    process.env.BAYBLAZE_DRIVER_SERVICE_TOKEN;

  if (!value) {
    throw new Error("BAYBLAZE_INVENTORY_SERVICE_TOKEN is not configured.");
  }

  return value;
}

export async function forwardInventoryRequest(req: Request) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const serviceToken = getInventoryServiceToken();

  return fetch(`${medusaBackendUrl}/admin/bayblaze/inventory`, {
    body: req.method === "POST" ? JSON.stringify(req.body ?? {}) : undefined,
    headers: {
      Authorization: `Bearer ${serviceToken}`,
      "Content-Type": "application/json",
      "x-bayblaze-service-token": serviceToken,
    },
    method: req.method,
  });
}

export async function forwardInventoryImageUpload(formData: FormData) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const serviceToken = getInventoryServiceToken();

  return fetch(`${medusaBackendUrl}/admin/bayblaze/inventory-images`, {
    body: formData,
    headers: {
      Authorization: `Bearer ${serviceToken}`,
      "x-bayblaze-service-token": serviceToken,
    },
    method: "POST",
  });
}

export async function forwardInventoryImageCleanup(rawBody: string) {
  const medusaBackendUrl = getMedusaBackendUrl();
  const serviceToken = getInventoryServiceToken();

  return fetch(`${medusaBackendUrl}/admin/bayblaze/inventory-images`, {
    body: rawBody || "{}",
    headers: {
      Authorization: `Bearer ${serviceToken}`,
      "Content-Type": "application/json",
      "x-bayblaze-service-token": serviceToken,
    },
    method: "DELETE",
  });
}
