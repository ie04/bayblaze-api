import { createHash, randomBytes } from "node:crypto";

import { FieldValue, Timestamp } from "firebase-admin/firestore";
import Stripe from "stripe";

import { getBayblazeFirestore, getBayblazeStorage } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import { ApiRequestError } from "../drivers/driverWorkflowService";
import { geocodeAddress, calculateRouteDuration } from "../isochronos/googleMapsService";
import { verifyAttributionToken } from "../partners/partnerDomain";
import { getPartner, resolvePartnerAttribution } from "../partners/partnerService";
import { calculateNfcMoney, nfcAffiliateCommissionCents } from "./nfcPricing";
import type { NfcAddressInput, NfcCustomerInput, NfcDesignInput, NfcFulfillmentInput } from "./nfcTypes";

const nfcOrdersCollection = "nfc_orders";
const nfcUploadsCollection = "nfc_private_uploads";
const nfcWebhookEventsCollection = "nfc_stripe_webhook_events";
const nfcAuditCollection = "nfc_admin_audit_events";
const commissionLedgerCollection = "nfc_affiliate_commissions";
const maxLocalDeliveryMinutes = 30;
const safeProtocols = new Set(["http:", "https:"]);
const uploadMimeTypes = new Set(["image/png", "image/jpeg", "image/webp"]);
const maxUploadBytes = 8 * 1024 * 1024;

let stripeClient: Stripe | null = null;

export async function resolveNfcAttribution(input: { code: string; existingToken?: string; sourcePath?: string }) {
  const result = await resolvePartnerAttribution({
    code: input.code,
    existingToken: input.existingToken,
    sourcePath: input.sourcePath || "/",
  });

  return {
    ...result,
    referralLink: buildNfcReferralLink(result.code),
  };
}

export async function quoteNfcOrder(input: {
  attributionToken?: string;
  customer?: Partial<NfcCustomerInput>;
  design: NfcDesignInput;
  fulfillment: NfcFulfillmentInput;
}) {
  const normalizedDestination = normalizeProgrammedDestination(input.design.productType, input.design.programmedDestination);
  const fulfillmentEligibility = await evaluateFulfillment(input.fulfillment);
  const money = calculateNfcMoney({
    fulfillmentMethod: fulfillmentEligibility.fulfillmentMethod,
    localDeliveryFeeCents: env.NFC_LOCAL_DELIVERY_FEE_CENTS,
    productType: input.design.productType,
    taxRateBps: env.NFC_TAX_RATE_BPS,
    uspsStandardFeeCents: env.NFC_USPS_STANDARD_FEE_CENTS,
    usesCustomColors: input.design.productType === "custom" ? false : input.design.customColors,
  });
  const attribution = await readValidatedAttribution(input.attributionToken);

  return {
    attribution: attribution ? { active: true, code: attribution.code } : { active: false },
    currency: "usd",
    fulfillmentEligibility,
    money,
    normalizedDestination,
    pricingPolicy: {
      commissionCents: nfcAffiliateCommissionCents,
      localDeliveryMaxMinutes: maxLocalDeliveryMinutes,
    },
  };
}

