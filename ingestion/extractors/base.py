"""Base extractor — shared load logic for all source systems."""

from __future__ import annotations
import logging
from typing import Any
from pydantic import BaseModel
from ingestion.utils.snowflake_client import get_connection, upsert_rows, bulk_insert

logger = logging.getLogger(__name__)


class BaseExtractor:
    """
    Subclass this for each source.
    Implementors must define `extract()` which returns a dict of
    table_name -> list[BaseModel].
    """

    source_name: str = "unknown"

    def extract(self) -> dict[str, list[BaseModel]]:
        raise NotImplementedError

    def load(self, data: dict[str, list[BaseModel]], append_only_tables: set[str] | None = None) -> dict[str, int]:
        append_only_tables = append_only_tables or set()
        counts: dict[str, int] = {}

        conn = get_connection()
        try:
            for table, records in data.items():
                if not records:
                    logger.info("No records for %s — skipping", table)
                    counts[table] = 0
                    continue

                rows = [r.model_dump() for r in records]
                # Uppercase keys to match Snowflake column names
                rows = [{k.upper(): v for k, v in row.items()} for row in rows]

                if table in append_only_tables:
                    n = bulk_insert(conn, table, rows)
                else:
                    n = upsert_rows(conn, table, rows)

                counts[table] = n
                logger.info("Loaded %d rows into %s", n, table)
        finally:
            conn.close()

        return counts

    def run(self, append_only_tables: set[str] | None = None) -> dict[str, int]:
        logger.info("Starting extraction: %s", self.source_name)
        data = self.extract()
        counts = self.load(data, append_only_tables)
        logger.info("Completed extraction: %s — %s", self.source_name, counts)
        return counts
