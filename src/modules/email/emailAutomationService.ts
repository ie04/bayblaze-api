import { Resend } from "resend";
import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import { ApiRequestError } from "../drivers/driverWorkflowService";

export type EmailAutomationEventType = "order_placed";
export type EmailRecipientMode = "customer" | "internal" | "both";

export type EmailAutomationUpdateInput = {
  enabled?: boolean;
  fromEmail?: string;
  htmlTemplate?: string;
  internalRecipientEmails?: string[];
  recipientMode?: EmailRecipientMode;
  replyTo?: string;
  subjectTemplate?: string;
  textTemplate?: string;
};

export type EmailAutomationEventInput = {
  eventId?: string;
  eventType: EmailAutomationEventType;
  order?: Record<string, unknown>;
  payload?: Record<string, unknown>;
};

export type EmailAutomationTestInput = {
  recipientEmail: string;
};

type EmailAutomationRecord = {
  description: string;
  enabled: boolean;
  eventType: EmailAutomationEventType;
  fromEmail: string;
  htmlTemplate: string;
  internalRecipientEmails: string[];
  label: string;
  recipientMode: EmailRecipientMode;
  replyTo: string;
  subjectTemplate: string;
  textTemplate: string;
  updatedAt?: unknown;
};

type RenderedEmail = {
  html: string;
  subject: string;
  text: string;
};

const emailAutomationsCollection = "email_automations";
const emailEventLogsCollection = "email_event_logs";
const maxLogCount = 50;

const defaultAutomations: Record<EmailAutomationEventType, EmailAutomationRecord> = {
  order_placed: {
    description: "Sent when a customer order is placed.",
    enabled: true,
    eventType: "order_placed",
    fromEmail: "",
    htmlTemplate: [
      "<div style=\"font-family:Arial,sans-serif;color:#11130f;line-height:1.5\">",
      "<h1 style=\"font-size:24px;margin:0 0 12px\">Order received</h1>",
      "<p>Thanks {{customerName}}. We received your BayBlaze order {{orderNumber}}.</p>",
      "<p><strong>Total due:</strong> {{orderTotal}}</p>",
      "<p>Payment is due on delivery. Please have your ID ready.</p>",
      "<p><a href=\"{{orderUrl}}\">Track your order</a></p>",
      "</div>",
    ].join(""),
    internalRecipientEmails: [],
    label: "Order placed",
    recipientMode: "customer",
    replyTo: "",
    subjectTemplate: "We got your BayBlaze order {{orderNumber}}",
    textTemplate: [
      "Order received",
      "Thanks {{customerName}}. We received your BayBlaze order {{orderNumber}}.",
      "Total due: {{orderTotal}}",
      "Payment is due on delivery. Please have your ID ready.",
      "Track your order: {{orderUrl}}",
    ].join("\n"),
  },
};

export async function listEmailAutomations() {
  const db = getBayblazeFirestore();
  const [automationsSnapshot, logsSnapshot] = await Promise.all([
    db.collection(emailAutomationsCollection).get(),
    db.collection(emailEventLogsCollection).orderBy("createdAt", "desc").limit(maxLogCount).get(),
  ]);
  const stored = new Map(automationsSnapshot.docs.map((doc) => [doc.id, doc.data() as Partial<EmailAutomationRecord>]));

  return {
    automations: (Object.keys(defaultAutomations) as EmailAutomationEventType[]).map((eventType) =>
      serializeAutomation(eventType, {
        ...defaultAutomations[eventType],
        ...(stored.get(eventType) ?? {}),
      }),
    ),
    logs: logsSnapshot.docs.map((doc) => serializeEmailLog(doc.id, doc.data())),
  };
}

