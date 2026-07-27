import type { NfcFulfillmentMethod, NfcMoneyBreakdown, NfcProductType } from "./nfcTypes";

export const nfcBasePricesCents: Record<NfcProductType, number> = {
  custom: 4_000,
  instagram: 2_000,
  plain: 2_000,
  snapchat: 2_000,
  x: 2_000,
};

export const nfcGenericCustomColorSurchargeCents = 500;
export const nfcAffiliateCommissionCents = 1_000;

export function calculateNfcMoney(input: {
  fulfillmentMethod: NfcFulfillmentMethod;
  localDeliveryFeeCents: number;
  productType: NfcProductType;
  taxRateBps: number;
  uspsStandardFeeCents: number;
  usesCustomColors: boolean;
}): NfcMoneyBreakdown {
  const basePriceCents = nfcBasePricesCents[input.productType];
  const customColorSurchargeCents =
    input.productType === "custom" || !input.usesCustomColors ? 0 : nfcGenericCustomColorSurchargeCents;
  const deliveryFeeCents =
    input.fulfillmentMethod === "local_delivery" ? input.localDeliveryFeeCents : input.uspsStandardFeeCents;
  const subtotalCents = basePriceCents + customColorSurchargeCents + deliveryFeeCents;
  const estimatedTaxCents = Math.round((subtotalCents * input.taxRateBps) / 10_000);

  return {
    basePriceCents,
    customColorSurchargeCents,
    deliveryFeeCents,
    estimatedTaxCents,
    subtotalCents,
    totalCents: subtotalCents + estimatedTaxCents,
  };
}
