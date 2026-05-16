"""Pydantic models mirroring the Splose API response shapes."""

from __future__ import annotations
from typing import Any, Optional
from pydantic import BaseModel


class SPPatient(BaseModel):
    id: str
    first_name: str
    last_name: str
    date_of_birth: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    suburb: Optional[str] = None
    state: Optional[str] = None
    postcode: Optional[str] = None
    ndis_number: Optional[str] = None
    fund_management: Optional[str] = None  # ndia_managed | plan_managed | self_managed | private
    ndis_plan_start: Optional[str] = None
    ndis_plan_end: Optional[str] = None
    diagnosis: Optional[str] = None
    nominee_name: Optional[str] = None
    nominee_phone: Optional[str] = None
    primary_disability: Optional[str] = None
    status: str = "active"
    tags: Optional[list[str]] = None
    custom_fields: Optional[dict[str, Any]] = None
    raw_json: Optional[dict[str, Any]] = None


class SPPractitioner(BaseModel):
    id: str
    eh_employee_id: Optional[str] = None
    first_name: str
    last_name: str
    email: Optional[str] = None
    discipline: str  # occupational_therapy | physiotherapy | speech_pathology | ...
    ahpra_number: Optional[str] = None
    registration_type: Optional[str] = None
    location_ids: Optional[list[str]] = None
    status: str = "active"
    raw_json: Optional[dict[str, Any]] = None


class SPLocation(BaseModel):
    id: str
    name: str
    address: Optional[str] = None
    suburb: Optional[str] = None
    state: Optional[str] = None
    postcode: Optional[str] = None
    phone: Optional[str] = None
    is_active: str = "true"
    raw_json: Optional[dict[str, Any]] = None


class SPAppointment(BaseModel):
    id: str
    patient_id: str
    practitioner_id: str
    location_id: Optional[str] = None
    appointment_type: str  # individual | group | telehealth
    start_time: str
    end_time: str
    duration_minutes: str
    status: str  # scheduled | completed | cancelled | dna
    cancellation_reason: Optional[str] = None
    notes: Optional[str] = None
    case_id: Optional[str] = None
    billing_status: str = "unbilled"
    raw_json: Optional[dict[str, Any]] = None


class SPSupportItem(BaseModel):
    id: str
    appointment_id: str
    patient_id: str
    support_item_number: str
    support_item_name: str
    support_category: str
    unit_of_measure: str  # H | EA | D
    quantity: str
    rate: str
    total_amount: str
    gst_code: str  # P1 | P2
    claim_type: str  # ndis | private | medicare
    raw_json: Optional[dict[str, Any]] = None


class SPInvoice(BaseModel):
    id: str
    patient_id: str
    practitioner_id: str
    invoice_number: str
    invoice_date: str
    due_date: str
    status: str  # draft | sent | paid | overdue | void
    fund_management: str
    subtotal: str
    gst_amount: str
    total_amount: str
    paid_amount: str
    outstanding: str
    payment_method: Optional[str] = None
    ndis_claim_ref: Optional[str] = None
    raw_json: Optional[dict[str, Any]] = None


class SPPayment(BaseModel):
    id: str
    invoice_id: str
    patient_id: str
    payment_date: str
    amount: str
    payment_method: str
    reference: Optional[str] = None
    notes: Optional[str] = None
    raw_json: Optional[dict[str, Any]] = None


class SPCase(BaseModel):
    id: str
    patient_id: str
    practitioner_id: str
    case_name: str
    support_category: str
    plan_budget: str
    allocated_budget: str
    used_budget: str
    start_date: str
    end_date: str
    status: str
    raw_json: Optional[dict[str, Any]] = None


class SPAvailability(BaseModel):
    id: str
    practitioner_id: str
    date: str
    start_time: str
    end_time: str
    location_id: Optional[str] = None
    is_available: str = "true"
    raw_json: Optional[dict[str, Any]] = None
