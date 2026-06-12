import { MedusaContainer } from "@medusajs/framework";
import {
  ContainerRegistrationKeys,
  Modules,
} from "@medusajs/framework/utils";
import {
  isBayblazeOrderNumber,
  syncBayblazeOrderNumberSequence,
} from "../lib/bayblaze-order-number";

type Order = {
  id: string;
  display_id?: number | string | null;
  custom_display_id?: string | null;
};

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
  }) => Promise<{ data: T[] }>;
};

const DELETE_CHUNK_SIZE = 50;

export default async function deleteOldOrders({
  args,
  container,
}: {
  args: string[];
  container: MedusaContainer;
}) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const query = container.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const orderModuleService = container.resolve(Modules.ORDER);
  const deleteAll =
    args.includes("--all") ||
    process.env.BAYBLAZE_DELETE_ALL_ORDERS === "true" ||
    process.env.BAYBLAZE_DELETE_ALL_ORDERS === "1";

  const { data: orders } = await query.graph<Order>({
    entity: "order",
    fields: ["id", "display_id", "custom_display_id"],
  });
  const ordersToDelete = deleteAll
    ? orders
    : orders.filter((order) => !isBayblazeOrderNumber(order.custom_display_id));
  const remainingOrders = orders.filter(
    (order) => !ordersToDelete.some((deleted) => deleted.id === order.id),
  );

  logger.info(
    deleteAll
      ? `Deleting all ${ordersToDelete.length} existing orders.`
      : `Deleting ${ordersToDelete.length} orders without a BB-XXXXX order number.`,
  );

  for (let index = 0; index < ordersToDelete.length; index += DELETE_CHUNK_SIZE) {
    const chunk = ordersToDelete.slice(index, index + DELETE_CHUNK_SIZE);

    await orderModuleService.deleteOrders(chunk.map((order) => order.id));

    for (const order of chunk) {
      logger.info(
        `Deleted order ${order.custom_display_id ?? order.display_id ?? order.id}.`,
      );
    }
  }

  const nextOrderNumber = await syncBayblazeOrderNumberSequence(
    remainingOrders.map((order) => order.custom_display_id),
  );

  logger.info(`Next Bayblaze order number will be ${nextOrderNumber}.`);
}
