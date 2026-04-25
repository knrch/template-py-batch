# ADR 0001: Tech stack (batch)

- **Status**: Accepted
- **Date**: 2026-04-25

## Context

Single-developer batch workloads, deployed to Railway as cron or one-off.

## Decision

- Python 3.14, uv, ruff, pyright
- structlog → JSON, sentry-sdk
- Chainguard images
- Railway cron service for scheduling

## Consequences

Same single-dev tradeoffs as `template-py-web`. No web framework
dependency keeps the image small and the surface area minimal.