export async function updateEmailAutomation(
  eventType: EmailAutomationEventType,
  input: EmailAutomationUpdateInput,
) {
  const existing = await getAutomation(eventType);
  const next: EmailAutomationRecord = {
    ...existing,
    enabled: input.enabled ?? existing.enabled,
    fromEmail: input.fromEmail === undefined ? existing.fromEmail : normalizeOptionalString(input.fromEmail),
    htmlTemplate: input.htmlTemplate === undefined ? existing.htmlTemplate : normalizeTemplate(input.htmlTemplate, "HTML template"),
    internalRecipientEmails: input.internalRecipientEmails === undefined
      ? existing.internalRecipientEmails
      : normalizeEmailList(input.internalRecipientEmails),
    recipientMode: input.recipientMode ?? existing.recipientMode,
    replyTo: input.replyTo === undefined ? existing.replyTo : normalizeOptionalString(input.replyTo),
    subjectTemplate: input.subjectTemplate === undefined
      ? existing.subjectTemplate
      : normalizeTemplate(input.subjectTemplate, "Subject"),
    textTemplate: input.textTemplate === undefined
      ? existing.textTemplate
      : normalizeTemplate(input.textTemplate, "Text template"),
  };

  await getBayblazeFirestore().collection(emailAutomationsCollection).doc(eventType).set({
    ...next,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });

  return {
    automation: serializeAutomation(eventType, {
      ...next,
      updatedAt: new Date().toISOString(),
    }),
  };
}

export async function triggerEmailAutomationEvent(input: EmailAutomationEventInput) {
  const eventType = input.eventType;
  const eventId = normalizeOptionalString(input.eventId) || `${eventType}:${Date.now()}`;
  const automation = await getAutomation(eventType);
  const variables = buildEventVariables(eventType, input.order ?? input.payload ?? {});
  const existingLog = await readEmailLog(eventId);

  if (existingLog?.status === "sent") {
    return { duplicate: true, sent: 0, skipped: true };
  }

  if (!automation.enabled) {
    await writeEmailLog({
      eventId,
      eventType,
      message: "Automation is disabled.",
      recipientCount: 0,
      status: "skipped",
    });
    return { sent: 0, skipped: true };
  }

  const from = resolveFromEmail(automation);
  const recipients = resolveRecipients(automation, variables);

  if (!from) {
    throw new ApiRequestError(503, "Automated email from-address is not configured.");
  }

  if (!env.RESEND_API_KEY) {
    throw new ApiRequestError(503, "Resend is not configured.");
  }

  if (recipients.length === 0) {
    await writeEmailLog({
      eventId,
      eventType,
      message: "No email recipients were available.",
      recipientCount: 0,
      status: "skipped",
    });
    return { sent: 0, skipped: true };
  }

  const rendered = renderAutomationEmail(automation, variables);
  const resend = new Resend(env.RESEND_API_KEY);
  const results = await Promise.allSettled(
    recipients.map((to) =>
      resend.emails.send({
        from,
        html: rendered.html,
        replyTo: automation.replyTo || env.AUTOMATED_EMAIL_REPLY_TO || undefined,
        subject: rendered.subject,
        text: rendered.text,
        to,
      }),
    ),
  );
  const failures = results.filter((result) => result.status === "rejected");

  await writeEmailLog({
    eventId,
    eventType,
    message: failures.length ? `${failures.length} email send failed.` : "Email automation sent.",
    recipientCount: recipients.length - failures.length,
    status: failures.length === results.length ? "failed" : "sent",
    subject: rendered.subject,
    to: recipients,
  });

  if (failures.length === results.length) {
    throw new ApiRequestError(502, "Email automation failed to send.");
  }

  return {
    failed: failures.length,
    sent: recipients.length - failures.length,
    skipped: false,
  };
}

export async function sendEmailAutomationTest(
  eventType: EmailAutomationEventType,
  input: EmailAutomationTestInput,
) {
  const recipientEmail = normalizeEmail(input.recipientEmail);
  const automation = await getAutomation(eventType);
  const sampleOrder = {
    custom_display_id: "BB-1001",
    email: recipientEmail,
    orderReference: "BB-1001",
    shipping_address: {
      first_name: "BayBlaze",
      last_name: "Customer",
    },
    total: 4200,
  };
  const from = resolveFromEmail(automation);

  if (!from) {
    throw new ApiRequestError(503, "Automated email from-address is not configured.");
  }

  if (!env.RESEND_API_KEY) {
    throw new ApiRequestError(503, "Resend is not configured.");
  }

  const variables = buildEventVariables(eventType, sampleOrder);
  const rendered = renderAutomationEmail(automation, variables);
  const resend = new Resend(env.RESEND_API_KEY);
  await resend.emails.send({
    from,
    html: rendered.html,
    replyTo: automation.replyTo || env.AUTOMATED_EMAIL_REPLY_TO || undefined,
    subject: `[Test] ${rendered.subject}`,
    text: rendered.text,
    to: recipientEmail,
  });
  await writeEmailLog({
    eventId: `test:${eventType}:${Date.now()}`,
    eventType,
    message: "Test email sent.",
    recipientCount: 1,
    status: "sent",
    subject: `[Test] ${rendered.subject}`,
    to: [recipientEmail],
  });

  return { sent: 1, skipped: false };
}

