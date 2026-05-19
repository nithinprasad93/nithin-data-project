
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    client_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.dim_client
where client_key is not null
group by client_key
having count(*) > 1



  
  
      
    ) dbt_internal_test