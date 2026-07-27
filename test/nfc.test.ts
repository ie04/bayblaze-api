import assert from "node:assert/strict";
import test from "node:test";

import { calculateNfcMoney, nfcAffiliateCommissionCents } from "../src/modules/nfc/nfcPricing";
import { nfcDesignSchema } from "../src/modules/nfc/nfcValidation";

test("NFC base prices are server-authoritative", () => {
  for (const productType of ["plain", "instagram", "snapchat", "x"] as const) {
    assert.equal(calculateNfcMoney({
      fulfillmentMethod: "usps_standard",
      localDeliveryFeeCents: 0,
      productType,
      taxRateBps: 0,
      uspsStandardFeeCents: 599,
      usesCustomColors: false,
    }).basePriceCents, 2_000);
  }

  assert.equal(calculateNfcMoney({
    fulfillmentMethod: "usps_standard",
    localDeliveryFeeCents: 0,
    productType: "custom",
    taxRateBps: 0,
    uspsStandardFeeCents: 599,
    usesCustomColors: true,
  }).basePriceCents, 4_000);
});

test("generic custom colors add five dollars before tax", () => {
  const quote = calculateNfcMoney({
    fulfillmentMethod: "usps_standard",
    localDeliveryFeeCents: 0,
    productType: "instagram",
    taxRateBps: 0,
    uspsStandardFeeCents: 599,
    usesCustomColors: true,
  });

  assert.equal(quote.customColorSurchargeCents, 500);
  assert.equal(quote.subtotalCents, 3_099);
});

test("custom design receives no extra color surcharge", () => {
  const quote = calculateNfcMoney({
    fulfillmentMethod: "usps_standard",
    localDeliveryFeeCents: 0,
    productType: "custom",
    taxRateBps: 0,
    uspsStandardFeeCents: 599,
    usesCustomColors: true,
  });

  assert.equal(quote.customColorSurchargeCents, 0);
  assert.equal(quote.subtotalCents, 4_599);
});

test("tax and delivery are calculated in integer cents", () => {
  const quote = calculateNfcMoney({
    fulfillmentMethod: "local_delivery",
    localDeliveryFeeCents: 300,
    productType: "plain",
    taxRateBps: 887,
    uspsStandardFeeCents: 599,
    usesCustomColors: true,
  });

  assert.deepEqual(quote, {
    basePriceCents: 2_000,
    customColorSurchargeCents: 500,
    deliveryFeeCents: 300,
    estimatedTaxCents: 248,
    subtotalCents: 2_800,
    totalCents: 3_048,
  });
});

test("custom design description is required only for custom products", () => {
  assert.equal(nfcDesignSchema.safeParse({
    customColors: false,
    programmedDestination: "https://example.com",
    productType: "custom",
  }).success, false);

  assert.equal(nfcDesignSchema.safeParse({
    customColors: false,
    customDesignDescription: "Use the uploaded logo and black background.",
    programmedDestination: "https://example.com",
    productType: "custom",
  }).success, true);
});

test("custom color description is required for generic custom-color orders", () => {
  assert.equal(nfcDesignSchema.safeParse({
    customColors: true,
    programmedDestination: "@bayblaze",
    productType: "instagram",
  }).success, false);
});

test("NFC affiliate commission is fixed at ten dollars", () => {
  assert.equal(nfcAffiliateCommissionCents, 1_000);
});
