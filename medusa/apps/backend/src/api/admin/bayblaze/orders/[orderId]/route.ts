import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils";
import {
  batchInventoryItemLevelsWorkflow,
  updateProductVariantsWorkflow,
} from "@medusajs/medusa/core-flows";

import { assertBayblazeServiceToken } from "../../../../../lib/bayblaze-service-auth";
import { getOrderReference, readOrderTotal } from "../route";

export const AUTHENTICATE = false;

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
    filters?: Record<string, unknown>;
  }) => Promise<{ data: T[] }>;
};

type BayblazeAdminOrderDetail = {
  id: string;
  custom_display_id?: string | null;
  display_id?: string | number | null;
  items?: BayblazeOrderItem[] | null;
  metadata?: Record<string, unknown> | null;
  summary?: {
    current_order_total?: number | null;
    paid_total?: number | null;
    raw_current_order_total?: { value?: string | number | null } | null;
  } | null;
  total?: number | null;
};

type BayblazeOrderItem = {
  quantity?: unknown;
  variant_id?: string | null;
  variant?: {
    id?: string | null;
  } | null;
};

type ProductVariant = {
  id: string;
  product_id?: string | null;
  metadata?: Record<string, unknown> | null;
};

type ProductVariantInventoryItem = {
  inventory_item_id?: string | null;
  variant_id?: string | null;
};

type InventoryLevel = {
  id: string;
  inventory_item_id?: string | null;
  location_id?: string | null;
};

type StockLocation = {
  id: string;
  name?: string | null;
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

const localDeliveryStockLocationName = "BayBlaze Local Delivery";

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

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const orderId = typeof req.params.orderId === "string" ? req.params.orderId.trim() : "";

  if (!orderId) {
    return res.status(400).json({ message: "Order ID is required." });
  }

  const logger = req.scope.resolve("logger");
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const orderModuleService = req.scope.resolve(Modules.ORDER);
  const { data } = await query.graph<BayblazeAdminOrderDetail>({
    entity: "order",
    fields: orderFields,
  });
  const order = data.find((candidate) => matchesOrderId(candidate, orderId));

  if (!order) {
    return res.status(404).json({ message: `Order ${orderId} was not found.` });
  }

  const releasedItems = await releaseOrderInventory(req, query, order);

  await orderModuleService.deleteOrders([order.id]);

  logger.info(
    `Cancelled and deleted BayBlaze order ${getOrderReference(order)}; restored ${releasedItems.length} inventory line(s).`,
  );

  return res.status(200).json({
    cancelled: true,
    deleted: true,
    orderId: order.id,
    orderReference: getOrderReference(order),
    releasedItems,
  });
}

export async function DELETE(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const orderId = typeof req.params.orderId === "string" ? req.params.orderId.trim() : "";

  if (!orderId) {
    return res.status(400).json({ message: "Order ID is required." });
  }

  const body = (req.body ?? {}) as Record<string, unknown>;
  const releaseStock = body.releaseStock === true;
  const logger = req.scope.resolve("logger");
  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const orderModuleService = req.scope.resolve(Modules.ORDER);
  const { data } = await query.graph<BayblazeAdminOrderDetail>({
    entity: "order",
    fields: orderFields,
  });
  const order = data.find((candidate) => matchesOrderId(candidate, orderId));

  if (!order) {
    return res.status(404).json({ message: `Order ${orderId} was not found.` });
  }

  const releasedItems = releaseStock ? await releaseOrderInventory(req, query, order) : [];
  const deletedAt = new Date().toISOString();
  const metadata = {
    ...(order.metadata ?? {}),
    bayblaze_deleted: true,
    bayblaze_deleted_at: deletedAt,
    bayblaze_deleted_release_stock: releaseStock,
    bayblaze_order_status: "deleted",
    order_status: "deleted",
  };

  await orderModuleService.updateOrders(order.id, {
    metadata,
  } as never);

  logger.info(
    `Soft-deleted BayBlaze order ${getOrderReference(order)}; restored ${releasedItems.length} inventory line(s).`,
  );

  return res.status(200).json({
    deleted: true,
    deletedAt,
    orderId: order.id,
    orderReference: getOrderReference(order),
    releasedItems,
    releasedStock: releaseStock,
  });
}

function matchesOrderId(order: BayblazeAdminOrderDetail, orderId: string) {
  return [order.id, order.custom_display_id, order.display_id]
    .map((value) => (typeof value === "number" ? String(value) : value))
    .some((value) => value === orderId);
}

async function releaseOrderInventory(
  req: MedusaRequest,
  query: Query,
  order: BayblazeAdminOrderDetail,
) {
  const items = getReleaseItems(order);
  const releasedItems: Array<{
    nextQuantity: number;
    quantity: number;
    variantId: string;
  }> = [];

  for (const item of items) {
    const variant = await getVariant(query, item.variantId);
    const metadata = variant.metadata ?? {};
    const currentQuantity = readQuantity(metadata.availableQuantity);
    const nextQuantity =
      item.availableQuantityAtCheckout === null
        ? currentQuantity + item.quantity
        : currentQuantity < item.availableQuantityAtCheckout
          ? Math.min(currentQuantity + item.quantity, item.availableQuantityAtCheckout)
          : currentQuantity;

    await updateProductVariantsWorkflow(req.scope).run({
      input: {
        product_variants: [
          {
            id: item.variantId,
            metadata: {
              ...metadata,
              availableQuantity: nextQuantity,
            },
          },
        ],
      },
    });

    await syncVariantInventoryLevel(req, query, item.variantId, nextQuantity);

    releasedItems.push({
      nextQuantity,
      quantity: item.quantity,
      variantId: item.variantId,
    });
  }

  return releasedItems;
}

