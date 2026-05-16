with source as (
    select * from {{ source('employment_hero', 'eh_timesheet_entries') }}
),

renamed as (
    select
        id                                                          as timesheet_id,
        employee_id,
        organisation_id,
        try_to_date(date, 'YYYY-MM-DD')                            as work_date,
        try_to_timestamp(start_time, 'YYYY-MM-DD HH24:MI:SS')     as start_time,
        try_to_timestamp(end_time, 'YYYY-MM-DD HH24:MI:SS')       as end_time,
        try_to_decimal(break_duration, 10, 2)                      as break_hours,
        try_to_decimal(total_hours, 10, 2)                         as total_hours,
        work_type_id,
        work_location_id,
        notes,
        lower(status)                                               as status,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
