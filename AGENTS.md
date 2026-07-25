# BayBlaze API Agent Rules

## Project role

`bayblaze-api` is the shared app-facing backend boundary and backend monorepo
for BayBlaze.

BayBlaze apps should call `bayblaze-api` instead of directly integrating with backend-only services.

Primary clients:

* `bayblaze-storefront`
* `bayblaze-driver`
* `bayblaze-inventory`
* `bayblaze-admin`
* future `bayblaze-isochronos-console` / operations display apps

Integrated backend services and dependencies:

* Embedded Medusa service under `medusa/`
* IsoChronos routing/tracking modules
* Firebase Admin SDK
* Google Maps APIs
* Twilio
* object/file storage
* future age verification/payment-support integrations when needed

The API exists to provide stable BayBlaze business workflows such as:

* delivery eligibility
* order tracking
* inventory/product management
* image uploads
* vehicle stock assignment
* driver workflow actions
* delivery attempts
* transactional messaging
* routing/ETA/coverage data
* operational diagnostics

## Source-of-record boundaries

Do not turn `bayblaze-api` into a second commerce database.

Medusa remains the source of truth for:

* products
* variants
* orders
* payment state
* fulfillment state
* inventory quantities
* order metadata
* product images once committed to a product
* product category metadata used by storefront/inventory sync

Referral partner promos are unified discount records in
`customer_discount_codes/{CODE}` with category `referral_partner`, an
`ownerUid` pointing at an existing BayBlaze account, a customer discount
percentage, a partner commission percentage, and an optional pre-tax product
minimum. Each completed use is recorded idempotently under
`order_usages/{orderId}` and aggregated on the promo. Commission is calculated
in cents from the completed order's product total after the referral discount;
the order's immutable promo metadata is verified against embedded Medusa before
the ledger is updated. Prior order ledger entries keep their original
commission percentage if the promo is edited later.
Partner referral dashboard records are fed by `/v1/partners/order-events`.
Medusa still forwards order/payment events, but storefront checkout also sends
an idempotent `order_placed` event for referral-partner promos, and driver
delivery completion/cancellation paths send `order_completed`/`order_canceled`
events directly after Medusa accepts the delivery attempt. For pay-on-delivery
orders, an `order_completed` partner event is treated as the paid completion
moment unless the order payment status is failed/canceled/refunded.
Partner referral activity should display the referred customer's name when the
trusted order event includes it. Keep internal customer hashes, emails, partner
UIDs, and referral codes out of the public partner activity response.

For customer-facing order totals in email, invoice, partner, and tracking
surfaces, prefer BayBlaze checkout metadata totals such as
`checkout_promo_total_after_discount` and
`first_order_offer_total_after_discount` as dollar amounts. Medusa native money
fields such as `total`, `subtotal`, and `discount_total` are cents/raw money
values and should only be fallback sources after the checkout metadata is
absent.

Medusa source now lives inside this repository at `medusa/`. The previous
standalone `bayblaze-medusa` repository is retired as an independent source of
truth after the June 2026 consolidation. Make Medusa route/model/deployment
changes in `bayblaze-api/medusa`, not in the old repository.

Firebase remains the source of truth for live driver state and driver workflow UI data, including:

* driver profiles
* vehicles
* driver delivery queues
* driver location snapshots
* driver-created delivery event logs

IsoChronos logic remains the source of truth for routing/tracking intelligence, including:

* geocoding
* drive-time calculations
* ETA
* coverage
* route scoring
* usage accounting
* route/geocode/cache state
* tracking aggregation

Preserve IsoChronos-derived routing/tracking code as clean internal modules, not scattered utility code.

## Target architecture

Apps should call:

```text
bayblaze-storefront
bayblaze-driver
bayblaze-inventory
bayblaze-isochronos-console
        ↓
   bayblaze-api
        ↓
Medusa / Firebase / Google Maps / Twilio / Storage
```

## June 2026 Medusa Repo And Runtime Consolidation

`bayblaze-medusa` has been copied into this repository at `medusa/`, making
`bayblaze-api` the repo of record for both the app-facing API and the Medusa
commerce backend.

Root commands:

```bash
npm run api:dev
npm run api:build
npm run medusa:install
npm run medusa:dev
npm run medusa:build
npm run build:all
```

The embedded Medusa service keeps its original package/workspace shape under
`medusa/`, including `medusa/apps/backend`, `medusa/apps/label-printer-agent`,
and the Medusa Dockerfile. Production runtime is now consolidated under the
`bayblaze-api` deployment: `/opt/bayblaze/bayblaze-api/docker-compose.prod.yml`
owns Caddy, `bayblaze-api`, embedded `medusa`, Postgres, and Redis in the
single `bayblaze-api` Compose project. Do not deploy or update Medusa from the
retired `/opt/bayblaze/medusa` checkout or the old standalone
`bayblaze-medusa` repo.

The consolidated production compose intentionally reuses the old Docker volume
names (`medusa_postgres_data`, `medusa_redis_data`, `medusa_caddy_data`, and
`medusa_caddy_config`) so the runtime can move into the `bayblaze-api` project
without losing database, Redis, or Caddy state. The deploy workflow stops the
legacy standalone Medusa compose project if `/opt/bayblaze/medusa` still
exists, builds both API and embedded Medusa images from
`/opt/bayblaze/bayblaze-api`, runs Medusa migrations, and recreates the
integrated runtime.

The unified `.env.production` contains `PORT=3040` for `bayblaze-api`.
`docker-compose.prod.yml` must override the embedded `medusa` service with
`PORT=9000`; otherwise Medusa starts on the API port and API-to-Medusa calls to
`http://medusa:9000` fail with `ECONNREFUSED`.

