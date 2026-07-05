import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys } from "@medusajs/framework/utils";

import { assertBayblazeServiceToken } from "../../../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
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

type BayblazeOrderItem = {
  title?: string | null;
  variant_title?: string | null;
  subtitle?: string | null;
  quantity?: unknown;
  unit_price?: unknown;
  subtotal?: unknown;
  total?: unknown;
  raw_quantity?: unknown;
  raw_unit_price?: unknown;
  raw_subtotal?: unknown;
  raw_total?: unknown;
  detail?: Record<string, unknown> | null;
  product?: {
    title?: string | null;
  } | null;
  variant?: {
    title?: string | null;
  } | null;
};

type BayblazeOrder = {
  id: string;
  display_id?: number | null;
  custom_display_id?: string | null;
  email?: string | null;
  currency_code?: string | null;
  subtotal?: number | null;
  discount_total?: number | null;
  shipping_total?: number | null;
  tax_total?: number | null;
  total?: number | null;
  items?: BayblazeOrderItem[] | null;
  metadata?: Record<string, unknown> | null;
  shipping_address?: OrderAddress | null;
};

type PrintJob = {
  jobId: string;
  jobType: "delivery_label" | "invoice";
  orderId: string;
  orderNumber: string;
  orderUrl: string;
  customerName: string;
  customerPhone?: string;
  customerEmail?: string;
  address: string[];
  instructions: string;
  currencyCode?: string;
  forceReprint: true;
  items?: {
    title: string;
    variantTitle: string;
    quantity: number;
    unitPrice: number;
    total: number;
  }[];
  totals?: {
    subtotal: number;
    discountTotal: number;
    discountLabel?: string;
    shippingTotal: number;
    taxTotal: number;
    total: number;
  };
  paymentMethod?: string;
};

const orderFields = [
  "id",
  "display_id",
  "custom_display_id",
  "email",
  "currency_code",
  "subtotal",
  "discount_total",
  "shipping_total",
  "tax_total",
  "total",
  "items.*",
  "items.detail.*",
  "items.product.*",
  "items.variant.*",
  "metadata",
  "shipping_address.*",
];

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const orderId = typeof req.params.orderId === "string" ? req.params.orderId.trim() : "";
  const labelPrinterUrl = getLabelPrinterAgentUrl();

  if (!orderId) {
    return res.status(400).json({ message: "Order ID is required." });
  }

  if (!labelPrinterUrl) {
    return res.status(503).json({ message: "Label printer agent is not configured." });
  }

  const logger = req.scope.resolve("logger");
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const { data } = await query.graph<BayblazeOrder>({
    entity: "order",
    fields: orderFields,
  });
  const order = data.find((candidate) => matchesOrderId(candidate, orderId));

  if (!order) {
    return res.status(404).json({ message: `Order ${orderId} was not found.` });
  }

  const jobs = [
    toLabelPrintJob(order),
    toInvoicePrintJob(order),
  ];
  const results = await Promise.all(jobs.map((job) => submitPrintJob(job, labelPrinterUrl)));

  logger.info(
    `[BayBlaze Label Printer] Reprint requested for ${getOrderNumber(order)} by ${readRequestedBy(req.body)}.`,
  );

  return res.status(202).json({
    accepted: true,
    orderId: order.id,
    orderNumber: getOrderNumber(order),
    results,
  });
}

async function submitPrintJob(job: PrintJob, labelPrinterUrl: string) {
  let response: globalThis.Response | null = null;
  let responseBody = "";

  for (const headers of getLabelPrinterHeaderCandidates()) {
    response = await fetch(`${labelPrinterUrl}/print-label`, {
      body: JSON.stringify(job),
      headers,
      method: "POST",
    });
    responseBody = await response.text().catch(() => "");

    if (response.status !== 401) {
      break;
    }
  }

  if (!response?.ok) {
    throw new Error(
      `Label reprint failed for ${job.orderNumber}: ${response?.status ?? 500} ${response?.statusText ?? ""} ${responseBody}`,
    );
  }

  return {
    jobId: job.jobId,
    jobType: job.jobType,
    response: responseBody ? JSON.parse(responseBody) : { ok: true },
  };
}

function toLabelPrintJob(order: BayblazeOrder): PrintJob {
  const orderNumber = getOrderNumber(order);
  const shippingAddress = order.shipping_address ?? {};
  const metadata = order.metadata ?? {};
  const reprintId = Date.now();

  return {
    jobId: `delivery-label:${order.id}:reprint:${reprintId}`,
    jobType: "delivery_label",
    orderId: order.id,
    orderNumber,
    orderUrl: getOrderUrl(orderNumber),
    customerName: formatCustomerName(shippingAddress, order.email),
    address: formatAddressLines(shippingAddress, readAddressLine2(metadata)),
    instructions: readInstructions(metadata),
    forceReprint: true,
  };
}

