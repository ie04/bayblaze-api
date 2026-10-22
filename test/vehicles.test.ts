import assert from "node:assert/strict";
import test from "node:test";
import { FieldValue, type Firestore } from "firebase-admin/firestore";
import type { Request } from "express";
import { VehicleRegistry, serializeVehicle, vehicleCreateSchema, vehicleUpdateSchema } from "../src/modules/vehicles/vehicleService";
import { validateInventoryVehicleMutation } from "../src/modules/vehicles/inventoryVehicleValidation";
import { linkVehicleToDriver, clockInDriver, clockOutDriver } from "../src/modules/drivers/driverWorkflowService";

function fixture(initial: Record<string, Record<string, unknown>>) {
  const rows = new Map(Object.entries(initial));
  const snapshot = (path: string) => ({ id: path.split("/").at(-1)!, exists: rows.has(path), data: () => rows.get(path) });
  const db = {
    collection: (name: string) => ({
      doc: (id: string) => ({ path: name + "/" + id, get: async () => snapshot(name + "/" + id) }),
      get: async () => ({ docs: [...rows.keys()].filter(path => path.startsWith(name + "/")).map(snapshot) }),
    }),
    runTransaction: async (operation: (transaction: unknown) => Promise<unknown>) => {
      const writes: (() => void)[] = [];
      const transaction = {
        get: async (ref: { path: string }) => {
          assert.equal(writes.length, 0, "transaction reads must precede writes");
          return snapshot(ref.path);
        },
        create: (ref: { path: string }, data: Record<string, unknown>) => writes.push(() => rows.set(ref.path, data)),
        update: (ref: { path: string }, data: Record<string, unknown>) => writes.push(() => {
          const next = { ...rows.get(ref.path) };
          for (const [key, value] of Object.entries(data)) {
            if (value instanceof FieldValue && value.isEqual(FieldValue.delete())) delete next[key];
            else next[key] = value;
          }
          rows.set(ref.path, next);
        }),
      };
      const result = await operation(transaction);
      writes.forEach(write => write());
      return result;
    },
  } as unknown as Firestore;
  return { rows, db, registry: new VehicleRegistry(db, async () => false) };
}

test("vehicle IDs come from canonical document identity and legacy plate aliases normalize", () => {
  assert.deepEqual(serializeVehicle("V01", { vehicleId: "incorrect", plate: "ABC", linkedDriverUid: "driver", active: true }),
    { vehicleId: "V01", label: "V01", plateNumber: "ABC", make: "", model: "", color: "", active: true, linkedDriverUid: "driver" });
  assert.throws(() => vehicleCreateSchema.parse({ vehicleId: "warehouse", label: "Fake warehouse" }));
  assert.throws(() => vehicleUpdateSchema.parse({ linkedDriverUid: "hijack" }));
  assert.throws(() => vehicleUpdateSchema.parse({ vehicleId: "V02" }));
});

test("registry preserves V01, rejects duplicate IDs, and keeps live driver linkage on edits", async () => {
  const { registry, rows } = fixture({ "vehicles/V01": { label: "Van", active: true, linkedDriverUid: "driver" } });
  const created = vehicleCreateSchema.parse({ vehicleId: "V02", label: "Second van" });
  await registry.create(created, "admin");
  await assert.rejects(() => registry.create(created, "admin"), /already exists/);
  await registry.update("V01", { label: "Primary van" }, "admin");
  assert.equal(rows.get("vehicles/V01")!.linkedDriverUid, "driver");
  await assert.rejects(() => registry.update("V01", { active: false }, "admin"), /clock out/);
  await registry.update("V02", { active: false }, "admin");
  await assert.rejects(() => registry.requireActive("V02"), /inactive/);
  await assert.rejects(() => registry.requireActive("missing"), /not found/);
});

test("deactivation refuses vehicles carrying inventory", async () => {
  const { db, rows } = fixture({ "vehicles/V01": { label: "Van", active: true } });
  const registry = new VehicleRegistry(db, async () => true);
  await assert.rejects(() => registry.update("V01", { active: false }, "admin"), /inventory/);
  assert.equal(rows.get("vehicles/V01")!.active, true);
});

