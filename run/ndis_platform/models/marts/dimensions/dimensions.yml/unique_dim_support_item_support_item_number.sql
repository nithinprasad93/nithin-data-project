
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    support_item_number as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.dim_support_item
where support_item_number is not null
group by support_item_number
having count(*) > 1



  
  
      
    ) dbt_internal_test