import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";

export type StorefrontActivityEventType =
  | "activity"
  | "beforeunload"
  | "cart"
  | "checkout"
  | "page_view"
  | "pagehide"
  | "visibility_hidden";

export type StorefrontActivityInput = {
  cart?: {
    itemCount?: number;
    valueCents?: number;
  };
  eventId: string;
  eventType: StorefrontActivityEventType;
  occurredAt: string;
  page: {
    path: string;
    referrer?: string;
    title?: string;
    url?: string;
  };
  sessionId: string;
  userAgent?: string;
  visitorId: string;
};

const sessionsCollection = "storefront_sessions";
const maxRecentEvents = 20;

export async function recordStorefrontActivity(input: StorefrontActivityInput) {
  const nowIso = new Date().toISOString();
  const occurredAt = normalizeIsoDate(input.occurredAt) || nowIso;
  const sessionId = sanitizeId(input.sessionId);
  const visitorId = sanitizeId(input.visitorId);
  const eventId = sanitizeId(input.eventId);

  const sessionRef = getBayblazeFirestore()
    .collection(sessionsCollection)
    .doc(sessionId);
  const eventRef = sessionRef.collection("events").doc(eventId);
  const [existingEvent, existingSession] = await Promise.all([
    eventRef.get(),
    sessionRef.get(),
  ]);

  if (existingEvent.exists) {
    return { ok: true, duplicate: true };
  }

  const event = {
    cart: normalizeCart(input.cart),
    eventId,
    eventType: input.eventType,
    occurredAt,
    page: normalizePage(input.page),
    receivedAt: FieldValue.serverTimestamp(),
    sessionId,
    userAgent: normalizeText(input.userAgent).slice(0, 500),
    visitorId,
  };

  await eventRef.set(event);
  await sessionRef.set({
    abandoned: isAbandonmentSignal(input.eventType),
    abandonmentReason: getAbandonmentReason(input.eventType),
    cart: event.cart,
    createdAt: existingSession.exists
      ? existingSession.data()?.createdAt ?? FieldValue.serverTimestamp()
      : FieldValue.serverTimestamp(),
    endedAt: isAbandonmentSignal(input.eventType) ? occurredAt : FieldValue.delete(),
    lastEventType: input.eventType,
    lastPage: event.page,
    lastSeenAt: occurredAt,
    recentEvents: FieldValue.arrayUnion({
      eventId,
      eventType: input.eventType,
      occurredAt,
      path: event.page.path,
    }),
    updatedAt: FieldValue.serverTimestamp(),
    userAgent: event.userAgent,
    visitorId,
  }, { merge: true });

  await trimRecentEvents(sessionRef);

  return { ok: true, duplicate: false };
}

export async function listStorefrontAbandonmentSessions(limit = 100) {
  const snapshot = await getBayblazeFirestore()
    .collection(sessionsCollection)
    .orderBy("lastSeenAt", "desc")
    .limit(Math.min(Math.max(limit, 1), 200))
    .get();

  return {
    sessions: snapshot.docs.map((doc) => serializeSession(doc.id, doc.data())),
  };
}

export async function getStorefrontVisitorAnalytics(days = 30) {
  const bucketCount = Math.min(Math.max(Math.round(days), 1), 90);
  const dates = getRecentDateKeys(bucketCount);
  const buckets = new Map(dates.map((date) => [
    date,
    {
      date,
      pageViews: 0,
      sessions: new Set<string>(),
      uniqueVisitors: new Set<string>(),
    },
  ]));
  const sinceDate = new Date(`${dates[0]}T00:00:00.000Z`);
  const snapshot = await getBayblazeFirestore()
    .collectionGroup("events")
    .where("occurredAt", ">=", sinceDate.toISOString())
    .orderBy("occurredAt", "desc")
    .limit(50_000)
    .get();
  const visitors = new Set<string>();
  const sessions = new Set<string>();
  let pageViews = 0;

  snapshot.docs.forEach((doc) => {
    const data = doc.data();
    const date = getDateKey(data.occurredAt);
    const bucket = buckets.get(date);

    if (!bucket) {
      return;
    }

    const visitorId = normalizeText(data.visitorId) || doc.id;
    const sessionId = normalizeText(data.sessionId) || doc.ref.parent.parent?.id || doc.id;
    const isPageView = normalizeText(data.eventType) === "page_view";

    bucket.sessions.add(sessionId);
    bucket.uniqueVisitors.add(visitorId);
    bucket.pageViews += isPageView ? 1 : 0;
    sessions.add(sessionId);
    visitors.add(visitorId);
    pageViews += isPageView ? 1 : 0;
  });

  const serializedBuckets = Array.from(buckets.values()).map((bucket) => ({
    date: bucket.date,
    pageViews: bucket.pageViews,
    sessions: bucket.sessions.size,
    uniqueVisitors: bucket.uniqueVisitors.size,
  }));

  return {
    buckets: serializedBuckets,
    range: {
      days: bucketCount,
      from: `${dates[0]}T00:00:00.000Z`,
      to: new Date().toISOString(),
    },
    totals: {
      pageViews,
      sessions: sessions.size,
      uniqueVisitors: visitors.size,
    },
  };
}

