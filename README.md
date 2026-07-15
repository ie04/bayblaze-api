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
