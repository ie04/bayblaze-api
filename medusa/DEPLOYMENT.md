# BayBlaze Embedded Medusa Deployment

Medusa is no longer deployed from a standalone `bayblaze-medusa` runtime
checkout. The source and production runtime are both owned by `bayblaze-api`.

## Production Runtime

The VPS runtime directory is:

```bash
/opt/bayblaze/bayblaze-api
```

The production Compose file is:

```bash
/opt/bayblaze/bayblaze-api/docker-compose.prod.yml
```

That single Compose project runs:

- Caddy for `api.bayblaze.net`
- `bayblaze-api` on port `3040`
- embedded `medusa` on port `9000` inside the Compose network
- Postgres
- Redis

`api.bayblaze.net/v1/*` is routed by Caddy to `bayblaze-api`; all other
commerce/admin traffic is routed to embedded Medusa.

## Environment

Use one production env file:

```bash
/opt/bayblaze/bayblaze-api/.env.production
```

It must include both API and Medusa runtime variables, including
`DATABASE_URL`, `POSTGRES_PASSWORD`, `JWT_SECRET`, `COOKIE_SECRET`,
`BAYBLAZE_MEDUSA_SERVICE_TOKEN`, `LABEL_PRINTER_AGENT_URL`, and
`LABEL_PRINTER_AGENT_TOKEN`.

## Data Continuity

The consolidated Compose project intentionally reuses the old named Docker
volumes:

```text
medusa_postgres_data
medusa_redis_data
medusa_caddy_data
medusa_caddy_config
```

This keeps the existing Medusa database, Redis data, and Caddy state while
moving service ownership into the `bayblaze-api` deployment.

Medusa upload files are mounted from:

```bash
/opt/bayblaze/bayblaze-api/medusa/uploads
```

## Deploy

Pushes to `bayblaze-api/main` run `.github/workflows/deploy.yml` on the
`bayblaze-api` self-hosted runner. The workflow syncs the release to
`/opt/bayblaze/bayblaze-api`, stops the legacy standalone Medusa compose
project if `/opt/bayblaze/medusa` still exists, builds API and embedded Medusa
images, runs Medusa migrations, and recreates the consolidated runtime.

Manual equivalent:

```bash
cd /opt/bayblaze/bayblaze-api
docker compose -p bayblaze-api -f docker-compose.prod.yml build
docker compose -p bayblaze-api -f docker-compose.prod.yml run --rm medusa npx medusa db:migrate
docker compose -p bayblaze-api -f docker-compose.prod.yml up -d --remove-orphans
```
