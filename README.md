# <PROJECT_NAME>

Batch process generated from `template-py-batch`.

## Stack

Python 3.14, uv, ruff, pyright, structlog, sentry-sdk. Multi-stage
Dockerfile on digest-pinned `python:3.14-slim`. Deploys to Railway as
a cron or one-off service.

Security toolchain (mandatory): gitleaks, semgrep, osv-scanner,
pip-audit, trivy — orchestrated by `scripts/audit-all.sh` and gated by
`scripts/safe-uv.sh` on every dependency change.

## Get started

```bash
./bootstrap.sh <project-name>
cp .env.example .env
uv sync
just hooks-install   # wires pre-commit; prints missing audit tools

# Resolve digest placeholders in Dockerfile, docker-compose.yml,
# and scripts/audit-all.sh before the first build:
docker pull python:3.14-slim
docker inspect --format='{{index .RepoDigests 0}}' python:3.14-slim
# ...and repeat for each PIN_ME_AT_BOOTSTRAP entry.

uv run python -m app
```

## Daily

| Action | Command |
|---|---|
| Run | `just dev` |
| Test | `just test` |
| Lint | `just lint` |
| Format | `just fmt` |
| Audit (lockfile + source) | `just audit` |
| Audit incl. Trivy on images | `just audit-images` |
| Add a dep (audited) | `just safe-uv add <pkg>` |
| Build image | `just docker-build` |
| Run image | `just docker-run` |
| Deploy | `just deploy` |
| Tail logs | `just logs` |

## Pre-commit bypass envs (emergency only)

| Env | Effect |
|---|---|
| `SKIP_STATIC_SCAN=1` | Skip gitleaks + semgrep |
| `SKIP_GITLEAKS=1` | Skip gitleaks only |
| `SKIP_SEMGREP=1` | Skip semgrep only |
| `SKIP_AUDIT=1` | Skip `scripts/audit-all.sh` block only |

If a bypass becomes routine, fix the allowlist (`.gitleaks.toml`,
`.semgrepignore`, `.trivyignore`) — don't accumulate bypass habits.

## Workflow

15-step cycle in `.cursor/rules/00-workflow.mdc`. Track phase in
`AGENTS.md`. Branch policy: main only.

## Layout

```
src/app/         entrypoint and modules
tests/           pytest + hypothesis
Dockerfile       multi-stage, digest-pinned python:3.14-slim
docker-compose.yml  local dev only
scripts/         _lib.sh, _static_scan.sh, audit-all.sh, safe-uv.sh,
                 install-hooks.sh, git-hooks/pre-commit
.gitleaks.toml   secret-scan allowlist
.semgrepignore   semgrep traversal exclusions
.trivyignore     accepted CVEs (each with reason + re-check date)
deploy/          fly.toml.example escape hatch
docs/            Security.md, Deployment.md, adr/
.cursor/         rules + prompts (synced from cursor-harness)
```

## When to switch to template-py-cron

If your job is a lightweight scheduled task (daily digest emails,
cache refreshes, RSS pulls) consider `template-py-cron` instead. It
ships the GitHub-Actions-only pattern out of the box (no Docker, no
Railway, no compose), with the same audit harness. Switch the moment
you realize you're going to delete Docker / Railway from this
template anyway.

If you want to keep this template but strip it down in place, the
manual steps are below.

## Stripping down to a minimal mode (in place)

To run this on GitHub Actions only and skip Docker + Railway:

1. Delete `Dockerfile`, `docker-compose.yml`, `railway.toml`,
   `deploy/`.
2. Replace `.github/workflows/ci.yml` with a single scheduled workflow
   (template below).
3. If you persist state across runs (e.g. a dedup store) commit it
   back at the end of the run with `[skip ci]` to avoid loops.

Example `.github/workflows/run.yml`:

```yaml
name: Run
on:
  schedule:
    - cron: '0 21 * * *'   # daily 21:00 UTC
  workflow_dispatch:
permissions:
  contents: write   # required to commit state back
jobs:
  run:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    steps:
      - uses: actions/checkout@v5
      - uses: astral-sh/setup-uv@v6
      - uses: actions/setup-python@v5
        with:
          python-version: '3.14'
      - run: uv sync --frozen
      - run: uv run python -m app
        env:
          SOME_API_KEY: ${{ secrets.SOME_API_KEY }}
      - name: Commit state
        run: |
          git config user.name 'github-actions[bot]'
          git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
          if [[ -n "$(git status --porcelain data/)" ]]; then
            git add data/
            git commit -m 'chore: persist run state [skip ci]'
            git push
          fi
```

The audit pipeline (`scripts/audit-all.sh`, gitleaks/semgrep hooks,
safe-uv.sh) still applies in minimal mode — only the deployment shape
changes.
