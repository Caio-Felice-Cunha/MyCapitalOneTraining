"""Data-integrity tests for the Scenario-01 dataset.

The original repo shipped CSVs whose contents disagreed with the MySQL seed in
docker/mysql/init.sql (same IDs, different values). These tests pin the two
sources together so they cannot silently drift again, and assert the basic
referential integrity an analyst would assume when answering the drills.

Run from the repo root:

    pytest -q
"""

from __future__ import annotations

import csv
import sys
from pathlib import Path

import pandas as pd
import pytest

REPO_ROOT = Path(__file__).resolve().parents[1]
RAW = REPO_ROOT / "data" / "raw"

sys.path.insert(0, str(REPO_ROOT / "scripts"))
import export_csvs  # noqa: E402  (import after sys.path tweak)


EXPECTED_ROW_COUNTS = {
    "customers": 30,
    "products": 12,
    "subscriptions": 60,
    "payments": 90,
}


@pytest.fixture(scope="module")
def frames() -> dict[str, pd.DataFrame]:
    return {
        "customers": pd.read_csv(RAW / "customers.csv"),
        "products": pd.read_csv(RAW / "products.csv"),
        "subscriptions": pd.read_csv(RAW / "subscriptions.csv"),
        "payments": pd.read_csv(RAW / "payments.csv"),
    }


@pytest.mark.parametrize("table, count", EXPECTED_ROW_COUNTS.items())
def test_row_counts(frames, table, count):
    assert len(frames[table]) == count


def test_primary_keys_unique(frames):
    assert frames["customers"]["customer_id"].is_unique
    assert frames["products"]["product_id"].is_unique
    assert frames["subscriptions"]["subscription_id"].is_unique
    assert frames["payments"]["payment_id"].is_unique


def test_no_orphan_foreign_keys(frames):
    cust = set(frames["customers"]["customer_id"])
    prod = set(frames["products"]["product_id"])
    subs = set(frames["subscriptions"]["subscription_id"])

    sub_cust = set(frames["subscriptions"]["customer_id"])
    sub_prod = set(frames["subscriptions"]["product_id"])
    pay_sub = set(frames["payments"]["subscription_id"])

    assert sub_cust <= cust, f"subscriptions reference unknown customers: {sub_cust - cust}"
    assert sub_prod <= prod, f"subscriptions reference unknown products: {sub_prod - prod}"
    assert pay_sub <= subs, f"payments reference unknown subscriptions: {pay_sub - subs}"


def test_active_subscriptions_have_no_end_date(frames):
    subs = frames["subscriptions"]
    active = subs[subs["status"] == "active"]
    assert active["end_date"].isna().all()


def test_cancelled_subscriptions_have_end_date(frames):
    subs = frames["subscriptions"]
    cancelled = subs[subs["status"] == "cancelled"]
    assert cancelled["end_date"].notna().all()


def test_csvs_match_init_sql():
    """The CSVs must equal what scripts/export_csvs.py produces from init.sql.

    This is the regression guard for the original CSV-vs-MySQL divergence.
    """
    sql_text = export_csvs.INIT_SQL.read_text(encoding="utf-8")
    for table, header in export_csvs.TABLES.items():
        expected_rows = export_csvs.extract_rows(sql_text, table)
        with (RAW / f"{table}.csv").open(newline="", encoding="utf-8") as handle:
            reader = csv.reader(handle)
            actual_header = next(reader)
            actual_rows = list(reader)
        assert actual_header == header, f"{table}: header mismatch"
        assert actual_rows == expected_rows, (
            f"{table}: CSV does not match init.sql. "
            "Run `python scripts/export_csvs.py` to regenerate."
        )
