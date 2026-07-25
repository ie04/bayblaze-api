import type { MedusaContainer, SubscriberArgs, SubscriberConfig } from "@medusajs/framework";
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils";
import {
  batchInventoryItemLevelsWorkflow,
  updateProductVariantsWorkflow,
} from "@medusajs/medusa/core-flows";

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
    filters?: Record<string, unknown>;
  }) => Promise<{ data: T[] }>;
};

type OrderItem = {
  quantity?: unknown;
  variant_id?: string | null;
  variant?: {
    id?: string | null;
  } | null;
};

type Order = {
  id: string;
  items?: OrderItem[] | null;
  metadata?: Record<string, unknown> | null;
};

type ProductVariant = {
  id: string;
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
  reserved_quantity?: number | string | null;
};

type StockLocation = {
  id: string;
  name?: string | null;
};

const localDeliveryStockLocationName = "Bayblaze Local Delivery Hub";

const orderFields = [
  "id",
  "items.*",
  "items.variant.*",
  "metadata",
];

export default async function bayblazeOrderInventoryHandler({
  event,
  container,
}: SubscriberArgs<{ id?: string; order_id?: string }>) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const query = container.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const eventName = readString((event as { name?: unknown }).name);
  const orderId = readString(event.data?.order_id, event.data?.id);

  if (!orderId) {
    return;
  }

  try {
    const order = await getOrder(query, orderId);

    if (!order) {
      logger.warn(`[BayBlaze Inventory] Could not find order ${orderId}; skipping stock sync.`);
      return;
    }

    if (eventName === "order.placed") {
      await reserveOrderInventory({ container, logger, order, query });
    } else if (eventName === "order.canceled") {
      await releaseOrderInventory({ container, logger, order, query });
    }
  } catch (error) {
    logger.error(
      `[BayBlaze Inventory] Could not sync order ${orderId}: ${
        error instanceof Error ? error.message : String(error)
      }`,
    );
    throw error;
  }
}

export const config: SubscriberConfig = {
  event: ["order.placed", "order.canceled"],
};

async function reserveOrderInventory({
  container,
  logger,
  order,
  query,
}: {
  container: MedusaContainer;
  logger: { info: (message: string) => void };
  order: Order;
  query: Query;
}) {
  if (order.metadata?.bayblaze_inventory_reserved_at) {
    return;
  }

  const adjustedItems = await adjustOrderInventory({
    container,
    order,
    query,
    release: false,
  });

  await updateOrderInventoryMetadata(container, order, {
    bayblaze_inventory_reserved_at: new Date().toISOString(),
    bayblaze_inventory_reserved_items: adjustedItems,
  });

  logger.info(
    `[BayBlaze Inventory] Reserved ${adjustedItems.length} order inventory line(s) for ${order.id}.`,
  );
}

async function releaseOrderInventory({
  container,
  logger,
  order,
  query,
}: {
  container: MedusaContainer;
  logger: { info: (message: string) => void };
  order: Order;
  query: Query;
}) {
  if (order.metadata?.bayblaze_inventory_released_at) {
    return;
  }

  const adjustedItems = await adjustOrderInventory({
    container,
    order,
    query,
    release: true,
  });

  await updateOrderInventoryMetadata(container, order, {
    bayblaze_inventory_released_at: new Date().toISOString(),
    bayblaze_inventory_released_items: adjustedItems,
  });

  logger.info(
    `[BayBlaze Inventory] Released ${adjustedItems.length} order inventory line(s) for ${order.id}.`,
  );
}

async function adjustOrderInventory({
  container,
  order,
  query,
  release,
}: {
  container: MedusaContainer;
  order: Order;
  query: Query;
  release: boolean;
}) {
  const adjustedItems: Array<{
    nextQuantity: number;
    quantity: number;
    variantId: string;
  }> = [];

  for (const item of getOrderInventoryItems(order)) {
    const variant = await getVariant(query, item.variantId);
    const metadata = variant.metadata ?? {};
    const currentQuantity = readQuantity(metadata.availableQuantity);
    const nextQuantity = release
      ? getReleasedQuantity(currentQuantity, item.quantity, item.availableQuantityAtCheckout)
      : Math.max(0, currentQuantity - item.quantity);

    await updateProductVariantsWorkflow(container).run({
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

    await syncVariantInventoryLevel(container, query, item.variantId, nextQuantity);

    adjustedItems.push({
      nextQuantity,
      quantity: item.quantity,
      variantId: item.variantId,
    });
  }

  return adjustedItems;
}

function getReleasedQuantity(
  currentQuantity: number,
  quantity: number,
  availableQuantityAtCheckout: number | null,
) {
  if (availableQuantityAtCheckout === null) {
    return currentQuantity + quantity;
  }

  return currentQuantity < availableQuantityAtCheckout
    ? Math.min(currentQuantity + quantity, availableQuantityAtCheckout)
    : currentQuantity;
}

function getOrderInventoryItems(order: Order) {
  const quantitiesByVariant = new Map<string, {
    availableQuantityAtCheckout: number | null;
    quantity: number;
  }>();

  for (const item of readRequestedItems(order.metadata)) {
    addOrderInventoryItem(
      quantitiesByVariant,
      item.variantId,
      item.quantity,
      item.availableQuantityAtCheckout,
    );
  }

  if (quantitiesByVariant.size === 0) {
    for (const item of order.items ?? []) {
      addOrderInventoryItem(
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
    } => Boolean(item?.variantId && item.quantity > 0));
}

function addOrderInventoryItem(
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

async function getOrder(query: Query, orderId: string) {
  const { data: orders } = await query.graph<Order>({
    entity: "order",
    fields: orderFields,
    filters: { id: orderId },
  });

  return orders[0];
}

async function getVariant(query: Query, variantId: string) {
  const { data: variants } = await query.graph<ProductVariant>({
    entity: "product_variant",
    fields: ["id", "metadata"],
    filters: { id: variantId },
  });
  const variant = variants[0];

  if (!variant) {
    throw new Error(`Variant ${variantId} was not found.`);
  }

  return variant;
}

async function syncVariantInventoryLevel(
  container: MedusaContainer,
  query: Query,
  variantId: string,
  quantity: number,
) {
  const inventoryItemId = await getVariantInventoryItemId(query, variantId);
  const stockLocationId = await getLocalDeliveryStockLocationId(query);
  const existingLevel = await getInventoryLevel(query, inventoryItemId, stockLocationId);
  const reservedQuantity = readQuantity(existingLevel?.reserved_quantity);
  const levelDraft = {
    inventory_item_id: inventoryItemId,
    location_id: stockLocationId,
    stocked_quantity: quantity + reservedQuantity,
  };

  await batchInventoryItemLevelsWorkflow(container).run({
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
    fields: ["id", "inventory_item_id", "location_id", "reserved_quantity"],
    filters: {
      inventory_item_id: inventoryItemId,
      location_id: stockLocationId,
    },
  });

  return inventoryLevels[0];
}

async function updateOrderInventoryMetadata(
  container: MedusaContainer,
  order: Order,
  metadata: Record<string, unknown>,
) {
  const orderModuleService = container.resolve(Modules.ORDER);

  await orderModuleService.updateOrders(order.id, {
    metadata: {
      ...(order.metadata ?? {}),
      ...metadata,
    },
  } as never);
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

function readQuantity(value: unknown) {
  const number = typeof value === "number" ? value : Number(value);

  return Number.isInteger(number) && number > 0 ? number : 0;
}

function readOptionalQuantity(value: unknown) {
  const number = typeof value === "number" ? value : Number(value);

  return Number.isInteger(number) && number >= 0 ? number : null;
}
