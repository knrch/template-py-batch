"""Shared fixtures."""
import pytest


@pytest.fixture
def example_value() -> int:
    return 42
