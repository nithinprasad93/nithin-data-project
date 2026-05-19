
    
    

with child as (
    select invoice_date_id as from_field
    from NDIS_DB.MARTS.fact_billing
    where invoice_date_id is not null
),

parent as (
    select date_id as to_field
    from NDIS_DB.MARTS.dim_date
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


