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
    lefthook install

sbom:
    syft scan dir:. -o spdx-json > sbom.json

verify-images:
    cosign verify cgr.dev/chainguard/python --certificate-identity-regexp '.*chainguard.*' --certificate-oidc-issuer-regexp '.*'