function toInvoicePrintJob(order: BayblazeOrder): PrintJob {
  const orderNumber = getOrderNumber(order);
  const shippingAddress = order.shipping_address ?? {};
  const metadata = order.metadata ?? {};
  const invoiceItems = normalizeInvoiceItems(order.items, metadata);
  const itemsSubtotal = invoiceItems.reduce((sum, item) => sum + item.total, 0);
  const subtotal =
    readMoney(order.subtotal) ||
    readDollarMoney(metadata.checkout_promo_subtotal) ||
    readDollarMoney(metadata.first_order_offer_subtotal) ||
    itemsSubtotal;
  const discountTotal =
    readMoney(order.discount_total) ||
    readDollarMoney(
      metadata.checkout_promo_discount_amount,
      metadata.first_order_offer_discount_amount,
      metadata.bayblaze_referral_discount_amount,
      metadata.referral_discount_amount,
    );
  const shippingTotal = readMoney(order.shipping_total);
  const taxTotal = readMoney(order.tax_total);
  const total =
    readMoney(order.total) ||
    readDollarMoney(
      metadata.checkout_promo_total_after_discount,
      metadata.first_order_offer_total_after_discount,
      metadata.bayblaze_referral_total_after_discount,
      metadata.referral_total_after_discount,
    ) ||
    Math.max(0, subtotal - discountTotal + shippingTotal + taxTotal);

  return {
    jobId: `invoice:${order.id}:reprint:${Date.now()}`,
    jobType: "invoice",
    orderId: order.id,
    orderNumber,
    orderUrl: getOrderUrl(orderNumber),
    customerName: formatCustomerName(shippingAddress, order.email),
    customerPhone: readString(shippingAddress.phone),
    customerEmail: readString(order.email),
    address: formatAddressLines(shippingAddress, readAddressLine2(metadata)),
    instructions: readInstructions(metadata),
    currencyCode: readString(order.currency_code).toUpperCase() || "USD",
    forceReprint: true,
    items: invoiceItems,
    totals: {
      subtotal,
      discountTotal,
      discountLabel: getDiscountLabel(metadata),
      shippingTotal,
      taxTotal,
      total,
    },
    paymentMethod: "Pay on delivery",
  };
}

function getDiscountLabel(metadata: Record<string, unknown>) {
  const checkoutPromoCode = readString(metadata.checkout_promo_code);
  const firstOrderCode = readString(metadata.first_order_offer_code);

  if (checkoutPromoCode) {
    return `Discount ${checkoutPromoCode}`;
  }

  if (firstOrderCode) {
    return `Discount ${firstOrderCode}`;
  }

  return "Discount";
}

function matchesOrderId(order: BayblazeOrder, orderId: string) {
  return [order.id, order.custom_display_id, order.display_id]
    .map((value) => (typeof value === "number" ? String(value) : value))
    .some((value) => value === orderId);
}

function normalizeInvoiceItems(
  items?: BayblazeOrderItem[] | null,
  metadata?: Record<string, unknown> | null,
) {
  const medusaItems = (items ?? [])
    .map((item) => {
      const detail = item.detail ?? {};
      const quantity = readQuantity(item.quantity, item.raw_quantity, detail.quantity, detail.raw_quantity);
      const total = readMoney(
        item.total,
        item.raw_total,
        item.subtotal,
        item.raw_subtotal,
        detail.total,
        detail.raw_total,
        detail.subtotal,
        detail.raw_subtotal,
      );
      const unitPrice =
        readMoney(item.unit_price, item.raw_unit_price, detail.unit_price, detail.raw_unit_price) ||
        (quantity > 0 ? Math.round(total / quantity) : 0);

      return {
        title: readString(item.title, item.product?.title, item.subtitle, "Item"),
        variantTitle: readString(item.variant_title, item.variant?.title),
        quantity,
        unitPrice,
        total,
      };
    })
    .filter((item) => item.quantity > 0 || item.total > 0);

  return medusaItems.length ? medusaItems : readRequestedInvoiceItems(metadata);
}

function readRequestedInvoiceItems(metadata?: Record<string, unknown> | null) {
  const requestedItems = metadata?.requested_items;

  if (!Array.isArray(requestedItems)) {
    return [];
  }

  return requestedItems
    .map((item) => {
      if (!item || typeof item !== "object") {
        return null;
      }

      const record = item as Record<string, unknown>;
      const quantity = readQuantity(record.quantity, 1);
      const unitPrice = readMoney(record.unit_price_cents, record.unit_price, record.price_cents, record.price);
      const total = readMoney(record.total_cents, record.total, record.line_total_cents) || unitPrice * quantity;

      return {
        title: readString(record.name, "Item"),
        variantTitle: readString(record.flavor),
        quantity,
        unitPrice: unitPrice || (quantity > 0 ? Math.round(total / quantity) : 0),
        total,
      };
    })
    .filter((item): item is NonNullable<PrintJob["items"]>[number] => {
      return Boolean(item && (item.quantity > 0 || item.total > 0));
    });
}

