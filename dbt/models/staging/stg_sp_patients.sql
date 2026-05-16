with source as (
    select * from {{ source('splose', 'sp_patients') }}
),

renamed as (
    select
        id                                              as patient_id,
        first_name,
        last_name,
        first_name || ' ' || last_name                 as full_name,
        try_to_date(date_of_birth, 'YYYY-MM-DD')       as date_of_birth,
        lower(email)                                   as email,
        phone,
        address,
        suburb,
        upper(state)                                   as state,
        postcode,
        ndis_number,
        lower(fund_management)                         as fund_management,
        try_to_date(ndis_plan_start, 'YYYY-MM-DD')     as ndis_plan_start,
        try_to_date(ndis_plan_end, 'YYYY-MM-DD')       as ndis_plan_end,
        diagnosis,
        nominee_name,
        nominee_phone,
        primary_disability,
        lower(status)                                  as status,
        -- NDIS plan status
        case
            when ndis_plan_end is not null
                 and try_to_date(ndis_plan_end, 'YYYY-MM-DD') < current_date()
            then 'expired'
            when ndis_plan_start is not null
                 and try_to_date(ndis_plan_start, 'YYYY-MM-DD') <= current_date()
                 and (ndis_plan_end is null
                      or try_to_date(ndis_plan_end, 'YYYY-MM-DD') >= current_date())
            then 'active'
            else 'unknown'
        end                                             as ndis_plan_status,
        tags,
        custom_fields,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
