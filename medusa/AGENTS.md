# Bayblaze Embedded Medusa Notes

## Repository Ownership

This Medusa service is embedded under `bayblaze-api/medusa`. The `bayblaze-api`
repository is the repo of record for BayBlaze Medusa code, routes, Docker
Compose, deployment notes, runtime ownership, and future migrations.

The previous standalone `bayblaze-medusa` repository is retired as an
independent source repo after the June 2026 consolidation. Make new Medusa
changes here, not in the old repo.

Production runtime is also consolidated into `bayblaze-api`. The VPS should run
embedded Medusa from `/opt/bayblaze/bayblaze-api/docker-compose.prod.yml` as
part of the `bayblaze-api` Compose project. Do not run production Medusa from a
separate `/opt/bayblaze/medusa` checkout. The consolidated compose reuses the
old named Docker volumes (`medusa_postgres_data`, `medusa_redis_data`,
`medusa_caddy_data`, and `medusa_caddy_config`) for data continuity.

## Durable Project Memory

Record durable project facts, recurring commands, local service topology,
deployment details, and workflow preferences in this file so future Codex
sessions can pick them up after context compaction or a new chat.

Prefer updating this file when the user says to "remember" something for this
repo.

When infrastructure, deployment, environment variables, service topology,
runner setup, or cross-repo integration details change, update the relevant
`AGENTS.md` files in the same work session so future Codex/LLM sessions inherit
the current operating model.

## IsoChronos Integration

IsoChronos lives in the sibling repository `bayblaze-isochronos`. Treat it as
BayBlaze's backend-only delivery intelligence service for geocoding, routing,
delivery ETA, address autocomplete session handling, geographic order
partitioning, and Google Maps usage guardrails.

- Medusa should delegate Google Maps work to IsoChronos service/API boundaries
  rather than duplicating Google Maps calls and cost-control logic inside Medusa
  modules.
- Never expose Google Maps API keys through Medusa responses intended for
  storefront or driver clients.
- Order fulfillment, delivery, and notification workflows can consume
  IsoChronos route snapshots, cached geocodes, partitioned order groups, and ETA
  interpolation data.
- Worker queues, scheduled jobs, and fulfillment workflows should call
  IsoChronos reusable backend services or HTTP endpoints instead of coupling
  paid Google API calls directly to request handlers.
- Keep customer address/location data structured and intentional. Avoid logging
  full addresses when a place ID, cache key, coordinate pair, order ID, or usage
  event metadata is enough.
- Medusa owns products, variants, orders, fulfillment, payment state, and
  inventory. IsoChronos and the storefront should consume normalized
  variant-level inventory data from Medusa instead of becoming commerce data
  sources of truth.
- `bayblaze-inventory` is the staff-facing inventory PWA for routine product,
  variant, stock count, metadata, and delivery vehicle assignment workflows. It
  must call Medusa through a trusted inventory API/backend boundary and must not
  expose Medusa admin or service tokens in browser code.
- `bayblaze-api` is now the preferred app-facing backend layer in front of
  Medusa for frontend app workflows. Inventory, storefront, and driver server
  boundaries should call `bayblaze-api` first, while `bayblaze-api` forwards to
  Medusa service routes with backend-only tokens. Existing direct calls may
  remain only as rollout fallbacks.
- Public `https://api.bayblaze.net/v1/*` traffic is routed by the consolidated
  Caddy service in `/opt/bayblaze/bayblaze-api/docker-compose.prod.yml` to the
  `bayblaze-api` service (`reverse_proxy bayblaze-api:3040`). Non-`/v1`
  traffic continues to proxy to the embedded `medusa` service
  (`reverse_proxy medusa:9000`) in the same Compose project.
- Product photos edited by `bayblaze-inventory` are written to Medusa product
  `thumbnail` and `images`; product media remains Medusa-owned.
  Inventory-uploaded image bytes are currently stored on the VPS filesystem
  under `/opt/bayblaze/bayblaze-api/medusa/uploads/bayblaze-inventory`, mounted
  into the embedded Medusa container at `/app/uploads`. Keep `uploads/`
  gitignored and preserve this bind mount in Docker Compose until image storage
  moves to object storage.