export async function createNfcOrder(input: {
  attributionToken?: string;
  customer?: Partial<NfcCustomerInput>;
  design: NfcDesignInput;
  fulfillment: NfcFulfillmentInput;
  idempotencyKey: string;
}) {
  const customer = requireCompleteCustomer(input.customer);
  const quote = await quoteNfcOrder(input);
  const orderId = `nfc_${createHash("sha256").update(input.idempotencyKey).digest("hex").slice(0, 24)}`;
  const db = getBayblazeFirestore();
  const orderRef = db.collection(nfcOrdersCollection).doc(orderId);
  const existing = await orderRef.get();

  if (existing.exists) {
    const serialized = serializeOrderResponse(existing.id, existing.data() ?? {});
    return {
      clientSecret: readString((existing.data() ?? {}).stripeClientSecret),
      order: serialized.order,
    };
  }

  if (input.fulfillment.method === "local_delivery" && quote.fulfillmentEligibility.status !== "eligible") {
    throw new ApiRequestError(409, "Local delivery is not available for this address. USPS standard shipping is available.");
  }

  const stripe = getStripe();
  const paymentIntent = await stripe.paymentIntents.create({
    amount: quote.money.totalCents,
    automatic_payment_methods: { enabled: true },
    currency: "usd",
    description: "BayBlaze NFC tag order",
    metadata: {
      nfc_order_id: orderId,
      referral_active: quote.attribution.active ? "true" : "false",
    },
    receipt_email: customer.email,
  }, {
    idempotencyKey: `nfc-order:${orderId}`,
  });

  const now = FieldValue.serverTimestamp();
  await orderRef.create({
    attribution: quote.attribution,
    attributionToken: input.attributionToken || null,
    createdAt: now,
    currency: "usd",
    customer,
    design: {
      ...input.design,
      customColors: input.design.productType === "custom" ? false : input.design.customColors,
      normalizedDestination: quote.normalizedDestination,
    },
    fulfillment: {
      ...input.fulfillment,
      method: quote.fulfillmentEligibility.fulfillmentMethod,
    },
    fulfillmentEligibility: quote.fulfillmentEligibility,
    idempotencyKey: input.idempotencyKey,
    money: quote.money,
    orderId,
    paymentIntentId: paymentIntent.id,
    status: "payment_pending",
    stripe: {
      paymentIntentId: paymentIntent.id,
    },
    stripeClientSecret: paymentIntent.client_secret,
    updatedAt: now,
  });

  return {
    clientSecret: paymentIntent.client_secret,
    order: serializeOrderResponse(orderId, (await orderRef.get()).data() ?? {}).order,
  };
}

export async function getNfcOrder(orderId: string) {
  const snapshot = await getBayblazeFirestore().collection(nfcOrdersCollection).doc(orderId).get();
  if (!snapshot.exists) throw new ApiRequestError(404, "NFC order was not found.");
  return serializeOrderResponse(snapshot.id, snapshot.data() ?? {});
}

export async function storeNfcUpload(input: {
  buffer: Buffer;
  filename: string;
  mimeType: string;
}) {
  if (!uploadMimeTypes.has(input.mimeType)) {
    throw new ApiRequestError(400, "Upload must be a PNG, JPEG, or WebP image.");
  }
  if (input.buffer.length > maxUploadBytes) {
    throw new ApiRequestError(413, "Image uploads must be 8 MB or smaller.");
  }
  assertImageMagic(input.buffer, input.mimeType);

  const uploadId = `nfc_upload_${randomBytes(18).toString("base64url")}`;
  const extension = input.mimeType === "image/png" ? "png" : input.mimeType === "image/webp" ? "webp" : "jpg";
  const storagePath = `nfc-order-assets/${uploadId}.${extension}`;
  const bucket = getBayblazeStorage().bucket();
  await bucket.file(storagePath).save(input.buffer, {
    contentType: input.mimeType,
    metadata: {
      cacheControl: "private, max-age=0, no-store",
      metadata: {
        originalNameHash: createHash("sha256").update(input.filename).digest("hex"),
      },
    },
    resumable: false,
  });
  await getBayblazeFirestore().collection(nfcUploadsCollection).doc(uploadId).create({
    contentType: input.mimeType,
    createdAt: FieldValue.serverTimestamp(),
    sizeBytes: input.buffer.length,
    storagePath,
    uploadId,
  });

  return { contentType: input.mimeType, sizeBytes: input.buffer.length, storageRef: storagePath, uploadId };
}

export async function handleNfcStripeWebhook(input: {
  body: Buffer;
  signature: string | undefined;
}) {
  const stripe = getStripe();
  const event = stripe.webhooks.constructEvent(input.body, input.signature || "", requireEnv("NFC_STRIPE_WEBHOOK_SECRET"));
  const eventRef = getBayblazeFirestore().collection(nfcWebhookEventsCollection).doc(event.id);
  const existing = await eventRef.get();
  if (existing.exists) return { duplicate: true, eventId: event.id };

  await eventRef.create({
    createdAt: FieldValue.serverTimestamp(),
    eventId: event.id,
    type: event.type,
  });

  if (event.type === "payment_intent.succeeded") {
    await markOrderPaid(event.data.object as Stripe.PaymentIntent, event.id);
  }
  if (["payment_intent.canceled", "charge.refunded", "charge.dispute.created"].includes(event.type)) {
    await reverseOrderCommission(event);
  }

  await eventRef.set({ processedAt: FieldValue.serverTimestamp() }, { merge: true });
  return { ok: true, eventId: event.id };
}

