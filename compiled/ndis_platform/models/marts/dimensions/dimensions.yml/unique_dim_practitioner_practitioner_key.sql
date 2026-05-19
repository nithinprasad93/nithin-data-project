
    
    

select
    practitioner_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.dim_practitioner
where practitioner_key is not null
group by practitioner_key
having count(*) > 1


