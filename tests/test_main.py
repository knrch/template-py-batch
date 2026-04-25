"""Smoke test for batch entrypoint."""
from __future__ import annotations

from app.__main__ import run_batch


def test_run_batch_does_not_raise() -> None:
    run_batch()
