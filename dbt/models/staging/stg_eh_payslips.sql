with source as (
    select * from {{ source('employment_hero', 'eh_payslips') }}
),

renamed as (
    select
        id                                                  as payslip_id,
        employee_id,
        organisation_id,
        try_to_date(pay_period_start, 'YYYY-MM-DD')        as pay_period_start,
        try_to_date(pay_period_end, 'YYYY-MM-DD')          as pay_period_end,
        try_to_decimal(gross_earnings, 12, 2)              as gross_earnings,
        try_to_decimal(net_earnings, 12, 2)                as net_earnings,
        try_to_decimal(tax_withheld, 12, 2)                as tax_withheld,
        try_to_decimal(superannuation, 12, 2)              as superannuation,
        try_to_decimal(total_deductions, 12, 2)            as total_deductions,
        try_to_date(payment_date, 'YYYY-MM-DD')            as payment_date,
        lower(status)                                       as status,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
