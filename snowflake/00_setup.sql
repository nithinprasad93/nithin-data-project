-- =============================================================
-- Snowflake Setup — NDIS Allied Health Data Platform
-- Run this once as ACCOUNTADMIN to bootstrap the environment
-- =============================================================

USE ROLE ACCOUNTADMIN;

-- ---------------------------------------------------------------
-- 1. Virtual Warehouse
--    XS + auto-suspend after 60s to protect free trial credits
-- ---------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS NDIS_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Primary warehouse for NDIS data platform';

-- ---------------------------------------------------------------
-- 2. Resource Monitor — alert at $10, suspend at $20
-- ---------------------------------------------------------------
CREATE RESOURCE MONITOR IF NOT EXISTS NDIS_MONITOR
    WITH CREDIT_QUOTA = 20
    FREQUENCY = MONTHLY
    START_TIMESTAMP = IMMEDIATELY
    TRIGGERS
        ON 50 PERCENT DO NOTIFY
        ON 80 PERCENT DO NOTIFY
        ON 100 PERCENT DO SUSPEND;

ALTER WAREHOUSE NDIS_WH SET RESOURCE_MONITOR = NDIS_MONITOR;

-- ---------------------------------------------------------------
-- 3. Database
-- ---------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS NDIS_DB
    COMMENT = 'NDIS Allied Health data platform';

-- ---------------------------------------------------------------
-- 4. Schemas (Medallion layers)
-- ---------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS NDIS_DB.RAW
    COMMENT = 'Bronze — raw ingested data, exact replica of source API responses';

CREATE SCHEMA IF NOT EXISTS NDIS_DB.STAGING
    COMMENT = 'Silver — cleaned, typed, deduplicated models';

CREATE SCHEMA IF NOT EXISTS NDIS_DB.INTERMEDIATE
    COMMENT = 'Silver — business logic joins and enrichment';

CREATE SCHEMA IF NOT EXISTS NDIS_DB.MARTS
    COMMENT = 'Gold — Kimball dimensional model (facts and dims)';

CREATE SCHEMA IF NOT EXISTS NDIS_DB.SEEDS
    COMMENT = 'dbt seed reference data (NDIS support catalogue, etc.)';

-- ---------------------------------------------------------------
-- 5. Roles
-- ---------------------------------------------------------------
CREATE ROLE IF NOT EXISTS NDIS_LOADER
    COMMENT = 'Used by Python ingestion scripts to write raw data';

CREATE ROLE IF NOT EXISTS NDIS_TRANSFORMER
    COMMENT = 'Used by dbt to read raw and write staging/marts';

CREATE ROLE IF NOT EXISTS NDIS_REPORTER
    COMMENT = 'Read-only access to marts for Evidence.dev';

-- ---------------------------------------------------------------
-- 6. Role hierarchy
-- ---------------------------------------------------------------
GRANT ROLE NDIS_LOADER      TO ROLE SYSADMIN;
GRANT ROLE NDIS_TRANSFORMER TO ROLE SYSADMIN;
GRANT ROLE NDIS_REPORTER    TO ROLE SYSADMIN;

-- ---------------------------------------------------------------
-- 7. Warehouse access
-- ---------------------------------------------------------------
GRANT USAGE ON WAREHOUSE NDIS_WH TO ROLE NDIS_LOADER;
GRANT USAGE ON WAREHOUSE NDIS_WH TO ROLE NDIS_TRANSFORMER;
GRANT USAGE ON WAREHOUSE NDIS_WH TO ROLE NDIS_REPORTER;

-- ---------------------------------------------------------------
-- 8. Database + schema access per role
-- ---------------------------------------------------------------

-- LOADER: write to RAW only
GRANT USAGE ON DATABASE NDIS_DB TO ROLE NDIS_LOADER;
GRANT USAGE ON SCHEMA NDIS_DB.RAW TO ROLE NDIS_LOADER;
GRANT CREATE TABLE, CREATE STAGE ON SCHEMA NDIS_DB.RAW TO ROLE NDIS_LOADER;
GRANT INSERT, UPDATE ON FUTURE TABLES IN SCHEMA NDIS_DB.RAW TO ROLE NDIS_LOADER;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA NDIS_DB.RAW TO ROLE NDIS_LOADER;

