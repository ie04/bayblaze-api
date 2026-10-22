import { readInventoryVariants } from "./vehicleInventory";
import { FieldValue, type Firestore } from "firebase-admin/firestore";
import { z } from "zod";
import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { ApiRequestError } from "../../http/apiRequestError";

const fields = {
  label: z.string().trim().min(1).max(100),
  plateNumber: z.string().trim().max(32),
  make: z.string().trim().max(80),
  model: z.string().trim().max(80),
  color: z.string().trim().max(50),
  active: z.boolean(),
};
export const vehicleCreateSchema = z.object({
  ...fields,
  vehicleId: z.string().trim().regex(/^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$/)
    .refine(id => id.toLowerCase() !== "warehouse", "Warehouse is not a vehicle ID."),
  plateNumber: fields.plateNumber.default(""),
  make: fields.make.default(""), model: fields.model.default(""), color: fields.color.default(""),
  active: fields.active.default(true),
}).strict();
export const vehicleUpdateSchema = z.object(fields).partial().strict()
  .refine(input => Object.keys(input).length > 0, "Provide at least one vehicle field.");
export type VehicleInput = z.infer<typeof vehicleCreateSchema>;
export type VehicleUpdate = z.infer<typeof vehicleUpdateSchema>;

export function serializeVehicle(id: string, data: Record<string, unknown>) {
  const text = (value: unknown) => typeof value === "string" ? value.trim() : "";
  return {
    vehicleId: id, label: text(data.label) || id,
    plateNumber: text(data.plateNumber) || text(data.plate),
    make: text(data.make), model: text(data.model), color: text(data.color),
    active: data.active !== false,
    ...(text(data.linkedDriverUid) ? { linkedDriverUid: text(data.linkedDriverUid) } : {}),
  };
}

export class VehicleRegistry {
  constructor(private readonly db: Firestore, private readonly hasStock = hasAssignedInventory) {}
  async list() {
    const snapshot = await this.db.collection("vehicles").get();
    return snapshot.docs.map(doc => serializeVehicle(doc.id, doc.data()))
      .sort((a, b) => a.label.localeCompare(b.label) || a.vehicleId.localeCompare(b.vehicleId));
  }
  async requireActive(id: string) {
    if (!/^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$/.test(id) || id.toLowerCase() === "warehouse") {
      throw new ApiRequestError(400, "Select an active vehicle.");
    }
    const doc = await this.db.collection("vehicles").doc(id).get();
    if (!doc.exists) throw new ApiRequestError(400, "Vehicle was not found. Select an active vehicle.");
    const vehicle = serializeVehicle(doc.id, doc.data()!);
    if (!vehicle.active) throw new ApiRequestError(409, "Vehicle is inactive. Select an active vehicle.");
    return vehicle;
  }
  async create(input: VehicleInput, actorUid: string) {
    const ref = this.db.collection("vehicles").doc(input.vehicleId);
    await this.db.runTransaction(async transaction => {
      const doc = await transaction.get(ref);
      if (doc.exists) throw new ApiRequestError(409, "This vehicle ID already exists.");
      transaction.create(ref, { ...input, createdBy: actorUid,
        createdAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    });
    return serializeVehicle(input.vehicleId, input);
  }
  async update(id: string, input: VehicleUpdate, actorUid: string) {
    if (!/^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$/.test(id)) throw new ApiRequestError(400, "Vehicle ID is invalid.");
    if (input.active === false && await this.hasStock(id)) {
      throw new ApiRequestError(409, "Move this vehicle's inventory to the warehouse or another vehicle before deactivating it.");
    }
    const ref = this.db.collection("vehicles").doc(id);
    return this.db.runTransaction(async transaction => {
      const doc = await transaction.get(ref);
      if (!doc.exists) throw new ApiRequestError(404, "Vehicle was not found.");
      const data = doc.data()!;
      if (input.active === false && data.linkedDriverUid) {
        throw new ApiRequestError(409, "The driver must clock out and release this vehicle before it can be deactivated.");
      }
      transaction.update(ref, { ...input, updatedBy: actorUid, updatedAt: FieldValue.serverTimestamp() });
      return serializeVehicle(id, { ...data, ...input });
    });
  }
}
export function getVehicleRegistry() { return new VehicleRegistry(getBayblazeFirestore()); }

async function hasAssignedInventory(id: string) {
  return (await readInventoryVariants()).some(variant => variant.metadata?.assignedVehicleId === id);
}
