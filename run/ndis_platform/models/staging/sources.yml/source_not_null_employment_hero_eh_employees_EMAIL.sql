
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select EMAIL
from NDIS_DB.RAW.eh_employees
where EMAIL is null



  
  
      
    ) dbt_internal_test