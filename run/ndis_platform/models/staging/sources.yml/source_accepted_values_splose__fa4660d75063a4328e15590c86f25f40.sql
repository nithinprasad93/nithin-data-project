
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        DISCIPLINE as value_field,
        count(*) as n_records

    from NDIS_DB.RAW.sp_practitioners
    group by DISCIPLINE

)

select *
from all_values
where value_field not in (
    'occupational_therapy','physiotherapy','speech_pathology','psychology','social_work','dietetics','exercise_physiology','behaviour_support','support_coordination'
)



  
  
      
    ) dbt_internal_test