# Project: <PROJECT_NAME>

## Current Phase

REQUIREMENTS

## Last Action

Project created from template-py-batch.

## Next Action

Fill out `REQUIREMENTS.md`, then run prompts/01-requirements-review.md.

## Open Decisions

- [ ] Schedule: cron via Railway, or invoked manually?
- [ ] State store: filesystem (no), Postgres (yes), S3 (yes), GitHub-
      committed JSON (minimal mode)?
- [ ] Deployment shape: Docker + Railway, or minimal GitHub-Actions-only
      mode (see README.md → "Minimal cron mode")?
- [ ] Sentry project created?
- [ ] Digest placeholders resolved (`PIN_ME_AT_BOOTSTRAP` in
      Dockerfile / docker-compose.yml / scripts/audit-all.sh)?

## Tech Stack (locked)

- Python 3.14, uv, ruff, pyright
- Container: digest-pinned `python:3.14-slim` (no Chainguard)
- Audit: gitleaks + semgrep + osv-scanner + pip-audit + trivy via
  `scripts/audit-all.sh`; dep ops via `scripts/safe-uv.sh`
- Deploy: Railway (cron job or one-off) — OR minimal GitHub-Actions
  mode for lightweight scheduled work
- Observability: structlog, Sentry

## Conventions

- Main only, no PRs, ADRs in `docs/adr/`
- Pre-commit hook lives in `scripts/git-hooks/pre-commit`; lefthook
  invokes it. Bypass envs: `SKIP_STATIC_SCAN`, `SKIP_GITLEAKS`,
  `SKIP_SEMGREP`, `SKIP_AUDIT` — emergency only
