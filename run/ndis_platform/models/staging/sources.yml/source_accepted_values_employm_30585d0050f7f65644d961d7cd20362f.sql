
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        STATUS as value_field,
        count(*) as n_records

    from NDIS_DB.RAW.eh_leave_requests
    group by STATUS

)

select *
from all_values
where value_field not in (
    'pending','approved','declined','cancelled'
)



  
  
      
    ) dbt_internal_test