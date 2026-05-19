
    
    

with all_values as (

    select
        STATUS as value_field,
        count(*) as n_records

    from NDIS_DB.RAW.sp_invoices
    group by STATUS

)

select *
from all_values
where value_field not in (
    'draft','sent','paid','overdue','void'
)


