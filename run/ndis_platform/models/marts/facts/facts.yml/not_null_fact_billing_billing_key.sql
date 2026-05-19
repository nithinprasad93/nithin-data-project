
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select billing_key
from NDIS_DB.MARTS.fact_billing
where billing_key is null



  
  
      
    ) dbt_internal_test