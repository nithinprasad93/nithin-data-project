
    
    

with child as (
    select INVOICE_ID as from_field
    from NDIS_DB.RAW.sp_payments
    where INVOICE_ID is not null
),

parent as (
    select ID as to_field
    from NDIS_DB.RAW.sp_invoices
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


