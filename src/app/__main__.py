"""Batch process entrypoint."""
from __future__ import annotations

import sys

import sentry_sdk

from app.config import get_settings
from app.logging import configure_logging, get_logger


def main() -> int:
    settings = get_settings()
    configure_logging(level=settings.log_level)
    log = get_logger(__name__)

    if settings.sentry_dsn:
        sentry_sdk.init(dsn=settings.sentry_dsn, traces_sample_rate=0.1)

    log.info("batch_start", env=settings.env)
    try:
        # TODO: replace with real batch logic
        run_batch()
    except Exception as e:  # noqa: BLE001
        log.error("batch_failed", error=str(e), exc_info=True)
        return 1
    log.info("batch_complete")
    return 0


def run_batch() -> None:
    """Implement batch logic here."""
    log = get_logger(__name__)
    log.info("batch_doing_thing", thing="placeholder")


if __name__ == "__main__":
    sys.exit(main())