API-to-Medusa service auth should use one canonical secret:

```env
BAYBLAZE_MEDUSA_SERVICE_TOKEN=<shared API-to-Medusa secret>
```

Set the same value for `bayblaze-api` and the embedded `medusa` service in the
single `/opt/bayblaze/bayblaze-api/.env.production` file.
Legacy `BAYBLAZE_INVENTORY_SERVICE_TOKEN`, `BAYBLAZE_DRIVER_SERVICE_TOKEN`, and
`MEDUSA_ADMIN_API_TOKEN` remain compatibility fallbacks only. Do not introduce
new app-specific Medusa service token names.

The apps should speak BayBlaze business language:

* “Can this order be delivered?”
* “Where is the driver?”
* “Create this product.”
* “Upload this product image.”
* “Move this product to this vehicle.”
* “Mark this order out for delivery.”
* “Send this delivery coordination message.”

The apps should not need to know internal service details such as:

* Medusa workflow names
* Google Maps route-cache keys
* Firebase collection names
* Medusa internal order ID vs BayBlaze display reference matching
* Twilio credentials
* upload storage paths
* driver Firebase vs IsoChronos Firebase project split

## June 2026 Unified Driver/IsoChronos Backend Direction

The target backend shape is now a single Firestore-backed operational database
behind `bayblaze-api`.

* Driver browser code must call `bayblaze-api` for auth/account flows, driver
  sessions, profile and delivery-attempt photo uploads, driver profiles,
  vehicles, queues, clock state, delivery attempts, notification tokens, and
  live location writes. It should not import Firebase SDKs, Firestore collection
  names, Firebase Storage APIs, or write Firestore docs directly.
* Firebase Authentication may remain the underlying password provider, but API
  routes own sign-in/signup, issue BayBlaze driver session tokens, and then
  read/write Firestore through Firebase Admin.
* `bayblaze-isochronos` functions used by storefront and driver workflows now
  live as internal `src/modules/isochronos/*` modules in `bayblaze-api`. Do not
  add new app-facing dependencies on the standalone IsoChronos HTTP service.
* Use one Firebase project/database for driver workflow data and routing/cache
  data. The old `bayblaze-isochronos` primary Firestore plus separate
  `bayblaze-driver` secondary Firestore split is deprecated.

Current first merged API routes:

```text
GET    /v1/driver/me/profile
PUT    /v1/driver/me/profile
POST   /v1/driver/me/profile-photo
GET    /v1/driver/me/vehicles/available
POST   /v1/driver/me/vehicles/link
POST   /v1/driver/me/clock-in
POST   /v1/driver/me/clock-out
GET    /v1/driver/me/queue
POST   /v1/driver/me/queue/sync
POST   /v1/driver/me/location
POST   /v1/driver/me/delivery-attempts
POST   /v1/driver/me/delivery-attempt-photos
POST   /v1/driver/me/deliveries/:orderId/reprint-labels
POST   /v1/driver/me/notification-tokens
DELETE /v1/driver/me/notification-tokens/:tokenId
```

Driver auth/account routes are:

```text
POST   /v1/driver/auth/access
POST   /v1/driver/auth/accounts
POST   /v1/driver/auth/login
```

The `/v1/driver/me/*` routes require a BayBlaze driver session bearer token, not
`BAYBLAZE_API_SERVICE_TOKEN`. Firebase ID tokens remain accepted as a rollout
fallback. Existing trusted bridge routes under `/v1/drivers/*` still use the
service token for server-to-server callers.

## June 2026 Universal Account And Admin Dashboard Direction

`bayblaze-api` now owns the universal BayBlaze account boundary for all app
roles. Firebase Auth remains the password provider, but account authorization is
represented by API-owned Firestore records in `accounts/{uid}`:

```text
badges: customer | employee
roles: admin | driver | inventory
settings.ageVerificationDisabled: boolean
disabled: boolean
```

Every account should carry exactly the user-facing access badge intended for
that identity: `customer` for storefront shoppers or `employee` for BayBlaze
staff. Employee accounts can then receive any combination of `driver`,
`inventory`, and `admin` roles. Role-protected API middleware requires both the
`employee` badge and the requested role.

Universal account routes:

```text
POST /v1/auth/login
POST /v1/auth/google/start
POST /v1/auth/google/callback
GET  /v1/auth/me
```

Admin dashboard routes:

```text
GET    /v1/admin/accounts
PATCH  /v1/admin/accounts/:uid
GET    /v1/admin/drivers/map
GET    /v1/admin/drivers/routes
POST   /v1/admin/isochrones
GET    /v1/admin/coverage-areas
POST   /v1/admin/coverage-areas
PATCH  /v1/admin/coverage-areas/:coverageAreaId
DELETE /v1/admin/coverage-areas/:coverageAreaId
POST   /v1/admin/coverage-areas/:coverageAreaId/regenerate
POST   /v1/admin/coverage-areas/regenerate-due
GET    /v1/admin/promo-codes
POST   /v1/admin/promo-codes
PATCH  /v1/admin/promo-codes/:code
DELETE /v1/admin/promo-codes/:code
GET    /v1/admin/email-automations
PATCH  /v1/admin/email-automations/:eventType
POST   /v1/admin/email-automations/:eventType/test
GET    /v1/admin/orders
GET    /v1/admin/orders/:orderId
DELETE /v1/admin/orders/:orderId
```

`GET /v1/admin/accounts` and `PATCH /v1/admin/accounts/:uid` include both
`winReferrals` and commercial `referralPromos` summaries on returned account
objects. These expose friend-code/freebie state plus partner discount,
commission, referred-customer, purchase, and spend totals without requiring the
admin browser to read Firestore directly.

