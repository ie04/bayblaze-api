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

## June 2026 Medusa Repo Consolidation

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
Medusa Dockerfiles, and Medusa compose files. The root API Dockerfile excludes
`medusa/` so the API image stays small; use `docker-compose.integrated.yml` or
the Medusa compose files under `medusa/` when deploying both services from this
repo.

API-to-Medusa service auth should use one canonical secret:

```env
BAYBLAZE_MEDUSA_SERVICE_TOKEN=<shared API-to-Medusa secret>
```

Set the same value for `bayblaze-api` and the embedded `medusa` service.
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
GET   /v1/admin/orders
GET   /v1/admin/orders/:orderId
```

`/v1/admin/*` routes require a BayBlaze account session bearer token from an
employee account with the `admin` role. The admin dashboard lives at
`admin.bayblaze.net` and must call only `bayblaze-api`; it must not import
Firebase, Firestore, Medusa, Google Maps, or service-token clients in browser
code.

`POST /v1/admin/isochrones` samples Google Routes round-trip duration from WH1
or the requested origin across radial bearings and stores short-lived
`coverage_isochrones` cache documents. It should return a route-duration
polygon for the requested round-trip minute budget, not a simple geometric
circle.

Additional account/admin environment variables:

```env
ACCOUNT_SESSION_SECRET=<server-only signing secret>
ACCOUNT_SESSION_TTL_SECONDS=1209600
MEDUSA_ADMIN_ORDERS_PATH=/admin/bayblaze/orders
MEDUSA_CUSTOMER_SESSION_PATH=/admin/bayblaze/customer-sessions
GOOGLE_OAUTH_CLIENT_ID=<google oauth client id>
GOOGLE_OAUTH_CLIENT_SECRET=<google oauth client secret>
GOOGLE_OAUTH_REDIRECT_URL=https://bayblaze.net/api/auth/oauth/google/callback,https://driver.bayblaze.net/auth/google/callback,https://inventory.bayblaze.net/auth/google/callback
```

Production `/opt/bayblaze/bayblaze-api/.env.production` should keep the same
comma-separated OAuth redirect allowlist. It was updated on June 14, 2026 to
include the driver and inventory callback URLs alongside the storefront
callback.
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
`POST /v1/drivers/queues/score`, and `POST /v1/drivers/location` now execute
inside `bayblaze-api`; do not configure old IsoChronos path variables for these
app-facing contracts.

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

## Variant and inventory contract

Every sellable unit must be represented at the variant level.

Every BayBlaze-routable Medusa variant must have metadata:

```env
inventoryState=ON_VEHICLE or IN_WAREHOUSE
availableQuantity=integer >= 0
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

Orders placed after 11 PM should not be promised for immediate delivery. They should dispatch at 10 AM the next day or later depending on selected scheduled delivery time.

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
directory. The GitHub runner workspace under
`/home/codex-deploy/github-runners/bayblaze-api/_work/...` is transient and
must not be the long-lived Compose working directory. Keep
`/opt/bayblaze/bayblaze-api/.env.production` and
`/opt/bayblaze/bayblaze-api/uploads` out of rsync deletion.

If Dockerized, production should load `.env.production` and explicitly pass critical env vars when ambiguity is risky.

Recommended production env includes:

```env
NODE_ENV=production
PORT=3040
BAYBLAZE_PUBLIC_API_URL=https://api.bayblaze.net

MEDUSA_BACKEND_URL=http://medusa:9000
BAYBLAZE_MEDUSA_SERVICE_TOKEN=...
MEDUSA_DRIVER_QUEUE_PATH=/admin/bayblaze/driver-queues/{uid}
MEDUSA_DELIVERY_ATTEMPT_PATH=/admin/bayblaze/delivery-attempts
MEDUSA_ADMIN_ORDERS_PATH=/admin/bayblaze/orders

FIREBASE_PROJECT_ID=bayblaze-isochronos
FIRESTORE_DATABASE_ID=(default)
FIREBASE_SERVICE_ACCOUNT_JSON_BASE64=...
FIREBASE_STORAGE_BUCKET=bayblaze-isochronos.firebasestorage.app

GOOGLE_MAPS_API_KEY=...

TWILIO_ACCOUNT_SID=...
TWILIO_AUTH_TOKEN=...
TWILIO_FROM_NUMBER=...

BAYBLAZE_STORAGE_MODE=...
BAYBLAZE_UPLOAD_DIR=...
```

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
