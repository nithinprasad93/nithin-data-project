
    
    

with all_values as (

    select
        STATUS as value_field,
        count(*) as n_records

    from NDIS_DB.RAW.sp_appointments
    group by STATUS

)

select *
from all_values
where value_field not in (
    'scheduled','completed','cancelled','dna'
)


