"""
Daily seeder — generates one day of realistic NDIS operational data using Faker.
Fast, free, and reliable. No Claude API calls.

Run:
    python -m ingestion.seeder.seed_daily [--date YYYY-MM-DD]  # defaults to today
    python -m ingestion.seeder.seed_daily --backfill-days 30
"""

from __future__ import annotations
import argparse
import logging
import random
from datetime import date, datetime, timedelta

from dotenv import load_dotenv
load_dotenv()

from faker import Faker
from ingestion.utils.snowflake_client import get_connection, bulk_insert, upsert_rows

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

fake = Faker("en_AU")

ORG_ID = "ORG-001"
PRAC_IDS  = [f"PRAC-{i:03d}" for i in range(1, 16)]
EMP_IDS   = [f"EMP-{i:03d}"  for i in range(1, 16)]
PAT_IDS   = [f"PAT-{i:03d}"  for i in range(1, 51)]
NDIS_PATS = [f"PAT-{i:03d}"  for i in range(1, 41)]
PRIV_PATS = [f"PAT-{i:03d}"  for i in range(41, 51)]
LOC_IDS   = ["LOC-001", "LOC-002", "LOC-003", "LOC-004"]

SUPPORT_ITEMS = [
    ("15_056_0128_1_3", "Assistance with Self-Care Activities",         "Daily Activities",   "193.99"),
    ("15_037_0128_1_3", "Assistance with Daily Life - Standard",        "Daily Activities",   "65.09"),
    ("07_002_0106_6_3", "Support Coordination",                        "Support Coordination","100.14"),
    ("15_043_0128_1_3", "Therapeutic Supports - Occupational Therapy",  "Capacity Building",  "193.99"),
    ("15_053_0128_1_3", "Therapeutic Supports - Physiotherapy",         "Capacity Building",  "193.99"),
    ("15_054_0128_1_3", "Therapeutic Supports - Speech Pathology",      "Capacity Building",  "193.99"),
    ("15_056_0128_1_3", "Therapeutic Supports - Psychology",            "Capacity Building",  "234.00"),
    ("04_210_0125_6_1", "Assistive Technology Assessment",              "Assistive Technology","193.99"),
]

FUND_TYPES = ["ndia_managed", "plan_managed", "self_managed"]


def fmt_dt(dt: datetime) -> str:
    return dt.strftime("%Y-%m-%d %H:%M:%S")


def make_appointments(target_date: date, id_prefix: str) -> list[dict]:
    appointments = []
    # Pick 6-10 practitioners to work today
    working_pracs = random.sample(PRAC_IDS, k=random.randint(6, 10))
    apt_num = 1
    for prac_id in working_pracs:
        # Each practitioner sees 2-4 patients
        for _ in range(random.randint(2, 4)):
            patient_id = random.choice(NDIS_PATS + PRIV_PATS)
            hour = random.randint(8, 15)
            start = datetime(target_date.year, target_date.month, target_date.day, hour, 0)
            duration = random.choice([45, 60, 90])
            end = start + timedelta(minutes=duration)
            status = random.choices(
                ["completed", "cancelled", "dna"],
                weights=[85, 10, 5]
            )[0]
            apt_idx = f"PRAC{prac_id[-3:]}"
            case_pat = patient_id if patient_id in NDIS_PATS else None
            appointments.append({
                "ID": f"APT-{id_prefix}-{apt_num:03d}",
                "PATIENT_ID": patient_id,
                "PRACTITIONER_ID": prac_id,
                "LOCATION_ID": random.choice(LOC_IDS),
                "APPOINTMENT_TYPE": random.choice(["individual", "telehealth"]),
                "START_TIME": fmt_dt(start),
                "END_TIME": fmt_dt(end),
                "DURATION_MINUTES": str(duration),
                "STATUS": status,
                "CANCELLATION_REASON": fake.sentence() if status in ("cancelled", "dna") else None,
                "NOTES": fake.sentence() if status == "completed" else None,
                "CASE_ID": f"CASE-{patient_id}-01" if case_pat else None,
                "BILLING_STATUS": "invoiced" if status == "completed" else "unbilled",
                "RAW_JSON": {"source": "seed", "date": target_date.isoformat()},
            })
            apt_num += 1
    return appointments


