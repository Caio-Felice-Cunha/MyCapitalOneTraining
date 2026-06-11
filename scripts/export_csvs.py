"""Regenerate the Scenario-01 CSVs from docker/mysql/init.sql.

docker/mysql/init.sql is the single source of truth for the Scenario-01
practice data. This script parses its INSERT statements and writes the four
CSVs in data/raw/ so the CSV-only workflow and the MySQL workflow always agree.

Run it after editing init.sql:

    python scripts/export_csvs.py

It writes customers.csv, products.csv, subscriptions.csv and payments.csv into
data/raw/ (comma-delimited, empty string for SQL NULL).
"""

from __future__ import annotations

import csv
import re
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
INIT_SQL = REPO_ROOT / "docker" / "mysql" / "init.sql"
RAW_DIR = REPO_ROOT / "data" / "raw"

# table name -> (column header list, regex anchor used to find its INSERT block)
TABLES = {
    "customers": ["customer_id", "country", "province_state", "signup_date", "segment"],
    "products": ["product_id", "product_name", "category", "monthly_price"],
    "subscriptions": [
        "subscription_id",
        "customer_id",
        "product_id",
        "start_date",
        "end_date",
        "status",
    ],
    "payments": ["payment_id", "subscription_id", "payment_date", "amount"],
}


def _split_tuples(block: str) -> list[str]:
    """Split a VALUES block into the text inside each top-level (...) group."""
    rows: list[str] = []
    depth = 0
    current: list[str] = []
    for char in block:
        if char == "(":
            depth += 1
            if depth == 1:
                current = []
                continue
        elif char == ")":
            depth -= 1
            if depth == 0:
                rows.append("".join(current))
                continue
        if depth >= 1:
            current.append(char)
    return rows


def _parse_value(token: str) -> str:
    """Turn a single SQL literal token into a CSV cell value."""
    token = token.strip()
    if token.upper() == "NULL":
        return ""
    if token.startswith("'") and token.endswith("'"):
        return token[1:-1]
    return token


def _parse_fields(row_text: str) -> list[str]:
    """Split one tuple's text into fields, honouring quoted commas."""
    fields: list[str] = []
    buf: list[str] = []
    in_quote = False
    for char in row_text:
        if char == "'":
            in_quote = not in_quote
            buf.append(char)
        elif char == "," and not in_quote:
            fields.append("".join(buf))
            buf = []
        else:
            buf.append(char)
    fields.append("".join(buf))
    return [_parse_value(f) for f in fields]


def extract_rows(sql_text: str, table: str) -> list[list[str]]:
    pattern = re.compile(
        rf"INSERT\s+INTO\s+{table}\b.*?VALUES(.*?);",
        re.IGNORECASE | re.DOTALL,
    )
    match = pattern.search(sql_text)
    if not match:
        raise ValueError(f"No INSERT INTO {table} found in {INIT_SQL}")
    return [_parse_fields(t) for t in _split_tuples(match.group(1))]


def main() -> None:
    sql_text = INIT_SQL.read_text(encoding="utf-8")
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    for table, header in TABLES.items():
        rows = extract_rows(sql_text, table)
        bad = [r for r in rows if len(r) != len(header)]
        if bad:
            raise ValueError(
                f"{table}: {len(bad)} row(s) do not have {len(header)} columns"
            )
        out_path = RAW_DIR / f"{table}.csv"
        with out_path.open("w", newline="", encoding="utf-8") as handle:
            writer = csv.writer(handle)
            writer.writerow(header)
            writer.writerows(rows)
        print(f"wrote {out_path.relative_to(REPO_ROOT)} ({len(rows)} rows)")


if __name__ == "__main__":
    main()
