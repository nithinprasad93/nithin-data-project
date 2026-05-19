
    
    

select
    compliance_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.fact_compliance
where compliance_key is not null
group by compliance_key
having count(*) > 1


