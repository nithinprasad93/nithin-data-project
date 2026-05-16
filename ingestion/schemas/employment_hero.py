"""Pydantic models mirroring the Employment Hero API response shapes."""

from __future__ import annotations
from datetime import date, datetime
from typing import Any, Optional
from pydantic import BaseModel, field_validator


class EHEmployee(BaseModel):
    id: str
    organisation_id: str
    first_name: str
    last_name: str
    email: str
    date_of_birth: Optional[str] = None
    gender: Optional[str] = None
    pronouns: Optional[str] = None
    phone: Optional[str] = None
    address: Optional[str] = None
    job_title: Optional[str] = None
    employment_type: Optional[str] = None
    status: str = "active"
    start_date: Optional[str] = None
    termination_date: Optional[str] = None
    primary_manager_id: Optional[str] = None
    team_id: Optional[str] = None
    department_id: Optional[str] = None
    cost_centre_id: Optional[str] = None
    employing_entity_id: Optional[str] = None
    payroll_type: Optional[str] = None
    custom_fields: Optional[dict[str, Any]] = None
    raw_json: Optional[dict[str, Any]] = None


class EHCertification(BaseModel):
    id: str
    employee_id: str
    organisation_id: str
    certification_name: str
    certification_type: str
    status: str
    issue_date: Optional[str] = None
    expiry_date: Optional[str] = None
    notes: Optional[str] = None
    raw_json: Optional[dict[str, Any]] = None


class EHTimesheetEntry(BaseModel):
    id: str
    employee_id: str
    organisation_id: str
    date: str
    start_time: str
    end_time: str
    break_duration: Optional[str] = "0"
    total_hours: str
    work_type_id: Optional[str] = None
    work_location_id: Optional[str] = None
    notes: Optional[str] = None
    status: str = "approved"
    raw_json: Optional[dict[str, Any]] = None


class EHLeaveRequest(BaseModel):
    id: str
    employee_id: str
    organisation_id: str
    leave_category_id: Optional[str] = None
    leave_type: str
    start_date: str
    end_date: str
    hours_requested: str
    status: str
    reason: Optional[str] = None
    approved_by_id: Optional[str] = None
    raw_json: Optional[dict[str, Any]] = None


class EHPayslip(BaseModel):
    id: str
    employee_id: str
    organisation_id: str
    pay_period_start: str
    pay_period_end: str
    gross_earnings: str
    net_earnings: str
    tax_withheld: str
    superannuation: str
    total_deductions: str
    payment_date: str
    status: str = "finalised"
    raw_json: Optional[dict[str, Any]] = None


class EHRosteredShift(BaseModel):
    id: str
    employee_id: str
    organisation_id: str
    role_id: Optional[str] = None
    start_time: str
    end_time: str
    break_duration: Optional[str] = "0"
    work_site_id: Optional[str] = None
    status: str = "published"
    cost: Optional[str] = None
    raw_json: Optional[dict[str, Any]] = None


class EHTeam(BaseModel):
    id: str
    organisation_id: str
    name: str
    description: Optional[str] = None
    manager_id: Optional[str] = None
    raw_json: Optional[dict[str, Any]] = None


class EHDepartment(BaseModel):
    id: str
    organisation_id: str
    name: str
    parent_id: Optional[str] = None
    raw_json: Optional[dict[str, Any]] = None
