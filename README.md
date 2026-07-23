# BayBlaze API

BayBlaze API is the shared backend for the BayBlaze commerce, operations, and
delivery applications. It centralizes account sessions, storefront settings,
inventory bridging, order workflows, driver workflows, referral rewards, email
automation, and delivery intelligence behind trusted server boundaries.

The repository also contains the current embedded Medusa backend used by
BayBlaze commerce. Browser applications call BayBlaze API routes instead of
holding privileged Medusa, Firebase, email, routing, or service credentials.

## Highlights

- Express and TypeScript API service.
- Embedded Medusa commerce runtime for products, variants, orders, promotions,
  inventory, and BayBlaze-specific admin endpoints.
- Firebase Admin integration for account, driver, referral, and operational
  records.
- API-owned storefront settings, activity analytics, promo-code validation, and
  customer account flows.
- Driver workflow routes for onboarding, clock state, delivery queues, delivery
  attempt logging, uploads, and notification registration.
- Inventory bridge for product, variant, stock, image, unit-cost, and vehicle
  assignment workflows.

## Local Development

```bash
npm install
npm run dev
npm run build
```

Medusa-specific commands are exposed through the root `package.json` scripts.
Runtime credentials and service tokens are intentionally not included in this
repository.

## Repository Notes

This project is source-available for implementation reference. Production use
requires your own configured Firebase, Medusa, email, maps/routing, payment, and
deployment secrets.

## Referral Partner Runtime

Referral partners use the universal BayBlaze account identity and Firestore
records owned by this API. Self-service routes under `/v1/partners/me` always
derive the partner UID from the authenticated account session. Admin approval,
status, and external payout-recording routes require an employee admin account;
Medusa order events require a server-to-server token.

Production partner configuration:

```env
PARTNER_ATTRIBUTION_WINDOW_DAYS=30
PARTNER_COMMISSION_ELIGIBILITY_DAYS=7
PARTNER_REFERRAL_CODE_PREFIX=LOCAL
PARTNER_ATTRIBUTION_TOKEN_SECRET=<at-least-32-random-characters>
PARTNER_CUSTOMER_HASH_SECRET=<different-at-least-32-random-characters>
```

The migration is dry-run by default and refuses ambiguous owners with more than
one legacy referral promo:

```bash
npm run migrate:referral-partners
npm run migrate:referral-partners -- --apply
```

It creates `referral_partners/{accountUid}`, the unique
`referral_partner_codes/{CODE}` index, and privacy-safe historical referral
records. The deployment workflow applies it after the Medusa database migration
and before recreating the runtime.

No payout provider is configured. `/v1/admin/partners/:uid/payouts/record` only
records an already completed external payout with an idempotency key; it never
moves money or exposes payment credentials.
