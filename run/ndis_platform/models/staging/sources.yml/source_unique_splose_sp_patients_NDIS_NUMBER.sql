
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    NDIS_NUMBER as unique_field,
    count(*) as n_records

from NDIS_DB.RAW.sp_patients
where NDIS_NUMBER is not null
group by NDIS_NUMBER
having count(*) > 1



  
  
      
    ) dbt_internal_test