- Product publish state edited by `bayblaze-inventory` is written to Medusa
  product `status` through the inventory boundary. New products default to
  `draft`; staff publish reviewed products from the inventory product editor.
  The inventory boundary must also attach created/published products to the
  storefront sales channel automatically when products are created, published,
  saved while already published, or when variants on an already-published
  product are saved, so Medusa Store API responses include them for the
  publishable key. If multiple sales channels exist, set
  `BAYBLAZE_STOREFRONT_SALES_CHANNEL_ID` to the storefront channel ID.
- Product description, Medusa product collection assignment, and storefront
  spec metadata are also managed through the inventory boundary. The
  `/admin/bayblaze/inventory` snapshot returns product `description`,
  `collectionId`, `collectionTitle`, editable product metadata, and a
  `collections` list from Medusa product collections. Inventory writes should
  store storefront specs on product metadata keys `spec_puffs`, `spec_capacity`,
  and `spec_battery` while preserving `inventoryCategory` as the BayBlaze
  storefront category bridge.
- The inventory endpoint normalizes Medusa price reads for the inventory PWA:
  decimal-dollar amounts such as `24.99` are returned to the PWA as `2499`
  cents, while existing cent amounts such as `2499` remain unchanged.
- The inventory endpoint must convert PWA `priceCents` back to Medusa
  decimal-dollar price amounts on writes. For example, `1999` from the PWA must
  be written to Medusa as `19.99`, not `1999`; otherwise the storefront renders
  prices as `$1,999.00`.
- Inventory unit cost is separate from listed storefront price. The inventory
  endpoint reads and writes variant metadata `unitPriceCents` for profit
  calculations and must not map it to Medusa price sets.
- The inventory endpoint must keep Medusa `inventory_level` rows in sync with
  variant `availableQuantity` metadata for managed variants. New variants and
  quantity edits should create or update stock at the `Bayblaze Local Delivery
  Hub` stock location so checkout can associate the storefront sales channel
  with an eligible stock location. On June 14, 2026, production variants missing
  this level were backfilled from their `availableQuantity` metadata.
- The Medusa inventory boundary is
  `/admin/bayblaze/inventory` and exports `AUTHENTICATE = false` so the route
  can validate `x-bayblaze-service-token` itself. The shared service-token
  helper accepts `BAYBLAZE_INVENTORY_SERVICE_TOKEN`,
  `BAYBLAZE_DRIVER_SERVICE_TOKEN`, or `MEDUSA_ADMIN_API_TOKEN` in that order.
  The current VPS deploy workflow already injects `BAYBLAZE_DRIVER_SERVICE_TOKEN`
  into Docker Compose, so Vercel can use the same token value as
  `BAYBLAZE_INVENTORY_SERVICE_TOKEN` until a dedicated secret is introduced.
- Optional Medusa env `BAYBLAZE_INVENTORY_VEHICLES` may contain a JSON array of
  `{ "id": "...", "label": "...", "plate": "...", "active": true }` records.
  The inventory route also derives vehicle IDs from variant
  `metadata.assignedVehicleId`.
- Driver PWA service-to-service endpoints live at
  `/admin/bayblaze/driver-queues/{uid}` and
  `/admin/bayblaze/delivery-attempts`. These routes opt out of Medusa's default
  `/admin` auth with `AUTHENTICATE = false` and validate
  `x-bayblaze-service-token` against `BAYBLAZE_DRIVER_SERVICE_TOKEN` (falling
  back to `MEDUSA_ADMIN_API_TOKEN` only for compatibility). The token must match
  the `bayblaze-api` Medusa driver service token, and direct fallback driver
  Firebase Functions `MEDUSA_ADMIN_API_TOKEN` if those fallbacks are still
  enabled. The VPS deploy workflow passes it from the GitHub Actions secret
  `BAYBLAZE_DRIVER_SERVICE_TOKEN` into Docker Compose. Both compose files expose
  this variable to the Medusa container.