test("inventory accepts active occupied vehicles, rejects inactive/unknown vehicles and missing assignment", async () => {
  const { registry } = fixture({ "vehicles/V01": { label: "Van", active: true, linkedDriverUid: "driver" },
    "vehicles/V02": { active: false } });
  const validate = (body: unknown) => validateInventoryVehicleMutation({ body } as Request, registry);
  await validate({ type: "assign-vehicle", vehicleId: "V01" });
  await validate({ type: "assign-vehicle", vehicleId: "warehouse" });
  await validate({ type: "create-product-with-variant", draft: { variant: { inventoryState: "ON_VEHICLE", vehicleId: "V01" } } });
  await assert.rejects(() => validate({ type: "assign-vehicle", vehicleId: "V02" }), /inactive/);
  await assert.rejects(() => validate({ type: "assign-vehicle", vehicleId: "unknown" }), /not found/);
  await assert.rejects(() => validate({ type: "create-variant", draft: { inventoryState: "ON_VEHICLE" } }), /Select a vehicle/);
  await validate({ type: "update-variant-details", draft: { title: "New label" } });
});

test("driver linking prevents double occupancy and multiple simultaneous vehicle links", async () => {
  const { db, rows } = fixture({ "vehicles/V01": { vehicleId: "V01", label: "Van", active: true },
    "vehicles/V02": { active: true }, "driver_profiles/a": { onboardingComplete: true }, "driver_profiles/b": { onboardingComplete: true } });
  await linkVehicleToDriver("a", "V01", db);
  await assert.rejects(() => linkVehicleToDriver("b", "V01", db), /already linked/);
  await assert.rejects(() => linkVehicleToDriver("a", "V02", db), /Release your current/);
  assert.equal(rows.get("vehicles/V02")!.linkedDriverUid, undefined);
  await clockInDriver("a", db);
  assert.equal(rows.get("driver_profiles/a")!.clockedIn, true);
  await clockOutDriver("a", db);
  assert.equal(rows.get("vehicles/V01")!.linkedDriverUid, undefined);
  assert.equal(rows.get("driver_profiles/a")!.activeVehicleId, undefined);
  assert.equal(rows.get("driver_profiles/a")!.clockedIn, false);
  await assert.rejects(() => clockInDriver("a", db), /Select a vehicle/);
  await linkVehicleToDriver("b", "V01", db);
});

test("clock-in rejects an inactive vehicle or a vehicle owned by another driver", async () => {
  for (const vehicle of [{ active: false, linkedDriverUid: "a" }, { active: true, linkedDriverUid: "b" }]) {
    const { db, rows } = fixture({ "vehicles/V01": vehicle, "driver_profiles/a": { activeVehicleId: "V01", onboardingComplete: true } });
    await assert.rejects(() => clockInDriver("a", db), /Select an available vehicle/);
    assert.notEqual(rows.get("driver_profiles/a")!.clockedIn, true);
  }
});

test("admin vehicle endpoints reject unauthenticated reads and writes", async () => {
  const { default: express } = await import("express");
  const { once } = await import("node:events");
  const { createAdminRouter } = await import("../src/modules/admin/adminRouter");
  const app = express(); app.use(express.json()); app.use("/v1", createAdminRouter());
  const server = app.listen(0); await once(server, "listening");
  const address = server.address(); assert(address && typeof address === "object");
  try {
    for (const [method, path] of [["GET", "/vehicles"], ["POST", "/vehicles"], ["PATCH", "/vehicles/V01"]]) {
      const response = await fetch(`http://127.0.0.1:${address.port}/v1/admin${path}`, { method });
      assert.equal(response.status, 401);
    }
  } finally { server.close(); await once(server, "close"); }
});

test("vehicle administration requires employee and admin role together", async () => {
  const { requireAccountRole } = await import("../src/http/middleware/accountAuth");
  for (const account of [{ badges: ["customer"], roles: ["admin"] }, { badges: ["employee"], roles: ["driver"] }]) {
    let status = 0; let called = false;
    const response = { status(code: number) { status = code; return this; }, json() {} };
    requireAccountRole("admin")({ accountAuth: account } as never, response as never, () => { called = true; });
    assert.equal(status, 403); assert.equal(called, false);
  }
});

test("partial stock edits cannot clear a vehicle assignment or restore stock onto an inactive vehicle", async () => {
  const { registry } = fixture({ "vehicles/V01": { active: true }, "vehicles/V02": { active: false } });
  const read = async () => [{ id: "variant", metadata: { inventoryState: "ON_VEHICLE", assignedVehicleId: "V02" } }];
  const validate = (body: unknown) => validateInventoryVehicleMutation({ body } as Request, registry, read);
  await assert.rejects(() => validate({ type: "update-variant-details", variantId: "variant", draft: { vehicleId: "" } }), /Select a vehicle/);
  await assert.rejects(() => validate({ type: "set-state", variantId: "variant", state: "ON_VEHICLE" }), /inactive/);
  await validate({ type: "update-variant-details", variantId: "variant", draft: { vehicleId: "V01" } });
});
