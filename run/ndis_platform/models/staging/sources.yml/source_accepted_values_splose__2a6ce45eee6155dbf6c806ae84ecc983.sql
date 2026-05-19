
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        STATUS as value_field,
        count(*) as n_records

    from NDIS_DB.RAW.sp_appointments
    group by STATUS

)

select *
from all_values
where value_field not in (
    'scheduled','completed','cancelled','dna'
)



  
  
      
    ) dbt_internal_test