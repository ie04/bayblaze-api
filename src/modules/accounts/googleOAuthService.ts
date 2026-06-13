import { createHmac, randomBytes, timingSafeEqual } from "node:crypto";

import { getBayblazeAuth } from "../../clients/firebaseAdminClient";
import { createMedusaCustomerSession } from "../../clients/medusaCustomerSessionClient";
import { env } from "../../config/env";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import {
  createSessionResponse,
  ensureAccountRecord,
  getAccount,
  parseEmail,
} from "./accountService";

type GoogleOAuthState = {
  callbackUrl: string;
  commerce?: "storefront";
  exp: number;
  nonce: string;
  redirectTo?: string;
  version: 1;
};

type GoogleTokenResponse = {
  access_token?: string;
  error?: string;
  error_description?: string;
  id_token?: string;
};

type GoogleTokenInfoResponse = {
  aud?: string;
  email?: string;
  email_verified?: string | boolean;
  error?: string;
  family_name?: string;
  given_name?: string;
  name?: string;
  sub?: string;
};

const googleAuthorizationUrl = "https://accounts.google.com/o/oauth2/v2/auth";
const googleTokenUrl = "https://oauth2.googleapis.com/token";
const googleTokenInfoUrl = "https://oauth2.googleapis.com/tokeninfo";
const stateTtlSeconds = 10 * 60;

export function createGoogleOAuthStart(input: {
  callbackUrl: string;
  commerce?: "storefront";
  redirectTo?: string;
}) {
  const { clientId } = getGoogleOAuthConfig();
  const callbackUrl = parseUrl(input.callbackUrl, "Google OAuth callback URL is not valid.");
  assertAllowedCallbackUrl(callbackUrl);
  const redirectTo = parseRedirectTo(input.redirectTo);
  const state = signState({
    callbackUrl,
    commerce: input.commerce,
    exp: Math.floor(Date.now() / 1000) + stateTtlSeconds,
    nonce: randomBytes(16).toString("base64url"),
    redirectTo,
    version: 1,
  });
  const authorizationUrl = new URL(googleAuthorizationUrl);

  authorizationUrl.searchParams.set("client_id", clientId);
  authorizationUrl.searchParams.set("redirect_uri", callbackUrl);
  authorizationUrl.searchParams.set("response_type", "code");
  authorizationUrl.searchParams.set("scope", "openid email profile");
  authorizationUrl.searchParams.set("state", state);
  authorizationUrl.searchParams.set("prompt", "select_account");

  return {
    authorizationUrl: authorizationUrl.toString(),
    expiresInSeconds: stateTtlSeconds,
  };
}

export async function completeGoogleOAuth(input: {
  callbackUrl: string;
  code: string;
  state: string;
}) {
  const state = verifyState(input.state);
  const callbackUrl = parseUrl(input.callbackUrl, "Google OAuth callback URL is not valid.");
  assertAllowedCallbackUrl(callbackUrl);

  if (callbackUrl !== state.callbackUrl) {
    throw new ApiRequestError(400, "Google OAuth callback URL does not match.");
  }

  const googleProfile = await exchangeCodeForGoogleProfile(input.code, callbackUrl);
  const email = parseEmail(googleProfile.email);
  const authUser = await getOrCreateGoogleFirebaseUser({
    displayName: googleProfile.name,
    email,
  });
  const displayName = googleProfile.name || authUser.displayName || "";
  const existingAccount = await getAccount(authUser.uid);
  const account = await ensureAccountRecord(authUser.uid, email, {
    badges: existingAccount?.badges ?? ["customer"],
    displayName,
  });
  const medusaSession = state.commerce === "storefront" && account.badges.includes("customer")
    ? await createMedusaCustomerSession({
        email,
        firstName: googleProfile.given_name,
        googleSubject: googleProfile.sub,
        lastName: googleProfile.family_name,
      })
    : null;

  return {
    ...createSessionResponse(account),
    ...(medusaSession
      ? {
          commerce: {
            customer: medusaSession.customer,
            customerToken: medusaSession.token,
          },
        }
      : {}),
    redirectTo: state.redirectTo ?? "/account",
  };
}

