-- Certification compliance snapshot — one row per practitioner per cert type per snapshot date
-- Used to track NDIS Worker Screening and AHPRA expiry over time



with certs as (
    select * from NDIS_DB.STAGING.stg_eh_certifications
    
        where _loaded_at > (select max(_loaded_at) from NDIS_DB.MARTS.fact_compliance)
    
),

practitioners as (
    select practitioner_key, eh_employee_id from NDIS_DB.MARTS.dim_practitioner
),

final as (
    select
        md5(cast(coalesce(cast(c.certification_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as compliance_key,
        c.certification_id,
        current_date()                                  as snapshot_date_id,
        coalesce(p.practitioner_key, 'UNKNOWN')         as practitioner_key,
        c.employee_id,
        c.certification_type,
        c.certification_name,
        c.status,
        c.issue_date,
        c.expiry_date,
        -- measures
        datediff('day', current_date(), c.expiry_date)  as days_until_expiry,
        -- flags
        c.is_ndis_screening::int    as is_ndis_screening,
        c.is_expired::int           as is_expired,
        c.expires_in_30_days::int   as expires_in_30_days,
        c._loaded_at
    from certs c
    left join practitioners p on c.employee_id = p.eh_employee_id
)

select * from final