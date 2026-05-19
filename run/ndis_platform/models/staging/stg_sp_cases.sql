
  create or replace   view NDIS_DB.STAGING.stg_sp_cases
  
  
  
  
  as (
    with source as (
    select * from NDIS_DB.RAW.sp_cases
),

renamed as (
    select
        id                                          as case_id,
        patient_id,
        practitioner_id,
        case_name,
        lower(support_category)                    as support_category,
        try_to_decimal(plan_budget, 12, 2)         as plan_budget,
        try_to_decimal(allocated_budget, 12, 2)    as allocated_budget,
        try_to_decimal(used_budget, 12, 2)         as used_budget,
        plan_budget::decimal(12,2)
            - used_budget::decimal(12,2)           as remaining_budget,
        case
            when plan_budget::decimal > 0
            then round(used_budget::decimal / plan_budget::decimal * 100, 2)
            else null
        end                                         as budget_utilisation_pct,
        try_to_date(start_date, 'YYYY-MM-DD')      as start_date,
        try_to_date(end_date, 'YYYY-MM-DD')        as end_date,
        lower(status)                              as status,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
  );