-- TRANSFORMER: read RAW, write STAGING / INTERMEDIATE / MARTS / SEEDS
GRANT USAGE ON DATABASE NDIS_DB TO ROLE NDIS_TRANSFORMER;
GRANT USAGE ON SCHEMA NDIS_DB.RAW         TO ROLE NDIS_TRANSFORMER;
GRANT USAGE ON SCHEMA NDIS_DB.STAGING     TO ROLE NDIS_TRANSFORMER;
GRANT USAGE ON SCHEMA NDIS_DB.INTERMEDIATE TO ROLE NDIS_TRANSFORMER;
GRANT USAGE ON SCHEMA NDIS_DB.MARTS       TO ROLE NDIS_TRANSFORMER;
GRANT USAGE ON SCHEMA NDIS_DB.SEEDS       TO ROLE NDIS_TRANSFORMER;

GRANT SELECT ON ALL TABLES IN SCHEMA NDIS_DB.RAW TO ROLE NDIS_TRANSFORMER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA NDIS_DB.STAGING      TO ROLE NDIS_TRANSFORMER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA NDIS_DB.INTERMEDIATE TO ROLE NDIS_TRANSFORMER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA NDIS_DB.MARTS        TO ROLE NDIS_TRANSFORMER;
GRANT CREATE TABLE, CREATE VIEW ON SCHEMA NDIS_DB.SEEDS        TO ROLE NDIS_TRANSFORMER;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA NDIS_DB.STAGING      TO ROLE NDIS_TRANSFORMER;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA NDIS_DB.INTERMEDIATE TO ROLE NDIS_TRANSFORMER;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA NDIS_DB.MARTS        TO ROLE NDIS_TRANSFORMER;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON FUTURE TABLES IN SCHEMA NDIS_DB.SEEDS        TO ROLE NDIS_TRANSFORMER;

GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA NDIS_DB.STAGING      TO ROLE NDIS_TRANSFORMER;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA NDIS_DB.INTERMEDIATE TO ROLE NDIS_TRANSFORMER;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA NDIS_DB.MARTS        TO ROLE NDIS_TRANSFORMER;
GRANT INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA NDIS_DB.SEEDS        TO ROLE NDIS_TRANSFORMER;

-- REPORTER: read MARTS only
GRANT USAGE ON DATABASE NDIS_DB TO ROLE NDIS_REPORTER;
GRANT USAGE ON SCHEMA NDIS_DB.MARTS TO ROLE NDIS_REPORTER;
GRANT SELECT ON ALL TABLES IN SCHEMA NDIS_DB.MARTS TO ROLE NDIS_REPORTER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA NDIS_DB.MARTS TO ROLE NDIS_REPORTER;

-- ---------------------------------------------------------------
-- 9. Service accounts (users)
--    Replace <STRONG_PASSWORD> with real values before running
-- ---------------------------------------------------------------
CREATE USER IF NOT EXISTS SVC_LOADER
    PASSWORD = '<STRONG_PASSWORD_LOADER>'
    DEFAULT_ROLE = NDIS_LOADER
    DEFAULT_WAREHOUSE = NDIS_WH
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Service account for Python ingestion / seeder';

CREATE USER IF NOT EXISTS SVC_TRANSFORMER
    PASSWORD = '<STRONG_PASSWORD_TRANSFORMER>'
    DEFAULT_ROLE = NDIS_TRANSFORMER
    DEFAULT_WAREHOUSE = NDIS_WH
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Service account for dbt Core';

CREATE USER IF NOT EXISTS SVC_REPORTER
    PASSWORD = '<STRONG_PASSWORD_REPORTER>'
    DEFAULT_ROLE = NDIS_REPORTER
    DEFAULT_WAREHOUSE = NDIS_WH
    MUST_CHANGE_PASSWORD = FALSE
    COMMENT = 'Service account for Evidence.dev';

GRANT ROLE NDIS_LOADER      TO USER SVC_LOADER;
GRANT ROLE NDIS_TRANSFORMER TO USER SVC_TRANSFORMER;
GRANT ROLE NDIS_REPORTER    TO USER SVC_REPORTER;

-- ---------------------------------------------------------------
-- 10. Future grants — ensures new tables are auto-accessible
-- ---------------------------------------------------------------
GRANT SELECT ON FUTURE TABLES IN SCHEMA NDIS_DB.RAW         TO ROLE NDIS_TRANSFORMER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA NDIS_DB.STAGING     TO ROLE NDIS_REPORTER;
GRANT SELECT ON FUTURE TABLES IN SCHEMA NDIS_DB.MARTS       TO ROLE NDIS_REPORTER;