- BayBlaze Admin order reads live at `/admin/bayblaze/orders` and
  `/admin/bayblaze/orders/{orderId}`. These routes also opt out of Medusa's
  default `/admin` auth and use the shared BayBlaze service-token helper.
  `bayblaze-api` should set
  `MEDUSA_ADMIN_ORDERS_PATH=/admin/bayblaze/orders`; do not point it at native
  `/admin/orders` unless the API is changed to use a real Medusa admin auth
  flow.
- The embedded Medusa `order.placed` subscriber posts an `order_placed` email
  automation event to `bayblaze-api` at `POST /v1/email/events` using
  `BAYBLAZE_MEDUSA_SERVICE_TOKEN`. It defaults to
  `http://bayblaze-api:3040` inside the consolidated Compose network unless
  `BAYBLAZE_API_URL` is set. This email event must run independently of label
  printing; missing `LABEL_PRINTER_AGENT_URL` should not prevent the email
  trigger.
- Customer cancellation also uses `/admin/bayblaze/orders/{orderId}` via POST
  from `bayblaze-api`. It must restore each ordered variant's
  `availableQuantity` metadata and Medusa inventory level from the order item
  snapshot before calling `orderModuleService.deleteOrders` to clear the order.
- BayBlaze customer Google OAuth is owned by `bayblaze-api`, not Medusa's
  native OAuth routes. After `bayblaze-api` verifies Google and creates/finds
  the BayBlaze account, it calls Medusa service route
  `/admin/bayblaze/customer-sessions` with the shared service token. That route
  finds or creates the Medusa customer account, links a `bayblaze_google` auth
  identity, and returns a Store API-compatible customer bearer token for the
  storefront `bayblaze_customer_token` cookie.
- `/admin/bayblaze/delivery-attempts` accepts driver lifecycle events
  `out_for_delivery`, `completed`, and `cancelled`. `out_for_delivery` is
  non-terminal and should update order metadata with
  `bayblaze_delivery_status`, `bayblaze_delivery_driver_uid`,
  `bayblaze_delivery_event_at`, and `bayblaze_out_for_delivery_at` so storefront
  order progress can mark the Out for delivery step. Terminal events
  (`completed` and `cancelled`) also set `bayblaze_delivery_terminal_event_at`.
  The driver queue route treats terminal metadata as closed state and excludes
  those orders from future driver syncs. The public `/store/order-lookup/{orderId}`
  route must include `metadata` so storefront customer tracking pages can display
  the same lifecycle.
- The driver queue route normally returns only orders with explicit driver
  assignment metadata (`driverUid`, `driver_uid`, `assignedDriverUid`, or
  `assigned_driver_uid`). When Firebase Functions has verified there is exactly
  one active, onboarded, clocked-in driver with a linked vehicle, it may call the
  route with `include_unassigned=true` to include open unassigned orders as a
  temporary solo-driver dispatch fallback. With multiple active drivers,
  unassigned orders should be assigned by a future dispatch/partitioning service
  before they appear in a driver's queue.
- Every sellable product/variant used by BayBlaze routing must explicitly define
  variant metadata `inventoryState` as either `ON_VEHICLE` or `IN_WAREHOUSE` and
  `availableQuantity` as an integer >= 0. Do not rely on storefront or
  IsoChronos defaults for missing inventory state or quantity.
- Pre-checkout delivery eligibility evaluation happens in the storefront through
  IsoChronos before AgeChecker.Net and before Medusa cart/order creation.
  Medusa order metadata may include routing token verification fields such as
  `routing_provider`, `routing_status`, `routing_decision`,
  `routing_classification`, `routing_fulfillment_mode`,
  `routing_estimated_minutes`, and `routing_evaluated_at`.
- IsoChronos has its own repo-scoped VPS runner now:
  `bayblaze-isochronos-vps` in the `bayblaze-isochronos` repo with labels
  `self-hosted`, `Linux`, `X64`, and `isochronos`. Do not add or restore Medusa
  workflows that deploy IsoChronos through the Medusa runner.

## Label Printer Integration