Storefront promo codes share the API-owned discount code module in
`src/modules/discountCodes/discountCodeService.ts` and Firestore collection
`customer_discount_codes/{CODE}`. Admin-created promo records use
`category: "admin_promo"`; individualized partner records use
`category: "referral_partner"`; BayBlaze Win friend-code records use
`category: "win_referral"`. `GET /v1/admin/promo-codes` returns all categories
as the same serialized discount-code object so operators can see centralized
promo usage. Admin routes may manage `admin_promo` and `referral_partner`
records, while `win_referral` remains read-only and API-managed.
The public and customer discount preview endpoints accept all three categories.
Admin promo records may set `minimumSpendCents`; `0` disables the minimum. The
discount preview endpoints enforce that basket minimum against the before-tax
product subtotal and return `eligible=false` with
`ineligibilityReason="minimum_spend"`, `minimumSpendCents`, `subtotalCents`, and
`amountNeededCents` when the basket is too small.
Admin promo records may set `singleUsePerAccount`; when true, authenticated
customer promo preview must reject accounts with a prior recorded use for that
code. Successful storefront checkout with an applied promo must call
`POST /v1/customer/discount-codes/use` with the completed order ID so the API
records account usage under the centralized discount-code document.

Automated email settings live in Firestore `email_automations/{eventType}` and
recent outcomes are recorded in `email_event_logs`. Admins configure them
through `/v1/admin/email-automations`. Service-to-service triggers call
`POST /v1/email/events` with either `BAYBLAZE_API_SERVICE_TOKEN` or
`BAYBLAZE_MEDUSA_SERVICE_TOKEN`. The embedded Medusa `order.placed` subscriber
posts an `order_placed` event to `bayblaze-api`; the API renders the configured
template and sends through Resend using `AUTOMATED_EMAIL_FROM`, falling back to
`DRIVER_EMAIL_FROM` when no automation-level from-address is set.
Built-in BayBlaze email HTML should follow the storefront Jost theme: Jost-first
font stack, off-white background, white rounded card, black text, green accents,
and email-safe inline styles. The API upgrades the legacy built-in
`order_placed` Arial template to the Jost default while preserving custom admin
templates.

Customer storefront account routes:

```text
POST /v1/customer/auth/accounts
POST /v1/customer/auth/login
```

The storefront uses these routes for BayBlaze identity and keeps the Medusa
customer token only for commerce reads such as saved customer details and order
history.
Storefront sign-in is self-service customer access: when a valid existing
BayBlaze account signs into the storefront by email/password or Google OAuth,
the API should ensure the `customer` badge automatically instead of requiring an
admin to grant storefront access.
Storefront customer account creation should also create the Medusa commerce
session through the API-owned embedded Medusa `/admin/bayblaze/customer-sessions`
bridge and return `commerce.customerToken`; the storefront should not call
native Medusa email/password registration directly.

BayBlaze Win discount/referral codes are owned by `bayblaze-api`. When a
customer starts the win flow, the API creates a customer-scoped reward document,
a win-specific referral index, and a shared `customer_discount_codes/{code}`
record built through the common discount-code service with
`category=win_referral`, `ownerUid`, `usageLimit=1`, and `usedCount=0`. Win
friend-code generation must check both the win referral index and centralized
discount-code collection for collisions. Completion through
`POST /v1/win/referrals/complete` must run in a Firestore transaction, mark the
central code used, tie it to the qualifying order, and reject any later order
for the same code. Do not rely on a storefront-only or Medusa-only discount code
as the source of truth for one-time win reward qualification.
BayBlaze Win freebies only unlock when the friend code is used by a customer on
that customer's first order. Storefront checkout must send
`isCustomerFirstOrder` to `POST /v1/customer/discount-codes/use`; if the friend
has prior orders, the API should audit the ignored code use without marking the
win reward qualified or issuing a freebie claim token.
Customer checkout promo codes can only be applied by signed-in customer
accounts. Storefront checkout should use authenticated
`POST /v1/customer/discount-codes/preview`, which validates code existence,
status, one-time usage, minimum spend, account-bound promo ownership, and
single-use-per-account history. Successful checkout with an applied promo should
call authenticated `POST /v1/customer/discount-codes/use`. Promo codes must not
stack in storefront UX; applying a second coupon replaces the first. The public
`POST /v1/discount-codes/preview` route may exist for compatibility, but
storefront checkout must not treat it as applying a promo.

Storefront-wide customer-facing settings live in Firestore
`storefront_settings/global`. `GET /v1/storefront/settings` exposes safe public
settings such as `priceAdjustmentCents` and `ageVerificationDisabled`; admin
operators manage the same values through
`GET/PATCH /v1/admin/storefront-settings`. The storefront applies
`priceAdjustmentCents` before product prices reach shop/product/cart/checkout
flows, so changing it adjusts item prices sitewide without a storefront redeploy.
When `ageVerificationDisabled` is true, storefront checkout bypasses AgeChecker
globally for testing and records `age_verification_source:
"storefront_testing"` in order metadata.

Storefront abandonment/activity tracking is API-owned. The storefront browser
posts safe lifecycle events to public
`POST /v1/storefront/activity/events`; the API stores rolling session summaries
in Firestore `storefront_sessions/{sessionId}` with recent event breadcrumbs.
Admin operators read those summaries through authenticated
`GET /v1/admin/storefront-activity/sessions`. Admin storefront visitor trends
come from authenticated `GET /v1/admin/storefront-activity/analytics`, which
returns daily buckets for unique visitors, sessions, and page views from the
stored activity events. Do not put Firebase writes or service tokens in the
storefront/admin browser bundles for this workflow.

