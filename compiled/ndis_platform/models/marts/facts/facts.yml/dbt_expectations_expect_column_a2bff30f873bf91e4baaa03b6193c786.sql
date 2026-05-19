






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and total_amount >= 0 and total_amount <= 100000
)
 as expression


    from NDIS_DB.MARTS.fact_billing
    

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







