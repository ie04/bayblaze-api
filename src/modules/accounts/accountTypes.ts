export const accountRoles = ["admin", "driver", "inventory"] as const;
export const accountBadges = ["customer", "employee"] as const;

export type AccountRole = (typeof accountRoles)[number];
export type AccountBadge = (typeof accountBadges)[number];

export type AccountSettings = {
  ageVerificationDisabled: boolean;
};

export type AccountRecord = {
  uid: string;
  email: string;
  disabled: boolean;
  displayName?: string;
  badges: AccountBadge[];
  roles: AccountRole[];
  settings: AccountSettings;
  createdAt?: unknown;
  updatedAt?: unknown;
  lastLoginAt?: unknown;
};

export type AccountSessionPayload = {
  email: string;
  exp: number;
  badges: AccountBadge[];
  roles: AccountRole[];
  settings: AccountSettings;
  uid: string;
};
