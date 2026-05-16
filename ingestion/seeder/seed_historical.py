"""
One-time historical seeder — generates reference/static data using Faker.
No Claude API calls — fast, free, and reliable.

Run this ONCE before starting daily seeding:
    python -m ingestion.seeder.seed_historical
"""

from __future__ import annotations
import json
import logging
import random
import uuid
from datetime import date, timedelta

from dotenv import load_dotenv
load_dotenv()

from faker import Faker
from ingestion.utils.snowflake_client import get_connection, upsert_rows

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

fake = Faker("en_AU")
random.seed(42)
Faker.seed(42)

ORG_ID = "ORG-001"
SUBURBS = [
    ("Chermside", "4032"), ("Carindale", "4152"),
    ("Spring Hill", "4000"), ("Indooroopilly", "4068"),
]
DISCIPLINES = [
    ("occupational_therapy",  "Occupational Therapist",  "OCC", 3),
    ("physiotherapy",         "Physiotherapist",          "PHY", 3),
    ("speech_pathology",      "Speech Pathologist",       "SPA", 3),
    ("psychology",            "Psychologist",             "PSY", 2),
    ("social_work",           "Social Worker",            "SWK", 2),
    ("behaviour_support",     "Behaviour Support Practitioner", "BSP", 1),
    ("support_coordination",  "Support Coordinator",      "SPC", 1),
]
NDIS_DISABILITIES = [
    "Autism Spectrum Disorder", "Cerebral Palsy", "Intellectual Disability",
    "Down Syndrome", "Acquired Brain Injury", "Spinal Cord Injury",
    "Multiple Sclerosis", "Hearing Impairment", "Vision Impairment",
    "Psychosocial Disability",
]
SUPPORT_CATEGORIES = [
    "Daily Activities", "Capacity Building", "Support Coordination",
    "Social and Community Participation", "Health and Wellbeing",
]
FUND_TYPES = ["ndia_managed", "plan_managed", "self_managed"]


def random_date(start: date, end: date) -> date:
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


def fmt(d: date | None) -> str | None:
    return d.isoformat() if d else None


# ── Generators ──────────────────────────────────────────────────────────────

def make_locations() -> list[dict]:
    locations = []
    names = ["Chermside Clinic", "Carindale Clinic", "Spring Hill Clinic", "Indooroopilly Clinic"]
    for i, (suburb, postcode) in enumerate(SUBURBS, 1):
        locations.append({
            "ID": f"LOC-{i:03d}",
            "NAME": names[i - 1],
            "ADDRESS": fake.street_address(),
            "SUBURB": suburb,
            "STATE": "QLD",
            "POSTCODE": postcode,
            "PHONE": fake.phone_number(),
            "IS_ACTIVE": "true",
            "RAW_JSON": json.dumps({"source": "seed"}),
        })
    return locations


def make_teams() -> list[dict]:
    teams = []
    for i, (disc, title, _, _) in enumerate(DISCIPLINES, 1):
        teams.append({
            "ID": f"TEAM-{i:03d}",
            "ORGANISATION_ID": ORG_ID,
            "NAME": f"{title} Team",
            "DESCRIPTION": f"Clinical team for {title.lower()} services",
            "MANAGER_ID": f"EMP-{i:03d}",
            "RAW_JSON": json.dumps({"source": "seed"}),
        })
    return teams


def make_departments() -> list[dict]:
    return [
        {"ID": "DEPT-CLINICAL", "ORGANISATION_ID": ORG_ID, "NAME": "Clinical", "PARENT_ID": None, "RAW_JSON": json.dumps({"source": "seed"})},
        {"ID": "DEPT-ADMIN",    "ORGANISATION_ID": ORG_ID, "NAME": "Administration", "PARENT_ID": None, "RAW_JSON": json.dumps({"source": "seed"})},
        {"ID": "DEPT-MGMT",     "ORGANISATION_ID": ORG_ID, "NAME": "Management", "PARENT_ID": None, "RAW_JSON": json.dumps({"source": "seed"})},
    ]


