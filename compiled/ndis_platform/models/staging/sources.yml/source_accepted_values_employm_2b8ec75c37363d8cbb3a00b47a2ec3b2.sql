
    
    

with all_values as (

    select
        STATUS as value_field,
        count(*) as n_records

    from NDIS_DB.RAW.eh_employees
    group by STATUS

)

select *
from all_values
where value_field not in (
    'active','terminated'
)