Google OAuth must be centralized through `bayblaze-api`: the API signs OAuth
state, exchanges Google authorization codes, verifies the Google ID token,
creates or finds the Firebase Auth user, ensures an account record, and returns
a universal BayBlaze account session. Apps then enforce their required
badge/role. Storefront OAuth passes `commerce: "storefront"` to the universal
start route; when the resulting account has the `customer` badge, the API also
calls embedded Medusa's service-only `/admin/bayblaze/customer-sessions` route
to create or retrieve the matching Medusa customer session. Do not use Medusa
OAuth as the primary identity authority from the storefront.

Driver signup/login still preserves the manual `driver_allowlist` gate, but it
now ensures the Firebase user has an `accounts/{uid}` record with the
`employee` badge and `driver` role, then returns a universal account session
token. Driver workflow routes require a bearer token from an employee account
with the `driver` role.

Admin routes for `bayblaze-admin`:

```text
GET   /v1/admin/accounts
PATCH /v1/admin/accounts/:uid
GET   /v1/admin/drivers/map
GET   /v1/admin/drivers/routes
POST  /v1/admin/isochrones
GET   /v1/admin/coverage-areas
POST  /v1/admin/coverage-areas
PATCH /v1/admin/coverage-areas/:coverageAreaId
DELETE /v1/admin/coverage-areas/:coverageAreaId
POST  /v1/admin/coverage-areas/:coverageAreaId/regenerate
POST  /v1/admin/coverage-areas/regenerate-due
GET   /v1/admin/orders
GET   /v1/admin/orders/:orderId
DELETE /v1/admin/orders/:orderId
```

`/v1/admin/*` routes require a BayBlaze account session bearer token from an
employee account with the `admin` role. The admin dashboard lives at
`admin.bayblaze.net` and must call only `bayblaze-api`; it must not import
Firebase, Firestore, Medusa, Google Maps, or service-token clients in browser
code.

Admin order deletion uses `DELETE /v1/admin/orders/:orderId` with
`releaseStock: boolean`. The API forwards this to embedded Medusa's BayBlaze
admin order route, which soft-deletes by setting order metadata such as
`bayblaze_deleted`, `bayblaze_deleted_at`, and `bayblaze_order_status:
"deleted"` so deleted orders can remain visible to admin clients. When
`releaseStock` is true, Medusa increments the ordered variants' BayBlaze
inventory quantities and local-delivery stock levels before marking the order
deleted.

Coverage areas are stored in `coverage_areas/{id}`. A coverage area is a
polygonal bidirectional drive-time isochrone centered on a warehouse point:
every accepted address must be inside the polygon when one exists, at most X
minutes from the warehouse, and at most X minutes back to the warehouse. Zones
may intersect; checkout resolves accepted destinations to the matching active
zone with the shortest total bidirectional drive time and rejects destinations
outside all active zones with `OUTSIDE_COVERAGE_AREA`. Coverage records include
label, optional description, warehouse identity/address/location, max one-way
drive minutes, polygon granularity, active state, generated
polygon/radius, and optional regeneration schedule metadata.

`POST /v1/admin/isochrones` remains as a compatibility preview route, while
coverage CRUD and regeneration use `/v1/admin/coverage-areas`. The
`/v1/admin/coverage-areas/regenerate-due` route processes zones whose schedule
metadata is due and should be called by an external scheduler if automatic
production regeneration is needed.

Additional account/admin environment variables:

```env
ACCOUNT_SESSION_SECRET=<server-only signing secret>
ACCOUNT_SESSION_TTL_SECONDS=1209600
MEDUSA_ADMIN_ORDERS_PATH=/admin/bayblaze/orders
MEDUSA_CUSTOMER_SESSION_PATH=/admin/bayblaze/customer-sessions
GOOGLE_OAUTH_CLIENT_ID=<google oauth client id>
GOOGLE_OAUTH_CLIENT_SECRET=<google oauth client secret>
GOOGLE_OAUTH_REDIRECT_URL=https://bayblaze.net/api/auth/oauth/google/callback,https://admin.bayblaze.net/auth/google/callback,https://driver.bayblaze.net/auth/google/callback,https://stock.bayblaze.net/auth/google/callback,https://inventory.bayblaze.net/auth/google/callback,https://win.bayblaze.net/auth/google/callback,https://bayblaze-tap-win.lovable.app/auth/google/callback
```

Production `/opt/bayblaze/bayblaze-api/.env.production` should keep the same
comma-separated OAuth redirect allowlist. It was updated on June 14, 2026 to
include the driver and inventory callback URLs alongside the storefront
callback, on July 4, 2026 to include `win.bayblaze.net`, the Lovable preview
callback, and local Vite callback URLs for `localhost`/`127.0.0.1` on ports
`5173`, `5174`, and `5175`, and on July 5, 2026 to include the admin callback
URL `https://admin.bayblaze.net/auth/google/callback`. It was updated on
July 11, 2026 to include the active inventory app callback URL
`https://stock.bayblaze.net/auth/google/callback`.
The same URLs must also be present in the Google Cloud OAuth web client's
Authorized redirect URIs. If `GOOGLE_OAUTH_REDIRECT_URL` allows a callback but
Google Cloud does not, the app reaches Google and fails with
`Error 400: redirect_uri_mismatch`.

## June 2026 Common API Bridge

`bayblaze-api` now exposes the first shared bridge routes for existing
BayBlaze backend services:

```text
GET/POST /v1/inventory
POST     /v1/inventory/images
GET      /v1/inventory/images/:filename
DELETE   /v1/inventory/images
POST     /v1/checkout/eligibility
POST     /v1/orders/live-tracking
POST     /v1/orders/:orderId/cancel
GET      /v1/drivers/:uid/queue
POST     /v1/drivers/queues/score
POST     /v1/drivers/location
POST     /v1/delivery-attempts
```

