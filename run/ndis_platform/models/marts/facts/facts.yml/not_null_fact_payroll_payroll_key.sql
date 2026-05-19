
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select payroll_key
from NDIS_DB.MARTS.fact_payroll
where payroll_key is null



  
  
      
    ) dbt_internal_test