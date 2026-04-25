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
command -v lefthook >/dev/null && lefthook install
command -v mise >/dev/null && mise install
uv sync

cat <<EOF

Bootstrap complete: $NAME

Next:
  1. Edit REQUIREMENTS.md
  2. cp .env.example .env
  3. uv run python -m app
  4. gh repo create knrch/$NAME --source=. --private --push
EOF
