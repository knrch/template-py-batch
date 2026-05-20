#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <project-name>" >&2
    exit 1
fi
NAME="$1"

find . -type f \( -name '*.md' -o -name '*.toml' -o -name '*.json' -o -name '*.yml' -o -name '*.yaml' -o -name 'justfile' -o -name 'Dockerfile' \) \
    -not -path './.git/*' -not -path './.venv/*' \
    -exec sed -i.bak "s/<PROJECT_NAME>/$NAME/g" {} \;
find . -name '*.bak' -delete

[[ -d .git ]] || git init -b main
command -v mise >/dev/null && mise install
uv sync
./scripts/install-hooks.sh || true

cat <<EOF

Bootstrap complete: $NAME

Resolve digest placeholders before the first \`just docker-build\`:

  docker pull python:3.14-slim
  docker inspect --format='{{index .RepoDigests 0}}' python:3.14-slim
  docker pull ghcr.io/astral-sh/uv:0.11.8
  docker inspect --format='{{index .RepoDigests 0}}' ghcr.io/astral-sh/uv:0.11.8
  docker pull postgres:16-alpine
  docker inspect --format='{{index .RepoDigests 0}}' postgres:16-alpine

Then substitute each PIN_ME_AT_BOOTSTRAP literal in:
  - Dockerfile
  - docker-compose.yml
  - scripts/audit-all.sh   (RUNTIME_IMAGES + UV_IMAGE)

The three locations must agree.

Next:
  1. Edit REQUIREMENTS.md
  2. cp .env.example .env
  3. just hooks-install    (verify audit tools are on PATH)
  4. uv run python -m app
  5. gh repo create knrch/$NAME --source=. --private --push
EOF