def make_support_items(appointments: list[dict], id_prefix: str) -> list[dict]:
    items = []
    num = 1
    for apt in appointments:
        if apt["STATUS"] != "completed":
            continue
        item = random.choice(SUPPORT_ITEMS)
        qty = str(round(int(apt["DURATION_MINUTES"]) / 60, 2))
        rate = item[3]
        total = str(round(float(qty) * float(rate), 2))
        claim = "ndis" if apt["PATIENT_ID"] in NDIS_PATS else "private"
        items.append({
            "ID": f"SI-{id_prefix}-{num:03d}",
            "APPOINTMENT_ID": apt["ID"],
            "PATIENT_ID": apt["PATIENT_ID"],
            "SUPPORT_ITEM_NUMBER": item[0],
            "SUPPORT_ITEM_NAME": item[1],
            "SUPPORT_CATEGORY": item[2],
            "UNIT_OF_MEASURE": "H",
            "QUANTITY": qty,
            "RATE": rate,
            "TOTAL_AMOUNT": total,
            "GST_CODE": "P2",
            "CLAIM_TYPE": claim,
            "RAW_JSON": {"source": "seed"},
        })
        num += 1
    return items


def make_invoices(appointments: list[dict], support_items: list[dict], id_prefix: str) -> list[dict]:
    invoices = []
    num = 1
    si_by_apt = {si["APPOINTMENT_ID"]: si for si in support_items}
    for apt in appointments:
        if apt["STATUS"] != "completed":
            continue
        si = si_by_apt.get(apt["ID"])
        total = si["TOTAL_AMOUNT"] if si else "193.99"
        due = (date.fromisoformat(apt["START_TIME"][:10]) + timedelta(days=30)).isoformat()
        fund = random.choice(FUND_TYPES) if apt["PATIENT_ID"] in NDIS_PATS else "private"
        invoices.append({
            "ID": f"INV-{id_prefix}-{num:03d}",
            "PATIENT_ID": apt["PATIENT_ID"],
            "PRACTITIONER_ID": apt["PRACTITIONER_ID"],
            "INVOICE_NUMBER": f"INV-{id_prefix}-{num:03d}",
            "INVOICE_DATE": apt["START_TIME"][:10],
            "DUE_DATE": due,
            "STATUS": "sent",
            "FUND_MANAGEMENT": fund,
            "SUBTOTAL": total,
            "GST_AMOUNT": "0.00",
            "TOTAL_AMOUNT": total,
            "PAID_AMOUNT": "0.00",
            "OUTSTANDING": total,
            "PAYMENT_METHOD": None,
            "NDIS_CLAIM_REF": None,
            "RAW_JSON": {"source": "seed"},
        })
        num += 1
    return invoices


def make_timesheets(appointments: list[dict], target_date: date, id_prefix: str) -> list[dict]:
    working_pracs = list({apt["PRACTITIONER_ID"] for apt in appointments if apt["STATUS"] == "completed"})
    entries = []
    for i, prac_id in enumerate(working_pracs, 1):
        emp_num = int(prac_id.split("-")[1])
        emp_id = f"EMP-{emp_num:03d}"
        start = datetime(target_date.year, target_date.month, target_date.day, 8, 30)
        end = datetime(target_date.year, target_date.month, target_date.day, 17, 0)
        entries.append({
            "ID": f"TS-{id_prefix}-{i:03d}",
            "EMPLOYEE_ID": emp_id,
            "ORGANISATION_ID": ORG_ID,
            "DATE": target_date.isoformat(),
            "START_TIME": fmt_dt(start),
            "END_TIME": fmt_dt(end),
            "BREAK_DURATION": "0.5",
            "TOTAL_HOURS": "8.0",
            "WORK_TYPE_ID": None,
            "WORK_LOCATION_ID": None,
            "NOTES": None,
            "STATUS": "approved",
            "RAW_JSON": {"source": "seed"},
        })
    return entries


