
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select ID
from NDIS_DB.RAW.eh_leave_requests
where ID is null



  
  
      
    ) dbt_internal_test