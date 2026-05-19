
    
    

select
    leave_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.fact_leave
where leave_key is not null
group by leave_key
having count(*) > 1


