
    
    

select
    INVOICE_NUMBER as unique_field,
    count(*) as n_records

from NDIS_DB.RAW.sp_invoices
where INVOICE_NUMBER is not null
group by INVOICE_NUMBER
having count(*) > 1


