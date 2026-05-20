# ADR 0001: Tech stack (batch)

- **Status**: Accepted
- **Date**: 2026-04-25 (initial); 2026-05-20 (revised — removed
  Chainguard, added audit toolchain)

## Context

Single-developer batch workloads, deployed to Railway as cron or
one-off — or, for lightweight schedules, as a GitHub-Actions cron
workflow with no container (see README → "Minimal cron mode").

## Decision

- Python 3.14, uv, ruff, pyright
- structlog → JSON, sentry-sdk
- Container: digest-pinned `python:3.14-slim` (no Chainguard, no
  cosign)
- Audit: gitleaks + semgrep + osv-scanner + pip-audit + trivy via
  `scripts/audit-all.sh`; deps gated by `scripts/safe-uv.sh`
- Pre-commit: lefthook invokes `scripts/git-hooks/pre-commit`
- Deploy: Railway cron service — or minimal GitHub-Actions cron for
  lightweight schedules

## Consequences

Same single-dev tradeoffs as `template-py-web`. No web framework
dependency keeps the image small and the surface area minimal. The
minimal-cron escape hatch (no Docker, no Railway) is documented in
the README for jobs that don't need either.
