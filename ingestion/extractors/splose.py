"""Splose extractor — reads from Snowflake RAW tables seeded by the generator."""

from __future__ import annotations
import logging
from ingestion.extractors.base import BaseExtractor

logger = logging.getLogger(__name__)


class SplosExtractor(BaseExtractor):
    """
    In a real integration this would call api.splose.com/v1.
    Here it reads from the seeder-populated RAW tables.
    In production: replace with HTTP calls using cursor-based pagination
    (id_gt / update_gt parameters) for incremental loads.
    """

    source_name = "splose"

    def extract(self) -> dict:
        logger.info("Splose extractor: data pre-loaded by seeder — no-op.")
        return {}

    def run(self, append_only_tables=None):
        logger.info("Splose data loaded via seeder pipeline.")
        return {}
