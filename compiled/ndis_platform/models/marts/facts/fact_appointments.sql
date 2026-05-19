

with appointments_raw as (
    select * from NDIS_DB.STAGING.stg_sp_appointments
    
        where _loaded_at > (select max(_loaded_at) from NDIS_DB.MARTS.fact_appointments)
    
),

-- Deduplicate: keep the most recently loaded row per appointment_id
appointments as (
    select * from appointments_raw
    qualify row_number() over (partition by appointment_id order by _loaded_at desc) = 1
),

practitioners as (
    select practitioner_key, practitioner_id from NDIS_DB.MARTS.dim_practitioner
),

clients as (
    select client_key, patient_id from NDIS_DB.MARTS.dim_client
),

locations as (
    select location_key, location_id from NDIS_DB.MARTS.dim_location
),

final as (
    select
        md5(cast(coalesce(cast(a.appointment_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as appointment_key,
        a.appointment_id,
        -- FK to dimensions
        a.appointment_date                  as appointment_date_id,
        coalesce(p.practitioner_key, 'UNKNOWN') as practitioner_key,
        coalesce(c.client_key, 'UNKNOWN')   as client_key,
        coalesce(l.location_key, 'UNKNOWN') as location_key,
        a.case_id,
        -- descriptive attributes (degenerate dimensions)
        a.appointment_type,
        a.status,
        a.billing_status,
        a.cancellation_reason,
        -- measures
        a.duration_minutes,
        a.duration_minutes / 60.0           as duration_hours,
        -- flags (additive)
        a.is_completed::int                 as is_completed,
        a.is_dna::int                       as is_dna,
        a.is_cancelled::int                 as is_cancelled,
        a.is_telehealth::int                as is_telehealth,
        a._loaded_at
    from appointments a
    left join practitioners p on a.practitioner_id = p.practitioner_id
    left join clients c       on a.patient_id = c.patient_id
    left join locations l     on a.location_id = l.location_id
)

select * from final