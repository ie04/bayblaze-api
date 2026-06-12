import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

import { isBayblazeOrderNumber } from "../../../../lib/bayblaze-order-number";

type Order = {
  id: string;
  custom_display_id?: string | null;
};

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
    filters?: Record<string, unknown>;
  }) => Promise<{ data: T[] }>;
};

const orderFields = [
  "id",
  "custom_display_id",
  "email",
  "status",
  "total",
  "currency_code",
  "created_at",
  "metadata",
  "*items",
  "*shipping_address",
  "*billing_address",
  "*shipping_methods",
];

export async function GET(req: MedusaRequest, res: MedusaResponse) {
  const orderId = req.params.orderId;

  if (typeof orderId !== "string" || !orderId.trim()) {
    return res.status(400).json({ message: "Order ID is required." });
  }

  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const trimmedOrderId = orderId.trim().toUpperCase();

  if (!isBayblazeOrderNumber(trimmedOrderId)) {
    return res.status(404).json({ message: "Order not found." });
  }

  const { data } = await query.graph<Order>({
    entity: "order",
    fields: orderFields,
    filters: {
      custom_display_id: trimmedOrderId,
    },
  });
  const order = data[0];

  if (!order) {
    return res.status(404).json({ message: "Order not found." });
  }

  return res.status(200).json({ order });
}