def make_employees() -> list[dict]:
    employees = []
    emp_id = 1

    # Clinical practitioners
    for team_idx, (disc, title, ahpra_prefix, count) in enumerate(DISCIPLINES, 1):
        for _ in range(count):
            dob = random_date(date(1975, 1, 1), date(1998, 12, 31))
            start = random_date(date(2018, 1, 1), date(2024, 1, 1))
            employees.append({
                "ID": f"EMP-{emp_id:03d}",
                "ORGANISATION_ID": ORG_ID,
                "FIRST_NAME": fake.first_name(),
                "LAST_NAME": fake.last_name(),
                "EMAIL": fake.email(),
                "DATE_OF_BIRTH": fmt(dob),
                "GENDER": random.choice(["female", "male", "non_binary"]),
                "PRONOUNS": random.choice(["she/her", "he/him", "they/them"]),
                "PHONE": fake.phone_number(),
                "ADDRESS": f"{fake.street_address()}, {random.choice(SUBURBS)[0]} QLD {random.choice(SUBURBS)[1]}",
                "JOB_TITLE": title,
                "EMPLOYMENT_TYPE": random.choice(["full_time", "part_time", "casual"]),
                "STATUS": "active",
                "START_DATE": fmt(start),
                "TERMINATION_DATE": None,
                "PRIMARY_MANAGER_ID": "EMP-001",
                "TEAM_ID": f"TEAM-{team_idx:03d}",
                "DEPARTMENT_ID": "DEPT-CLINICAL",
                "COST_CENTRE_ID": "CC-CLINICAL",
                "EMPLOYING_ENTITY_ID": "ENTITY-001",
                "PAYROLL_TYPE": random.choice(["salary", "hourly"]),
                "CUSTOM_FIELDS": {
                    "ndis_screening_number": f"NSW{random.randint(1000000, 9999999)}",
                    "discipline": disc,
                    "ahpra_number": f"{ahpra_prefix}{random.randint(1000000, 9999999)}",
                },
                "RAW_JSON": {"source": "seed"},
            })
            emp_id += 1

    # Admin staff
    for _ in range(5):
        dob = random_date(date(1975, 1, 1), date(1998, 12, 31))
        start = random_date(date(2018, 1, 1), date(2024, 1, 1))
        employees.append({
            "ID": f"EMP-{emp_id:03d}",
            "ORGANISATION_ID": ORG_ID,
            "FIRST_NAME": fake.first_name(),
            "LAST_NAME": fake.last_name(),
            "EMAIL": fake.email(),
            "DATE_OF_BIRTH": fmt(dob),
            "GENDER": random.choice(["female", "male"]),
            "PRONOUNS": None,
            "PHONE": fake.phone_number(),
            "ADDRESS": f"{fake.street_address()}, {random.choice(SUBURBS)[0]} QLD {random.choice(SUBURBS)[1]}",
            "JOB_TITLE": random.choice(["Practice Manager", "Administration Officer", "Receptionist"]),
            "EMPLOYMENT_TYPE": random.choice(["full_time", "part_time"]),
            "STATUS": "active",
            "START_DATE": fmt(start),
            "TERMINATION_DATE": None,
            "PRIMARY_MANAGER_ID": "EMP-001",
            "TEAM_ID": None,
            "DEPARTMENT_ID": "DEPT-ADMIN",
            "COST_CENTRE_ID": "CC-ADMIN",
            "EMPLOYING_ENTITY_ID": "ENTITY-001",
            "PAYROLL_TYPE": "salary",
            "CUSTOM_FIELDS": {"discipline": "administration"},
            "RAW_JSON": {"source": "seed"},
        })
        emp_id += 1

    return employees


