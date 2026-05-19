
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select PRACTITIONER_ID
from NDIS_DB.RAW.sp_appointments
where PRACTITIONER_ID is null



  
  
      
    ) dbt_internal_test