
    
    

select
    support_item_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.dim_support_item
where support_item_key is not null
group by support_item_key
having count(*) > 1


