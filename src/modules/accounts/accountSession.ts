import { createHmac, timingSafeEqual } from "node:crypto";

import { env } from "../../config/env";
import type { AccountSessionPayload } from "./accountTypes";

export function createAccountSessionToken(input: {
  badges: AccountSessionPayload["badges"];
  email: string;
  roles: AccountSessionPayload["roles"];
  settings: AccountSessionPayload["settings"];
  uid: string;
}) {
  const payload: AccountSessionPayload = {
    email: input.email,
    exp: Math.floor(Date.now() / 1000) + env.ACCOUNT_SESSION_TTL_SECONDS,
    badges: input.badges,
    roles: input.roles,
    settings: input.settings,
    uid: input.uid,
  };
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));
  const signature = sign(encodedPayload);

  return `${encodedPayload}.${signature}`;
}

export function verifyAccountSessionToken(token: string) {
  const [encodedPayload, signature] = token.split(".");

  if (!encodedPayload || !signature || !safeEqual(signature, sign(encodedPayload))) {
    return null;
  }

  try {
    const payload = JSON.parse(base64UrlDecode(encodedPayload)) as AccountSessionPayload;

    if (!payload.uid || !payload.email || payload.exp < Math.floor(Date.now() / 1000)) {
      return null;
    }

    return {
      ...payload,
      roles: Array.isArray(payload.roles) ? payload.roles : [],
      badges: Array.isArray(payload.badges) ? payload.badges : [],
      settings: {
        ageVerificationDisabled: payload.settings?.ageVerificationDisabled === true,
      },
    };
  } catch {
    return null;
  }
}

function sign(value: string) {
  const secret = env.ACCOUNT_SESSION_SECRET || env.DRIVER_SESSION_SECRET || env.BAYBLAZE_API_SERVICE_TOKEN;

  if (!secret) {
    throw new Error("Account session signing is not configured.");
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