function readAddressLine2(metadata: Record<string, unknown>) {
  return readString(
    metadata.address_line_2,
    metadata.delivery_address_line_2,
    metadata.checkout_address_line_2,
    metadata.customer_address_line_2,
  );
}

function readInstructions(metadata: Record<string, unknown>) {
  return readString(
    metadata.driver_note,
    metadata.checkout_notes,
    metadata.delivery_instructions,
    metadata.instructions,
  );
}

function getOrderNumber(order: BayblazeOrder) {
  if (order.custom_display_id?.trim()) {
    return order.custom_display_id.trim();
  }

  if (typeof order.display_id === "number") {
    return `BB-${String(order.display_id).padStart(5, "0")}`;
  }

  return order.id;
}

function getOrderUrl(orderNumber: string) {
  const siteUrl =
    process.env.BAYBLAZE_STOREFRONT_URL?.trim() ||
    process.env.NEXT_PUBLIC_SITE_URL?.trim() ||
    "https://bayblaze.net";

  return `${siteUrl.replace(/\/$/, "")}/orders/${encodeURIComponent(orderNumber)}`;
}

function formatCustomerName(address: OrderAddress, fallback?: string | null) {
  const name = [address.first_name, address.last_name]
    .map((part) => part?.trim())
    .filter(Boolean)
    .join(" ");

  return name || fallback?.trim() || "BayBlaze customer";
}

function formatAddressLines(address: OrderAddress, addressLine2 = "") {
  const locality = [address.city, address.province]
    .map((part) => readString(part))
    .filter(Boolean)
    .join(", ");
  const cityLine = [locality, readString(address.postal_code)]
    .filter(Boolean)
    .join(" ");

  return [
    readString(address.address_1),
    readString(address.address_2, addressLine2),
    cityLine,
    readString(address.country_code).toUpperCase(),
  ].filter((part): part is string => Boolean(part));
}

function getLabelPrinterAgentUrl() {
  return (
    process.env.LABEL_PRINTER_AGENT_URL?.trim() ||
    process.env.LABEL_AGENT_URL?.trim() ||
    ""
  ).replace(/\/$/, "");
}

function getLabelPrinterHeaderCandidates() {
  const tokens = [
    process.env.LABEL_PRINTER_AGENT_TOKEN?.trim(),
    process.env.LABEL_AGENT_TOKEN?.trim(),
  ].filter((token): token is string => Boolean(token));
  const uniqueTokens = Array.from(new Set(tokens));

  if (uniqueTokens.length === 0) {
    return [{ "content-type": "application/json" }];
  }

  return uniqueTokens.map((token) => ({
    authorization: `Bearer ${token}`,
    "content-type": "application/json",
    "x-label-printer-token": token,
  }));
}

function readRequestedBy(body: unknown) {
  if (!body || typeof body !== "object") {
    return "unknown";
  }

  const requestedBy = (body as Record<string, unknown>).requestedBy;
  return typeof requestedBy === "string" && requestedBy.trim()
    ? requestedBy.trim()
    : "unknown";
}

function readMoney(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "number" && Number.isFinite(value)) {
      return Math.round(value);
    }

    if (typeof value === "object" && value !== null) {
      const record = value as Record<string, unknown>;
      const nested = readMoney(record.value, record.amount);

      if (nested > 0) {
        return nested;
      }
    }

    if (typeof value === "string" && value.trim()) {
      const parsed = Number(value.replace(/[^\d.-]/g, ""));
      if (Number.isFinite(parsed)) {
        return value.includes(".") ? Math.round(parsed * 100) : Math.round(parsed);
      }
    }
  }

  return 0;
}

function readDollarMoney(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "number" && Number.isFinite(value)) {
      return Math.round(value * 100);
    }

    if (typeof value === "string" && value.trim()) {
      const parsed = Number(value.replace(/[^\d.-]/g, ""));
      if (Number.isFinite(parsed)) {
        return Math.round(parsed * 100);
      }
    }
  }

  return 0;
}

function readQuantity(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "number" && Number.isFinite(value)) {
      return Math.max(0, Math.round(value));
    }

    if (typeof value === "object" && value !== null) {
      const record = value as Record<string, unknown>;
      const nested = readQuantity(record.value, record.amount);

      if (nested > 0) {
        return nested;
      }
    }

    if (typeof value === "string" && value.trim()) {
      const parsed = Number(value.replace(/[^\d.-]/g, ""));
      if (Number.isFinite(parsed)) {
        return Math.max(0, Math.round(parsed));
      }
    }
  }

  return 0;
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }

  return "";
}
