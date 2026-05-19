
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select INVOICE_ID
from NDIS_DB.RAW.sp_payments
where INVOICE_ID is null



  
  
      
    ) dbt_internal_test