These routes require `Authorization: Bearer $BAYBLAZE_API_SERVICE_TOKEN` (or
`x-bayblaze-api-token`) from trusted app server boundaries such as Next API
routes, Vercel functions, or Firebase Functions. Browser bundles must not embed
this token.
`BAYBLAZE_API_SERVICE_TOKEN` is the single app-to-API token name for inventory
and other trusted app server boundaries. Do not introduce inventory-specific
token aliases unless there is a concrete rotation plan.

The current bridge pattern is:

```text
frontend browser → app-owned server boundary → bayblaze-api → Medusa / Firebase / internal routing
```

`bayblaze-inventory` must use this bridge strictly for inventory/product and
inventory-image workflows; its Vercel/server boundary should not fall back to
direct Medusa routes or hold Medusa service tokens. `bayblaze-api` forwards to
embedded Medusa BayBlaze routes:

```env
MEDUSA_DRIVER_QUEUE_PATH=/admin/bayblaze/driver-queues/{uid}
MEDUSA_DELIVERY_ATTEMPT_PATH=/admin/bayblaze/delivery-attempts
MEDUSA_ADMIN_ORDERS_PATH=/admin/bayblaze/orders
```

`POST /v1/checkout/eligibility`, `POST /v1/orders/live-tracking`,
`POST /v1/orders/:orderId/cancel`, `POST /v1/drivers/queues/score`, and
`POST /v1/drivers/location` now execute inside `bayblaze-api`; do not configure
old IsoChronos path variables for these app-facing contracts.

Customer order cancellation is app-server initiated only: the storefront
`/api/orders/[orderId]` route calls `bayblaze-api`, which forwards to embedded
Medusa `/admin/bayblaze/orders/{orderId}`. Medusa restores each ordered
variant's `availableQuantity` plus inventory level before deleting the order.

## Module boundaries

Keep routes thin. Business logic belongs in modules/services.

Recommended structure:

```text
src/
  app.ts
  server.ts

  config/
    env.ts

  http/
    routes.ts
    middleware/
    errorHandler.ts
    auth.ts
    requestLogger.ts

  modules/
    isochronos/
      routing/
      tracking/
      geocoding/
      coverage/
      usage/
      diagnostics/

    inventory/
      productService.ts
      variantService.ts
      imageService.ts
      vehicleInventoryService.ts

    orders/
      orderService.ts
      deliveryAttemptService.ts
      orderTrackingService.ts

    drivers/
      driverProfileService.ts
      driverQueueService.ts
      driverLocationService.ts

    messaging/
      twilioService.ts
      templates/

    storage/
      storageService.ts

  clients/
    medusaClient.ts
    driverFirebaseClient.ts
    isochronosFirebaseClient.ts
    googleMapsClient.ts
    twilioClient.ts
    storageClient.ts

  types/
    api.ts
    inventory.ts
    routing.ts
    tracking.ts
    drivers.ts
```

Do not put large amounts of Medusa/Firebase/Google Maps/Twilio logic directly in route handlers.

Good:

```ts
router.post("/checkout/eligibility", async (req, res) => {
  const result = await routingService.evaluatePreCheckoutEligibility(req.body);
  res.json(result);
});
```

Bad:

```ts
router.post("/checkout/eligibility", async (req, res) => {
  // Hundreds of lines of cart parsing, geocoding, route math,
  // Medusa calls, Firebase reads, token signing, and Maps usage accounting.
});
```

## IsoChronos migration rules

`bayblaze-api` has absorbed the IsoChronos functions used by storefront and
driver workflows as internal modules.

Current pattern:

```text
apps → bayblaze-api → internal modules/isochronos/*
```

When migrating from `bayblaze-isochronos`, preserve the existing service contracts wherever possible:

* `evaluatePreCheckoutDeliveryEligibility`
* routing acceptance result states
* tracking response states
* geocode/cache behavior
* usage accounting behavior
* coverage/isochrone semantics
* driver workflow read behavior through API-owned Firebase Admin services

Do not expose Google Maps secrets or raw route-provider responses to frontend apps.

## Unified Firebase project

Production should converge on one Firebase project/database for operational
driver state and routing/cache state, owned behind `bayblaze-api`.

Unified Firebase project:

```env
FIREBASE_PROJECT_ID=bayblaze-isochronos
FIRESTORE_DATABASE_ID=(default)
FIREBASE_SERVICE_ACCOUNT_JSON_BASE64=...
FIREBASE_STORAGE_BUCKET=bayblaze-isochronos.firebasestorage.app
```

This owns driver/live and routing/cache collections such as:

```text
driver_profiles
vehicles
driver_delivery_queues
driver_location_snapshots
delivery_attempt_logs
driver_notification_tokens
geocode_cache
api_usage_events
coverage_isochrones
autocomplete/session records
routing/cache state
```

The old split of separate primary and driver Firebase projects is deprecated.
New code should use the unified Firebase Admin client in
`src/clients/firebaseAdminClient.ts`. The production Storage bucket
`gs://bayblaze-isochronos.firebasestorage.app` must exist before driver profile
or delivery-attempt photo uploads can succeed; missing buckets surface to the
driver PWA as "The specified bucket does not exist."

## Medusa integration rules

Medusa remains the commerce source of truth.

`bayblaze-api` may call Medusa to:

* create products
* update products
* delete products
* create variants
* update variants
* update inventory metadata
* update order metadata
* read orders
* forward delivery attempt events
* synchronize product/category/image state

