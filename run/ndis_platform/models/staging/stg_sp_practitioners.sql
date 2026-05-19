
  create or replace   view NDIS_DB.STAGING.stg_sp_practitioners
  
  
  
  
  as (
    with source as (
    select * from NDIS_DB.RAW.sp_practitioners
),

renamed as (
    select
        id                          as practitioner_id,
        eh_employee_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        lower(email)               as email,
        lower(discipline)          as discipline,
        ahpra_number,
        lower(registration_type)   as registration_type,
        location_ids,
        lower(status)              as status,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
  );