export async function listNfcAdminSummary() {
  const snapshot = await getBayblazeFirestore().collection(nfcOrdersCollection).orderBy("createdAt", "desc").limit(100).get();
  const orders = snapshot.docs.map((doc) => serializeSafeOrder(doc.id, doc.data() ?? {}));
  const commissions = await getBayblazeFirestore().collection(commissionLedgerCollection).orderBy("createdAt", "desc").limit(100).get();
  const ledger = commissions.docs.map((doc) => ({ id: doc.id, data: doc.data() ?? {} }));
  return {
    commissionLedger: ledger,
    metrics: {
      orders: orders.length,
      paidSalesCents: orders
        .filter((order) => order.status !== "payment_pending")
        .reduce((sum, order) => sum + readNumber(order.money.totalCents), 0),
      pendingCommissionsCents: ledger
        .filter((entry) => readString(entry.data.status) === "pending")
        .reduce((sum, entry) => sum + readNumber(entry.data.amountCents), 0),
    },
    orders,
  };
}

export async function recordNfcAdminAudit(input: {
  action: string;
  adminUid: string;
  reason: string;
  subjectId: string;
}) {
  await getBayblazeFirestore().collection(nfcAuditCollection).add({
    ...input,
    createdAt: FieldValue.serverTimestamp(),
  });
  return { ok: true };
}

async function markOrderPaid(intent: Stripe.PaymentIntent, eventId: string) {
  const orderId = String(intent.metadata?.nfc_order_id || "");
  if (!orderId) return;
  const db = getBayblazeFirestore();
  const orderRef = db.collection(nfcOrdersCollection).doc(orderId);
  const orderSnapshot = await orderRef.get();
  if (!orderSnapshot.exists) return;
  const order = orderSnapshot.data() ?? {};
  const now = FieldValue.serverTimestamp();
  await orderRef.set({
    paidAt: now,
    status: "fulfillment_pending",
    stripe: {
      paymentIntentId: intent.id,
      paymentStatus: intent.status,
    },
    updatedAt: now,
  }, { merge: true });

  const attributionToken = readString(order.attributionToken);
  if (!attributionToken) return;
  await createFixedNfcCommission({
    attributionToken,
    eventId,
    order,
    orderId,
  });
}

async function createFixedNfcCommission(input: {
  attributionToken: string;
  eventId: string;
  order: Record<string, unknown>;
  orderId: string;
}) {
  const attribution = await readValidatedAttribution(input.attributionToken);
  if (!attribution) return;
  const partner = await getPartner(attribution.partnerUid);
  if (partner?.status !== "active") return;

  const db = getBayblazeFirestore();
  const commissionRef = db.collection(commissionLedgerCollection).doc(input.orderId);
  const partnerReferralRef = db.collection("referral_partners").doc(attribution.partnerUid).collection("referrals").doc(input.orderId);
  await db.runTransaction(async (transaction) => {
    const [commissionSnapshot, partnerReferralSnapshot] = await Promise.all([
      transaction.get(commissionRef),
      transaction.get(partnerReferralRef),
    ]);
    if (commissionSnapshot.exists || partnerReferralSnapshot.exists) return;
    const customer = readRecord(input.order.customer);
    const money = readRecord(input.order.money);
    const now = FieldValue.serverTimestamp();
    const eligibilityAt = Timestamp.fromDate(
      new Date(Date.now() + env.PARTNER_COMMISSION_ELIGIBILITY_DAYS * 86_400_000),
    );
    const ledger = {
      amountCents: nfcAffiliateCommissionCents,
      attributionId: attribution.attributionId,
      commissionCents: nfcAffiliateCommissionCents,
      createdAt: now,
      currency: "usd",
      eventId: input.eventId,
      orderId: input.orderId,
      orderStatus: "paid",
      partnerUid: attribution.partnerUid,
      referralCode: attribution.code,
      status: "pending",
      updatedAt: now,
    };
    transaction.create(commissionRef, ledger);
    transaction.create(partnerReferralRef, {
      attributedAt: now,
      attributionId: attribution.attributionId,
      attributionSource: "promo_query",
      clawbackCents: 0,
      clawbackSettledCents: 0,
      commissionCents: nfcAffiliateCommissionCents,
      commissionRateBps: 0,
      createdAt: now,
      currency: "usd",
      customerLabel: privacyLabel(readString(customer.email)),
      customerRef: hashValue(readString(customer.email) || input.orderId),
      eligibilityAt,
      eligibleAt: null,
      orderCompletedAt: now,
      orderId: input.orderId,
      orderStatus: "paid",
      originalCommissionCents: nfcAffiliateCommissionCents,
      originalQualifyingSubtotalCents: readNumber(money.subtotalCents),
      paidCommissionCents: 0,
      partnerUid: attribution.partnerUid,
      paymentCapturedAt: now,
      payoutId: "",
      qualifyingSubtotalCents: readNumber(money.subtotalCents),
      referralCode: attribution.code,
      refundedCents: 0,
      source: "nfc_storefront",
      status: "pending",
      updatedAt: now,
    });
  });
}

