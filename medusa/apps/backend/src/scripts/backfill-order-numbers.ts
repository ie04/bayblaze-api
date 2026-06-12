import { MedusaContainer } from "@medusajs/framework";
import {
  ContainerRegistrationKeys,
  Modules,
} from "@medusajs/framework/utils";
import { generateBayblazeOrderNumber } from "../lib/bayblaze-order-number";

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

export default async function backfillOrderNumbers({
  container,
}: {
  container: MedusaContainer;
}) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const query = container.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const orderModuleService = container.resolve(Modules.ORDER);

  const { data: orders } = await query.graph<Order>({
    entity: "order",
    fields: ["id", "display_id", "custom_display_id"],
  });
  const ordersWithoutPublicNumber = orders.filter(
    (order) => !order.custom_display_id,
  );

  logger.info(
    `Found ${ordersWithoutPublicNumber.length} orders without a Bayblaze order number.`,
  );

  for (const order of ordersWithoutPublicNumber) {
    const customDisplayId = await generateBayblazeOrderNumber(order, {});

    await orderModuleService.updateOrders(order.id, {
      custom_display_id: customDisplayId,
    } as never);

    logger.info(`Updated order ${order.display_id ?? order.id}: ${customDisplayId}`);
  }
}
