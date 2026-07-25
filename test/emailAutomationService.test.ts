import assert from "node:assert/strict";
import test from "node:test";

import { buildEmailAutomationEventVariablesForTest } from "../src/modules/email/emailAutomationService";

test("order placed email prefers BayBlaze discounted dollar metadata over Medusa cents total", () => {
  const variables = buildEmailAutomationEventVariablesForTest("order_placed", {
    custom_display_id: "BB-2001",
    email: "customer@example.com",
    id: "order_1",
    metadata: {
      checkout_promo_status: "applied",
      checkout_promo_total_after_discount: 21.58,
    },
    shipping_address: {
      first_name: "BayBlaze",
      last_name: "Customer",
    },
    total: 29,
  });

  assert.equal(variables.orderTotal, "$21.58");
});

test("order placed email falls back to Medusa cents total when checkout metadata is absent", () => {
  const variables = buildEmailAutomationEventVariablesForTest("order_placed", {
    custom_display_id: "BB-2002",
    email: "customer@example.com",
    id: "order_2",
    metadata: {},
    shipping_address: {
      first_name: "BayBlaze",
      last_name: "Customer",
    },
    total: 2158,
  });

  assert.equal(variables.orderTotal, "$21.58");
});
