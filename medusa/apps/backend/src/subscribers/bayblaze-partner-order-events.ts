import type { SubscriberArgs, SubscriberConfig } from "@medusajs/framework";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
    filters?: Record<string, unknown>;
  }) => Promise<{ data: T[] }>;
};

type Payment = {
  id: string;
  payment_collection?: { order?: { id?: string | null } | null } | null;
};

type Order = {
  currency_code?: string | null;
  email?: string | null;
  fulfillment_status?: string | null;
  id: string;
  metadata?: Record<string, unknown> | null;
  payment_collections?: Array<{
    refunded_amount?: unknown;
    payments?: Array<{
      refunds?: Array<{ amount?: unknown }> | null;
    }> | null;
  }> | null;
  payment_status?: string | null;
  shipping_address?: {
    first_name?: string | null;
    last_name?: string | null;
  } | null;
  status?: string | null;
};

const orderFields = [
  "id",
  "email",
  "currency_code",
  "status",
  "payment_status",
  "fulfillment_status",
  "metadata",
  "payment_collections.refunded_amount",
  "payment_collections.payments.refunds.amount",
  "shipping_address.first_name",
  "shipping_address.last_name",
];

export default async function bayblazePartnerOrderEventHandler({
  event,
  container,
}: SubscriberArgs<{ id?: string; order_id?: string }>) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const eventName = readString((event as { name?: unknown }).name);
  const entityId = readString(event.data?.id);
  const query = container.resolve<Query>(ContainerRegistrationKeys.QUERY);

  try {
    const orderId = eventName.startsWith("payment.")
      ? await getPaymentOrderId(query, entityId)
      : readString(event.data?.order_id) || entityId;
    if (!orderId) return;

    const { data: orders } = await query.graph<Order>({
      entity: "order",
      fields: orderFields,
      filters: { id: orderId },
    });
    const order = orders[0];
    if (!order) return;
    const eventType = toPartnerEventType(eventName, order);
    if (!eventType) return;
    const refundedCents = readRefundedCents(order);
    const deliveryEventAt = readString(order.metadata?.bayblaze_delivery_event_at);

    await notifyPartnerApi({
      eventAt: deliveryEventAt || new Date().toISOString(),
      eventId: `${eventName}:${entityId || order.id}:${refundedCents}:${deliveryEventAt}`,
      eventType,
      order: {
        currencyCode: readString(order.currency_code),
        customerName: getCustomerName(order),
        customerUid: readString(order.metadata?.bayblaze_account_uid),
        email: readString(order.email),
        fulfillmentStatus: readString(order.fulfillment_status),
        id: order.id,
        metadata: order.metadata ?? {},
        paymentStatus: readString(order.payment_status),
        refundedCents,
        status: readString(order.status),
      },
    });
  } catch (error) {
    logger.error(
      `[BayBlaze Partners] Could not forward ${eventName || "order"} event: ${error instanceof Error ? error.message : String(error)}`,
    );
    throw error;
  }
}

export const config: SubscriberConfig = {
  event: [
    "order.placed",
    "order.updated",
    "order.completed",
    "order.canceled",
    "payment.captured",
    "payment.chargeback",
    "payment.failed",
    "payment.refunded",
  ],
};

async function getPaymentOrderId(query: Query, paymentId: string) {
  if (!paymentId) return "";
  const { data } = await query.graph<Payment>({
    entity: "payment",
    fields: ["id", "payment_collection.order.id"],
    filters: { id: paymentId },
  });
  return readString(data[0]?.payment_collection?.order?.id);
}

function toPartnerEventType(eventName: string, order: Order) {
  if (eventName === "order.placed") return "order_placed";
  if (eventName === "order.completed") return "order_completed";
  if (eventName === "order.canceled") return "order_canceled";
  if (eventName === "payment.captured") return "payment_captured";
  if (eventName === "payment.chargeback") return "chargeback";
  if (eventName === "payment.failed") return "payment_failed";
  if (eventName === "payment.refunded") return "payment_refunded";
  if (eventName === "order.updated") {
    if (order.metadata?.bayblaze_deleted === true) return "order_canceled";
    const deliveryStatus = readString(order.metadata?.bayblaze_delivery_status);
    if (deliveryStatus === "completed") return "order_completed";
    if (deliveryStatus === "cancelled" || deliveryStatus === "canceled") return "order_canceled";
  }
  return null;
}

function readRefundedCents(order: Order) {
  const collectionTotal = (order.payment_collections ?? []).reduce(
    (sum, collection) => sum + readMoney(collection.refunded_amount),
    0,
  );
  if (collectionTotal > 0) return Math.round(collectionTotal * 100);
  const refundTotal = (order.payment_collections ?? []).flatMap((collection) => collection.payments ?? [])
    .flatMap((payment) => payment.refunds ?? [])
    .reduce((sum, refund) => sum + readMoney(refund.amount), 0);
  return Math.round(refundTotal * 100);
}

async function notifyPartnerApi(payload: Record<string, unknown>) {
  const apiUrl = readString(process.env.BAYBLAZE_API_URL).replace(/\/$/, "");
  const token = readString(process.env.BAYBLAZE_MEDUSA_SERVICE_TOKEN || process.env.BAYBLAZE_API_SERVICE_TOKEN);
  if (!apiUrl || !token) throw new Error("BAYBLAZE_API_URL and BAYBLAZE_MEDUSA_SERVICE_TOKEN are required.");
  const response = await fetch(`${apiUrl}/v1/partners/order-events`, {
    body: JSON.stringify(payload),
    headers: {
      "content-type": "application/json",
      "x-bayblaze-service-token": token,
    },
    method: "POST",
  });
  if (!response.ok) throw new Error(`Partner event endpoint returned HTTP ${response.status}: ${await response.text()}`);
}

function readMoney(value: unknown) {
  const number = typeof value === "number" || typeof value === "string" ? Number(value) : Number.NaN;
  return Number.isFinite(number) && number > 0 ? number : 0;
}

function getCustomerName(order: Order) {
  return [
    order.shipping_address?.first_name,
    order.shipping_address?.last_name,
  ]
    .map(readString)
    .filter(Boolean)
    .join(" ");
}

function readString(value: unknown) {
  return typeof value === "string" ? value.trim() : "";
}