`bayblaze-api` must not maintain independent commerce tables for products, variants, orders, payments, fulfillment, or inventory quantities.

If caching is added, cache must be clearly derived from Medusa and safely refreshable.

Driver assignment alerts are sent by `bayblaze-api` after
`syncDriverDeliveryQueue` detects stops that were not present in the previous
materialized queue, including the first materialized queue when no prior
`driver_delivery_queues/{uid}` document exists. Queue sync must await alert
submission so server runtimes do not drop push/email work after responding.
Email alerts use `RESEND_API_KEY`, `DRIVER_EMAIL_FROM`, and
`DRIVER_EMAIL_REPLY_TO`. Closed-app browser push uses standard Web Push
subscriptions stored under `driver_notification_tokens/{uid}/tokens/{tokenId}`
and VAPID variables `DRIVER_WEB_PUSH_PUBLIC_KEY`,
`DRIVER_WEB_PUSH_PRIVATE_KEY`, and `DRIVER_WEB_PUSH_SUBJECT`. The matching
browser-safe public key must be exposed to `bayblaze-driver` as
`VITE_BAYBLAZE_WEB_PUSH_PUBLIC_KEY`; private VAPID keys never belong in app
repos.

Driver label/invoice reprints are initiated by `bayblaze-driver` through
`POST /v1/driver/me/deliveries/:orderId/reprint-labels`. `bayblaze-api`
validates that the order is in the driver's active queue, then forwards to
Medusa at `MEDUSA_REPRINT_LABELS_PATH` (default
`/admin/bayblaze/orders/{orderId}/reprint-labels`). Medusa rebuilds delivery
label and invoice jobs from order data and submits them to the existing label
printer agent with `forceReprint: true`, which bypasses the agent's normal
already-printed dedupe only for explicit reprint jobs.

Driver-facing queue responses from `/v1/driver/me/queue` and
`/v1/driver/me/queue/sync` must be sanitized BayBlaze workflow DTOs. Do not
return Medusa/internal commerce identifiers such as `medusaOrderId` or
`orderReference` to the driver PWA; translate the public `orderId` to internal
IDs only inside `bayblaze-api`.

## Variant and inventory contract

Every sellable unit must be represented at the variant level.

Every BayBlaze-routable Medusa variant must have metadata:

```env
inventoryState=ON_VEHICLE or IN_WAREHOUSE
availableQuantity=integer >= 0
unitPriceCents=integer >= 0, optional internal unit cost for profit reporting
```

Storefront cart/order items passed into routing eligibility must normalize to variant-level items:

```ts
itemId
productId
variantId
inventoryState
availableQuantity
requestedQuantity
```

Use `requestedQuantity`, not just `quantity`, for routing eligibility payloads.

## Inventory API scope

`bayblaze-api` should eventually own app-facing inventory workflows:

```text
GET    /v1/inventory/snapshot
POST   /v1/inventory/products
PATCH  /v1/inventory/products/:productId
DELETE /v1/inventory/products/:productId

POST   /v1/inventory/variants
PATCH  /v1/inventory/variants/:variantId

POST   /v1/inventory/images
DELETE /v1/inventory/images/:imageId

GET    /v1/vehicles
GET    /v1/vehicles/:vehicleId/inventory
POST   /v1/vehicles/:vehicleId/inventory
DELETE /v1/vehicles/:vehicleId/inventory/:variantId
```

Inventory image uploads should not depend on fragile frontend-to-Medusa local filesystem behavior.

Preferred long-term image storage:

* Cloudflare R2, S3, or S3-compatible object storage

Temporary images should be cleaned up safely. Final product images should only be committed to Medusa after product creation succeeds.

## Storefront API scope

`bayblaze-api` should eventually own storefront-facing workflows:

```text
POST /v1/checkout/eligibility
GET  /v1/orders/:reference/tracking
GET  /v1/orders/:reference/summary
```

Checkout eligibility must call internal IsoChronos-derived routing logic.

The storefront should receive customer-safe DTOs, not raw Medusa/Firebase/Google Maps documents.

## Driver API scope

The driver app should not call Firestore directly. Driver UI state and durable
business actions should go through `bayblaze-api`, such as:

```text
GET    /v1/driver/me/profile
PUT    /v1/driver/me/profile
GET    /v1/driver/me/vehicles/available
POST   /v1/driver/me/vehicles/link
POST   /v1/driver/me/clock-in
POST   /v1/driver/me/clock-out
GET    /v1/driver/me/queue
POST   /v1/driver/me/queue/sync
POST   /v1/driver/me/location
POST   /v1/driver/me/delivery-attempts
POST   /v1/driver/me/notification-tokens
DELETE /v1/driver/me/notification-tokens/:tokenId
POST /v1/messages/delivery
POST /v1/orders/:reference/out-for-delivery
POST /v1/orders/:reference/complete
POST /v1/orders/:reference/cancel
```

Driver app actions that affect Medusa, Twilio, tracking, or cross-service workflow must be validated and coordinated by `bayblaze-api`.

## Delivery attempt contract

The Add items to box step is the business transition to:

```text
out_for_delivery
```

Delivery attempt event types forwarded to Medusa:

```text
out_for_delivery
completed
cancelled
```

Only terminal events:

```text
completed
cancelled
```

`out_for_delivery` is non-terminal and must not remove/re-score the driver queue as if the delivery is complete.

Medusa order metadata should support:

```json
{
  "bayblaze_delivery_status": "out_for_delivery",
  "bayblaze_delivery_driver_uid": "...",
  "bayblaze_delivery_event_at": "...",
  "bayblaze_out_for_delivery_at": "..."
}
```

Terminal events should also set:

```json
{
  "bayblaze_delivery_terminal_event_at": "..."
}
```

