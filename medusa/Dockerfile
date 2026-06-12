# syntax=docker/dockerfile:1.7

FROM node:20-bookworm-slim AS builder

WORKDIR /app
ENV CI=true

COPY package.json package-lock.json turbo.json ./
COPY apps/backend/package.json apps/backend/package.json
COPY apps/label-printer-agent/package.json apps/label-printer-agent/package.json

RUN printf "auto-install-peers=true\n" > .npmrc

RUN --mount=type=cache,target=/root/.npm \
  npm ci \
    --workspace @dtc/backend \
    --include-workspace-root=false \
    --prefer-offline \
    --no-audit \
    --fund=false

COPY apps/backend apps/backend

RUN NODE_OPTIONS=--max-old-space-size=1536 npm run build -w @dtc/backend

FROM node:20-bookworm-slim AS runner

WORKDIR /app
ENV NODE_ENV=production

RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

COPY package-lock.json ./
COPY --from=builder /app/apps/backend/.medusa/server ./
COPY --from=builder /app/apps/backend/static ./static

RUN --mount=type=cache,target=/root/.npm \
  npm install \
    --omit=dev \
    --legacy-peer-deps \
    --prefer-offline \
    --no-audit \
    --fund=false

EXPOSE 9000

CMD ["npx", "medusa", "start", "--host", "0.0.0.0"]
