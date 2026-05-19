
  create or replace   view NDIS_DB.STAGING.stg_eh_employees
  
  
  
  
  as (
    with source as (
    select * from NDIS_DB.RAW.eh_employees
),

renamed as (
    select
        id                                              as employee_id,
        organisation_id,
        first_name,
        last_name,
        first_name || ' ' || last_name                 as full_name,
        lower(email)                                   as email,
        try_to_date(date_of_birth, 'YYYY-MM-DD')       as date_of_birth,
        lower(gender)                                  as gender,
        lower(pronouns)                                as pronouns,
        phone,
        address,
        job_title,
        lower(employment_type)                         as employment_type,
        lower(status)                                  as status,
        try_to_date(start_date, 'YYYY-MM-DD')          as start_date,
        try_to_date(termination_date, 'YYYY-MM-DD')    as termination_date,
        primary_manager_id,
        team_id,
        department_id,
        cost_centre_id,
        employing_entity_id,
        lower(payroll_type)                            as payroll_type,
        custom_fields,
        -- derive practitioner flag from job title keywords
        case
            when lower(job_title) like any (
                '%occupational therapist%', '%physiotherapist%',
                '%speech pathologist%', '%psychologist%',
                '%social worker%', '%dietitian%', '%exercise physiologist%',
                '%behaviour support%', '%support coordinator%'
            ) then true
            else false
        end                                             as is_practitioner,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
  );

