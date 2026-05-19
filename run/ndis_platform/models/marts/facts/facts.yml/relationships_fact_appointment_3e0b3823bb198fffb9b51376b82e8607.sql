
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select appointment_date_id as from_field
    from NDIS_DB.MARTS.fact_appointments
    where appointment_date_id is not null
),

parent as (
    select date_id as to_field
    from NDIS_DB.MARTS.dim_date
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test