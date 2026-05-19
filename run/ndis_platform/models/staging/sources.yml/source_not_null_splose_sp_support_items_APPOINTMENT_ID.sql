
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select APPOINTMENT_ID
from NDIS_DB.RAW.sp_support_items
where APPOINTMENT_ID is null



  
  
      
    ) dbt_internal_test