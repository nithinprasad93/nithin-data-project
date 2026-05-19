
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select INVOICE_NUMBER
from NDIS_DB.RAW.sp_invoices
where INVOICE_NUMBER is null



  
  
      
    ) dbt_internal_test