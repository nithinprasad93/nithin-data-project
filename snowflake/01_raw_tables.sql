-- =============================================================
-- Raw (Bronze) table definitions
-- Mirrors the shape of Employment Hero + Splose API responses
-- All columns TEXT to preserve source fidelity; dbt casts types
-- =============================================================

USE ROLE NDIS_LOADER;
USE WAREHOUSE NDIS_WH;
USE DATABASE NDIS_DB;
USE SCHEMA RAW;

-- ---------------------------------------------------------------
-- Employment Hero
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS RAW.EH_EMPLOYEES (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'employment_hero',
    ID                  TEXT,
    ORGANISATION_ID     TEXT,
    FIRST_NAME          TEXT,
    LAST_NAME           TEXT,
    EMAIL               TEXT,
    DATE_OF_BIRTH       TEXT,
    GENDER              TEXT,
    PRONOUNS            TEXT,
    PHONE               TEXT,
    ADDRESS             TEXT,
    JOB_TITLE           TEXT,
    EMPLOYMENT_TYPE     TEXT,   -- full_time, part_time, casual, contractor
    STATUS              TEXT,   -- active, terminated
    START_DATE          TEXT,
    TERMINATION_DATE    TEXT,
    PRIMARY_MANAGER_ID  TEXT,
    TEAM_ID             TEXT,
    DEPARTMENT_ID       TEXT,
    COST_CENTRE_ID      TEXT,
    EMPLOYING_ENTITY_ID TEXT,
    PAYROLL_TYPE        TEXT,
    CUSTOM_FIELDS       VARIANT, -- JSON blob for NDIS screening, discipline, AHPRA
    RAW_JSON            VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.EH_CERTIFICATIONS (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'employment_hero',
    ID                  TEXT,
    EMPLOYEE_ID         TEXT,
    ORGANISATION_ID     TEXT,
    CERTIFICATION_NAME  TEXT,
    CERTIFICATION_TYPE  TEXT,  -- ndis_screening, wwcc, first_aid, ahpra, etc.
    STATUS              TEXT,  -- active, expired, pending
    ISSUE_DATE          TEXT,
    EXPIRY_DATE         TEXT,
    NOTES               TEXT,
    RAW_JSON            VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.EH_TIMESHEET_ENTRIES (
    _LOADED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE         TEXT DEFAULT 'employment_hero',
    ID              TEXT,
    EMPLOYEE_ID     TEXT,
    ORGANISATION_ID TEXT,
    DATE            TEXT,
    START_TIME      TEXT,
    END_TIME        TEXT,
    BREAK_DURATION  TEXT,
    TOTAL_HOURS     TEXT,
    WORK_TYPE_ID    TEXT,
    WORK_LOCATION_ID TEXT,
    NOTES           TEXT,
    STATUS          TEXT,  -- pending, approved, rejected
    RAW_JSON        VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.EH_ROSTERED_SHIFTS (
    _LOADED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE         TEXT DEFAULT 'employment_hero',
    ID              TEXT,
    EMPLOYEE_ID     TEXT,
    ORGANISATION_ID TEXT,
    ROLE_ID         TEXT,
    START_TIME      TEXT,
    END_TIME        TEXT,
    BREAK_DURATION  TEXT,
    WORK_SITE_ID    TEXT,
    STATUS          TEXT,
    COST            TEXT,
    RAW_JSON        VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.EH_LEAVE_REQUESTS (
    _LOADED_AT       TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE          TEXT DEFAULT 'employment_hero',
    ID               TEXT,
    EMPLOYEE_ID      TEXT,
    ORGANISATION_ID  TEXT,
    LEAVE_CATEGORY_ID TEXT,
    LEAVE_TYPE       TEXT,  -- annual, personal, study, unpaid
    START_DATE       TEXT,
    END_DATE         TEXT,
    HOURS_REQUESTED  TEXT,
    STATUS           TEXT,  -- pending, approved, declined, cancelled
    REASON           TEXT,
    APPROVED_BY_ID   TEXT,
    RAW_JSON         VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.EH_PAYSLIPS (
    _LOADED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE         TEXT DEFAULT 'employment_hero',
    ID              TEXT,
    EMPLOYEE_ID     TEXT,
    ORGANISATION_ID TEXT,
    PAY_PERIOD_START TEXT,
    PAY_PERIOD_END   TEXT,
    GROSS_EARNINGS   TEXT,
    NET_EARNINGS     TEXT,
    TAX_WITHHELD     TEXT,
    SUPERANNUATION   TEXT,
    TOTAL_DEDUCTIONS TEXT,
    PAYMENT_DATE     TEXT,
    STATUS           TEXT,
    RAW_JSON         VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.EH_TEAMS (
    _LOADED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE         TEXT DEFAULT 'employment_hero',
    ID              TEXT,
    ORGANISATION_ID TEXT,
    NAME            TEXT,
    DESCRIPTION     TEXT,
    MANAGER_ID      TEXT,
    RAW_JSON        VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.EH_DEPARTMENTS (
    _LOADED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE         TEXT DEFAULT 'employment_hero',
    ID              TEXT,
    ORGANISATION_ID TEXT,
    NAME            TEXT,
    PARENT_ID       TEXT,
    RAW_JSON        VARIANT
);

-- ---------------------------------------------------------------
-- Splose
-- ---------------------------------------------------------------

CREATE TABLE IF NOT EXISTS RAW.SP_PATIENTS (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'splose',
    ID                  TEXT,
    FIRST_NAME          TEXT,
    LAST_NAME           TEXT,
    DATE_OF_BIRTH       TEXT,
    EMAIL               TEXT,
    PHONE               TEXT,
    ADDRESS             TEXT,
    SUBURB              TEXT,
    STATE               TEXT,
    POSTCODE            TEXT,
    NDIS_NUMBER         TEXT,
    FUND_MANAGEMENT     TEXT,  -- ndia_managed, plan_managed, self_managed
    NDIS_PLAN_START     TEXT,
    NDIS_PLAN_END       TEXT,
    DIAGNOSIS           TEXT,
    NOMINEE_NAME        TEXT,
    NOMINEE_PHONE       TEXT,
    PRIMARY_DISABILITY  TEXT,
    STATUS              TEXT,  -- active, archived
    TAGS                VARIANT,
    CUSTOM_FIELDS       VARIANT,
    RAW_JSON            VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_PRACTITIONERS (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'splose',
    ID                  TEXT,
    EH_EMPLOYEE_ID      TEXT,  -- foreign key to Employment Hero
    FIRST_NAME          TEXT,
    LAST_NAME           TEXT,
    EMAIL               TEXT,
    DISCIPLINE          TEXT,  -- OT, physio, speech_pathology, psychology, etc.
    AHPRA_NUMBER        TEXT,
    REGISTRATION_TYPE   TEXT,
    LOCATION_IDS        VARIANT,
    STATUS              TEXT,
    RAW_JSON            VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_LOCATIONS (
    _LOADED_AT  TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE     TEXT DEFAULT 'splose',
    ID          TEXT,
    NAME        TEXT,
    ADDRESS     TEXT,
    SUBURB      TEXT,
    STATE       TEXT,
    POSTCODE    TEXT,
    PHONE       TEXT,
    IS_ACTIVE   TEXT,
    RAW_JSON    VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_APPOINTMENTS (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'splose',
    ID                  TEXT,
    PATIENT_ID          TEXT,
    PRACTITIONER_ID     TEXT,
    LOCATION_ID         TEXT,
    APPOINTMENT_TYPE    TEXT,   -- individual, group, telehealth
    START_TIME          TEXT,
    END_TIME            TEXT,
    DURATION_MINUTES    TEXT,
    STATUS              TEXT,   -- scheduled, completed, cancelled, dna (did_not_attend)
    CANCELLATION_REASON TEXT,
    NOTES               TEXT,
    CASE_ID             TEXT,
    BILLING_STATUS      TEXT,   -- unbilled, invoiced, paid, claimed
    RAW_JSON            VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_SUPPORT_ITEMS (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'splose',
    ID                  TEXT,
    APPOINTMENT_ID      TEXT,
    PATIENT_ID          TEXT,
    SUPPORT_ITEM_NUMBER TEXT,   -- NDIS catalogue number e.g. 15_056_0128_1_3
    SUPPORT_ITEM_NAME   TEXT,
    SUPPORT_CATEGORY    TEXT,   -- e.g. Daily Activities, Capacity Building
    UNIT_OF_MEASURE     TEXT,   -- H (hour), EA (each), D (day)
    QUANTITY            TEXT,
    RATE                TEXT,
    TOTAL_AMOUNT        TEXT,
    GST_CODE            TEXT,   -- P2 (gst free), P1 (gst applies)
    CLAIM_TYPE          TEXT,   -- NDIS, private, medicare
    RAW_JSON            VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_INVOICES (
    _LOADED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE         TEXT DEFAULT 'splose',
    ID              TEXT,
    PATIENT_ID      TEXT,
    PRACTITIONER_ID TEXT,
    INVOICE_NUMBER  TEXT,
    INVOICE_DATE    TEXT,
    DUE_DATE        TEXT,
    STATUS          TEXT,   -- draft, sent, paid, overdue, void
    FUND_MANAGEMENT TEXT,   -- mirrors patient fund_management at time of invoice
    SUBTOTAL        TEXT,
    GST_AMOUNT      TEXT,
    TOTAL_AMOUNT    TEXT,
    PAID_AMOUNT     TEXT,
    OUTSTANDING     TEXT,
    PAYMENT_METHOD  TEXT,   -- ndis_portal, bank_transfer, credit_card, etc.
    NDIS_CLAIM_REF  TEXT,
    RAW_JSON        VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_PAYMENTS (
    _LOADED_AT      TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE         TEXT DEFAULT 'splose',
    ID              TEXT,
    INVOICE_ID      TEXT,
    PATIENT_ID      TEXT,
    PAYMENT_DATE    TEXT,
    AMOUNT          TEXT,
    PAYMENT_METHOD  TEXT,
    REFERENCE       TEXT,
    NOTES           TEXT,
    RAW_JSON        VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_CASES (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'splose',
    ID                  TEXT,
    PATIENT_ID          TEXT,
    PRACTITIONER_ID     TEXT,
    CASE_NAME           TEXT,
    SUPPORT_CATEGORY    TEXT,
    PLAN_BUDGET         TEXT,
    ALLOCATED_BUDGET    TEXT,
    USED_BUDGET         TEXT,
    START_DATE          TEXT,
    END_DATE            TEXT,
    STATUS              TEXT,
    RAW_JSON            VARIANT
);

CREATE TABLE IF NOT EXISTS RAW.SP_AVAILABILITY (
    _LOADED_AT          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    _SOURCE             TEXT DEFAULT 'splose',
    ID                  TEXT,
    PRACTITIONER_ID     TEXT,
    DATE                TEXT,
    START_TIME          TEXT,
    END_TIME            TEXT,
    LOCATION_ID         TEXT,
    IS_AVAILABLE        TEXT,
    RAW_JSON            VARIANT
);
