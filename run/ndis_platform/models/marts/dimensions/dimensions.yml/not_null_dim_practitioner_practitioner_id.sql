
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select practitioner_id
from NDIS_DB.MARTS.dim_practitioner
where practitioner_id is null



  
  
      
    ) dbt_internal_test