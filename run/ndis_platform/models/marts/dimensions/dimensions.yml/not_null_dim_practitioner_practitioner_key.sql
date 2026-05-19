
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select practitioner_key
from NDIS_DB.MARTS.dim_practitioner
where practitioner_key is null



  
  
      
    ) dbt_internal_test