function getReleaseItems(order: BayblazeAdminOrderDetail) {
  const quantitiesByVariant = new Map<string, {
    availableQuantityAtCheckout: number | null;
    quantity: number;
  }>();

  for (const item of readRequestedItems(order.metadata)) {
    addReleaseItem(
      quantitiesByVariant,
      item.variantId,
      item.quantity,
      item.availableQuantityAtCheckout,
    );
  }

  if (quantitiesByVariant.size === 0) {
    for (const item of order.items ?? []) {
      addReleaseItem(
        quantitiesByVariant,
        readString(item.variant_id, item.variant?.id),
        readQuantity(item.quantity),
        null,
      );
    }
  }

  return Array.from(quantitiesByVariant.entries()).map(([variantId, item]) => ({
    availableQuantityAtCheckout: item.availableQuantityAtCheckout,
    quantity: item.quantity,
    variantId,
  }));
}

function readRequestedItems(metadata?: Record<string, unknown> | null) {
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

      return {
        availableQuantityAtCheckout: readOptionalQuantity(record.available_quantity),
        quantity: readQuantity(record.quantity),
        variantId: readString(record.variant_id, record.variantId),
      };
    })
    .filter((item): item is {
      availableQuantityAtCheckout: number | null;
      quantity: number;
      variantId: string;
    } => {
      return Boolean(item?.variantId && item.quantity > 0);
    });
}

function addReleaseItem(
  quantitiesByVariant: Map<string, {
    availableQuantityAtCheckout: number | null;
    quantity: number;
  }>,
  variantId: string,
  quantity: number,
  availableQuantityAtCheckout: number | null,
) {
  if (!variantId || quantity <= 0) {
    return;
  }

  const current = quantitiesByVariant.get(variantId);

  quantitiesByVariant.set(variantId, {
    availableQuantityAtCheckout:
      current?.availableQuantityAtCheckout ?? availableQuantityAtCheckout,
    quantity: (current?.quantity ?? 0) + quantity,
  });
}

async function getVariant(query: Query, variantId: string) {
  const { data: variants } = await query.graph<ProductVariant>({
    entity: "product_variant",
    fields: ["id", "product_id", "metadata"],
    filters: { id: variantId },
  });
  const variant = variants[0];

  if (!variant) {
    throw new Error(`Variant ${variantId} was not found.`);
  }

  return variant;
}

async function syncVariantInventoryLevel(
  req: MedusaRequest,
  query: Query,
  variantId: string,
  quantity: number,
) {
  const inventoryItemId = await getVariantInventoryItemId(query, variantId);
  const stockLocationId = await getLocalDeliveryStockLocationId(query);
  const existingLevel = await getInventoryLevel(query, inventoryItemId, stockLocationId);
  const levelDraft = {
    inventory_item_id: inventoryItemId,
    location_id: stockLocationId,
    stocked_quantity: quantity,
  };

  await batchInventoryItemLevelsWorkflow(req.scope).run({
    input: existingLevel
      ? {
          update: [
            {
              ...levelDraft,
              id: existingLevel.id,
            },
          ],
        }
      : {
          create: [levelDraft],
        },
  });
}

async function getVariantInventoryItemId(query: Query, variantId: string) {
  const { data: inventoryItems } = await query.graph<ProductVariantInventoryItem>({
    entity: "product_variant_inventory_item",
    fields: ["variant_id", "inventory_item_id"],
    filters: { variant_id: variantId },
  });
  const inventoryItemId = readString(inventoryItems[0]?.inventory_item_id);

  if (!inventoryItemId) {
    throw new Error(`Variant ${variantId} is missing a Medusa inventory item.`);
  }

  return inventoryItemId;
}

async function getLocalDeliveryStockLocationId(query: Query) {
  const { data: stockLocations } = await query.graph<StockLocation>({
    entity: "stock_location",
    fields: ["id", "name"],
  });
  const stockLocation = stockLocations.find(
    (location) => readString(location.name) === localDeliveryStockLocationName,
  ) ?? stockLocations[0];

  if (!stockLocation) {
    throw new Error("No Medusa stock location is available for inventory sync.");
  }

  return stockLocation.id;
}

async function getInventoryLevel(
  query: Query,
  inventoryItemId: string,
  stockLocationId: string,
) {
  const { data: inventoryLevels } = await query.graph<InventoryLevel>({
    entity: "inventory_level",
    fields: ["id", "inventory_item_id", "location_id"],
    filters: {
      inventory_item_id: inventoryItemId,
      location_id: stockLocationId,
    },
  });

  return inventoryLevels[0];
}

function readQuantity(value: unknown) {
  const number = typeof value === "number" ? value : Number(value);

  return Number.isInteger(number) && number > 0 ? number : 0;
}

function readOptionalQuantity(value: unknown) {
  const number = typeof value === "number" ? value : Number(value);

  return Number.isInteger(number) && number >= 0 ? number : null;
}

function readString(...values: unknown[]) {
  for (const value of values) {
    if (typeof value === "string" && value.trim()) {
      return value.trim();
    }
  }

  return "";
}
