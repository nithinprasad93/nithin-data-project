-- NDIS participant / client dimension

with patients as (
    select * from NDIS_DB.STAGING.stg_sp_patients
),

final as (
    select
        md5(cast(coalesce(cast(patient_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as client_key,
        patient_id,
        full_name               as client_name,
        first_name,
        last_name,
        date_of_birth,
        datediff('year', date_of_birth, current_date()) as age_years,
        case
            when datediff('year', date_of_birth, current_date()) < 18 then 'child'
            when datediff('year', date_of_birth, current_date()) < 65 then 'adult'
            else 'older_adult'
        end                     as age_group,
        suburb,
        state,
        postcode,
        ndis_number,
        fund_management,
        ndis_plan_start,
        ndis_plan_end,
        ndis_plan_status,
        diagnosis,
        primary_disability,
        status                  as client_status,
        _loaded_at
    from patients
)

select * from final