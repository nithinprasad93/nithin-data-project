
    
    

with all_values as (

    select
        discipline as value_field,
        count(*) as n_records

    from NDIS_DB.MARTS.dim_practitioner
    group by discipline

)

select *
from all_values
where value_field not in (
    'occupational_therapy','physiotherapy','speech_pathology','psychology','social_work','dietetics','exercise_physiology','behaviour_support','support_coordination'
)


