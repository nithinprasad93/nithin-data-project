"""Snowflake connection and bulk-load utilities."""

import os
import json
from typing import Any
import snowflake.connector


def get_connection() -> snowflake.connector.SnowflakeConnection:
    return snowflake.connector.connect(
        account=os.environ["SNOWFLAKE_ACCOUNT"],
        user=os.environ["SNOWFLAKE_USER"],
        password=os.environ["SNOWFLAKE_PASSWORD"],
        role=os.environ.get("SNOWFLAKE_ROLE", "NDIS_LOADER"),
        warehouse=os.environ.get("SNOWFLAKE_WAREHOUSE", "NDIS_WH"),
        database=os.environ.get("SNOWFLAKE_DATABASE", "NDIS_DB"),
        schema=os.environ.get("SNOWFLAKE_SCHEMA", "RAW"),
    )


def _build_placeholders(row: dict[str, Any]) -> tuple[str, tuple]:
    """
    Return (placeholder_sql, values_tuple) for a single row.
    VARIANT columns (dicts/lists) use PARSE_JSON(%s), scalars use %s.
    """
    parts = []
    values = []
    for v in row.values():
        if isinstance(v, (dict, list)):
            parts.append("PARSE_JSON(%s)")
            values.append(json.dumps(v))
        else:
            parts.append("%s")
            values.append(v)
    return ", ".join(parts), tuple(values)


def upsert_rows(
    conn: snowflake.connector.SnowflakeConnection,
    table: str,
    rows: list[dict[str, Any]],
    id_column: str = "ID",
) -> int:
    """Insert rows; skip duplicates based on id_column."""
    if not rows:
        return 0

    col_list = ", ".join(rows[0].keys())

    with conn.cursor() as cur:
        for row in rows:
            placeholders, values = _build_placeholders(row)
            sql = f"""
                INSERT INTO {table} ({col_list})
                SELECT {col_list} FROM (SELECT {placeholders}) AS src({col_list})
                WHERE NOT EXISTS (
                    SELECT 1 FROM {table} t WHERE t.{id_column} = src.{id_column}
                )
            """
            cur.execute(sql, values)

    return len(rows)


def bulk_insert(
    conn: snowflake.connector.SnowflakeConnection,
    table: str,
    rows: list[dict[str, Any]],
) -> int:
    """Append-only insert — no dedup check."""
    if not rows:
        return 0

    col_list = ", ".join(rows[0].keys())

    with conn.cursor() as cur:
        for row in rows:
            placeholders, values = _build_placeholders(row)
            sql = f"INSERT INTO {table} ({col_list}) SELECT {placeholders}"
            cur.execute(sql, values)

    return len(rows)
