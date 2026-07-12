import { FieldValue, Timestamp } from "firebase-admin/firestore";

import { getBayblazeFirestore } from "../../clients/firebaseAdminClient";
import { ApiRequestError } from "../drivers/driverWorkflowService";

const storefrontSettingsCollection = "storefront_settings";
const storefrontSettingsDoc = "global";

export type StorefrontSettingsUpdateInput = {
  priceAdjustmentCents?: number;
};

export async function getStorefrontSettings() {
  const snapshot = await getBayblazeFirestore()
    .collection(storefrontSettingsCollection)
    .doc(storefrontSettingsDoc)
    .get();

  return serializeStorefrontSettings(snapshot.data() ?? {});
}

export async function updateStorefrontSettings(input: StorefrontSettingsUpdateInput) {
  const priceAdjustmentCents = normalizePriceAdjustmentCents(input.priceAdjustmentCents);

  await getBayblazeFirestore()
    .collection(storefrontSettingsCollection)
    .doc(storefrontSettingsDoc)
    .set(
      {
        priceAdjustmentCents,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

  return serializeStorefrontSettings({
    priceAdjustmentCents,
    updatedAt: new Date().toISOString(),
  });
}

function serializeStorefrontSettings(data: Record<string, unknown>) {
  return {
    priceAdjustmentCents: readNonnegativeInteger(data.priceAdjustmentCents),
    updatedAt: serializeTimestamp(data.updatedAt),
  };
}

function normalizePriceAdjustmentCents(value: unknown) {
  const cents = readNonnegativeInteger(value);

  if (cents > 1_000_000_00) {
    throw new ApiRequestError(400, "Price adjustment must be no more than $1,000,000.");
  }

  return cents;
}

function readNonnegativeInteger(value: unknown) {
  const number = typeof value === "number" || typeof value === "string"
    ? Number(value)
    : Number.NaN;

  return Number.isInteger(number) && number >= 0 ? number : 0;
}

function serializeTimestamp(value: unknown) {
  if (value instanceof Timestamp) {
    return value.toDate().toISOString();
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  if (typeof value === "string") {
    return value;
  }

  return "";
}
