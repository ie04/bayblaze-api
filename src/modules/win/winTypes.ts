export type WinRewardStatus =
  | "waiting_for_friend_order"
  | "qualified"
  | "claimed";

export type WinRewardRecord = {
  campaign: string;
  claimToken?: string;
  claimedAt?: unknown;
  claimedProductId?: string;
  claimedVariantId?: string;
  completedOrderId?: string;
  createdAt?: unknown;
  discountPercent: number;
  minimumSpendCents: number;
  nfcTagId?: string;
  qualifiedAt?: unknown;
  referralCode: string;
  referralUrl: string;
  source: string;
  status: WinRewardStatus;
  uid: string;
  updatedAt?: unknown;
};

export type FreebieProduct = {
  id: string;
  variantId: string;
  name: string;
  brand: string;
  image: string;
  price: string;
  categories: string[];
  description: string;
};