## Tracking contract

Order tracking states should remain stable for storefront/display clients:

```text
awaiting_assignment
awaiting_driver_location
stale_driver_location
driver_location_only
en_route
```

Tracking resolver must match all possible order identifiers, including:

Queue-level fields:

```text
activeOrderId
activeOrderReference
activeMedusaOrderId
```

Stop-level fields:

```text
orderId
orderReference
medusaOrderId
custom_display_id
display_id
id
```

Resolver must compare against both:

```text
Medusa internal order ID: order_...
BayBlaze custom reference: BB-00001
```

## Messaging rules

Twilio messaging through `bayblaze-api` must be transactional unless explicit marketing consent/compliance is implemented.

Allowed transactional SMS examples:

* order status
* driver ETA
* delivery coordination
* gate code requests
* substitution/out-of-stock coordination
* customer/driver communication for active orders

Do not add marketing SMS workflows by default.

## Business copy and compliance rules

BayBlaze is a Tampa-based mobile smoke shop/delivery business.

Public-facing copy must not claim CBD, kratom, THC, or other not-yet-sellable product categories are available unless explicitly confirmed.

BayBlaze Express/on-demand delivery is available 24/7. Do not reintroduce the old 10 AM to 11 PM delivery-hours restriction in customer-facing checkout, routing, or delivery copy unless the business explicitly changes the availability model again.

Age-gated fulfillment assumes the customer must be 21+ and have physical ID available at delivery.

## Error handling rules

All API errors returned to apps should be JSON.

Generic error handler must log unexpected errors:

```ts
console.error("Unhandled BayBlaze API error:", err);
```

Do not hide upstream errors behind generic 500s without logging the underlying error.

External service errors should be normalized into stable API responses, but logs should preserve details needed to debug:

* Medusa status/body when safe
* Firebase project/database being used
* Google Maps endpoint/category
* Twilio message SID/status when relevant
* storage key/object path when relevant

Never log secrets, tokens, service account JSON, full authorization headers, or payment/PII-sensitive data.

## Security rules

Do not expose backend service tokens to frontend apps.

Frontend apps should authenticate to `bayblaze-api` using app-appropriate auth, then `bayblaze-api` uses backend-only service credentials internally.

Do not put these secrets in client bundles:

```env
MEDUSA_ADMIN_API_TOKEN
BAYBLAZE_INVENTORY_SERVICE_TOKEN
BAYBLAZE_DRIVER_SERVICE_TOKEN
FIREBASE_SERVICE_ACCOUNT_JSON_BASE64
DRIVER_FIREBASE_SERVICE_ACCOUNT_JSON_BASE64
GOOGLE_MAPS_API_KEY
TWILIO_AUTH_TOKEN
```

Google Maps browser keys, if ever used by frontend apps, must be restricted and must not replace server-side Maps usage for routing/eligibility.

## DTO rules

Apps should receive stable DTOs, not raw database/provider documents.

Examples:

```ts
type LiveDriverDto = {
  uid: string;
  displayName: string;
  vehicleLabel: string | null;
  status: "offline" | "available" | "assigned" | "en_route" | "stale";
  lastLocationAt: string | null;
  lastKnownLocation: {
    lat: number;
    lng: number;
  } | null;
  activeOrderReference: string | null;
  etaMinutes: number | null;
};
```

```ts
type MapsUsageSummaryDto = {
  date: string;
  geocodingRequests: number;
  routesRequests: number;
  autocompleteRequests: number;
  placeDetailsRequests: number;
  trafficAwareRoutes: number;
  warnings: string[];
};
```

Raw Firestore docs, Medusa records, Google Maps responses, and Twilio objects should be translated before returning to apps.

## Deployment rules

`bayblaze-api` should run as backend infrastructure, preferably on the VPS or another backend runtime suitable for:

* long-lived server process
* backend-only secrets
* Firebase Admin SDK
* Google Maps server API calls
* Twilio
* image/object storage
* internal service clients

Use stable Docker Compose project/service names in production.

Production deploys must sync the checked-out release into the stable service
directory `/opt/bayblaze/bayblaze-api` and run Docker Compose from that
directory. This one Compose project owns the app-facing API plus embedded
Medusa/Caddy/Postgres/Redis runtime. The GitHub runner workspace under
`/home/codex-deploy/github-runners/bayblaze-api/_work/...` is transient and
must not be the long-lived Compose working directory. Keep
`/opt/bayblaze/bayblaze-api/.env.production` and
`/opt/bayblaze/bayblaze-api/uploads` out of rsync deletion. Also preserve
`/opt/bayblaze/bayblaze-api/medusa/uploads`; this is the embedded Medusa upload
bind mount.

If Dockerized, production should load `.env.production` and explicitly pass critical env vars when ambiguity is risky.

Recommended production env includes:

```env
NODE_ENV=production
PORT=3040
BAYBLAZE_PUBLIC_API_URL=https://api.bayblaze.net

MEDUSA_BACKEND_URL=http://medusa:9000
BAYBLAZE_MEDUSA_SERVICE_TOKEN=...
DATABASE_URL=postgres://medusa:<POSTGRES_PASSWORD>@postgres:5432/medusa?sslmode=disable
POSTGRES_PASSWORD=...
JWT_SECRET=...
COOKIE_SECRET=...
MEDUSA_DRIVER_QUEUE_PATH=/admin/bayblaze/driver-queues/{uid}
MEDUSA_DELIVERY_ATTEMPT_PATH=/admin/bayblaze/delivery-attempts
MEDUSA_REPRINT_LABELS_PATH=/admin/bayblaze/orders/{orderId}/reprint-labels
MEDUSA_ADMIN_ORDERS_PATH=/admin/bayblaze/orders

FIREBASE_PROJECT_ID=bayblaze-isochronos
FIRESTORE_DATABASE_ID=(default)
FIREBASE_SERVICE_ACCOUNT_JSON_BASE64=...
FIREBASE_STORAGE_BUCKET=bayblaze-isochronos.firebasestorage.app

GOOGLE_MAPS_API_KEY=...

TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_FROM_NUMBER=...

RESEND_API_KEY=...
DRIVER_EMAIL_FROM=...
DRIVER_EMAIL_REPLY_TO=...
DRIVER_WEB_PUSH_PUBLIC_KEY=...
DRIVER_WEB_PUSH_PRIVATE_KEY=...
DRIVER_WEB_PUSH_SUBJECT=mailto:drivers@bayblaze.net

BAYBLAZE_STORAGE_MODE=...
BAYBLAZE_UPLOAD_DIR=...
```

Production CORS is normally controlled by `CORS_ORIGINS`, and the API also
allows BayBlaze app custom domains (`bayblaze.net`, `www.bayblaze.net`,
`admin.bayblaze.net`, `driver.bayblaze.net`, `stock.bayblaze.net`,
`inventory.bayblaze.net`, and `win.bayblaze.net`) plus BayBlaze Vercel preview
origins matching `https://bayblaze-{admin,storefront,driver,inventory,win}*.vercel.app`
so browser apps can call `https://api.bayblaze.net` without `Failed to fetch`
CORS failures.

## Referral Partner Production Model

- Partner enrollment is one-to-one with the universal account UID in
  `referral_partners/{uid}`. Statuses are `pending`, `active`, `suspended`, and
  `rejected`; only active partners may use partner self-service data or receive
  new attribution.
- Customer accounts self-enroll through `POST /v1/partners/me/enrollment`, which
  records accepted partner terms and creates a `pending` partner profile without
  a referral code. BayBlaze manually creates the referral-promo coupon through
  the admin flow; that code assignment activates the dashboard and attribution.
- Deleting an unused partner referral promo from admin must clear the
  `referral_partners/{uid}.referralCode`, delete `referral_partner_codes/{CODE}`,
  and return the partner to `pending` so a replacement coupon can be assigned.
- Referral promo codes remain `customer_discount_codes/{CODE}` records with
  category `referral_partner`. `referral_partner_codes/{CODE}` is the unique,
  case-normalized code-to-partner index. Codes are stable after approval.
- Signed first-party attribution is created by `POST /v1/partners/attributions`
  and stored by the storefront in an HttpOnly `bayblaze_partner_attribution`
  cookie. The configured first valid touch wins for the attribution window. An
  explicitly applied valid partner promo can still credit its order when no
  valid cookie exists; the browser never supplies a partner UID.
- Trusted Medusa lifecycle subscribers call `POST /v1/partners/order-events`.
  Referral documents live at
  `referral_partners/{uid}/referrals/{orderId}` with immutable history below
  `history`. The order ID is the idempotency boundary.
- Commission money is integer cents and rates are integer basis points.
  Qualifying basis is the checkout product total after promo discount; taxes,
  tips, delivery charges, and other fees are excluded. Refund dollars
  conservatively reduce product basis first.
- Commission statuses are `tracked`, `pending`, `eligible`, `paid`, and
  `reversed`. Cancellations, failed payments, chargebacks, and full/partial
  refunds recalculate or reverse the financial record and append audit history.
- Payouts are persisted under `referral_partners/{uid}/payouts`. There is no
  payout provider: the admin route records an already completed external payout
  and offsets outstanding clawbacks, but never initiates money movement.
- Required production secrets are `PARTNER_ATTRIBUTION_TOKEN_SECRET` and
  `PARTNER_CUSTOMER_HASH_SECRET` (32+ characters and distinct in operations).
  Configurable rules are `PARTNER_ATTRIBUTION_WINDOW_DAYS` (default 30),
  `PARTNER_COMMISSION_ELIGIBILITY_DAYS` (default 7), and
  `PARTNER_REFERRAL_CODE_PREFIX` (default `LOCAL`).
- `src/migrations/20260722ReferralPartners.ts` is dry-run by default, blocks
  one-to-many legacy owner conflicts, preserves existing promo codes, and is
  idempotently applied during deployment before runtime recreation.
After changes that affect an admin screen, wait for the relevant deploy to
finish and smoke-test the deployed screen plus its API preflight from both
`https://admin.bayblaze.net` and the active Vercel preview origin when one is
being used.

## Migration priority

Recommended first migrations:

1. Inventory image uploads
2. Inventory product create/update/delete
3. Inventory category and vehicle assignment
4. Storefront checkout eligibility
5. Storefront order tracking
6. Driver delivery attempt actions
7. Twilio transactional messaging
8. IsoChronos routing/tracking internal modules
9. IsoChronos operations console API routes

Do not attempt to migrate all apps and services at once.

## Patch style

When asked for code changes, prefer direct patch commands.

Patch commands should:

* be copy-pasteable from the repository root
* use Python scripts with `pathlib` when editing existing files
* include build/test commands
* include `git add`, `git commit`, and `git push` when appropriate
* avoid `set -e`

Do not use `set -e` in generated shell commands.

Preferred pattern:

```bash
cd "/Users/user/Documents/Bay Blaze/bayblaze-api"

cat > /tmp/patch.py <<'PY'
from pathlib import Path

path = Path("src/example.ts")
text = path.read_text()
text = text.replace("old", "new")
path.write_text(text)
PY

python3 /tmp/patch.py

npm run build
git add src/example.ts
git commit -m "Clear commit message"
git push
```
