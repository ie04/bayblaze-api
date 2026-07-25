export const partnerStatuses = ["pending", "active", "suspended", "rejected"] as const;
export type PartnerStatus = (typeof partnerStatuses)[number];

export const commissionStatuses = ["tracked", "pending", "eligible", "paid", "reversed"] as const;
export type CommissionStatus = (typeof commissionStatuses)[number];

export const payoutStatuses = ["processing", "paid", "failed", "canceled"] as const;
export type PayoutStatus = (typeof payoutStatuses)[number];

export const partnerOrderEventTypes = [
  "order_placed",
  "order_completed",
  "order_canceled",
  "payment_captured",
  "payment_failed",
  "payment_refunded",
  "chargeback",
] as const;
export type PartnerOrderEventType = (typeof partnerOrderEventTypes)[number];

export type PartnerRecord = {
  approvedAt: string;
  createdAt: string;
  displayName: string;
  email: string;
  referralCode: string;
  rejectedAt: string;
  status: PartnerStatus;
  suspendedAt: string;
  uid: string;
  updatedAt: string;
};

export type PartnerCommissionRecord = {
  attributedAt: string;
  attributionId: string;
  attributionSource: "promo_code_checkout" | "promo_query";
  clawbackCents: number;
  clawbackSettledCents: number;
  commissionCents: number;
  commissionRateBps: number;
  createdAt: string;
  currency: string;
  customerLabel: string;
  customerRef: string;
  eligibilityAt: string;
  eligibleAt: string;
  orderId: string;
  orderCompletedAt: string;
  orderStatus: string;
  originalCommissionCents: number;
  originalQualifyingSubtotalCents: number;
  paidCommissionCents: number;
  partnerUid: string;
  paymentCapturedAt: string;
  payoutId: string;
  qualifyingSubtotalCents: number;
  referralCode: string;
  refundedCents: number;
  status: CommissionStatus;
  updatedAt: string;
};

export type PartnerPayoutRecord = {
  amountCents: number;
  commissionIds: string[];
  createdAt: string;
  currency: string;
  id: string;
  idempotencyKey: string;
  methodLabel: string;
  paidAt: string;
  reference: string;
  status: PayoutStatus;
  updatedAt: string;
};

export type TrustedPartnerOrder = {
  currencyCode?: string;
  customerName?: string;
  customerUid?: string;
  email?: string;
  fulfillmentStatus?: string;
  id: string;
  metadata?: Record<string, unknown>;
  paymentStatus?: string;
  refundedCents?: number;
  status?: string;
};

export type PartnerOrderEvent = {
  eventAt?: string;
  eventId: string;
  eventType: PartnerOrderEventType;
  order: TrustedPartnerOrder;
};
