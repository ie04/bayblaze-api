import { createHmac, timingSafeEqual } from "node:crypto";

import { env } from "../../config/env";

type DriverSessionPayload = {
  email: string;
  exp: number;
  uid: string;
};

export function createDriverSessionToken(input: { email: string; uid: string }) {
  const payload: DriverSessionPayload = {
    email: input.email,
    exp: Math.floor(Date.now() / 1000) + env.DRIVER_SESSION_TTL_SECONDS,
    uid: input.uid,
  };
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signature = sign(encodedPayload);

  return `${encodedPayload}.${signature}`;
}

export function verifyDriverSessionToken(token: string) {
  const [encodedPayload, signature] = token.split(".");

  if (!encodedPayload || !signature || !safeEqual(signature, sign(encodedPayload))) {
    return null;
  }

  try {
    const payload = JSON.parse(base64UrlDecode(encodedPayload)) as DriverSessionPayload;

    if (!payload.uid || payload.exp < Math.floor(Date.now() / 1000)) {
      return null;
    }

    return payload;
  } catch {
    return null;
  }
}

function sign(value: string) {
  const secret = env.DRIVER_SESSION_SECRET || env.BAYBLAZE_API_SERVICE_TOKEN;

  if (!secret) {
    throw new Error("Driver session signing is not configured.");
  }

  return createHmac("sha256", secret).update(value).digest("base64url");
}

function safeEqual(first: string, second: string) {
  const firstBuffer = Buffer.from(first);
  const secondBuffer = Buffer.from(second);

  return firstBuffer.length === secondBuffer.length && timingSafeEqual(firstBuffer, secondBuffer);
}

function base64UrlEncode(value: string) {
  return Buffer.from(value, "utf8").toString("base64url");
}

function base64UrlDecode(value: string) {
  return Buffer.from(value, "base64url").toString("utf8");
}
