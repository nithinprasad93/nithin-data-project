
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        FUND_MANAGEMENT as value_field,
        count(*) as n_records

    from NDIS_DB.RAW.sp_patients
    group by FUND_MANAGEMENT

)

select *
from all_values
where value_field not in (
    'ndia_managed','plan_managed','self_managed','private'
)



  
  
      
    ) dbt_internal_test