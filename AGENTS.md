# Project: <PROJECT_NAME>

## Current Phase

REQUIREMENTS

## Last Action

Project created from template-py-batch.

## Next Action

Fill out `REQUIREMENTS.md`, then run prompts/01-requirements-review.md.

## Open Decisions

- [ ] Schedule: cron via Railway, or invoked manually?
- [ ] State store: filesystem (no), Postgres (yes), S3 (yes)?
- [ ] Sentry project created?

## Tech Stack (locked)

- Python 3.14, uv, ruff, pyright
- Container: cgr.dev/chainguard/python
- Deploy: Railway (cron job or one-off)
- Observability: structlog, Sentry

## Conventions

- Same as template-py-web (main only, no PRs, ADRs in `docs/adr/`)
