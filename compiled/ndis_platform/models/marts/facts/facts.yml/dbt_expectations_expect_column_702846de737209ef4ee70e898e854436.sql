






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and gross_earnings >= 0 and gross_earnings <= 50000
)
 as expression


    from NDIS_DB.MARTS.fact_payroll
    

),
validation_errors as (

    select
        *
    from
        grouped_expression
    where
        not(expression = true)

)

select *
from validation_errors







