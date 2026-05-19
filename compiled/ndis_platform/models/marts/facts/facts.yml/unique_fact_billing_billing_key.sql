
    
    

select
    billing_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.fact_billing
where billing_key is not null
group by billing_key
having count(*) > 1


