

with leave as (
    select * from NDIS_DB.STAGING.stg_eh_leave_requests
    
        where _loaded_at > (select max(_loaded_at) from NDIS_DB.MARTS.fact_leave)
    
),

practitioners as (
    select practitioner_key, eh_employee_id from NDIS_DB.MARTS.dim_practitioner
),

final as (
    select
        md5(cast(coalesce(cast(l.leave_request_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as leave_key,
        l.leave_request_id,
        l.start_date                                    as start_date_id,
        l.end_date                                      as end_date_id,
        coalesce(p.practitioner_key, 'UNKNOWN')         as practitioner_key,
        l.employee_id,
        l.leave_type,
        l.status,
        -- measures
        l.hours_requested,
        l.calendar_days,
        -- flag approved only
        case when l.status = 'approved' then l.hours_requested else 0 end as approved_hours,
        case when l.status = 'approved' then l.calendar_days else 0 end   as approved_days,
        l._loaded_at
    from leave l
    left join practitioners p on l.employee_id = p.eh_employee_id
)

select * from final