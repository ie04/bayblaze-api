import { z } from "zod";

import { nfcFulfillmentMethods, nfcProductTypes } from "./nfcTypes";

export const nfcAddressSchema = z.object({
  city: z.string().trim().min(1).max(120),
  country: z.string().trim().min(2).max(2).default("US"),
  line1: z.string().trim().min(1).max(180),
  line2: z.string().trim().max(180).optional(),
  postalCode: z.string().trim().min(3).max(20),
  state: z.string().trim().min(2).max(40),
});

export const nfcCustomerSchema = z.object({
  email: z.string().trim().email().max(320),
  fullName: z.string().trim().min(2).max(160),
  phone: z.string().trim().min(7).max(40),
});

export const nfcDesignSchema = z.object({
  additionalComments: z.string().trim().max(1_500).optional(),
  colorDescription: z.string().trim().max(500).optional(),
  customColors: z.boolean().default(false),
  customDesignDescription: z.string().trim().max(2_000).optional(),
  programmedDestination: z.string().trim().min(1).max(1_000),
  productType: z.enum(nfcProductTypes),
  uploadedAssetId: z.string().trim().max(160).optional(),
}).superRefine((value, context) => {
  if (value.productType === "custom" && !value.customDesignDescription) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: "Describe the custom design.",
      path: ["customDesignDescription"],
    });
  }
  if (value.productType !== "custom" && value.customColors && !value.colorDescription) {
    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: "Describe the requested custom colors.",
      path: ["colorDescription"],
    });
  }
});

export const nfcFulfillmentSchema = z.object({
  address: nfcAddressSchema,
  method: z.enum(nfcFulfillmentMethods),
});

export const nfcQuoteSchema = z.object({
  attributionToken: z.string().max(2_048).optional(),
  customer: nfcCustomerSchema.partial().optional(),
  design: nfcDesignSchema,
  fulfillment: nfcFulfillmentSchema,
});

export const nfcOrderCreateSchema = nfcQuoteSchema.extend({
  idempotencyKey: z.string().trim().min(8).max(120),
});

export const nfcAttributionSchema = z.object({
  code: z.string().trim().min(1).max(80),
  existingToken: z.string().max(2_048).optional(),
  sourcePath: z.string().max(200).optional(),
});
