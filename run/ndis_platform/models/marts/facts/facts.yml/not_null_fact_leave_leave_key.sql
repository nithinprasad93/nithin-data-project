
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select leave_key
from NDIS_DB.MARTS.fact_leave
where leave_key is null



  
  
      
    ) dbt_internal_test