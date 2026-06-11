import type { Response as ExpressResponse } from "express";

export async function sendUpstreamJson(
  res: ExpressResponse,
  upstream: globalThis.Response,
  options: {
    fallbackMessage: string;
    upstreamName: string;
  },
) {
  const responseText = await upstream.text();
  let responseBody: { message?: unknown } | Record<string, unknown>;

  try {
    responseBody = responseText ? JSON.parse(responseText) : {};
  } catch {
    responseBody = {
      message: responseText || options.fallbackMessage,
    };
  }

  if (!upstream.ok && typeof responseBody.message !== "string") {
    responseBody = {
      ...responseBody,
      message: `${options.upstreamName} request failed with HTTP ${upstream.status}.`,
    };
  }

  return res.status(upstream.status).json(responseBody);
}
