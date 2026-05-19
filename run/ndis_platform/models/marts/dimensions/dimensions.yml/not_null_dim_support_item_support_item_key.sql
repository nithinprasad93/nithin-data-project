
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select support_item_key
from NDIS_DB.MARTS.dim_support_item
where support_item_key is null



  
  
      
    ) dbt_internal_test