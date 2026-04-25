# syntax=docker/dockerfile:1.7
FROM cgr.dev/chainguard/python:latest-dev AS builder
WORKDIR /app
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PROJECT_ENVIRONMENT=/app/.venv

COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-install-project --no-dev
COPY . .
RUN uv sync --frozen --no-dev

FROM cgr.dev/chainguard/python:latest
WORKDIR /app
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1
COPY --from=builder /app /app
ENTRYPOINT ["/app/.venv/bin/python", "-m", "app"]
