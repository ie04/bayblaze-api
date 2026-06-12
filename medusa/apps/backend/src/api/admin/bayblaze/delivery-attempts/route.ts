import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http";
import { ContainerRegistrationKeys, Modules } from "@medusajs/framework/utils";

import { assertBayblazeServiceToken } from "../../../../lib/bayblaze-service-auth";

export const AUTHENTICATE = false;

type Query = {
  graph: <T = unknown>(input: {
    entity: string;
    fields: string[];
  }) => Promise<{ data: T[] }>;
};

type OrderForDeliveryAttempt = {
  id: string;
  custom_display_id?: string | null;
  display_id?: string | number | null;
  metadata?: Record<string, unknown> | null;
};

const supportedAttemptTypes = new Set(["out_for_delivery", "completed", "cancelled"]);
const terminalAttemptTypes = new Set(["completed", "cancelled"]);

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  if (!assertBayblazeServiceToken(req, res)) {
    return;
  }

  const body = req.body as Record<string, unknown> | undefined;

  const orderId = typeof body?.orderId === "string" ? body.orderId : "";
  const uid = typeof body?.uid === "string" ? body.uid : "";

  if (!body || !orderId || !uid) {
    return res.status(400).json({ message: "Delivery attempt requires uid and orderId." });
  }

  const type = typeof body.type === "string" ? body.type : "unknown";
  const logger = req.scope.resolve("logger");
  logger.info(`Received BayBlaze delivery attempt event ${type} for ${orderId}.`);

  if (!supportedAttemptTypes.has(type)) {
    return res.status(202).json({ accepted: true, updated: false, terminal: false });
  }

  const query = req.scope.resolve<Query>(ContainerRegistrationKeys.QUERY);
  const orderModuleService = req.scope.resolve(Modules.ORDER);
  const { data: orders } = await query.graph<OrderForDeliveryAttempt>({
    entity: "order",
    fields: ["id", "display_id", "custom_display_id", "metadata"],
  });
  const order = orders.find((candidate) => matchesOrderId(candidate, orderId));

  if (!order) {
    return res.status(404).json({
      message: `Order ${orderId} was not found for delivery attempt update.`,
    });
  }

  const eventAt = new Date().toISOString();
  const isTerminal = terminalAttemptTypes.has(type);
  const metadata: Record<string, unknown> = {
    ...(order.metadata ?? {}),
    bayblaze_delivery_status: type,
    bayblaze_delivery_driver_uid: uid,
    bayblaze_delivery_event_at: eventAt,
  };

  if (type === "out_for_delivery") {
    metadata.bayblaze_out_for_delivery_at = eventAt;
  }

  if (isTerminal) {
    metadata.bayblaze_delivery_terminal_event_at = eventAt;
  }

  if (typeof body.note === "string" && body.note.trim()) {
    metadata.bayblaze_delivery_note = body.note.trim();
  }

  await orderModuleService.updateOrders(order.id, {
    metadata,
  } as never);

  logger.info(`Marked Medusa order ${order.id} delivery status as ${type}.`);

  return res.status(202).json({
    accepted: true,
    orderId: order.id,
    status: type,
    terminal: isTerminal,
  });
}

function matchesOrderId(order: OrderForDeliveryAttempt, orderId: string) {
  const normalizedOrderId = orderId.trim();

  return [order.id, order.custom_display_id, order.display_id]
    .map((value) => (typeof value === "number" ? String(value) : value))
    .some((value) => value === normalizedOrderId);
}