async function trimRecentEvents(sessionRef: FirebaseFirestore.DocumentReference) {
  const snapshot = await sessionRef.get();
  const data = snapshot.data() ?? {};
  const recentEvents = Array.isArray(data.recentEvents) ? data.recentEvents : [];

  if (recentEvents.length <= maxRecentEvents) {
    return;
  }

  await sessionRef.set({
    recentEvents: recentEvents
      .slice()
      .sort((left, right) => normalizeText(left.occurredAt).localeCompare(normalizeText(right.occurredAt)))
      .slice(-maxRecentEvents),
  }, { merge: true });
}

function serializeSession(id: string, data: FirebaseFirestore.DocumentData) {
  const recentEvents = Array.isArray(data.recentEvents) ? data.recentEvents : [];

  return {
    abandoned: data.abandoned === true,
    abandonmentReason: normalizeText(data.abandonmentReason),
    cart: normalizeCart(data.cart),
    createdAt: serializeTimestamp(data.createdAt),
    endedAt: serializeTimestamp(data.endedAt),
    id,
    lastEventType: normalizeText(data.lastEventType),
    lastPage: normalizePage(data.lastPage),
    lastSeenAt: serializeTimestamp(data.lastSeenAt),
    recentEvents: recentEvents
      .map((event) => ({
        eventId: normalizeText(event.eventId),
        eventType: normalizeText(event.eventType),
        occurredAt: serializeTimestamp(event.occurredAt),
        path: normalizeText(event.path),
      }))
      .filter((event) => event.eventId || event.eventType || event.occurredAt || event.path)
      .sort((left, right) => right.occurredAt.localeCompare(left.occurredAt)),
    updatedAt: serializeTimestamp(data.updatedAt),
    userAgent: normalizeText(data.userAgent),
    visitorId: normalizeText(data.visitorId),
  };
}

function normalizePage(page: unknown) {
  const value = typeof page === "object" && page !== null
    ? page as Record<string, unknown>
    : {};

  return {
    path: normalizeText(value.path).slice(0, 300) || "/",
    referrer: normalizeText(value.referrer).slice(0, 500),
    title: normalizeText(value.title).slice(0, 200),
    url: normalizeText(value.url).slice(0, 700),
  };
}

function normalizeCart(cart: unknown) {
  const value = typeof cart === "object" && cart !== null
    ? cart as Record<string, unknown>
    : {};

  return {
    itemCount: normalizeNonnegativeInteger(value.itemCount),
    valueCents: normalizeNonnegativeInteger(value.valueCents),
  };
}

function getAbandonmentReason(eventType: StorefrontActivityEventType) {
  if (eventType === "visibility_hidden") {
    return "tab_hidden_or_app_backgrounded";
  }

  if (eventType === "pagehide") {
    return "page_hidden_or_navigated_away";
  }

  if (eventType === "beforeunload") {
    return "browser_unload";
  }

  return "";
}

function isAbandonmentSignal(eventType: StorefrontActivityEventType) {
  return eventType === "visibility_hidden" || eventType === "pagehide" || eventType === "beforeunload";
}

function normalizeIsoDate(value: unknown) {
  if (typeof value !== "string") {
    return "";
  }

  const parsed = new Date(value);
  return Number.isNaN(parsed.getTime()) ? "" : parsed.toISOString();
}

function normalizeNonnegativeInteger(value: unknown) {
  const parsed = Number(value);
  return Number.isFinite(parsed) ? Math.max(0, Math.round(parsed)) : 0;
}

function normalizeText(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}

function sanitizeId(value: string) {
  const sanitized = value.replace(/[^a-zA-Z0-9_-]/g, "").slice(0, 120);
  return sanitized || Buffer.from(value).toString("base64url").slice(0, 120);
}

function serializeTimestamp(value: unknown) {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (typeof value === "string") {
    return normalizeIsoDate(value) || value;
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  return "";
}

function getRecentDateKeys(days: number) {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  return Array.from({ length: days }, (_, index) => {
    const date = new Date(today);
    date.setUTCDate(today.getUTCDate() - (days - index - 1));
    return date.toISOString().slice(0, 10);
  });
}

function getDateKey(value: unknown) {
  const iso = serializeTimestamp(value);
  const parsed = iso ? new Date(iso) : null;

  if (!parsed || Number.isNaN(parsed.getTime())) {
    return "";
  }

  return parsed.toISOString().slice(0, 10);
}