Medusa submits BayBlaze delivery labels from an `order.placed` subscriber at
`apps/backend/src/subscribers/bayblaze-print-order-label.ts`.

- The subscriber reads the completed Medusa order through `query.graph`, builds
  the label-agent payload, and posts to `POST /print-label`.
- The legacy `OrderLabelPrinterService` / `debug-order-label` print path was
  removed. Do not reintroduce a second order-label print sender; the
  `bayblaze-print-order-label` subscriber is the single automatic order-label
  pipeline.
- The label agent is the `@dtc/label-printer-agent` workspace and validates
  `jobId`, `orderId`, `orderNumber`, `orderUrl`, `customerName`, and an address
  array before rendering and printing.
- `LABEL_PRINTER_AGENT_URL` should point to the reachable label agent from the
  Medusa container. Local Docker defaults to `http://host.docker.internal:4786`.
- If the label agent is protected, set `LABEL_PRINTER_AGENT_TOKEN` in Medusa.
  The label-printer agent accepts `LABEL_AGENT_TOKEN` or
  `LABEL_PRINTER_AGENT_TOKEN`; the configured value must match Medusa.
- Label printing must never block order placement. The subscriber should catch
  and log print failures instead of throwing them back into checkout.
- The label address should include Medusa `shipping_address.address_2` when
  present so apartment/unit details print on the 4x6 delivery label. If
  Address Line 2 is only available on order metadata, fall back to
  `address_line_2`, `delivery_address_line_2`, `checkout_address_line_2`, or
  `customer_address_line_2`.
- The label-printer agent must dedupe by stable `jobId` and guard active
  in-flight print jobs before rendering/printing. Do not rely only on
  `printed-jobs.json` after `pdf-to-printer` returns, because duplicate
  Medusa/webhook requests can arrive while the first print is still in progress.
- Every completed order should submit two print jobs to the same local label
  agent: `delivery-label:{order.id}` with `jobType: "delivery_label"` and
  `invoice:{order.id}` with `jobType: "invoice"`. The invoice prints alongside
  the delivery label and must include itemized order details, discount/totals,
  payment method, delivery address, and a customer signature line.
- Storefront checkout metadata should preserve `requested_items` with quantity
  plus cents-based `unit_price_cents` and `total_cents`. The invoice subscriber
  may receive incomplete Medusa `items.*` expansions from `query.graph`, so it
  must fall back to that checkout snapshot before printing item rows or totals.
- Label-agent idempotency must include both `orderId` and `jobType`; otherwise
  the invoice job can be incorrectly skipped after the delivery label prints.

## Local Docker Backend

Prefer these npm shortcuts for local backend Docker work:

```bash
npm run backend:docker:deps
npm run backend:docker:migrate
npm run backend:docker:up
npm run backend:docker:logs
npm run backend:docker:down
```

Local services:

- Medusa: `http://localhost:9000`
- Postgres host port: `5433`
- Redis host port: `6380`
- Label printer agent from Docker: `http://host.docker.internal:4786`

## VPS Backend Deploys

Production backend deploys should use a GitHub Actions self-hosted runner on the
VPS instead of SSHing in from a hosted runner.

Runner details:

- Runner name: `bayblaze-vps`
- Runner labels currently used by workflows: `self-hosted`, `Linux`, `X64`
- Runner install directory: `/opt/github-runners/bayblaze-medusa`
- App checkout/deploy directory: `/opt/bayblaze/medusa`
- Runner user: `github-runner`

The runner service should be installed from `/opt/github-runners/bayblaze-medusa`
and run as `github-runner`. The `github-runner` user needs Docker access.

Current caveat: after the Medusa repo consolidation, the active
`bayblaze-api/.github/workflows/deploy.yml` deploys only the API container from
`/opt/bayblaze/bayblaze-api`; it does not rebuild this embedded Medusa service.
Until a Medusa deploy workflow is restored, deploy Medusa changes by syncing
`bayblaze-api/medusa/` to `/opt/bayblaze/medusa` while preserving `.env` and
`uploads`, then run the active compose file, `docker-compose.yml`:

