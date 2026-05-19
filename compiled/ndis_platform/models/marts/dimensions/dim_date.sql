-- Date dimension spanning the project window
-- Generated once as a table; no source dependency



with date_spine as (
    





with rawdata as (

    

    

    with p as (
        select 0 as generated_number union all select 1
    ), unioned as (

    select

    
    p0.generated_number * power(2, 0)
     + 
    
    p1.generated_number * power(2, 1)
     + 
    
    p2.generated_number * power(2, 2)
     + 
    
    p3.generated_number * power(2, 3)
     + 
    
    p4.generated_number * power(2, 4)
     + 
    
    p5.generated_number * power(2, 5)
     + 
    
    p6.generated_number * power(2, 6)
     + 
    
    p7.generated_number * power(2, 7)
     + 
    
    p8.generated_number * power(2, 8)
     + 
    
    p9.generated_number * power(2, 9)
    
    
    + 1
    as generated_number

    from

    
    p as p0
     cross join 
    
    p as p1
     cross join 
    
    p as p2
     cross join 
    
    p as p3
     cross join 
    
    p as p4
     cross join 
    
    p as p5
     cross join 
    
    p as p6
     cross join 
    
    p as p7
     cross join 
    
    p as p8
     cross join 
    
    p as p9
    
    

    )

    select *
    from unioned
    where generated_number <= 975
    order by generated_number



),

all_periods as (

    select (
        

    dateadd(
        day,
        row_number() over (order by generated_number) - 1,
        cast('2024-05-01' as date)
        )


    ) as date_day
    from rawdata

),

filtered as (

    select *
    from all_periods
    where date_day <= cast('2027-01-01' as date)

)

select * from filtered


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