import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

import { assertBayblazeServiceToken } from "../../../../../lib/bayblaze-service-auth";
import { getOrderReference, readOrderTotal } from "../route";

export const AUTHENTICATE = false;

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
  }) => Promise<{ data: T[] }>;
};

type BayblazeAdminOrderDetail = {
  id: string;
  custom_display_id?: string | null;
  display_id?: string | number | null;
  summary?: {
    current_order_total?: number | null;
    paid_total?: number | null;
    raw_current_order_total?: { value?: string | number | null } | null;
  } | null;
  total?: number | null;
};

const orderFields = [
  "id",
  "display_id",
  "custom_display_id",
  "status",
  "email",
  "created_at",
  "updated_at",
  "currency_code",
  "payment_status",
  "fulfillment_status",
  "total",
  "summary.*",
  "metadata",
  "shipping_address.*",
  "billing_address.*",
  "items.*",
  "items.product.*",
  "items.variant.*",
  "shipping_methods.*",
  "payment_collections.*",
  "fulfillments.*",
];

export async function GET(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const orderId = typeof req.params.orderId === "string" ? req.params.orderId.trim() : "";

  if (!orderId) {
    return res.status(400).json({ message: "Order ID is required." });
  }

  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const { data } = await query.graph<BayblazeAdminOrderDetail>({
    entity: "order",
    fields: orderFields,
  });
  const order = data.find((candidate) => matchesOrderId(candidate, orderId));

  if (!order) {
    return res.status(404).json({ message: `Order ${orderId} was not found.` });
  }

  return res.status(200).json({
    order: {
      ...order,
      orderReference: getOrderReference(order),
      total: readOrderTotal(order),
    },
  });
}

function matchesOrderId(order: BayblazeAdminOrderDetail, orderId: string) {
  return [order.id, order.custom_display_id, order.display_id]
    .map((value) => (typeof value === "number" ? String(value) : value))
    .some((value) => value === orderId);
}