def make_practitioners(employees: list[dict]) -> list[dict]:
    practitioners = []
    prac_id = 1
    for emp in employees:
        if emp["DEPARTMENT_ID"] != "DEPT-CLINICAL":
            continue
        loc_ids = random.sample(["LOC-001", "LOC-002", "LOC-003", "LOC-004"], k=random.randint(1, 2))
        practitioners.append({
            "ID": f"PRAC-{prac_id:03d}",
            "EH_EMPLOYEE_ID": emp["ID"],
            "FIRST_NAME": emp["FIRST_NAME"],
            "LAST_NAME": emp["LAST_NAME"],
            "EMAIL": emp["EMAIL"],
            "DISCIPLINE": emp["CUSTOM_FIELDS"]["discipline"],
            "AHPRA_NUMBER": emp["CUSTOM_FIELDS"].get("ahpra_number"),
            "REGISTRATION_TYPE": "general",
            "LOCATION_IDS": loc_ids,
            "STATUS": "active",
            "RAW_JSON": {"source": "seed"},
        })
        prac_id += 1
    return practitioners


def make_patients(n_ndis: int = 40, n_private: int = 10) -> list[dict]:
    patients = []
    for i in range(1, n_ndis + n_private + 1):
        is_ndis = i <= n_ndis
        dob = random_date(date(1960, 1, 1), date(2018, 12, 31))
        suburb, postcode = random.choice(SUBURBS)
        plan_start = random_date(date(2023, 1, 1), date(2025, 1, 1)) if is_ndis else None
        plan_end = (plan_start + timedelta(days=365)) if plan_start else None
        patients.append({
            "ID": f"PAT-{i:03d}",
            "FIRST_NAME": fake.first_name(),
            "LAST_NAME": fake.last_name(),
            "DATE_OF_BIRTH": fmt(dob),
            "EMAIL": fake.email(),
            "PHONE": fake.phone_number(),
            "ADDRESS": fake.street_address(),
            "SUBURB": suburb,
            "STATE": "QLD",
            "POSTCODE": postcode,
            "NDIS_NUMBER": f"43{random.randint(10000000, 99999999)}" if is_ndis else None,
            "FUND_MANAGEMENT": random.choice(FUND_TYPES) if is_ndis else "private",
            "NDIS_PLAN_START": fmt(plan_start),
            "NDIS_PLAN_END": fmt(plan_end),
            "DIAGNOSIS": random.choice(NDIS_DISABILITIES) if is_ndis else None,
            "NOMINEE_NAME": fake.name() if is_ndis and random.random() < 0.4 else None,
            "NOMINEE_PHONE": fake.phone_number() if is_ndis and random.random() < 0.4 else None,
            "PRIMARY_DISABILITY": random.choice(NDIS_DISABILITIES) if is_ndis else None,
            "STATUS": "active",
            "TAGS": [],
            "CUSTOM_FIELDS": {},
            "RAW_JSON": {"source": "seed"},
        })
    return patients


def make_certifications(employees: list[dict]) -> list[dict]:
    certs = []
    today = date.today()
    for emp in employees:
        if emp["DEPARTMENT_ID"] != "DEPT-CLINICAL":
            continue
        # NDIS Worker Screening
        issue = random_date(date(2021, 1, 1), date(2024, 1, 1))
        expiry = issue + timedelta(days=365 * 5)
        expired = random.random() < 0.1
        if expired:
            expiry = today - timedelta(days=random.randint(1, 180))
        certs.append({
            "ID": f"CERT-{emp['ID']}-NDIS",
            "EMPLOYEE_ID": emp["ID"],
            "ORGANISATION_ID": ORG_ID,
            "CERTIFICATION_NAME": "NDIS Worker Screening Check",
            "CERTIFICATION_TYPE": "ndis_worker_screening",
            "STATUS": "expired" if expired else "active",
            "ISSUE_DATE": fmt(issue),
            "EXPIRY_DATE": fmt(expiry),
            "NOTES": None,
            "RAW_JSON": {"source": "seed"},
        })
        # AHPRA
        issue2 = random_date(date(2022, 1, 1), date(2024, 6, 1))
        certs.append({
            "ID": f"CERT-{emp['ID']}-AHPRA",
            "EMPLOYEE_ID": emp["ID"],
            "ORGANISATION_ID": ORG_ID,
            "CERTIFICATION_NAME": "AHPRA Registration",
            "CERTIFICATION_TYPE": "ahpra",
            "STATUS": "active",
            "ISSUE_DATE": fmt(issue2),
            "EXPIRY_DATE": fmt(date(today.year + 1, 11, 30)),
            "NOTES": None,
            "RAW_JSON": {"source": "seed"},
        })
    return certs