```bash
cd /opt/bayblaze/medusa
rsync source should exclude .env, .env.production, node_modules, apps/backend/.medusa, and uploads
BAYBLAZE_DRIVER_SERVICE_TOKEN=... docker compose -f docker-compose.yml build medusa
BAYBLAZE_DRIVER_SERVICE_TOKEN=... docker compose -f docker-compose.yml run --rm medusa npx medusa db:migrate
BAYBLAZE_DRIVER_SERVICE_TOKEN=... docker compose -f docker-compose.yml up -d --remove-orphans
docker image prune -f
```

Code changes should still be committed and pushed to `bayblaze-api`; the manual
sync is only the current production activation step for embedded Medusa changes.

Do not run `git pull` or `git reset` in `/opt/bayblaze/medusa`; it is currently
a synced deployment tree rather than a git checkout.

Customer Google OAuth is configured in the Medusa Auth Module and is initiated
from the storefront `/login` page. Required backend environment variables:

```env
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_CALLBACK_URL=https://bayblaze.net/api/auth/oauth/google/callback
```

The Google auth provider is loaded only when all three values are present. This
keeps the API and product catalog online before OAuth credentials are configured;
Google sign-in will fail until the provider is enabled by those env vars.
The active VPS deploy workflow passes `GOOGLE_CLIENT_ID`,
`GOOGLE_CLIENT_SECRET`, and `GOOGLE_CALLBACK_URL` from GitHub Actions secrets
into `docker-compose.yml`; if any are missing, the deploy logs a warning and the
Medusa `google` auth provider remains disabled.

The Google OAuth authorized redirect URI must exactly match
`GOOGLE_CALLBACK_URL`. For local storefront testing, use
`http://localhost:3000/api/auth/oauth/google/callback` and include
`http://localhost:3000` in `AUTH_CORS`.

## AgeChecker.Net Integration

Age verification is currently enforced by the storefront before Medusa cart and
order creation. The storefront validates accepted AgeChecker.Net popup UUIDs
server-side, signs a short-lived BayBlaze checkout token, and then includes only
verification metadata on the Medusa cart/order.

Medusa workflows should treat these metadata keys as the storefront verification
marker:

- `age_verification_provider`
- `age_verification_status`
- `age_verification_uuid`
- `age_verified_at`

Do not store DOB, ID images, signatures, or other sensitive identity document
data in Medusa metadata. If backend-side enforcement is added later, preserve
the same metadata contract and keep AgeChecker account secrets server-only.

Troubleshooting deploys:

- Check the GitHub Actions run first:
  `https://github.com/ie04/bayblaze-medusa/actions`
- A successful deploy should end with the Docker Compose stack recreated on the
  VPS. The active compose project is `medusa` from `/opt/bayblaze/medusa` using
  `/opt/bayblaze/medusa/docker-compose.yml`.
- If the run is queued, confirm the self-hosted runner `bayblaze-vps` is online
  in GitHub and that the runner service is running on the VPS.
- If Docker commands fail, confirm the `github-runner` user has Docker access.
- If the deploy succeeds but the API is unhealthy, inspect VPS logs with:
  `cd /opt/bayblaze/medusa && docker compose -f docker-compose.yml logs -f medusa`

## June 2026 Production Env and Label Contracts

- Production Medusa Docker Compose should load the same env file used by the VPS
  deploy and explicitly preserve service-token variables needed by BayBlaze
  integrations. Do not assume `.env.production` and `.env` are interchangeable
  unless the active compose file names that env file.
- `BAYBLAZE_DRIVER_SERVICE_TOKEN` must match the token used by driver Firebase
  Functions when posting delivery attempt and queue sync events to Medusa.
- Address Line 2 must be available to the label subscriber from
  `shipping_address.address_2` first, then metadata fallbacks
  `address_line_2`, `delivery_address_line_2`, `checkout_address_line_2`, or
  `customer_address_line_2`.
- The label-printer agent and Medusa subscriber must remain idempotent. One
  successful order should create one stable label print job; duplicate webhook,
  subscriber, or retry paths must not print duplicate physical labels.