async function exchangeCodeForGoogleProfile(code: string, callbackUrl: string) {
  const { clientId, clientSecret } = getGoogleOAuthConfig();
  const tokenResponse = await fetch(googleTokenUrl, {
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      code,
      grant_type: "authorization_code",
      redirect_uri: callbackUrl,
    }),
    headers: { "content-type": "application/x-www-form-urlencoded" },
    method: "POST",
  });
  const tokenPayload = (await tokenResponse.json().catch(() => ({}))) as GoogleTokenResponse;

  if (!tokenResponse.ok || !tokenPayload.id_token) {
    throw new ApiRequestError(
      401,
      tokenPayload.error_description || tokenPayload.error || "Google sign-in could not be verified.",
    );
  }

  const profileResponse = await fetch(
    `${googleTokenInfoUrl}?id_token=${encodeURIComponent(tokenPayload.id_token)}`,
  );
  const profile = (await profileResponse.json().catch(() => ({}))) as GoogleTokenInfoResponse;

  if (!profileResponse.ok || profile.error) {
    throw new ApiRequestError(401, profile.error || "Google sign-in could not be verified.");
  }

  if (profile.aud !== clientId || !profile.sub || !profile.email) {
    throw new ApiRequestError(401, "Google sign-in token is not valid for BayBlaze.");
  }

  if (profile.email_verified !== true && profile.email_verified !== "true") {
    throw new ApiRequestError(403, "Google did not return a verified email address.");
  }

  return profile;
}

async function getOrCreateGoogleFirebaseUser(input: {
  displayName?: string;
  email: string;
}) {
  const auth = getBayblazeAuth();
  const existing = await auth.getUserByEmail(input.email).catch((caught) => {
    if (
      typeof caught === "object" &&
      caught !== null &&
      "code" in caught &&
      caught.code === "auth/user-not-found"
    ) {
      return null;
    }

    throw caught;
  });

  if (existing) {
    if (existing.disabled) {
      throw new ApiRequestError(403, "This BayBlaze account is disabled.");
    }

    if (input.displayName && !existing.displayName) {
      await auth.updateUser(existing.uid, { displayName: input.displayName });
    }

    return existing;
  }

  return auth.createUser({
    disabled: false,
    displayName: input.displayName || undefined,
    email: input.email,
    emailVerified: true,
  });
}

function getGoogleOAuthConfig() {
  const clientId = env.GOOGLE_OAUTH_CLIENT_ID;
  const clientSecret = env.GOOGLE_OAUTH_CLIENT_SECRET;

  if (!clientId || !clientSecret) {
    throw new ApiRequestError(503, "Google sign-in is not configured.");
  }

  return { clientId, clientSecret };
}

function signState(payload: GoogleOAuthState) {
  const encodedPayload = Buffer.from(JSON.stringify(payload), "utf8").toString("base64url");
  const signature = sign(encodedPayload);

  return `${encodedPayload}.${signature}`;
}

function verifyState(state: string) {
  const [encodedPayload, signature] = state.split(".");

  if (!encodedPayload || !signature || !safeEqual(signature, sign(encodedPayload))) {
    throw new ApiRequestError(400, "Google sign-in state is not valid.");
  }

  const payload = JSON.parse(Buffer.from(encodedPayload, "base64url").toString("utf8")) as GoogleOAuthState;

  if (
    payload.version !== 1 ||
    !payload.callbackUrl ||
    !payload.nonce ||
    payload.exp < Math.floor(Date.now() / 1000)
  ) {
    throw new ApiRequestError(400, "Google sign-in state expired. Try again.");
  }

  return payload;
}

function sign(value: string) {
  const secret =
    env.ACCOUNT_SESSION_SECRET ||
    env.DRIVER_SESSION_SECRET ||
    env.BAYBLAZE_API_SERVICE_TOKEN;

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

function parseUrl(value: unknown, message: string) {
  if (typeof value !== "string") {
    throw new ApiRequestError(400, message);
  }

  try {
    return new URL(value).toString();
  } catch {
    throw new ApiRequestError(400, message);
  }
}

function assertAllowedCallbackUrl(callbackUrl: string) {
  if (!env.GOOGLE_OAUTH_REDIRECT_URL) {
    return;
  }

  if (callbackUrl !== new URL(env.GOOGLE_OAUTH_REDIRECT_URL).toString()) {
    throw new ApiRequestError(400, "Google OAuth callback URL is not allowed.");
  }
}

function parseRedirectTo(value: unknown) {
  if (typeof value !== "string" || !value.startsWith("/") || value.startsWith("//")) {
    return "/account";
  }

  return value;
}
