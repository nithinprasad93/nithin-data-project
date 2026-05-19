
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    appointment_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.fact_appointments
where appointment_key is not null
group by appointment_key
having count(*) > 1



  
  
      
    ) dbt_internal_test