import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

import { assertBayblazeServiceToken } from "../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
  }) => Promise<{ data: T[] }>;
};

type BayblazeAdminOrder = {
  id: string;
  created_at?: string | null;
  currency_code?: string | null;
  custom_display_id?: string | null;
  display_id?: string | number | null;
  email?: string | null;
  fulfillment_status?: string | null;
  metadata?: Record<string, unknown> | null;
  payment_status?: string | null;
  status?: string | null;
  summary?: {
    current_order_total?: number | null;
    paid_total?: number | null;
    raw_current_order_total?: { value?: string | number | null } | null;
  } | null;
  total?: number | null;
  updated_at?: string | null;
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
  "items.*",
  "items.product.*",
  "items.variant.*",
];

export async function GET(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const limit = clamp(Number(req.query?.limit) || 25, 1, 100);
  const search = readQueryString(req.query?.q).toLowerCase();
  const { data } = await query.graph<BayblazeAdminOrder>({
    entity: "order",
    fields: orderFields,
  });
  const orders = data
    .filter((order) => matchesSearch(order, search))
    .sort((first, second) => readTime(second.created_at) - readTime(first.created_at))
    .slice(0, limit)
    .map(toAdminOrder);

  return res.status(200).json({
    count: orders.length,
    orders,
  });
}

function matchesSearch(order: BayblazeAdminOrder, search: string) {
  if (!search) {
    return true;
  }

  return [
    order.id,
    order.custom_display_id,
    order.display_id,
    order.email,
    order.status,
    order.payment_status,
    order.fulfillment_status,
  ]
    .map((value) => (value === undefined || value === null ? "" : String(value).toLowerCase()))
    .some((value) => value.includes(search));
}

export function toAdminOrder(order: BayblazeAdminOrder) {
  return {
    ...order,
    orderReference: getOrderReference(order),
    total: readOrderTotal(order),
  };
}

export function getOrderReference(order: BayblazeAdminOrder) {
  if (order.custom_display_id?.trim()) {
    return order.custom_display_id.trim();
  }

  if (order.display_id !== undefined && order.display_id !== null) {
    return String(order.display_id);
  }

  return order.id;
}

export function readOrderTotal(order: BayblazeAdminOrder) {
  if (typeof order.total === "number") {
    return order.total;
  }

  if (typeof order.summary?.current_order_total === "number") {
    return order.summary.current_order_total;
  }

  if (typeof order.summary?.paid_total === "number") {
    return order.summary.paid_total;
  }

  const rawTotal = order.summary?.raw_current_order_total?.value;
  const total = typeof rawTotal === "string" || typeof rawTotal === "number"
    ? Number(rawTotal)
    : Number.NaN;

  return Number.isFinite(total) ? total : null;
}

function readQueryString(value: unknown) {
  if (Array.isArray(value)) {
    return typeof value[0] === "string" ? value[0] : "";
  }

  return typeof value === "string" ? value : "";
}

function readTime(value: unknown) {
  return typeof value === "string" ? new Date(value).getTime() || 0 : 0;
}

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}
