
    
    

select
    payroll_key as unique_field,
    count(*) as n_records

from NDIS_DB.MARTS.fact_payroll
where payroll_key is not null
group by payroll_key
having count(*) > 1


