import type { Request } from "express";
import { readInventoryVariants } from "./vehicleInventory";
import { ApiRequestError } from "../../http/apiRequestError";
import { getVehicleRegistry, type VehicleRegistry } from "./vehicleService";

export async function validateInventoryVehicleMutation(
  req: Request, registry: Pick<VehicleRegistry, "requireActive"> = getVehicleRegistry(),
  readVariants = readInventoryVariants,
) {
  const mutation = req.body ?? {};
  let state: unknown;
  let vehicleId: unknown;
  if (mutation.type === "assign-vehicle") {
    if (mutation.vehicleId === "warehouse") return;
    vehicleId = mutation.vehicleId;
    state = "ON_VEHICLE";
  } else if (["create-variant", "update-variant-details", "create-product-with-variant"].includes(mutation.type)) {
    const draft = mutation.type === "create-product-with-variant" ? mutation.draft?.variant : mutation.draft;
    state = draft?.inventoryState;
    vehicleId = draft?.vehicleId;
    // Partial detail edits can leave both stock-location fields unchanged.
    if (state === undefined && vehicleId === undefined) return;
    if (state === "IN_WAREHOUSE") return;
    if (state === undefined) {
      const variant = (await readVariants()).find(item => item.id === mutation.variantId);
      state = variant?.metadata?.inventoryState;
      if (state !== "ON_VEHICLE" && !vehicleId) return;
    }
  } else if (mutation.type === "set-state" && mutation.state === "ON_VEHICLE") {
    const variant = (await readVariants()).find(item => item.id === mutation.variantId);
    vehicleId = variant?.metadata?.assignedVehicleId;
    state = "ON_VEHICLE";
  } else return;
  if (typeof vehicleId !== "string" || !vehicleId.trim()) {
    if (state === "ON_VEHICLE") throw new ApiRequestError(400, "Select a vehicle before assigning stock to a vehicle.");
    return;
  }
  // Driver occupancy is deliberately irrelevant to inventory assignment.
  await registry.requireActive(vehicleId.trim());
}
