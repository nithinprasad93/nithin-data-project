with source as (
    select * from NDIS_DB.RAW.eh_leave_requests
),

renamed as (
    select
        id                                              as leave_request_id,
        employee_id,
        organisation_id,
        leave_category_id,
        lower(leave_type)                              as leave_type,
        try_to_date(start_date, 'YYYY-MM-DD')          as start_date,
        try_to_date(end_date, 'YYYY-MM-DD')            as end_date,
        try_to_decimal(hours_requested, 10, 2)         as hours_requested,
        datediff('day',
            try_to_date(start_date, 'YYYY-MM-DD'),
            try_to_date(end_date, 'YYYY-MM-DD')
        ) + 1                                           as calendar_days,
        lower(status)                                  as status,
        reason,
        approved_by_id,
        _loaded_at
    from source
    where id is not null
)

select * from renamed