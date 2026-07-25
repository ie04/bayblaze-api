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

export type PromotionalEmailRecipientMode = "customers" | "manual" | "internal" | "combined";

export type PromotionalEmailInput = {
  body?: string;
  ctaLabel?: string;
  ctaUrl?: string;
  fromEmail?: string;
  headline?: string;
  imageUrl?: string;
  internalRecipientEmails?: string[];
  manualRecipientEmails?: string[];
  name?: string;
  preheader?: string;
  recipientMode?: PromotionalEmailRecipientMode;
  replyTo?: string;
  schedule?: {
    batchSize?: number;
    enabled?: boolean;
    intervalMinutes?: number;
    startAt?: string;
  };
  subject?: string;
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

type PromotionalEmailSchedule = {
  batchSize: number;
  enabled: boolean;
  intervalMinutes: number;
  startAt: string;
};

type PromotionalEmailCampaign = {
  body: string;
  createdAt: string;
  ctaLabel: string;
  ctaUrl: string;
  failedCount: number;
  fromEmail: string;
  headline: string;
  id: string;
  imageUrl: string;
  internalRecipientEmails: string[];
  lastQueuedAt: string;
  manualRecipientEmails: string[];
  name: string;
  preheader: string;
  queuedBatchCount: number;
  queuedRecipientCount: number;
  recipientMode: PromotionalEmailRecipientMode;
  replyTo: string;
  schedule: PromotionalEmailSchedule;
  sentCount: number;
  status: string;
  subject: string;
  updatedAt: string;
};

const emailAutomationsCollection = "email_automations";
const emailEventLogsCollection = "email_event_logs";
const promotionalEmailsCollection = "promotional_email_campaigns";
const promotionalEmailBatchesSubcollection = "batches";
const maxLogCount = 50;
const maxPromotionalEmailRecipients = 5000;
const maxPromotionalSendBatchSize = 100;
const legacyOrderPlacedHtmlTemplate = [
  "<div style=\"font-family:Arial,sans-serif;color:#11130f;line-height:1.5\">",
  "<h1 style=\"font-size:24px;margin:0 0 12px\">Order received</h1>",
  "<p>Thanks {{customerName}}. We received your BayBlaze order {{orderNumber}}.</p>",
  "<p><strong>Total due:</strong> {{orderTotal}}</p>",
  "<p>Payment is due on delivery. Please have your ID ready.</p>",
  "<p><a href=\"{{orderUrl}}\">Track your order</a></p>",
  "</div>",
].join("");

const defaultAutomations: Record<EmailAutomationEventType, EmailAutomationRecord> = {
  order_placed: {
    description: "Sent when a customer order is placed.",
    enabled: true,
    eventType: "order_placed",
    fromEmail: "",
    htmlTemplate: [
      "<div style=\"margin:0;padding:28px 18px;background:#f6f8f5;color:#000000;font-family:Jost,Avenir,Montserrat,Arial,sans-serif;line-height:1.6\">",
      "<div style=\"max-width:560px;margin:0 auto;background:#ffffff;border:1px solid #d8ded2;border-radius:18px;overflow:hidden;box-shadow:0 18px 44px rgba(17,19,15,0.12)\">",
      "<div style=\"padding:26px 26px 18px;border-bottom:1px solid #e3e7df\">",
      "<p style=\"margin:0 0 10px;color:#2c541d;font-size:12px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase\">BayBlaze</p>",
      "<h1 style=\"margin:0;color:#000000;font-size:30px;line-height:1.08;font-weight:800\">Order received</h1>",
      "</div>",
      "<div style=\"padding:24px 26px 28px\">",
      "<p style=\"margin:0 0 16px;font-size:17px;color:#11130f\">Thanks {{customerName}}. We received your BayBlaze order <strong style=\"font-weight:700\">{{orderNumber}}</strong>.</p>",
      "<div style=\"margin:0 0 18px;padding:16px 18px;background:#f6f8f5;border:1px solid #d8ded2;border-radius:14px\">",
      "<p style=\"margin:0;color:#585858;font-size:13px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase\">Total due on delivery</p>",
      "<p style=\"margin:4px 0 0;color:#000000;font-size:24px;font-weight:800\">{{orderTotal}}</p>",
      "</div>",
      "<p style=\"margin:0 0 22px;color:#585858;font-size:15px\">Payment is due on delivery. Please have your ID ready.</p>",
      "<a href=\"{{orderUrl}}\" style=\"display:inline-block;background:#74a84a;color:#000000;text-decoration:none;font-size:15px;font-weight:800;padding:13px 18px;border-radius:999px\">Track your order</a>",
      "</div>",
      "</div>",
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

export async function listPromotionalEmailCampaigns() {
  const snapshot = await getBayblazeFirestore()
    .collection(promotionalEmailsCollection)
    .orderBy("updatedAt", "desc")
    .limit(100)
    .get();

  return {
    campaigns: snapshot.docs.map((doc) => serializePromotionalEmailCampaign(doc.id, doc.data())),
  };
}

export async function createPromotionalEmailCampaign(input: PromotionalEmailInput) {
  const now = FieldValue.serverTimestamp();
  const campaign = buildPromotionalEmailRecord(input);
  const ref = getBayblazeFirestore().collection(promotionalEmailsCollection).doc();

  await ref.set({
    ...campaign,
    createdAt: now,
    updatedAt: now,
  });

  return {
    campaign: serializePromotionalEmailCampaign(ref.id, {
      ...campaign,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    }),
  };
}

export async function updatePromotionalEmailCampaign(campaignId: string, input: PromotionalEmailInput) {
  const ref = getPromotionalEmailCampaignRef(campaignId);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "Promotional email was not found.");
  }

  const existing = serializePromotionalEmailCampaign(snapshot.id, snapshot.data() ?? {});
  const next = buildPromotionalEmailRecord(input, existing);

  await ref.set({
    ...next,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });

  return {
    campaign: serializePromotionalEmailCampaign(campaignId, {
      ...next,
      createdAt: existing.createdAt,
      updatedAt: new Date().toISOString(),
    }),
  };
}

export async function sendPromotionalEmailTest(campaignId: string, input: EmailAutomationTestInput) {
  const recipientEmail = normalizeEmail(input.recipientEmail);
  const campaign = await getPromotionalEmailCampaign(campaignId);
  const from = resolvePromotionalFromEmail(campaign);

  if (!from) {
    throw new ApiRequestError(503, "Promotional email from-address is not configured.");
  }

  if (!env.RESEND_API_KEY) {
    throw new ApiRequestError(503, "Resend is not configured.");
  }

  const rendered = renderPromotionalEmail(campaign);
  const resend = new Resend(env.RESEND_API_KEY);
  await resend.emails.send({
    from,
    html: rendered.html,
    replyTo: campaign.replyTo || env.AUTOMATED_EMAIL_REPLY_TO || undefined,
    subject: `[Test] ${rendered.subject}`,
    text: rendered.text,
    to: recipientEmail,
  });
  await writePromotionalEmailLog({
    campaignId,
    message: "Promotional test email sent.",
    recipientCount: 1,
    status: "sent",
    subject: `[Test] ${rendered.subject}`,
    to: [recipientEmail],
  });

  return { sent: 1, skipped: false };
}

export async function startPromotionalEmailSend(campaignId: string, input: { scheduled?: boolean } = {}) {
  const campaign = await getPromotionalEmailCampaign(campaignId);
  const recipients = await resolvePromotionalRecipients(campaign);

  if (recipients.length === 0) {
    throw new ApiRequestError(409, "No recipients matched this promotional email.");
  }

  const ref = getPromotionalEmailCampaignRef(campaignId);
  const schedule = normalizePromotionalSchedule(campaign.schedule);
  const batchSize = schedule.batchSize || maxPromotionalSendBatchSize;
  const intervalMinutes = input.scheduled && schedule.enabled ? schedule.intervalMinutes : 0;
  const startAt = input.scheduled && schedule.enabled
    ? parseFutureDate(schedule.startAt) ?? new Date()
    : new Date();
  const batches = chunk(recipients, batchSize);
  const batch = getBayblazeFirestore().batch();
  const now = FieldValue.serverTimestamp();

  batches.forEach((batchRecipients, index) => {
    const scheduledFor = new Date(startAt.getTime() + index * intervalMinutes * 60 * 1000).toISOString();
    batch.set(ref.collection(promotionalEmailBatchesSubcollection).doc(), {
      campaignId,
      createdAt: now,
      recipientCount: batchRecipients.length,
      recipients: batchRecipients,
      scheduledFor,
      status: "queued",
      updatedAt: now,
    });
  });
  batch.set(ref, {
    lastQueuedAt: now,
    queuedBatchCount: batches.length,
    queuedRecipientCount: recipients.length,
    status: input.scheduled && schedule.enabled ? "scheduled" : "queued",
    updatedAt: now,
  }, { merge: true });
  await batch.commit();

  const processed = input.scheduled && schedule.enabled
    ? { failed: 0, processedBatches: 0, sent: 0 }
    : await sendDuePromotionalEmailBatches({ campaignId });

  return {
    campaign: await getPromotionalEmailCampaign(campaignId),
    queuedBatches: batches.length,
    queuedRecipients: recipients.length,
    ...processed,
  };
}

export async function sendDuePromotionalEmailBatches(input: { campaignId?: string; limit?: number } = {}) {
  const nowIso = new Date().toISOString();
  const limit = Math.min(Math.max(input.limit ?? 10, 1), 50);
  const snapshots = input.campaignId
    ? [await getPromotionalEmailCampaignRef(input.campaignId)
        .collection(promotionalEmailBatchesSubcollection)
        .where("status", "==", "queued")
        .limit(limit)
        .get()]
    : await Promise.all(
        (await listPromotionalEmailCampaigns()).campaigns.map((campaign) =>
          getPromotionalEmailCampaignRef(campaign.id)
            .collection(promotionalEmailBatchesSubcollection)
            .where("status", "==", "queued")
            .limit(limit)
            .get(),
        ),
      );
  const dueDocs = snapshots
    .flatMap((snapshot) => snapshot.docs)
    .filter((doc) => readString(doc.data().scheduledFor) <= nowIso)
    .sort((left, right) => readString(left.data().scheduledFor).localeCompare(readString(right.data().scheduledFor)))
    .slice(0, limit);
  let sent = 0;
  let failed = 0;

  for (const doc of dueDocs) {
    const batchResult = await sendPromotionalEmailBatch(doc.ref, doc.data());
    sent += batchResult.sent;
    failed += batchResult.failed;
  }

  return {
    failed,
    processedBatches: dueDocs.length,
    sent,
  };
}

export function renderPromotionalEmailPreview(input: PromotionalEmailInput) {
  return renderPromotionalEmail(buildPromotionalEmailRecord(input));
}

async function sendPromotionalEmailBatch(
  batchRef: FirebaseFirestore.DocumentReference,
  data: Record<string, unknown>,
) {
  const campaignId = readString(data.campaignId);
  const recipients = normalizeEmailList(Array.isArray(data.recipients) ? data.recipients : []);

  if (!campaignId || recipients.length === 0) {
    await batchRef.set({
      message: "Batch had no recipients.",
      status: "skipped",
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    return { failed: 0, sent: 0 };
  }

  const campaign = await getPromotionalEmailCampaign(campaignId);
  const from = resolvePromotionalFromEmail(campaign);

  if (!from) {
    throw new ApiRequestError(503, "Promotional email from-address is not configured.");
  }

  if (!env.RESEND_API_KEY) {
    throw new ApiRequestError(503, "Resend is not configured.");
  }

  await batchRef.set({
    startedAt: FieldValue.serverTimestamp(),
    status: "sending",
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });

  const rendered = renderPromotionalEmail(campaign);
  const resend = new Resend(env.RESEND_API_KEY);
  const results = await Promise.allSettled(
    recipients.map((to) =>
      resend.emails.send({
        from,
        html: rendered.html,
        replyTo: campaign.replyTo || env.AUTOMATED_EMAIL_REPLY_TO || undefined,
        subject: rendered.subject,
        text: rendered.text,
        to,
      }),
    ),
  );
  const failures = results.filter((result) => result.status === "rejected").length;
  const sent = recipients.length - failures;
  const status = failures === recipients.length ? "failed" : "sent";

  await batchRef.set({
    failedCount: failures,
    finishedAt: FieldValue.serverTimestamp(),
    sentCount: sent,
    status,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  await getPromotionalEmailCampaignRef(campaignId).set({
    failedCount: FieldValue.increment(failures),
    sentCount: FieldValue.increment(sent),
    status,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  await writePromotionalEmailLog({
    campaignId,
    message: failures ? `${failures} promotional email send failed.` : "Promotional email batch sent.",
    recipientCount: sent,
    status: failures === recipients.length ? "failed" : "sent",
    subject: rendered.subject,
    to: recipients,
  });

  return { failed: failures, sent };
}

async function resolvePromotionalRecipients(campaign: PromotionalEmailCampaign) {
  const recipients = new Set<string>();

  if (campaign.recipientMode === "customers" || campaign.recipientMode === "combined") {
    const snapshot = await getBayblazeFirestore()
      .collection("accounts")
      .where("badges", "array-contains", "customer")
      .limit(maxPromotionalEmailRecipients)
      .get();

    snapshot.docs.forEach((doc) => {
      const data = doc.data() ?? {};
      const email = normalizeOptionalEmail(data.email);
      if (email && data.disabled !== true) {
        recipients.add(email);
      }
    });
  }

  if (campaign.recipientMode === "manual" || campaign.recipientMode === "combined") {
    campaign.manualRecipientEmails.forEach((email) => recipients.add(email));
  }

  if (campaign.recipientMode === "internal" || campaign.recipientMode === "combined") {
    campaign.internalRecipientEmails.forEach((email) => recipients.add(email));
  }

  return Array.from(recipients).slice(0, maxPromotionalEmailRecipients);
}

async function getPromotionalEmailCampaign(campaignId: string) {
  const ref = getPromotionalEmailCampaignRef(campaignId);
  const snapshot = await ref.get();

  if (!snapshot.exists) {
    throw new ApiRequestError(404, "Promotional email was not found.");
  }

  return serializePromotionalEmailCampaign(snapshot.id, snapshot.data() ?? {});
}

function getPromotionalEmailCampaignRef(campaignId: string) {
  return getBayblazeFirestore()
    .collection(promotionalEmailsCollection)
    .doc(normalizeDocumentId(campaignId, "Promotional email ID"));
}

function buildPromotionalEmailRecord(input: PromotionalEmailInput, existing?: PromotionalEmailCampaign) {
  const name = input.name === undefined ? existing?.name : normalizeTemplate(input.name, "Campaign name");
  const subject = input.subject === undefined ? existing?.subject : normalizeTemplate(input.subject, "Subject");
  const headline = input.headline === undefined ? existing?.headline : normalizeTemplate(input.headline, "Headline");
  const body = input.body === undefined ? existing?.body : normalizeTemplate(input.body, "Body");
  const schedule = normalizePromotionalSchedule(input.schedule, existing?.schedule);

  return {
    body: body || "",
    ctaLabel: input.ctaLabel === undefined ? existing?.ctaLabel ?? "" : normalizeOptionalString(input.ctaLabel).slice(0, 80),
    ctaUrl: input.ctaUrl === undefined ? existing?.ctaUrl ?? "" : normalizeUrl(input.ctaUrl),
    fromEmail: input.fromEmail === undefined ? existing?.fromEmail ?? "" : normalizeOptionalString(input.fromEmail),
    headline: headline || "",
    imageUrl: input.imageUrl === undefined ? existing?.imageUrl ?? "" : normalizeUrl(input.imageUrl),
    internalRecipientEmails: input.internalRecipientEmails === undefined
      ? existing?.internalRecipientEmails ?? []
      : normalizeEmailList(input.internalRecipientEmails),
    manualRecipientEmails: input.manualRecipientEmails === undefined
      ? existing?.manualRecipientEmails ?? []
      : normalizeEmailList(input.manualRecipientEmails).slice(0, maxPromotionalEmailRecipients),
    name: name || "",
    preheader: input.preheader === undefined ? existing?.preheader ?? "" : normalizeOptionalString(input.preheader).slice(0, 240),
    recipientMode: normalizePromotionalRecipientMode(input.recipientMode ?? existing?.recipientMode),
    replyTo: input.replyTo === undefined ? existing?.replyTo ?? "" : normalizeOptionalString(input.replyTo),
    schedule,
    sentCount: existing?.sentCount ?? 0,
    status: existing?.status ?? "draft",
    subject: subject || "",
  };
}

function serializePromotionalEmailCampaign(id: string, data: Record<string, unknown>): PromotionalEmailCampaign {
  return {
    body: readString(data.body),
    createdAt: serializeTimestamp(data.createdAt),
    ctaLabel: readString(data.ctaLabel),
    ctaUrl: readString(data.ctaUrl),
    failedCount: readInteger(data.failedCount),
    fromEmail: normalizeOptionalString(data.fromEmail),
    headline: readString(data.headline),
    id,
    imageUrl: readString(data.imageUrl),
    internalRecipientEmails: normalizeEmailList(data.internalRecipientEmails),
    lastQueuedAt: serializeTimestamp(data.lastQueuedAt),
    manualRecipientEmails: normalizeEmailList(data.manualRecipientEmails),
    name: readString(data.name),
    preheader: readString(data.preheader),
    queuedBatchCount: readInteger(data.queuedBatchCount),
    queuedRecipientCount: readInteger(data.queuedRecipientCount),
    recipientMode: normalizePromotionalRecipientMode(data.recipientMode),
    replyTo: normalizeOptionalString(data.replyTo),
    schedule: normalizePromotionalSchedule(data.schedule),
    sentCount: readInteger(data.sentCount),
    status: readString(data.status) || "draft",
    subject: readString(data.subject),
    updatedAt: serializeTimestamp(data.updatedAt),
  };
}

function renderPromotionalEmail(campaign: Pick<PromotionalEmailCampaign, "body" | "ctaLabel" | "ctaUrl" | "headline" | "imageUrl" | "preheader" | "subject">): RenderedEmail {
  const paragraphs = campaign.body
    .split(/\n{2,}/)
    .map((paragraph) => paragraph.trim())
    .filter(Boolean)
    .map((paragraph) => `<p style="margin:0 0 16px;color:#11130f;font-size:16px;line-height:1.65">${escapeHtml(paragraph).replace(/\n/g, "<br>")}</p>`)
    .join("");
  const image = campaign.imageUrl
    ? `<img src="${escapeHtml(campaign.imageUrl)}" alt="" style="display:block;width:100%;max-height:260px;object-fit:cover">`
    : "";
  const cta = campaign.ctaLabel && campaign.ctaUrl
    ? `<a href="${escapeHtml(campaign.ctaUrl)}" style="display:inline-block;background:#c94d12;color:#ffffff;text-decoration:none;font-size:15px;font-weight:800;padding:13px 18px;border-radius:999px">${escapeHtml(campaign.ctaLabel)}</a>`
    : "";
  const html = [
    "<div style=\"margin:0;padding:28px 18px;background:#f6f8f5;color:#000000;font-family:Jost,Avenir,Montserrat,Arial,sans-serif;line-height:1.6\">",
    `<span style="display:none;max-height:0;overflow:hidden">${escapeHtml(campaign.preheader)}</span>`,
    "<div style=\"max-width:580px;margin:0 auto;background:#ffffff;border:1px solid #d8ded2;border-radius:18px;overflow:hidden;box-shadow:0 18px 44px rgba(17,19,15,0.12)\">",
    image,
    "<div style=\"padding:26px 26px 30px\">",
    "<p style=\"margin:0 0 10px;color:#2c541d;font-size:12px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase\">BayBlaze</p>",
    `<h1 style="margin:0 0 16px;color:#000000;font-size:30px;line-height:1.08;font-weight:800">${escapeHtml(campaign.headline || campaign.subject)}</h1>`,
    paragraphs,
    cta ? `<div style="margin-top:22px">${cta}</div>` : "",
    "<p style=\"margin:26px 0 0;color:#6d716b;font-size:12px;line-height:1.5\">You are receiving this because you have a BayBlaze account or were added by the BayBlaze team.</p>",
    "</div>",
    "</div>",
    "</div>",
  ].join("");

  return {
    html,
    subject: campaign.subject,
    text: [
      campaign.headline || campaign.subject,
      campaign.body,
      campaign.ctaLabel && campaign.ctaUrl ? `${campaign.ctaLabel}: ${campaign.ctaUrl}` : "",
    ].filter(Boolean).join("\n\n"),
  };
}

function resolvePromotionalFromEmail(campaign: { fromEmail: string }) {
  return campaign.fromEmail || env.AUTOMATED_EMAIL_FROM || env.DRIVER_EMAIL_FROM || "";
}

function writePromotionalEmailLog(input: {
  campaignId: string;
  message: string;
  recipientCount: number;
  status: "failed" | "sent" | "skipped";
  subject?: string;
  to?: string[];
}) {
  return getBayblazeFirestore().collection(emailEventLogsCollection).doc(emailLogDocId(`promo:${input.campaignId}:${Date.now()}`)).set({
    ...input,
    eventId: `promo:${input.campaignId}`,
    eventType: "promotional_email",
    createdAt: FieldValue.serverTimestamp(),
  }, { merge: true });
}

function normalizePromotionalRecipientMode(value: unknown): PromotionalEmailRecipientMode {
  return value === "manual" || value === "internal" || value === "combined" ? value : "customers";
}

function normalizePromotionalSchedule(value: unknown, current?: PromotionalEmailSchedule): PromotionalEmailSchedule {
  const record = readObject(value);

  return {
    batchSize: normalizeBoundedInteger(record.batchSize ?? current?.batchSize, maxPromotionalSendBatchSize, 1, maxPromotionalSendBatchSize),
    enabled: typeof record.enabled === "boolean" ? record.enabled : current?.enabled === true,
    intervalMinutes: normalizeBoundedInteger(record.intervalMinutes ?? current?.intervalMinutes, 60, 1, 60 * 24 * 14),
    startAt: normalizeOptionalString(record.startAt ?? current?.startAt),
  };
}

function normalizeBoundedInteger(value: unknown, fallback: number, min: number, max: number) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;
  return Number.isInteger(number) && number >= min && number <= max ? number : fallback;
}

function normalizeUrl(value: unknown) {
  const url = normalizeOptionalString(value).slice(0, 2000);

  if (!url) {
    return "";
  }

  try {
    const parsed = new URL(url);
    return parsed.protocol === "http:" || parsed.protocol === "https:" ? parsed.toString() : "";
  } catch {
    throw new ApiRequestError(400, "Enter a valid URL.");
  }
}

function normalizeDocumentId(value: unknown, label: string) {
  const id = normalizeOptionalString(value);

  if (!id) {
    throw new ApiRequestError(400, `${label} is required.`);
  }

  return id.replace(/[/?#[\]]/g, "_").slice(0, 500);
}

function parseFutureDate(value: string) {
  if (!value) {
    return null;
  }

  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
}

function chunk<T>(items: T[], size: number) {
  const chunks: T[][] = [];
  for (let index = 0; index < items.length; index += size) {
    chunks.push(items.slice(index, index + size));
  }
  return chunks;
}

function escapeHtml(value: string) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
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
    htmlTemplate: normalizeStoredHtmlTemplate(eventType, data.htmlTemplate ?? fallback.htmlTemplate),
    internalRecipientEmails: normalizeEmailList(data.internalRecipientEmails ?? fallback.internalRecipientEmails),
    recipientMode: normalizeRecipientMode(data.recipientMode ?? fallback.recipientMode),
  };
}

export function buildEmailAutomationEventVariablesForTest(
  eventType: EmailAutomationEventType,
  payload: Record<string, unknown>,
) {
  return buildEventVariables(eventType, payload);
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
    const orderTotal = readOrderTotalDue(metadata, payload.total);

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

function normalizeStoredHtmlTemplate(eventType: EmailAutomationEventType, template: string) {
  if (eventType === "order_placed" && template === legacyOrderPlacedHtmlTemplate) {
    return defaultAutomations[eventType].htmlTemplate;
  }

  return template;
}

function serializeAutomation(eventType: EmailAutomationEventType, data: Partial<EmailAutomationRecord>) {
  return {
    description: data.description ?? defaultAutomations[eventType].description,
    enabled: data.enabled !== false,
    eventType,
    fromEmail: normalizeOptionalString(data.fromEmail),
    htmlTemplate: normalizeStoredHtmlTemplate(eventType, data.htmlTemplate ?? defaultAutomations[eventType].htmlTemplate),
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

function readOrderTotalDue(metadata: Record<string, unknown>, fallbackTotal: unknown) {
  return readDollarMoney(
    metadata.bayblaze_checkout_total_after_adjustments,
    metadata.checkout_promo_total_after_discount,
    metadata.first_order_offer_total_after_discount,
    metadata.bayblaze_referral_total_after_discount,
    metadata.referral_total_after_discount,
  ) ?? readCentsMoney(fallbackTotal) ?? 0;
}

function readCentsMoney(...values: unknown[]) {
  for (const value of values) {
    const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

    if (Number.isFinite(number) && number >= 0) {
      return number / 100;
    }
  }

  return null;
}

function readDollarMoney(...values: unknown[]) {
  for (const value of values) {
    const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;

    if (Number.isFinite(number) && number >= 0) {
      return number;
    }
  }

  return null;
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
