
    
    

select
    ID as unique_field,
    count(*) as n_records

from NDIS_DB.RAW.eh_teams
where ID is not null
group by ID
having count(*) > 1


