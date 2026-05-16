-- Date dimension spanning the project window
-- Generated once as a table; no source dependency

{{
    config(
        materialized='table',
        tags=['dimension', 'dim_date']
    )
}}

with date_spine as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2024-05-01' as date)",
        end_date="cast('2027-01-01' as date)"
    ) }}
),

final as (
    select
        date_day                                                as date_id,
        date_day                                                as full_date,
        year(date_day)                                          as year,
        quarter(date_day)                                       as quarter,
        month(date_day)                                         as month,
        monthname(date_day)                                     as month_name,
        weekofyear(date_day)                                    as week_of_year,
        dayofweek(date_day)                                     as day_of_week,
        dayname(date_day)                                       as day_name,
        day(date_day)                                           as day_of_month,
        dayofyear(date_day)                                     as day_of_year,
        year(date_day)::text || '-Q' || quarter(date_day)::text as year_quarter,
        to_char(date_day, 'YYYY-MM')                            as year_month,
        case when dayofweek(date_day) in (0, 6) then false else true end as is_weekday,
        case when dayofweek(date_day) in (0, 6) then true else false end as is_weekend,
        -- Australian financial year (July–June)
        case
            when month(date_day) >= 7
            then year(date_day) || '-' || (year(date_day) + 1)
            else (year(date_day) - 1) || '-' || year(date_day)
        end                                                     as financial_year,
        case
            when month(date_day) between 7 and 9  then 'Q1'
            when month(date_day) between 10 and 12 then 'Q2'
            when month(date_day) between 1 and 3  then 'Q3'
            else 'Q4'
        end                                                     as financial_quarter
    from date_spine
)

select * from final
