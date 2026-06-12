import type {
  DriverDeliveryItem,
  DriverDeliveryQueue,
  DriverDeliveryStop,
} from "./driverWorkflowTypes";

export function normalizeDriverQueuePayload(uid: string, payload: unknown): DriverDeliveryQueue {
  const record = asRecord(payload) ?? {};
  const queueRecord = asRecord(record.queue) ?? record;

  const rawStops =
    readArray(queueRecord.stops) ??
    readArray(queueRecord.orders) ??
    readArray(queueRecord.deliveries) ??
    [];

  const stops = rawStops.map((stop, index) => normalizeDeliveryStop(stop, index));

  return {
    uid,
    activeOrderId:
      readOptionalString(queueRecord.activeOrderId, queueRecord.active_order_id) ??
      stops[0]?.orderId,
    stops: lockQueueHead(stops),
  };
}

export function lockQueueHead(stops: DriverDeliveryStop[]): DriverDeliveryStop[] {
  return stops.map((stop, index) => ({
    ...stop,
    locked: index < 2,
    status: index === 0 ? "current" : index === 1 ? "locked" : "scored",
  }));
}

export function removeUndefinedValues(value: unknown): unknown {
  if (Array.isArray(value)) {
    return value.map(removeUndefinedValues);
  }

  if (typeof value !== "object" || value === null) {
    return value;
  }

  return Object.fromEntries(
    Object.entries(value)
      .filter(([, entryValue]) => entryValue !== undefined)
      .map(([key, entryValue]) => [key, removeUndefinedValues(entryValue)]),
  );
}

function normalizeDeliveryStop(value: unknown, index: number): DriverDeliveryStop {
  const record = asRecord(value) ?? {};
  const customer = asRecord(record.customer) ?? {};
  const metadata = asRecord(record.metadata) ?? {};
  const shippingAddress =
    asRecord(record.shipping_address) ??
    asRecord(record.shippingAddress) ??
    asRecord(record.address) ??
    {};

  const rawItems =
    readArray(record.items) ??
    readArray(record.line_items) ??
    readArray(record.lineItems) ??
    readArray(record.order_items) ??
    readArray(metadata.requested_items) ??
    [];

  const orderId = readString(
    record.orderId,
    record.order_id,
    record.custom_display_id,
    record.display_id,
    record.id,
    `order-${index}`,
  );
  const medusaOrderId = readOptionalString(
    record.medusaOrderId,
    record.medusa_order_id,
    record.id,
  );
  const orderReference = readOptionalString(
    record.orderReference,
    record.order_reference,
    record.custom_display_id,
    record.display_id,
    orderId,
  );

  return {
    orderId,
    medusaOrderId,
    orderReference,
    customerPhone: readOptionalString(
      record.customerPhone,
      record.customer_phone,
      record.phone,
      customer.phone,
      shippingAddress.phone,
      metadata.customer_phone,
      metadata.phone,
    ),
    customerName: readString(
      record.customerName,
      record.customer_name,
      customer.name,
      formatCustomerNameFromAddress(shippingAddress),
      record.email,
      customer.email,
      "Customer",
    ),
    customerAddress: readString(
      record.customerAddress,
      record.customer_address,
      record.shippingAddress,
      record.shipping_address,
      formatAddress(shippingAddress),
      metadata.customer_address,
      "",
    ),
    status: index === 0 ? "current" : index === 1 ? "locked" : "scored",
    locked: index < 2,
    score: readNumber(record.score),
    eta: readOptionalString(record.eta, record.delivery_eta, metadata.eta, metadata.delivery_eta),
    items: rawItems.map(normalizeDeliveryItem),
  };
}

function normalizeDeliveryItem(value: unknown, index: number): DriverDeliveryItem {
  const record = asRecord(value) ?? {};
  const metadata = asRecord(record.metadata) ?? {};
  const variant = asRecord(record.variant) ?? {};
  const product = asRecord(record.product) ?? {};
  const thumbnail = readString(
    record.imageUrl,
    record.image_url,
    record.thumbnail,
    product.thumbnail,
    variant.thumbnail,
    "",
  );

  return {
    id: readString(record.id, record.lineItemId, record.line_item_id, `item-${index}`),
    productId: readOptionalString(record.productId, record.product_id, product.id),
    variantId: readOptionalString(record.variantId, record.variant_id, variant.id),
    name: readString(record.name, record.title, record.product_title, product.title, metadata.name, "Product"),
    variant: readString(
      record.variant,
      record.variantTitle,
      record.variant_title,
      variant.title,
      metadata.flavor,
      metadata.variant,
      "Default",
    ),
    quantity: readPositiveInteger(record.quantity, metadata.quantity, 1),
    imageUrl: thumbnail,
    inventoryLocation: readInventoryLocation(
      record.inventoryLocation,
      record.inventory_location,
      record.inventoryState,
      record.inventory_state,
      metadata.inventoryLocation,
      metadata.inventory_location,
      metadata.inventoryState,
      metadata.inventory_state,
    ),
  };
}

function formatCustomerNameFromAddress(address: Record<string, unknown>) {
  return [address.first_name, address.last_name]
    .map((part) => (typeof part === "string" ? part.trim() : ""))
    .filter(Boolean)
    .join(" ");
}

function formatAddress(address: Record<string, unknown>) {
  const locality = [address.city, address.province, address.state]
    .map((part) => (typeof part === "string" ? part.trim() : ""))
    .filter(Boolean)
    .join(", ");

  const cityLine = [locality, readString(address.postal_code, address.zip)]
    .filter(Boolean)
    .join(" ");

  return [
    address.address_1,
    address.address1,
    address.address_2,
    address.address2,
    cityLine,
    readString(address.country_code, address.country).toUpperCase(),
  ]
    .map((part) => (typeof part === "string" ? part.trim() : ""))
    .filter(Boolean)
    .join(", ");
}

function readInventoryLocation(...values: unknown[]): "vehicle" | "warehouse" {
  const value = readString(...values).toUpperCase();

  if (value === "WAREHOUSE" || value === "IN_WAREHOUSE" || value === "WAREHOUSE_PICKUP_REQUIRED") {
    return "warehouse";
  }

  return "vehicle";
}

function readArray(value: unknown) {
  return Array.isArray(value) ? value : undefined;
}

function readNumber(value: unknown) {
  return typeof value === "number" && Number.isFinite(value) ? value : undefined;
}

function readPositiveInteger(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "number" && Number.isInteger(value) && value > 0) {
      return value;
    }

    if (typeof value === "string") {
      const parsed = Number(value);
      if (Number.isInteger(parsed) && parsed > 0) {
        return parsed;
      }
    }
  }

  return 1;
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }

    if (typeof value === "number" && Number.isFinite(value)) {
      return String(value);
    }
  }

  return "";
}

function readOptionalString(...values: unknown[]) {
  const value = readString(...values);
  return value || undefined;
}

function asRecord(value: unknown): Record<string, unknown> | undefined {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    return undefined;
  }

  return value as Record<string, unknown>;
}