def make_leave(target_date: date, id_prefix: str) -> list[dict]:
    # ~20% chance of a leave request on any given day
    if random.random() > 0.2:
        return []
    emp = random.choice(EMP_IDS)
    leave_start = target_date + timedelta(days=random.randint(3, 14))
    leave_end = leave_start + timedelta(days=random.randint(1, 5))
    return [{
        "ID": f"LV-{id_prefix}-001",
        "EMPLOYEE_ID": emp,
        "ORGANISATION_ID": ORG_ID,
        "LEAVE_CATEGORY_ID": None,
        "LEAVE_TYPE": random.choice(["annual", "personal", "study"]),
        "START_DATE": leave_start.isoformat(),
        "END_DATE": leave_end.isoformat(),
        "HOURS_REQUESTED": str((leave_end - leave_start).days * 7.6),
        "STATUS": "pending",
        "REASON": fake.sentence(),
        "APPROVED_BY_ID": None,
        "RAW_JSON": {"source": "seed"},
    }]


def generate_daily_data(target_date: date) -> dict[str, list[dict]]:
    if target_date.weekday() >= 5:
        logger.info("%s is a weekend — skipping.", target_date)
        return {}

    id_prefix = target_date.strftime("%Y%m%d")
    random.seed(int(id_prefix))  # deterministic per date
    fake.seed_instance(int(id_prefix))

    appointments  = make_appointments(target_date, id_prefix)
    support_items = make_support_items(appointments, id_prefix)
    invoices      = make_invoices(appointments, support_items, id_prefix)
    timesheets    = make_timesheets(appointments, target_date, id_prefix)
    leave         = make_leave(target_date, id_prefix)

    return {
        "appointments":      appointments,
        "support_items":     support_items,
        "invoices":          invoices,
        "payments":          [],
        "timesheet_entries": timesheets,
        "leave_requests":    leave,
    }


def load_to_snowflake(data: dict[str, list[dict]]) -> dict[str, int]:
    table_map = {
        "appointments":      ("RAW.SP_APPOINTMENTS",      False),
        "support_items":     ("RAW.SP_SUPPORT_ITEMS",     False),
        "invoices":          ("RAW.SP_INVOICES",          False),
        "payments":          ("RAW.SP_PAYMENTS",          False),
        "timesheet_entries": ("RAW.EH_TIMESHEET_ENTRIES", False),
        "leave_requests":    ("RAW.EH_LEAVE_REQUESTS",    False),
    }
    counts: dict[str, int] = {}
    conn = get_connection()
    try:
        for key, (table, append_only) in table_map.items():
            records = data.get(key, [])
            if not records:
                counts[key] = 0
                continue
            rows = [{k.upper(): v for k, v in r.items()} for r in records]
            n = bulk_insert(conn, table, rows) if append_only else upsert_rows(conn, table, rows)
            counts[key] = n
            logger.info("  %s → %s: %d rows", key, table, n)
    finally:
        conn.close()
    return counts


def main() -> None:
    parser = argparse.ArgumentParser(description="Daily NDIS data seeder")
    parser.add_argument("--date", default=None, help="Target date YYYY-MM-DD (default: today)")
    parser.add_argument("--backfill-days", type=int, default=0,
                        help="Backfill N days ending on --date")
    args = parser.parse_args()

    target = date.fromisoformat(args.date) if args.date else date.today()

    if args.backfill_days > 0:
        current = target - timedelta(days=args.backfill_days - 1)
        while current <= target:
            logger.info("=== Seeding %s ===", current)
            data = generate_daily_data(current)
            if data:
                counts = load_to_snowflake(data)
                logger.info("Done %s: %s", current, counts)
            current += timedelta(days=1)
    else:
        logger.info("=== Seeding %s ===", target)
        data = generate_daily_data(target)
        if data:
            counts = load_to_snowflake(data)
            logger.info("Complete: %s", counts)
        else:
            logger.info("Nothing to seed.")


if __name__ == "__main__":
    main()
