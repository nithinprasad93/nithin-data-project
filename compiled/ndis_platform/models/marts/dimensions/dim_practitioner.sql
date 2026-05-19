-- Conformed practitioner dimension
-- Joins Splose practitioners with Employment Hero employee records

with practitioners as (
    select * from NDIS_DB.STAGING.stg_sp_practitioners
),

employees as (
    select * from NDIS_DB.STAGING.stg_eh_employees
),

-- Latest valid NDIS Worker Screening cert per employee
ndis_screening as (
    select
        employee_id,
        max(expiry_date) as ndis_screening_expiry,
        max(case when is_expired then 1 else 0 end) = 0 as has_valid_screening
    from NDIS_DB.STAGING.stg_eh_certifications
    where is_ndis_screening = true
    group by employee_id
),

final as (
    select
        md5(cast(coalesce(cast(p.practitioner_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as practitioner_key,
        p.practitioner_id,
        p.eh_employee_id,
        p.full_name                     as practitioner_name,
        p.first_name,
        p.last_name,
        p.email,
        p.discipline,
        p.ahpra_number,
        p.registration_type,
        p.status                        as practitioner_status,
        -- from Employment Hero
        e.job_title,
        e.employment_type,
        e.start_date                    as employment_start_date,
        e.termination_date,
        e.team_id,
        e.department_id,
        e.cost_centre_id,
        e.payroll_type,
        -- compliance
        ns.ndis_screening_expiry,
        coalesce(ns.has_valid_screening, false) as has_valid_ndis_screening,
        p._loaded_at
    from practitioners p
    left join employees e
        on p.eh_employee_id = e.employee_id
    left join ndis_screening ns
        on e.employee_id = ns.employee_id
)

select * from final