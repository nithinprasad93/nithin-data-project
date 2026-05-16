{{
    config(
        materialized='incremental',
        unique_key='leave_key',
        incremental_strategy='merge'
    )
}}

with leave as (
    select * from {{ ref('stg_eh_leave_requests') }}
    {% if is_incremental() %}
        where _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}
),

practitioners as (
    select practitioner_key, eh_employee_id from {{ ref('dim_practitioner') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['l.leave_request_id']) }} as leave_key,
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
