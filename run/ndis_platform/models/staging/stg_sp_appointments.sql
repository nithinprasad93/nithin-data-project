
  create or replace   view NDIS_DB.STAGING.stg_sp_appointments
  
  
  
  
  as (
    with source as (
    select * from NDIS_DB.RAW.sp_appointments
),

renamed as (
    select
        id                                                          as appointment_id,
        patient_id,
        practitioner_id,
        location_id,
        lower(appointment_type)                                    as appointment_type,
        try_to_timestamp(start_time, 'YYYY-MM-DD HH24:MI:SS')     as start_time,
        try_to_timestamp(end_time, 'YYYY-MM-DD HH24:MI:SS')       as end_time,
        try_to_number(duration_minutes)                            as duration_minutes,
        lower(status)                                              as status,
        cancellation_reason,
        notes,
        case_id,
        lower(billing_status)                                      as billing_status,
        -- extract date for partitioning / fact table keys
        date(try_to_timestamp(start_time, 'YYYY-MM-DD HH24:MI:SS')) as appointment_date,
        -- flags
        case when lower(status) = 'completed' then true else false end as is_completed,
        case when lower(status) = 'dna'       then true else false end as is_dna,
        case when lower(status) = 'cancelled' then true else false end as is_cancelled,
        case when lower(appointment_type) = 'telehealth' then true else false end as is_telehealth,
        _loaded_at
    from source
    where id is not null
    qualify row_number() over (partition by id order by _loaded_at desc) = 1
)

select * from renamed
  );

