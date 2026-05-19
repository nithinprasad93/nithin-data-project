
  create or replace   view NDIS_DB.STAGING.stg_eh_certifications
  
  
  
  
  as (
    with source as (
    select * from NDIS_DB.RAW.eh_certifications
),

renamed as (
    select
        id                                          as certification_id,
        employee_id,
        organisation_id,
        certification_name,
        lower(certification_type)                  as certification_type,
        lower(status)                              as status,
        try_to_date(issue_date, 'YYYY-MM-DD')      as issue_date,
        try_to_date(expiry_date, 'YYYY-MM-DD')     as expiry_date,
        notes,
        -- flag critical NDIS compliance certs
        case
            when lower(certification_type) like '%ndis%screening%' then true
            else false
        end                                         as is_ndis_screening,
        case
            when expiry_date is not null
                 and try_to_date(expiry_date, 'YYYY-MM-DD') < current_date()
            then true
            else false
        end                                         as is_expired,
        case
            when expiry_date is not null
                 and try_to_date(expiry_date, 'YYYY-MM-DD')
                     between current_date() and dateadd(day, 30, current_date())
            then true
            else false
        end                                         as expires_in_30_days,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
  );

