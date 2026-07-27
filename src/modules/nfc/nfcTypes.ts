export const nfcProductTypes = ["plain", "instagram", "snapchat", "x", "custom"] as const;
export type NfcProductType = (typeof nfcProductTypes)[number];

export const nfcFulfillmentMethods = ["local_delivery", "usps_standard"] as const;
export type NfcFulfillmentMethod = (typeof nfcFulfillmentMethods)[number];

export const nfcOrderStatuses = [
  "draft",
  "payment_pending",
  "paid",
  "fulfillment_pending",
  "fulfilled",
  "cancelled",
  "refunded",
] as const;
export type NfcOrderStatus = (typeof nfcOrderStatuses)[number];

export type NfcDesignInput = {
  additionalComments?: string;
  colorDescription?: string;
  customColors: boolean;
  customDesignDescription?: string;
  programmedDestination: string;
  productType: NfcProductType;
  uploadedAssetId?: string;
};

export type NfcAddressInput = {
  city: string;
  country: string;
  line1: string;
  line2?: string;
  postalCode: string;
  state: string;
};

export type NfcCustomerInput = {
  email: string;
  fullName: string;
  phone: string;
};

export type NfcFulfillmentInput = {
  address: NfcAddressInput;
  method: NfcFulfillmentMethod;
};

export type NfcMoneyBreakdown = {
  basePriceCents: number;
  customColorSurchargeCents: number;
  deliveryFeeCents: number;
  estimatedTaxCents: number;
  subtotalCents: number;
  totalCents: number;
};
