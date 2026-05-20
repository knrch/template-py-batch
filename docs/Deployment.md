# Deployment — <PROJECT_NAME>

Railway is the default target. A minimal GitHub-Actions-only mode is
also supported (see the README).

## Railway (default)

### Initial setup

```bash
railway login
railway init      # creates the project
railway link      # links this directory to it
```

### Env vars (set via CLI for audit trail)

```bash
railway variables --set DATABASE_URL=...
railway variables --set SENTRY_DSN=...
railway variables --set LOG_LEVEL=INFO
```

Never set via the dashboard — there's no diff history.

### Deploy

```bash
just deploy   # runs tests, then `railway up`
```

`railway.toml` declares the build (Dockerfile) and the deploy policy
(`restartPolicyType = "NEVER"` for a one-off; configure a cron service
for scheduled runs).

### Cron service

Add to `railway.toml`:

```toml
[[services]]
name = "<PROJECT_NAME>-cron"
cron = "0 3 * * *"   # daily at 03:00 UTC
```

Or configure in the Railway dashboard if cron syntax is changing
often; document the schedule here either way.

### Rollback

```bash
railway redeploy --previous
```

Rolls to the prior deployment within seconds.

## Minimal cron mode (GitHub Actions only)

For lightweight scheduled jobs with no live HTTP surface, you can
skip Docker + Railway entirely. See README → "Minimal cron mode" for
the workflow template.

When this fits:
- Daily / hourly batch with bounded runtime (≤ Actions free-tier
  limits)
- State is small enough to commit back to the repo with `[skip ci]`
- No live HTTP endpoint needed

When this doesn't fit:
- Long-running jobs (> 6h in a single invocation)
- State larger than ~10 MB
- Webhooks / event-triggered work outside cron

## Logs

- Railway: `railway logs --json | jq 'select(.level=="ERROR")'`
- GitHub Actions: the workflow run UI

`just logs` wraps the Railway tail.

## Healthchecks

A batch job typically doesn't expose `/health` (no live server). If
yours does (long-running consumer), wire it into Railway:

```toml
[deploy]
healthcheckPath = "/health"
healthcheckTimeout = 30
```

## Migrations

If the batch needs a DB:

```toml
[deploy]
preDeployCommand = "alembic upgrade head"
```

Deploy aborts if migrations fail.
