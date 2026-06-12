import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

import { assertBayblazeServiceToken } from "../../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
    filters?: Record<string, unknown>;
  }) => Promise<{ data: T[] }>;
};

type OrderAddress = {
  first_name?: string | null;
  last_name?: string | null;
  phone?: string | null;
  address_1?: string | null;
  address_2?: string | null;
  city?: string | null;
  province?: string | null;
  postal_code?: string | null;
  country_code?: string | null;
};

type OrderLineItem = {
  id: string;
  product_id?: string | null;
  variant_id?: string | null;
  title?: string | null;
  product_title?: string | null;
  variant_title?: string | null;
  quantity?: number | null;
  thumbnail?: string | null;
  metadata?: Record<string, unknown> | null;
};

type OrderForDriverQueue = {
  id: string;
  custom_display_id?: string | null;
  display_id?: string | number | null;
  status?: string | null;
  email?: string | null;
  metadata?: Record<string, unknown> | null;
  shipping_address?: OrderAddress | null;
  items?: OrderLineItem[] | null;
};

const orderFields = [
  "id",
  "display_id",
  "custom_display_id",
  "status",
  "email",
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

  const uid = req.params.uid;

  if (typeof uid !== "string" || !uid.trim()) {
    return res.status(400).json({ message: "Driver UID is required." });
  }

  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const includeUnassigned = readBooleanQuery(req.query?.include_unassigned);
  const { data } = await query.graph<OrderForDriverQueue>({
    entity: "order",
    fields: orderFields,
  });

  const stops = data
    .filter((order) => isOrderAssignedToDriver(order, uid, includeUnassigned))
    .filter((order) => !isClosedOrder(order))
    .map((order) => toDriverStop(order));

  return res.status(200).json({
    queue: {
      uid,
      activeOrderId: stops[0]?.orderId,
      stops,
    },
  });
}

function isOrderAssignedToDriver(
  order: OrderForDriverQueue,
  uid: string,
  includeUnassigned: boolean,
) {
  const metadata = order.metadata ?? {};
  const assignedUid =
    metadata.driverUid ??
    metadata.driver_uid ??
    metadata.assignedDriverUid ??
    metadata.assigned_driver_uid;

  if (typeof assignedUid === "string" && assignedUid.trim()) {
    return assignedUid.trim() === uid;
  }

  return includeUnassigned;
}

function isClosedOrder(order: OrderForDriverQueue) {
  const metadata = order.metadata ?? {};
  const deliveryStatus =
    readString(
      metadata.bayblaze_delivery_status,
      metadata.delivery_status,
      metadata.driver_delivery_status,
    ).toLowerCase();
  const orderStatus = order.status?.toLowerCase() ?? "";

  return ["canceled", "cancelled", "completed", "archived"].includes(orderStatus) ||
    ["canceled", "cancelled", "completed", "archived"].includes(deliveryStatus);
}

function toDriverStop(order: OrderForDriverQueue) {
  const address = order.shipping_address ?? {};
  const metadata = order.metadata ?? {};

  return {
    orderId: order.custom_display_id || order.id,
    medusaOrderId: order.id,
    orderReference: getOrderReference(order),
    customerName: formatCustomerName(address, order.email),
    customerPhone: readString(address.phone, metadata.customer_phone),
    customerAddress: formatAddress(address),
    eta: readString(metadata.eta, metadata.delivery_eta),
    items: (order.items ?? []).map(toDriverItem),
  };
}


function getOrderReference(order: OrderForDriverQueue) {
  if (order.custom_display_id?.trim()) {
    return order.custom_display_id.trim();
  }

  if (order.display_id !== undefined && order.display_id !== null) {
    return String(order.display_id);
  }

  return order.id;
}

function toDriverItem(item: OrderLineItem, index: number) {
  return {
    id: item.id || `item-${index}`,
    productId: item.product_id || undefined,
    variantId: item.variant_id || undefined,
    name: readString(item.product_title, item.title, "Product"),
    variant: readString(item.variant_title, "Default"),
    quantity: typeof item.quantity === "number" && item.quantity > 0 ? item.quantity : 1,
    imageUrl: readString(item.thumbnail),
    inventoryLocation:
      readString(item.metadata?.inventoryLocation, item.metadata?.inventory_state)
        .toLowerCase() === "warehouse"
        ? "warehouse"
        : "vehicle",
  };
}

function formatCustomerName(address: OrderAddress, fallback?: string | null) {
  const name = [address.first_name, address.last_name]
    .map((part) => part?.trim())
    .filter(Boolean)
    .join(" ");

  return name || fallback || "BayBlaze customer";
}

function formatAddress(address: OrderAddress) {
  const locality = [address.city, address.province]
    .map((part) => part?.trim())
    .filter(Boolean)
    .join(", ");
  const cityLine = [locality, address.postal_code?.trim()]
    .filter(Boolean)
    .join(" ");

  return [
    address.address_1,
    address.address_2,
    cityLine,
    address.country_code?.toUpperCase(),
  ]
    .map((part) => part?.trim())
    .filter(Boolean)
    .join(", ");
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }

  return "";
}

function readBooleanQuery(value: unknown) {
  if (Array.isArray(value)) {
    return value.some(readBooleanQuery);
  }

  return typeof value === "string" && ["1", "true", "yes"].includes(value.toLowerCase());
}
