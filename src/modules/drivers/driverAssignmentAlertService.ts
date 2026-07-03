import { Resend } from "resend";
import webPush from "web-push";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { env } from "../../config/env";
import type { DriverDeliveryStop, DriverProfile } from "./driverWorkflowTypes";

type DriverNotificationToken = {
  platform?: string;
  token?: string;
  tokenId?: string;
  uid?: string;
  userAgent?: string;
};

let webPushConfigured = false;

export async function sendDriverAssignmentAlerts(uid: string, stops: DriverDeliveryStop[]) {
  if (stops.length === 0) {
    return;
  }

  const profile = await readDriverProfile(uid);

  await Promise.allSettled([
    sendDriverAssignmentEmails(profile, stops),
    sendDriverAssignmentPushNotifications(uid, stops),
  ]);
}

async function sendDriverAssignmentEmails(profile: DriverProfile | null, stops: DriverDeliveryStop[]) {
  if (!profile?.email || !env.RESEND_API_KEY || !env.DRIVER_EMAIL_FROM) {
    return;
  }

  const resend = new Resend(env.RESEND_API_KEY);
  const from = env.DRIVER_EMAIL_FROM;

  await Promise.all(
    stops.map((stop) =>
      resend.emails.send({
        from,
        html: renderAssignmentEmailHtml(stop),
        replyTo: env.DRIVER_EMAIL_REPLY_TO || undefined,
        subject: `New BayBlaze delivery: ${formatOrderLabel(stop)}`,
        text: renderAssignmentEmailText(stop),
        to: profile.email,
      }),
    ),
  );
}

async function sendDriverAssignmentPushNotifications(uid: string, stops: DriverDeliveryStop[]) {
  if (!configureWebPush()) {
    return;
  }

  const snapshot = await getBayblazeFirestore()
    .collection("driver_notification_tokens")
    .doc(uid)
    .collection("tokens")
    .get();

  const tokens = snapshot.docs
    .map((doc) => ({
      docId: doc.id,
      data: doc.data() as DriverNotificationToken,
    }))
    .filter((entry) => entry.data.platform === "web-push" && entry.data.token);

  await Promise.all(
    tokens.flatMap((entry) =>
      stops.map(async (stop) => {
        try {
          await webPush.sendNotification(
            JSON.parse(entry.data.token ?? "{}"),
            JSON.stringify({
              data: {
                body: renderPushBody(stop),
                link: `/deliveries?orderId=${encodeURIComponent(stop.orderId)}`,
                orderId: stop.orderId,
                title: `New delivery: ${stop.customerName}`,
              },
            }),
          );
        } catch (caught) {
          if (isExpiredPushSubscription(caught)) {
            await snapshot.docs.find((doc) => doc.id === entry.docId)?.ref.delete();
          } else {
            console.warn("Driver assignment push notification failed.", caught);
          }
        }
      }),
    ),
  );
}

async function readDriverProfile(uid: string) {
  const snapshot = await getBayblazeFirestore().collection("driver_profiles").doc(uid).get();
  return snapshot.exists ? (snapshot.data() as DriverProfile) : null;
}

function configureWebPush() {
  if (webPushConfigured) {
    return true;
  }

  if (!env.DRIVER_WEB_PUSH_PUBLIC_KEY || !env.DRIVER_WEB_PUSH_PRIVATE_KEY) {
    return false;
  }

  webPush.setVapidDetails(
    env.DRIVER_WEB_PUSH_SUBJECT || "mailto:drivers@bayblaze.net",
    env.DRIVER_WEB_PUSH_PUBLIC_KEY,
    env.DRIVER_WEB_PUSH_PRIVATE_KEY,
  );
  webPushConfigured = true;

  return true;
}

function renderAssignmentEmailHtml(stop: DriverDeliveryStop) {
  return [
    "<div style=\"font-family:Arial,sans-serif;color:#111;line-height:1.5\">",
    "<h1 style=\"font-size:22px;margin:0 0 12px\">New BayBlaze delivery</h1>",
    `<p style="font-size:17px;font-weight:700;margin:0 0 8px">${escapeHtml(stop.customerName)}</p>`,
    `<p style="margin:0 0 12px">${escapeHtml(stop.customerAddress)}</p>`,
    `<p style="margin:0 0 12px">Order: ${escapeHtml(formatOrderLabel(stop))}</p>`,
    stop.eta ? `<p style="margin:0 0 12px">ETA: ${escapeHtml(stop.eta)}</p>` : "",
    "<p>Open the BayBlaze Driver app to start the delivery workflow.</p>",
    "</div>",
  ].join("");
}

function renderAssignmentEmailText(stop: DriverDeliveryStop) {
  const eta = stop.eta ? `\nETA: ${stop.eta}` : "";
  return [
    "New BayBlaze delivery",
    `Customer: ${stop.customerName}`,
    `Address: ${stop.customerAddress}`,
    `Order: ${formatOrderLabel(stop)}${eta}`,
    "Open the BayBlaze Driver app to start the delivery workflow.",
  ].join("\n");
}

function renderPushBody(stop: DriverDeliveryStop) {
  const eta = stop.eta ? `ETA ${stop.eta}. ` : "";
  return `${eta}${stop.customerAddress}`;
}

function formatOrderLabel(stop: DriverDeliveryStop) {
  return stop.orderId;
}

function escapeHtml(value: string) {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function isExpiredPushSubscription(caught: unknown) {
  return (
    typeof caught === "object" &&
    caught !== null &&
    "statusCode" in caught &&
    (caught.statusCode === 404 || caught.statusCode === 410)
  );
}
