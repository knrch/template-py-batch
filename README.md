# <PROJECT_NAME>

Batch process generated from `template-py-batch`.

## Stack

Python 3.14, uv, ruff, pyright, structlog, sentry-sdk. Chainguard
container. Deploys to Railway as a cron or one-off service.

## Get started

```bash
./bootstrap.sh <project-name>
cp .env.example .env
uv sync
uv run python -m app
```

## Daily

| Action | Command |
|---|---|
| Run | `just dev` |
| Test | `just test` |
| Lint | `just lint` |
| Format | `just fmt` |
| Build image | `just docker-build` |
| Run image | `just docker-run` |
| Deploy | `just deploy` |
| Tail logs | `just logs` |

## Workflow

15-step cycle in `.cursor/rules/00-workflow.mdc`. Track phase in
`AGENTS.md`. Branch policy: main only.

## Layout

```
src/app/         entrypoint and modules
tests/           pytest + hypothesis
Dockerfile       multi-stage Chainguard
deploy/          fly.toml.example escape hatch
.cursor/         rules + prompts (synced from cursor-harness)
docs/adr/        decision records
```