def make_cases(patients: list[dict], practitioners: list[dict]) -> list[dict]:
    cases = []
    ndis_patients = [p for p in patients if p["FUND_MANAGEMENT"] != "private"]
    for patient in ndis_patients:
        n_cases = random.randint(1, 2)
        categories = random.sample(SUPPORT_CATEGORIES, n_cases)
        for j, cat in enumerate(categories, 1):
            prac = random.choice(practitioners)
            budget = round(random.uniform(5000, 30000), 2)
            used = round(budget * random.uniform(0.1, 0.9), 2)
            start = date.fromisoformat(patient["NDIS_PLAN_START"])
            end = date.fromisoformat(patient["NDIS_PLAN_END"])
            cases.append({
                "ID": f"CASE-{patient['ID']}-{j:02d}",
                "PATIENT_ID": patient["ID"],
                "PRACTITIONER_ID": prac["ID"],
                "CASE_NAME": f"{cat} — {patient['FIRST_NAME']} {patient['LAST_NAME']}",
                "SUPPORT_CATEGORY": cat,
                "PLAN_BUDGET": str(budget),
                "ALLOCATED_BUDGET": str(budget),
                "USED_BUDGET": str(used),
                "START_DATE": fmt(start),
                "END_DATE": fmt(end),
                "STATUS": "active" if end >= date.today() else "closed",
                "RAW_JSON": {"source": "seed"},
            })
    return cases


# ── Loader ───────────────────────────────────────────────────────────────────

TABLE_MAP = {
    "locations":      "RAW.SP_LOCATIONS",
    "teams":          "RAW.EH_TEAMS",
    "departments":    "RAW.EH_DEPARTMENTS",
    "employees":      "RAW.EH_EMPLOYEES",
    "practitioners":  "RAW.SP_PRACTITIONERS",
    "patients":       "RAW.SP_PATIENTS",
    "certifications": "RAW.EH_CERTIFICATIONS",
    "cases":          "RAW.SP_CASES",
}


def table_has_data(conn, table: str) -> bool:
    try:
        result = conn.cursor().execute(f"SELECT COUNT(*) FROM {table}").fetchone()
        return result[0] > 0
    except Exception:
        return False


def load(conn, key: str, rows: list[dict]) -> None:
    table = TABLE_MAP[key]
    if table_has_data(conn, table):
        logger.info("Skipping %s — already loaded.", table)
        return
    n = upsert_rows(conn, table, rows)
    logger.info("  %s → %s: %d rows", key, table, n)


def main() -> None:
    logger.info("Generating reference data with Faker...")

    locations    = make_locations()
    teams        = make_teams()
    departments  = make_departments()
    employees    = make_employees()
    practitioners = make_practitioners(employees)
    patients     = make_patients(n_ndis=40, n_private=10)
    certifications = make_certifications(employees)
    cases        = make_cases(patients, practitioners)

    logger.info("Generated: %d employees, %d practitioners, %d patients, %d certs, %d cases",
                len(employees), len(practitioners), len(patients), len(certifications), len(cases))

    conn = get_connection()
    try:
        load(conn, "locations",      locations)
        load(conn, "teams",          teams)
        load(conn, "departments",    departments)
        load(conn, "employees",      employees)
        load(conn, "practitioners",  practitioners)
        load(conn, "patients",       patients)
        load(conn, "certifications", certifications)
        load(conn, "cases",          cases)
    finally:
        conn.close()

    logger.info("Historical seed complete.")


if __name__ == "__main__":
    main()
