import { env } from "../config/env";

function getIsoChronosApiUrl() {
  const value = env.ISOCHRONOS_API_URL?.replace(/\/$/, "");

  if (!value) {
    throw new Error("ISOCHRONOS_API_URL is not configured.");
  }

  return value;
}

function getIsoChronosAdminToken() {
  const value = env.ISOCHRONOS_ADMIN_TOKEN;

  if (!value) {
    throw new Error("ISOCHRONOS_ADMIN_TOKEN is not configured.");
  }

  return value;
}

export function forwardIsoChronosJson(path: string, body: unknown) {
  const apiUrl = getIsoChronosApiUrl();
  const token = getIsoChronosAdminToken();

  return fetch(new URL(path, apiUrl), {
    body: JSON.stringify(body ?? {}),
    headers: {
      authorization: `Bearer ${token}`,
      "content-type": "application/json",
    },
    method: "POST",
  });
}
