# Horizon Allied Health — Data Platform

A full end-to-end data engineering project simulating a real NDIS Allied Health organisation.
Built by **Firehawk Analytics** as a learning project covering the complete modern data stack.

---

## Architecture

```mermaid
flowchart TD

    %% ── Source Systems ──
    subgraph SRC["📦 Source Systems (Simulated)"]
        EH["Employment Hero\n(HR / Payroll)\nEmployees · Timesheets\nLeave · Certifications"]
        SP["Splose\n(Clinical / NDIS)\nAppointments · Patients\nInvoices · Practitioners"]
    end

    %% ── Ingestion ──
    subgraph ING["🐍 Ingestion — Python"]
        SEED_H["seed_historical.py\nOne-off static data\nEmployees · Patients\nPractitioners · Locations"]
        SEED_D["seed_daily.py\nDaily operational data\nAppointments · Invoices\nTimesheets · Leave"]
    end

    %% ── Bronze ──
    subgraph RAW["🥉 Bronze — Snowflake RAW"]
        direction LR
        R1["EH_EMPLOYEES\nEH_CERTIFICATIONS\nEH_TIMESHEET_ENTRIES\nEH_LEAVE_REQUESTS"]
        R2["SP_APPOINTMENTS\nSP_PATIENTS\nSP_PRACTITIONERS\nSP_INVOICES · SP_SUPPORT_ITEMS"]
    end

    %% ── Silver ──
    subgraph STG["🥈 Silver — Snowflake STAGING"]
        direction LR
        S1["stg_eh_employees\nstg_eh_certifications\nstg_eh_timesheet_entries\nstg_eh_leave_requests"]
        S2["stg_sp_appointments\nstg_sp_patients\nstg_sp_practitioners\nstg_sp_invoices"]
    end

    %% ── Gold ──
    subgraph MART["🥇 Gold — Snowflake MARTS"]
        direction LR
        DIM["Dimensions\ndim_practitioner\ndim_client\ndim_date\ndim_location\ndim_support_item"]
        FACT["Facts\nfact_appointments\nfact_billing\nfact_compliance\nfact_leave\nfact_payroll"]
    end

    %% ── Transformation ──
    subgraph DBT["⚙️ dbt Core"]
        DBT_STG["Staging Views\nRename · Cast · Deduplicate"]
        DBT_MART["Mart Tables\nKimball Dimensional Model\nSurrogate Keys · Flags"]
        DBT_TEST["Data Quality Tests\n92 tests · not_null\nunique · accepted_values\nrelationships · ranges"]
        DBT_DOCS["dbt Docs\nLineage Graph\nGitHub Pages"]
    end

    %% ── Presentation ──
    subgraph PRES["📊 Presentation — Evidence.dev"]
        DASH1["Business Overview\nKPIs · Revenue trend\nFunding breakdown\nTop practitioners"]
        DASH2["Practitioner Detail\nPer-practitioner filter\nWeekly charts\nClient breakdown"]
    end

    %% ── Orchestration ──
    subgraph CI["🔄 GitHub Actions"]
        GHA1["Daily Data Seed\n⏰ 12:00 UTC weekdays"]
        GHA2["dbt Transform\n▶ after seed succeeds"]
        GHA3["Deploy Evidence.dev\n▶ after dbt succeeds"]
    end

    %% ── Notifications ──
    subgraph NOTIFY["🔔 Notifications"]
        SLACK["Slack\nSuccess + Failure\nAll 3 jobs"]
        EMAIL["Email (Resend)\nStyled HTML\nSuccess + Failure\nAll 3 jobs"]
    end

    %% ── Hosting ──
    subgraph HOST["☁️ Hosting"]
        VERCEL["Vercel\nEvidence.dev\nProduction dashboard"]
        GHPAGES["GitHub Pages\ndbt Docs\nLineage + test results"]
    end

    %% ── Flows ──
    EH -->|"Faker generates\nrealistic data"| SEED_H
    SP -->|"Faker generates\nrealistic data"| SEED_H
    EH -->|"Daily operational\nevents"| SEED_D
    SP -->|"Daily operational\nevents"| SEED_D

    SEED_H -->|"upsert_rows()\nbulk load"| RAW
    SEED_D -->|"upsert_rows()\nidempotent"| RAW

    RAW -->|"dbt sources"| DBT_STG
    DBT_STG -->|"ref()"| DBT_MART
    DBT_MART -->|"dbt test"| DBT_TEST
    DBT_MART -->|"dbt docs generate"| DBT_DOCS

    DBT_STG --> STG
    DBT_MART --> MART

    MART -->|"npm run sources\nArrow cache"| PRES

    GHA1 -->|"triggers"| GHA2
    GHA2 -->|"triggers"| GHA3

    GHA1 -.->|"on success/failure"| NOTIFY
    GHA2 -.->|"on success/failure"| NOTIFY
    GHA3 -.->|"on success/failure"| NOTIFY

    GHA3 -->|"Vercel deploy hook"| VERCEL
    DBT_DOCS -->|"git push gh-pages"| GHPAGES

    PRES --> VERCEL
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Data warehouse | Snowflake (NDIS_DB) |
| Transformation | dbt Core 1.11 |
| Ingestion / seeding | Python 3.12 + Faker |
| Dashboards | Evidence.dev |
| Orchestration | GitHub Actions |
| Dashboard hosting | Vercel |
| Docs hosting | GitHub Pages |
| Notifications | Slack Webhooks + Resend (HTML email) |

## Medallion Architecture

| Layer | Schema | Materialisation | Role |
|---|---|---|---|
| Bronze | `RAW` | Tables (append/upsert) | Raw landing zone, TEXT + VARIANT columns |
| Silver | `STAGING` | Views | Renamed, cast, deduplicated |
| Gold | `MARTS` | Tables + Incremental | Kimball dims + facts, surrogate keys |

## Daily Pipeline Schedule (AEST / UTC+10)

```
10:00pm  →  Daily Data Seed      (Snowflake RAW)
11:00pm  →  dbt Transform        (STAGING + MARTS + tests)
12:00am  →  Deploy Evidence.dev  (Vercel rebuild)
```

## Links

- **Dashboard** — Vercel (Evidence.dev)
- **dbt Docs** — https://nithinprasad93.github.io/nithin-data-project/dbt-docs
- **Repository** — https://github.com/nithinprasad93/nithin-data-project
