set shell := ["bash", "-uc"]

default:
    @just --list

install:
    uv sync --frozen

dev:
    uv run python -m app

test:
    uv run pytest

lint:
    uv run ruff check . && uv run ruff format --check .
    uv run pyright

fmt:
    uv run ruff check --fix . && uv run ruff format .

docker-build:
    docker build -t <PROJECT_NAME> .

docker-run:
    docker run --rm --env-file .env <PROJECT_NAME>

deploy:
    just test
    railway up

logs:
    railway logs --json | jq -r '.message // .'

hooks-install:
    scripts/install-hooks.sh

# Supply-chain audits ------------------------------------------------------

# Lockfile + source scans (gitleaks + semgrep). No image scanning.
audit:
    scripts/audit-all.sh

# Above + Trivy on digest-pinned bases (HIGH/CRITICAL gate).
audit-images:
    scripts/audit-all.sh --with-images

# Above, but Trivy findings are advisory (used in scheduled CI).
audit-images-informational:
    scripts/audit-all.sh --with-images-informational

# Audited dependency operations — never bare `uv add`.
safe-uv +args:
    scripts/safe-uv.sh {{args}}

# SBOM for the built image (optional artifact).
sbom:
    syft scan dir:. -o spdx-json > sbom.json
