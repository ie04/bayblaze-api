import { createHmac, randomBytes, timingSafeEqual } from "node:crypto";

import type { CommissionStatus, PartnerOrderEventType } from "./partnerTypes";

const reservedCodeTokens = new Set([
  "ADMIN",
  "BAYBLAZE",
  "FREE",
  "GIVEAWAY",
  "OFFICIAL",
  "STAFF",
  "SUPPORT",
]);

export function normalizePartnerCode(value: unknown) {
  return typeof value === "string"
    ? value.trim().replace(/[^a-zA-Z0-9_-]/g, "").slice(0, 40).toUpperCase()
    : "";
}

export function validatePartnerCode(value: unknown, options: { allowLegacyReserved?: boolean } = {}) {
  const code = normalizePartnerCode(value);

  if (!/^[A-Z0-9][A-Z0-9_-]{4,39}$/.test(code)) {
    throw new Error("Referral codes must contain 5 to 40 letters, numbers, dashes, or underscores.");
  }

  const tokens = code.split(/[-_]/).filter(Boolean);
  if (!options.allowLegacyReserved && tokens.some((token) => reservedCodeTokens.has(token))) {
    throw new Error("That referral code uses a reserved or misleading term.");
  }

  return code;
}

export async function generateUniquePartnerCode(input: {
  isTaken: (code: string) => Promise<boolean>;
  prefix: string;
  uid: string;
}) {
  const prefix = normalizePartnerCode(input.prefix).replace(/[-_]/g, "").slice(0, 10) || "LOCAL";
  const stable = createHmac("sha256", `bayblaze-partner-code:${prefix}`)
    .update(input.uid)
    .digest("hex")
    .slice(0, 7)
    .toUpperCase();

  for (let attempt = 0; attempt < 12; attempt += 1) {
    const suffix = attempt === 0 ? stable : randomBytes(5).toString("hex").slice(0, 7).toUpperCase();
    const code = validatePartnerCode(`${prefix}-${suffix}`);
    if (!await input.isTaken(code)) return code;
  }

  throw new Error("Could not generate a unique referral code.");
}

export function percentToBasisPoints(value: unknown) {
  const percent = typeof value === "number" ? value : Number(value);
  if (!Number.isFinite(percent) || percent <= 0 || percent > 100) {
    throw new Error("Commission percent must be between 0 and 100.");
  }
  return Math.round(percent * 100);
}

export function basisPointsToPercent(value: number) {
  return Math.round(value) / 100;
}

export function calculatePartnerCommission(input: {
  commissionRateBps: number;
  originalQualifyingSubtotalCents: number;
  refundedCents?: number;
}) {
  assertNonnegativeInteger(input.originalQualifyingSubtotalCents, "Qualifying subtotal");
  assertNonnegativeInteger(input.refundedCents ?? 0, "Refund amount");
  if (!Number.isInteger(input.commissionRateBps) || input.commissionRateBps <= 0 || input.commissionRateBps > 10_000) {
    throw new Error("Commission rate must be an integer between 1 and 10000 basis points.");
  }

  // Conservative refund rule: refund dollars reduce qualifying product spend first.
  // This can under-credit a partner when a refund includes shipping/tax, but can never
  // make excluded charges commissionable without an itemized refund source.
  const refundedCents = Math.min(input.originalQualifyingSubtotalCents, input.refundedCents ?? 0);
  const qualifyingSubtotalCents = input.originalQualifyingSubtotalCents - refundedCents;
  const commissionCents = Math.round(
    (qualifyingSubtotalCents * input.commissionRateBps) / 10_000,
  );

  return { commissionCents, qualifyingSubtotalCents, refundedCents };
}