async function reverseOrderCommission(event: Stripe.Event) {
  const object = event.data.object as { metadata?: Record<string, string> };
  const orderId = object.metadata?.nfc_order_id || "";
  if (!orderId) return;
  const db = getBayblazeFirestore();
  const orderRef = db.collection(nfcOrdersCollection).doc(orderId);
  const ledgerRef = db.collection(commissionLedgerCollection).doc(orderId);
  await db.runTransaction(async (transaction) => {
    const [orderSnapshot, ledgerSnapshot] = await Promise.all([
      transaction.get(orderRef),
      transaction.get(ledgerRef),
    ]);
    if (orderSnapshot.exists) {
      transaction.set(orderRef, {
        refundedAt: FieldValue.serverTimestamp(),
        status: "refunded",
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
    }
    if (ledgerSnapshot.exists) {
      const ledger = ledgerSnapshot.data() ?? {};
      transaction.set(ledgerRef, {
        reversalCents: readNumber(ledger.amountCents),
        reversedAt: FieldValue.serverTimestamp(),
        status: "reversed",
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
      const partnerUid = readString(ledger.partnerUid);
      if (partnerUid) {
        transaction.set(db.collection("referral_partners").doc(partnerUid).collection("referrals").doc(orderId), {
          clawbackCents: readNumber(ledger.amountCents),
          refundedCents: readNumber(ledger.amountCents),
          status: "reversed",
          updatedAt: FieldValue.serverTimestamp(),
        }, { merge: true });
      }
    }
  });
}

async function evaluateFulfillment(input: NfcFulfillmentInput) {
  if (input.method !== "local_delivery") {
    return {
      fulfillmentMethod: "usps_standard" as const,
      status: "shipping_available",
    };
  }

  if (!env.NFC_LOCAL_DELIVERY_ORIGIN_ADDRESS) {
    return {
      fulfillmentMethod: "usps_standard" as const,
      reason: "LOCAL_ORIGIN_NOT_CONFIGURED",
      status: "inconclusive",
    };
  }

  try {
    const [origin, destination] = await Promise.all([
      geocodeAddress(env.NFC_LOCAL_DELIVERY_ORIGIN_ADDRESS),
      geocodeAddress(formatAddress(input.address)),
    ]);
    const route = await calculateRouteDuration([origin, destination]);
    const eligible = route.durationMinutes <= maxLocalDeliveryMinutes;
    return {
      audit: {
        destinationHash: hashValue(formatAddress(input.address)),
        distanceMeters: route.distanceMeters,
        estimatedTravelMinutes: route.durationMinutes,
        status: eligible ? "eligible" : "ineligible",
      },
      fulfillmentMethod: eligible ? "local_delivery" as const : "usps_standard" as const,
      status: eligible ? "eligible" : "outside_local_delivery_area",
    };
  } catch (caught) {
    return {
      fulfillmentMethod: "usps_standard" as const,
      reason: caught instanceof Error ? caught.message : "Local delivery check failed.",
      status: "inconclusive",
    };
  }
}

async function readValidatedAttribution(token: string | undefined) {
  const attribution = verifyAttributionToken(token, env.PARTNER_ATTRIBUTION_TOKEN_SECRET || "");
  if (!attribution) return null;
  const partner = await getPartner(attribution.partnerUid);
  return partner?.status === "active" ? attribution : null;
}

function normalizeProgrammedDestination(productType: string, value: string) {
  const submitted = value.trim();
  if (productType === "plain" || /^https?:\/\//i.test(submitted)) {
    const url = new URL(submitted);
    if (!safeProtocols.has(url.protocol)) throw new ApiRequestError(400, "Destination URL must use http or https.");
    return url.toString();
  }
  const handle = submitted.replace(/^@/, "").replace(/^https?:\/\/(?:www\.)?[^/]+\/?/i, "").split(/[/?#]/)[0];
  if (!/^[a-zA-Z0-9._-]{1,80}$/.test(handle)) {
    throw new ApiRequestError(400, "Enter a valid profile handle or URL.");
  }
  if (productType === "instagram") return `https://instagram.com/${handle}`;
  if (productType === "snapchat") return `https://snapchat.com/add/${handle}`;
  if (productType === "x") return `https://x.com/${handle}`;
  return submitted;
}

function getStripe() {
  if (stripeClient) return stripeClient;
  stripeClient = new Stripe(requireEnv("NFC_STRIPE_SECRET_KEY"));
  return stripeClient;
}

function requireCompleteCustomer(value?: Partial<NfcCustomerInput>) {
  if (!value?.email || !value.fullName || !value.phone) {
    throw new ApiRequestError(400, "Customer name, email, and phone are required.");
  }
  return value as NfcCustomerInput;
}

function assertImageMagic(buffer: Buffer, mimeType: string) {
  const png = buffer.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]));
  const jpg = buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff;
  const webp = buffer.subarray(0, 4).toString("ascii") === "RIFF" && buffer.subarray(8, 12).toString("ascii") === "WEBP";
  if ((mimeType === "image/png" && png) || (mimeType === "image/jpeg" && jpg) || (mimeType === "image/webp" && webp)) return;
  throw new ApiRequestError(400, "Image content did not match the declared file type.");
}

function buildNfcReferralLink(code: string) {
  const url = new URL(env.NFC_STOREFRONT_URL);
  url.searchParams.set("ref", code);
  return url.toString();
}

function serializeOrderResponse(id: string, data: Record<string, unknown>) {
  return { order: serializeSafeOrder(id, data) };
}

function serializeSafeOrder(id: string, data: Record<string, unknown>) {
  return {
    createdAt: serializeDate(data.createdAt),
    fulfillment: data.fulfillment,
    fulfillmentEligibility: data.fulfillmentEligibility,
    money: readRecord(data.money),
    orderId: id,
    status: readString(data.status),
  };
}

function formatAddress(address: NfcAddressInput) {
  return [address.line1, address.line2, address.city, address.state, address.postalCode, address.country]
    .filter(Boolean)
    .join(", ");
}

function privacyLabel(email: string) {
  const [name, domain] = email.split("@");
  return name && domain ? `${name.slice(0, 2)}***@${domain}` : "NFC customer";
}

function hashValue(value: string) {
  return createHash("sha256").update(value).digest("hex");
}

function requireEnv(key: string) {
  const value = process.env[key];
  if (!value) throw new ApiRequestError(500, `${key} is not configured.`);
  return value;
}

function readRecord(value: unknown): Record<string, unknown> {
  return value && typeof value === "object" && !Array.isArray(value) ? value as Record<string, unknown> : {};
}

function readString(value: unknown) {
  return typeof value === "string" ? value : "";
}

function readNumber(value: unknown) {
  return typeof value === "number" && Number.isFinite(value) ? value : 0;
}

function serializeDate(value: unknown) {
  if (value instanceof Timestamp) return value.toDate().toISOString();
  if (typeof value === "string") return value;
  const maybeTimestamp = value as { toDate?: () => Date } | undefined;
  return maybeTimestamp?.toDate?.().toISOString?.() || "";
}
