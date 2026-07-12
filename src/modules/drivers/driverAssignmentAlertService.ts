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

export type DriverAssignmentAlertResult = {
  emailCount: number;
  pushCount: number;
  tokenCount: number;
};

let webPushConfigured = false;

export async function sendDriverAssignmentAlerts(
  uid: string,
  stops: DriverDeliveryStop[],
): Promise<DriverAssignmentAlertResult> {
  if (stops.length === 0) {
    return { emailCount: 0, pushCount: 0, tokenCount: 0 };
  }

  const profile = await readDriverProfile(uid);
  const [emailResult, pushResult] = await Promise.allSettled([
    sendDriverAssignmentEmails(profile, stops),
    sendDriverAssignmentPushNotifications(uid, stops),
  ]);

  if (emailResult.status === "rejected") {
    console.warn("Driver assignment email alerts failed.", emailResult.reason);
  }

  if (pushResult.status === "rejected") {
    console.warn("Driver assignment push alerts failed.", pushResult.reason);
  }

  return {
    emailCount: emailResult.status === "fulfilled" ? emailResult.value : 0,
    pushCount: pushResult.status === "fulfilled" ? pushResult.value.pushCount : 0,
    tokenCount: pushResult.status === "fulfilled" ? pushResult.value.tokenCount : 0,
  };
}

async function sendDriverAssignmentEmails(profile: DriverProfile | null, stops: DriverDeliveryStop[]) {
  if (!profile?.email || !env.RESEND_API_KEY || !env.DRIVER_EMAIL_FROM) {
    return 0;
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

  return stops.length;
}

async function sendDriverAssignmentPushNotifications(uid: string, stops: DriverDeliveryStop[]) {
  if (!configureWebPush()) {
    return { pushCount: 0, tokenCount: 0 };
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
  let pushCount = 0;

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
          pushCount += 1;
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

  return {
    pushCount,
    tokenCount: tokens.length,
  };
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
    "<div style=\"margin:0;padding:28px 18px;background:#f6f8f5;color:#000000;font-family:Jost,Avenir,Montserrat,Arial,sans-serif;line-height:1.55\">",
    "<div style=\"max-width:540px;margin:0 auto;background:#ffffff;border:1px solid #d8ded2;border-radius:18px;overflow:hidden;box-shadow:0 18px 44px rgba(17,19,15,0.12)\">",
    "<div style=\"padding:24px 24px 16px;border-bottom:1px solid #e3e7df\">",
    "<p style=\"margin:0 0 10px;color:#2c541d;font-size:12px;font-weight:700;letter-spacing:0.12em;text-transform:uppercase\">BayBlaze Driver</p>",
    "<h1 style=\"margin:0;color:#000000;font-size:28px;line-height:1.1;font-weight:800\">New delivery</h1>",
    "</div>",
    "<div style=\"padding:22px 24px 26px\">",
    `<p style="font-size:18px;font-weight:800;margin:0 0 8px;color:#11130f">${escapeHtml(stop.customerName)}</p>`,
    `<p style="margin:0 0 16px;color:#585858;font-size:15px">${escapeHtml(stop.customerAddress)}</p>`,
    "<div style=\"margin:0 0 18px;padding:15px 16px;background:#f6f8f5;border:1px solid #d8ded2;border-radius:14px\">",
    `<p style="margin:0 0 6px;color:#585858;font-size:13px;font-weight:700;letter-spacing:0.08em;text-transform:uppercase">Order</p>`,
    `<p style="margin:0;color:#000000;font-size:18px;font-weight:800">${escapeHtml(formatOrderLabel(stop))}</p>`,
    stop.eta ? `<p style="margin:8px 0 0;color:#2c541d;font-size:15px;font-weight:700">ETA: ${escapeHtml(stop.eta)}</p>` : "",
    "</div>",
    "<p style=\"margin:0;color:#11130f;font-size:15px\">Open the BayBlaze Driver app to start the delivery workflow.</p>",
    "</div>",
    "</div>",
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
  if (typeof caught !== "object" || caught === null || !("statusCode" in caught)) {
    return false;
  }

  if (caught.statusCode === 404 || caught.statusCode === 410) {
    return true;
  }

  return caught.statusCode === 400 &&
    "body" in caught &&
    typeof caught.body === "string" &&
    caught.body.includes("VapidPkHashMismatch");
}
