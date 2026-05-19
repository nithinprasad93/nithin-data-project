
    
    

with all_values as (

    select
        fund_management as value_field,
        count(*) as n_records

    from NDIS_DB.MARTS.dim_client
    group by fund_management

)

select *
from all_values
where value_field not in (
    'ndia_managed','plan_managed','self_managed','private'
)


