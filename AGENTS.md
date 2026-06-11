# BayBlaze API Agent Rules

## Project role

`bayblaze-api` is the shared app-facing backend boundary for BayBlaze.

BayBlaze apps should call `bayblaze-api` instead of directly integrating with backend-only services.

Primary clients:

* `bayblaze-storefront`
* `bayblaze-driver`
* `bayblaze-inventory`
* future `bayblaze-isochronos-console` / operations display apps

Primary backend dependencies:

* Medusa
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

As IsoChronos is folded into `bayblaze-api`, preserve it as a clean internal module, not scattered utility code.

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

## June 2026 Common API Bridge

`bayblaze-api` now exposes the first shared bridge routes for existing
BayBlaze backend services:

```text
GET/POST /v1/inventory
POST     /v1/inventory/images
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

The current bridge pattern is:

```text
frontend browser → app-owned server boundary → bayblaze-api → Medusa/IsoChronos
```

Short-term app integrations may keep direct Medusa/IsoChronos fallbacks for
safe rollout, but new frontend-facing backend work should prefer `bayblaze-api`
as the upstream. `bayblaze-api` forwards to:

```env
MEDUSA_DRIVER_QUEUE_PATH=/admin/bayblaze/driver-queues/{uid}
MEDUSA_DELIVERY_ATTEMPT_PATH=/admin/bayblaze/delivery-attempts
ISOCHRONOS_PRECHECKOUT_ELIGIBILITY_PATH=/routing/pre-checkout/eligibility
ISOCHRONOS_ORDER_TRACKING_PATH=/orders/live-tracking
ISOCHRONOS_QUEUE_SCORE_PATH=/driver-queues/score
ISOCHRONOS_DRIVER_LOCATION_PATH=/driver-locations
```

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

`bayblaze-api` will eventually absorb IsoChronos as internal modules.

Short-term migration pattern:

```text
apps → bayblaze-api → existing bayblaze-isochronos service
```

Long-term target:

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
* driver Firebase read behavior

Do not expose Google Maps secrets or raw route-provider responses to frontend apps.

## Firebase project split

Production must preserve the two-Firebase-project model.

Primary IsoChronos Firebase project:

```env
FIREBASE_PROJECT_ID=bayblaze-isochronos
FIRESTORE_DATABASE_ID=(default)
FIREBASE_SERVICE_ACCOUNT_JSON_BASE64=...
```

This owns IsoChronos/internal routing collections such as:

```text
geocode_cache
api_usage_events
coverage_isochrones
autocomplete/session records
routing/cache state
```

Secondary driver Firebase project:

```env
DRIVER_FIREBASE_PROJECT_ID=bayblaze-driver
DRIVER_FIRESTORE_DATABASE_ID=(default)
DRIVER_FIREBASE_SERVICE_ACCOUNT_JSON_BASE64=...
```

This owns driver/live collections such as:

```text
driver_profiles
vehicles
driver_delivery_queues
driver_location_snapshots
delivery_attempt_logs
```

Never repoint the primary IsoChronos Firebase config to `bayblaze-driver`.

Use separate Firebase Admin app instances/clients for:

* IsoChronos Firestore
* driver Firestore

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

Checkout eligibility must call internal IsoChronos routing logic or the temporary IsoChronos service.

The storefront should receive customer-safe DTOs, not raw Medusa/Firebase/Google Maps documents.

## Driver API scope

The driver app may continue using Firebase directly for high-frequency realtime UI state when appropriate, such as:

* queue listeners
* live location snapshots
* clocked-in state

But durable business actions should go through `bayblaze-api`, such as:

```text
POST /v1/drivers/location
GET  /v1/drivers/me/queue
POST /v1/delivery-attempts
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

If Dockerized, production should load `.env.production` and explicitly pass critical env vars when ambiguity is risky.

Recommended production env includes:

```env
NODE_ENV=production
PORT=3040
BAYBLAZE_PUBLIC_API_URL=https://api.bayblaze.net

MEDUSA_BACKEND_URL=...
MEDUSA_ADMIN_API_TOKEN=...
BAYBLAZE_INVENTORY_SERVICE_TOKEN=...
BAYBLAZE_DRIVER_SERVICE_TOKEN=...

FIREBASE_PROJECT_ID=bayblaze-isochronos
FIRESTORE_DATABASE_ID=(default)
FIREBASE_SERVICE_ACCOUNT_JSON_BASE64=...

DRIVER_FIREBASE_PROJECT_ID=bayblaze-driver
DRIVER_FIRESTORE_DATABASE_ID=(default)
DRIVER_FIREBASE_SERVICE_ACCOUNT_JSON_BASE64=...

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
