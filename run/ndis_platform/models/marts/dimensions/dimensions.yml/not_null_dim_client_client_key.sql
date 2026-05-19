
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select client_key
from NDIS_DB.MARTS.dim_client
where client_key is null



  
  
      
    ) dbt_internal_test