
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    INVOICE_NUMBER as unique_field,
    count(*) as n_records

from NDIS_DB.RAW.sp_invoices
where INVOICE_NUMBER is not null
group by INVOICE_NUMBER
having count(*) > 1



  
  
      
    ) dbt_internal_test