# Bayblaze Medusa Deployment

Production target:

- `api.bayblaze.net` -> Caddy -> Medusa, except `/v1/*` routes to
  `bayblaze-api`
- Postgres and Redis run on the same server through Docker Compose.

## Files

- `Dockerfile` builds the Medusa backend from `apps/backend`.
- `docker-compose.prod.yml` runs Caddy, Medusa, Postgres, and Redis.
- `deploy/Caddyfile` routes `api.bayblaze.net` to Medusa and proxies `/v1/*`
  to `bayblaze-api:3040` on external Docker network `bayblaze-api_default`.
- `.env.production.example` documents required production environment values.

## Server Directory

On the server, this project lives at:

```bash
/opt/bayblaze/medusa
```

## First Deploy

Copy the project to the server, create `.env.production`, then run:

```bash
docker compose -f docker-compose.prod.yml build
docker compose -f docker-compose.prod.yml run --rm medusa npx medusa db:migrate
docker compose -f docker-compose.prod.yml up -d
```

Medusa Admin will be available at:

```text
https://api.bayblaze.net/app
```

The Store API will be available at:

```text
https://api.bayblaze.net/store
```

## Automatic Deploys

Pushes to `main` run `.github/workflows/deploy-vps.yml` on the self-hosted
GitHub Actions runner installed on the VPS. The workflow resets
`/opt/bayblaze/medusa` to `origin/main`, rebuilds the Medusa image, runs
database migrations, and recreates the Docker Compose stack.

Runner details:

- Runner name: `bayblaze-vps`
- Runner install directory: `/opt/github-runners/bayblaze-medusa`
- App checkout/deploy directory: `/opt/bayblaze/medusa`
- Runner labels currently used by the workflow: `self-hosted`, `Linux`, `X64`

The runner user must be able to run `git` and `docker compose` in the deploy
directory.
