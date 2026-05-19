






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and duration_minutes >= 0 and duration_minutes <= 480
)
 as expression


    from NDIS_DB.MARTS.fact_appointments
    

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







