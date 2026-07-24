import assert from "node:assert/strict";
import { once } from "node:events";
import test from "node:test";

import express, { type NextFunction, type Response } from "express";

import type { AccountAuthedRequest } from "../src/http/middleware/accountAuth";
import { createPartnerRouter } from "../src/modules/partners/partnerRouter";
import { serializePartnerReferralActivity } from "../src/modules/partners/partnerService";
import type { PartnerCommissionRecord } from "../src/modules/partners/partnerTypes";

test("self-service routes derive the partner UID from the authenticated session", async () => {
  let requestedUid = "";
  let requestedQuery: Record<string, unknown> = {};
  const app = express();
  app.use(express.json());
  app.use("/v1", createPartnerRouter({
    accountAuth: (req: AccountAuthedRequest, _res: Response, next: NextFunction) => {
      req.accountAuth = {
        badges: ["customer"], email: "a@example.com", exp: 2_000_000_000,
        roles: [], settings: { ageVerificationDisabled: false }, uid: "account-a",
      };
      next();
    },
    services: {
      listPartnerReferrals: (async (uid: string, input: Record<string, unknown>) => {
        requestedUid = uid;
        requestedQuery = input;
        return { items: [], nextCursor: null, total: 0 };
      }) as never,
    },
  }));
  const server = app.listen(0);
  await once(server, "listening");
  const address = server.address();
  assert(address && typeof address === "object");

  try {
    const response = await fetch(`http://127.0.0.1:${address.port}/v1/partners/me/referrals?partnerId=account-b&limit=2&q=1234&status=pending`);
    assert.equal(response.status, 200);
    assert.equal(requestedUid, "account-a");
    assert.deepEqual(requestedQuery, { cursor: undefined, limit: 2, query: "1234", status: "pending" });
  } finally {
    server.close();
    await once(server, "close");
  }
});

test("partner pagination and filters enforce safe input limits", async () => {
  let called = false;
  const app = express();
  app.use(express.json());
  app.use("/v1", createPartnerRouter({
    accountAuth: (req: AccountAuthedRequest, _res: Response, next: NextFunction) => {
      req.accountAuth = {
        badges: ["customer"], email: "a@example.com", exp: 2_000_000_000,
        roles: [], settings: { ageVerificationDisabled: false }, uid: "account-a",
      };
      next();
    },
    services: { listPartnerReferrals: (async () => { called = true; return { items: [], nextCursor: null, total: 0 }; }) as never },
  }));
  const server = app.listen(0);
  await once(server, "listening");
  const address = server.address();
  assert(address && typeof address === "object");

  try {
    const tooLarge = await fetch(`http://127.0.0.1:${address.port}/v1/partners/me/referrals?limit=51`);
    assert.equal(tooLarge.status, 400);
    assert.equal(called, false);
    const invalidStatus = await fetch(`http://127.0.0.1:${address.port}/v1/partners/me/referrals?status=available`);
    assert.equal(invalidStatus.status, 400);
  } finally {
    server.close();
    await once(server, "close");
  }
});

test("partner enrollment derives UID and requires accepted terms", async () => {
  let requestedUid = "";
  let requestedInput: Record<string, unknown> = {};
  const app = express();
  app.use(express.json());
  app.use("/v1", createPartnerRouter({
    accountAuth: (req: AccountAuthedRequest, _res: Response, next: NextFunction) => {
      req.accountAuth = {
        badges: ["customer"], email: "a@example.com", exp: 2_000_000_000,
        roles: [], settings: { ageVerificationDisabled: false }, uid: "account-a",
      };
      next();
    },
    services: {
      enrollPartnerAccount: (async (uid: string, input: Record<string, unknown>) => {
        requestedUid = uid;
        requestedInput = input;
        return { partner: { status: "pending", uid } };
      }) as never,
    },
  }));
  const server = app.listen(0);
  await once(server, "listening");
  const address = server.address();
  assert(address && typeof address === "object");

  try {
    const missingTerms = await fetch(`http://127.0.0.1:${address.port}/v1/partners/me/enrollment`, {
      body: JSON.stringify({}),
      headers: { "content-type": "application/json" },
      method: "POST",
    });
    assert.equal(missingTerms.status, 400);

    const enrolled = await fetch(`http://127.0.0.1:${address.port}/v1/partners/me/enrollment`, {
      body: JSON.stringify({ acceptedTerms: true }),
      headers: { "content-type": "application/json" },
      method: "POST",
    });
    assert.equal(enrolled.status, 201);
    assert.equal(requestedUid, "account-a");
    assert.deepEqual(requestedInput, { acceptedTerms: true });
  } finally {
    server.close();
    await once(server, "close");
  }
});

test("partner activity contracts expose privacy-safe customer labels only", () => {
  const record: PartnerCommissionRecord = {
    attributedAt: "2026-07-01T00:00:00.000Z", attributionId: "a1", attributionSource: "promo_query",
    clawbackCents: 0, clawbackSettledCents: 0, commissionCents: 300, commissionRateBps: 3000,
    createdAt: "2026-07-01T00:00:00.000Z", currency: "usd", customerLabel: "Customer ··9F2A",
    customerRef: "private-hash", eligibilityAt: "2026-07-08T00:00:00.000Z", eligibleAt: "",
    orderId: "order_123", orderStatus: "processing", originalCommissionCents: 300,
    orderCompletedAt: "2026-07-01T01:00:00.000Z", originalQualifyingSubtotalCents: 1000,
    paidCommissionCents: 0, partnerUid: "partner-a", paymentCapturedAt: "2026-07-01T00:30:00.000Z", payoutId: "",
    qualifyingSubtotalCents: 1000, referralCode: "LOCAL-12345", refundedCents: 0, status: "pending",
    updatedAt: "2026-07-01T00:00:00.000Z",
  };
  const activity = serializePartnerReferralActivity(record);
  assert.equal(activity.customerLabel, "Customer ··9F2A");
  assert.equal("customerRef" in activity, false);
  assert.equal("partnerUid" in activity, false);
  assert.equal("referralCode" in activity, false);
});

test("trusted order events require a configured service token", async () => {
  const previous = process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN;
  process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN = "partner-router-test-token";
  let called = false;
  const app = express();
  app.use(express.json());
  app.use("/v1", createPartnerRouter({
    services: {
      recordPartnerOrderEvent: (async () => { called = true; return { ignored: true, reason: "not_partner_promo" }; }) as never,
    },
  }));
  const server = app.listen(0);
  await once(server, "listening");
  const address = server.address();
  assert(address && typeof address === "object");
  const body = JSON.stringify({ eventId: "event-1", eventType: "order_placed", order: { id: "order-1", metadata: {} } });

  try {
    const unauthorized = await fetch(`http://127.0.0.1:${address.port}/v1/partners/order-events`, {
      body, headers: { "content-type": "application/json" }, method: "POST",
    });
    assert.equal(unauthorized.status, 401);
    assert.equal(called, false);
    const authorized = await fetch(`http://127.0.0.1:${address.port}/v1/partners/order-events`, {
      body,
      headers: { "content-type": "application/json", "x-bayblaze-service-token": "partner-router-test-token" },
      method: "POST",
    });
    assert.equal(authorized.status, 200);
    assert.equal(called, true);
  } finally {
    if (previous === undefined) delete process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN;
    else process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN = previous;
    server.close();
    await once(server, "close");
  }
});