async function getAutomation(eventType: EmailAutomationEventType): Promise<EmailAutomationRecord> {
  const fallback = defaultAutomations[eventType];

  if (!fallback) {
    throw new ApiRequestError(404, "Email automation was not found.");
  }

  const snapshot = await getBayblazeFirestore().collection(emailAutomationsCollection).doc(eventType).get();
  const data = snapshot.exists ? (snapshot.data() as Partial<EmailAutomationRecord>) : {};

  return {
    ...fallback,
    ...data,
    internalRecipientEmails: normalizeEmailList(data.internalRecipientEmails ?? fallback.internalRecipientEmails),
    recipientMode: normalizeRecipientMode(data.recipientMode ?? fallback.recipientMode),
  };
}

function buildEventVariables(eventType: EmailAutomationEventType, payload: Record<string, unknown>): Record<string, string> {
  if (eventType === "order_placed") {
    const metadata = readObject(payload.metadata);
    const shippingAddress = readObject(payload.shipping_address);
    const orderNumber = readString(payload.orderReference) ||
      readString(payload.custom_display_id) ||
      readString(payload.display_id) ||
      readString(payload.id);
    const customerEmail = readString(payload.email);
    const customerName = [shippingAddress.first_name, shippingAddress.last_name]
      .map(readString)
      .filter(Boolean)
      .join(" ") || customerEmail || "there";
    const orderTotal = readMoney(payload.total) ||
      readDollarMoney(metadata.checkout_promo_total_after_discount) ||
      readDollarMoney(metadata.first_order_offer_total_after_discount);

    return {
      customerEmail,
      customerName,
      orderId: readString(payload.id),
      orderNumber,
      orderTotal: formatMoney(orderTotal),
      orderUrl: buildOrderUrl(orderNumber || readString(payload.id)),
    };
  }

  return {};
}

function resolveRecipients(automation: EmailAutomationRecord, variables: Record<string, string>) {
  const recipients = new Set<string>();

  if ((automation.recipientMode === "customer" || automation.recipientMode === "both") && variables.customerEmail) {
    recipients.add(variables.customerEmail);
  }

  if (automation.recipientMode === "internal" || automation.recipientMode === "both") {
    automation.internalRecipientEmails.forEach((email) => recipients.add(email));
  }

  return Array.from(recipients);
}

function resolveFromEmail(automation: EmailAutomationRecord) {
  return automation.fromEmail || env.AUTOMATED_EMAIL_FROM || env.DRIVER_EMAIL_FROM || "";
}

function renderAutomationEmail(automation: EmailAutomationRecord, variables: Record<string, string>): RenderedEmail {
  return {
    html: renderTemplate(automation.htmlTemplate, variables),
    subject: renderTemplate(automation.subjectTemplate, variables),
    text: renderTemplate(automation.textTemplate, variables),
  };
}

function renderTemplate(template: string, variables: Record<string, string>) {
  return template.replace(/\{\{\s*([a-zA-Z0-9_]+)\s*\}\}/g, (_match, key: string) => variables[key] ?? "");
}

