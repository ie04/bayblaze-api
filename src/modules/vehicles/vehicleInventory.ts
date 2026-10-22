import { createBayblazeMedusaHeaders, getMedusaBackendUrl } from "../../clients/medusaServiceClient";
import { ApiRequestError } from "../../http/apiRequestError";

export type InventoryVehicleVariant = {
  id: string;
  metadata?: { inventoryState?: string; assignedVehicleId?: string };
};

export async function readInventoryVariants(): Promise<InventoryVehicleVariant[]> {
  const response = await fetch(`${getMedusaBackendUrl()}/admin/bayblaze/inventory`, {
    headers: createBayblazeMedusaHeaders(),
  });
  if (!response.ok) throw new ApiRequestError(502, "Vehicle inventory could not be verified. Try again.");
  const snapshot = await response.json() as { products?: { variants?: InventoryVehicleVariant[] }[] };
  return (snapshot.products ?? []).flatMap(product => product.variants ?? []);
}