export function getCommissionLifecycleUpdate(input: {
  commissionCents: number;
  currentStatus: CommissionStatus;
  eligibilityAt: Date;
  eventAt: Date;
  eventType: PartnerOrderEventType;
  paidCommissionCents?: number;
}) {
  const reversalEvents = new Set<PartnerOrderEventType>([
    "chargeback",
    "order_canceled",
    "payment_failed",
  ]);

  if (reversalEvents.has(input.eventType) || input.commissionCents === 0) {
    return {
      clawbackCents: Math.max(0, (input.paidCommissionCents ?? 0) - input.commissionCents),
      status: "reversed" as const,
    };
  }

  if (input.eventType === "payment_refunded" && (input.paidCommissionCents ?? 0) > 0) {
    return input.commissionCents < (input.paidCommissionCents ?? 0)
      ? {
          clawbackCents: (input.paidCommissionCents ?? 0) - input.commissionCents,
          status: "reversed" as const,
        }
      : { clawbackCents: 0, status: "paid" as const };
  }

  if (["order_completed", "payment_captured"].includes(input.eventType)) {
    return {
      clawbackCents: 0,
      status: input.eventAt >= input.eligibilityAt ? "eligible" as const : "pending" as const,
    };
  }

  if (input.currentStatus === "pending" && input.eventAt >= input.eligibilityAt) {
    return { clawbackCents: 0, status: "eligible" as const };
  }

  return { clawbackCents: 0, status: input.currentStatus };
}

export type AttributionTokenPayload = {
  attributionId: string;
  code: string;
  exp: number;
  partnerUid: string;
};

export function createAttributionToken(payload: AttributionTokenPayload, secret: string) {
  if (!secret) throw new Error("Partner attribution token signing is not configured.");
  const encoded = Buffer.from(JSON.stringify(payload), "utf8").toString("base64url");
  return `${encoded}.${sign(encoded, secret)}`;
}

export function verifyAttributionToken(token: unknown, secret: string, now = new Date()) {
  if (typeof token !== "string" || !secret) return null;
  const [encoded, signature] = token.split(".");
  if (!encoded || !signature || !safeEqual(signature, sign(encoded, secret))) return null;

  try {
    const payload = JSON.parse(Buffer.from(encoded, "base64url").toString("utf8")) as AttributionTokenPayload;
    if (
      !payload.attributionId ||
      !payload.partnerUid ||
      !normalizePartnerCode(payload.code) ||
      !Number.isInteger(payload.exp) ||
      payload.exp <= Math.floor(now.getTime() / 1000)
    ) return null;
    return { ...payload, code: normalizePartnerCode(payload.code) };
  } catch {
    return null;
  }
}

export function getEligibilityDate(start: Date, days: number) {
  return new Date(start.getTime() + days * 24 * 60 * 60 * 1000);
}

export function canAccessPartnerDashboard(status: string) {
  return status === "active";
}

export function isSelfReferralIdentity(input: {
  customerEmail?: string;
  customerUid?: string;
  partnerEmail?: string;
  partnerUid: string;
}) {
  return Boolean(
    (input.customerUid && input.customerUid === input.partnerUid) ||
    (input.customerEmail && input.partnerEmail &&
      input.customerEmail.trim().toLowerCase() === input.partnerEmail.trim().toLowerCase()),
  );
}

export function calculatePayoutSettlement(input: {
  eligibleCommissionCents: number[];
  outstandingClawbackCents: number[];
}) {
  input.eligibleCommissionCents.forEach((amount) => assertNonnegativeInteger(amount, "Eligible commission"));
  input.outstandingClawbackCents.forEach((amount) => assertNonnegativeInteger(amount, "Outstanding clawback"));
  const grossCommissionCents = input.eligibleCommissionCents.reduce((sum, amount) => sum + amount, 0);
  const offsetClawbackCents = input.outstandingClawbackCents.reduce((sum, amount) => sum + amount, 0);
  return {
    grossCommissionCents,
    offsetClawbackCents,
    payableCents: Math.max(0, grossCommissionCents - offsetClawbackCents),
  };
}

function assertNonnegativeInteger(value: number, label: string) {
  if (!Number.isInteger(value) || value < 0) throw new Error(`${label} must be a nonnegative integer.`);
}

function sign(value: string, secret: string) {
  return createHmac("sha256", secret).update(value).digest("base64url");
}

function safeEqual(first: string, second: string) {
  const firstBuffer = Buffer.from(first);
  const secondBuffer = Buffer.from(second);
  return firstBuffer.length === secondBuffer.length && timingSafeEqual(firstBuffer, secondBuffer);
}