function serializeAutomation(eventType: EmailAutomationEventType, data: Partial<EmailAutomationRecord>) {
  return {
    description: data.description ?? defaultAutomations[eventType].description,
    enabled: data.enabled !== false,
    eventType,
    fromEmail: normalizeOptionalString(data.fromEmail),
    htmlTemplate: data.htmlTemplate ?? defaultAutomations[eventType].htmlTemplate,
    internalRecipientEmails: normalizeEmailList(data.internalRecipientEmails ?? []),
    label: data.label ?? defaultAutomations[eventType].label,
    recipientMode: normalizeRecipientMode(data.recipientMode),
    replyTo: normalizeOptionalString(data.replyTo),
    subjectTemplate: data.subjectTemplate ?? defaultAutomations[eventType].subjectTemplate,
    textTemplate: data.textTemplate ?? defaultAutomations[eventType].textTemplate,
    updatedAt: serializeTimestamp(data.updatedAt),
  };
}

function serializeEmailLog(id: string, data: Record<string, unknown>) {
  return {
    createdAt: serializeTimestamp(data.createdAt),
    eventId: readString(data.eventId),
    eventType: readString(data.eventType),
    id,
    message: readString(data.message),
    recipientCount: readInteger(data.recipientCount),
    status: readString(data.status),
    subject: readString(data.subject),
    to: Array.isArray(data.to) ? data.to.map(readString).filter(Boolean) : [],
  };
}

async function readEmailLog(eventId: string) {
  const snapshot = await getBayblazeFirestore()
    .collection(emailEventLogsCollection)
    .doc(emailLogDocId(eventId))
    .get();

  return snapshot.exists ? snapshot.data() as { status?: string } : null;
}

function writeEmailLog(input: {
  eventId: string;
  eventType: EmailAutomationEventType;
  message: string;
  recipientCount: number;
  status: "failed" | "sent" | "skipped";
  subject?: string;
  to?: string[];
}) {
  return getBayblazeFirestore().collection(emailEventLogsCollection).doc(emailLogDocId(input.eventId)).set({
    ...input,
    createdAt: FieldValue.serverTimestamp(),
  }, { merge: true });
}

function emailLogDocId(eventId: string) {
  return eventId.replace(/[/?#[\]]/g, "_").slice(0, 500) || `event_${Date.now()}`;
}

function normalizeTemplate(value: unknown, label: string) {
  const template = readString(value);

  if (!template) {
    throw new ApiRequestError(400, `${label} is required.`);
  }

  return template.slice(0, 10000);
}

function normalizeRecipientMode(value: unknown): EmailRecipientMode {
  return value === "internal" || value === "both" ? value : "customer";
}

function normalizeEmailList(value: unknown) {
  const raw = Array.isArray(value) ? value : [];
  return raw.map((item) => normalizeOptionalEmail(item)).filter(Boolean).slice(0, 20);
}

function normalizeEmail(value: unknown) {
  const email = normalizeOptionalEmail(value);

  if (!email) {
    throw new ApiRequestError(400, "A valid email address is required.");
  }

  return email;
}

function normalizeOptionalEmail(value: unknown) {
  const email = normalizeOptionalString(value).toLowerCase();
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) ? email : "";
}

function normalizeOptionalString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function buildOrderUrl(orderReference: string) {
  const storefrontUrl = (env.BAYBLAZE_STOREFRONT_URL || "https://bayblaze.net").replace(/\/$/, "");
  return orderReference
    ? `${storefrontUrl}/orders/${encodeURIComponent(orderReference)}`
    : `${storefrontUrl}/orders`;
}

function readObject(value: unknown): Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value) ? value as Record<string, unknown> : {};
}

function readString(value: unknown) {
  if (typeof value === "number" && Number.isFinite(value)) {
    return String(value);
  }

  return typeof value === "string" ? value.trim() : "";
}

function readInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;
  return Number.isInteger(number) && number >= 0 ? number : 0;
}

function readMoney(...values: unknown[]) {
  for (const value of values) {
    const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

    if (Number.isFinite(number) && number >= 0) {
      return number / 100;
    }
  }

  return 0;
}

function readDollarMoney(...values: unknown[]) {
  for (const value of values) {
    const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

    if (Number.isFinite(number) && number >= 0) {
      return number;
    }
  }

  return 0;
}

function formatMoney(value: number) {
  return new Intl.NumberFormat("en-US", {
    currency: "USD",
    style: "currency",
  }).format(value);
}

function serializeTimestamp(value: unknown) {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  return typeof value === "string" ? value : "";
}
