with source as (
    select * from {{ source('splose', 'sp_invoices') }}
),

renamed as (
    select
        id                                              as invoice_id,
        patient_id,
        practitioner_id,
        invoice_number,
        try_to_date(invoice_date, 'YYYY-MM-DD')        as invoice_date,
        try_to_date(due_date, 'YYYY-MM-DD')            as due_date,
        lower(status)                                  as status,
        lower(fund_management)                         as fund_management,
        try_to_decimal(subtotal, 12, 2)               as subtotal,
        try_to_decimal(gst_amount, 12, 2)             as gst_amount,
        try_to_decimal(total_amount, 12, 2)           as total_amount,
        try_to_decimal(paid_amount, 12, 2)            as paid_amount,
        try_to_decimal(outstanding, 12, 2)            as outstanding,
        lower(payment_method)                          as payment_method,
        ndis_claim_ref,
        -- derived
        case when lower(status) = 'paid' then true else false end as is_paid,
        case
            when lower(status) = 'overdue'
                 or (due_date is not null
                     and try_to_date(due_date, 'YYYY-MM-DD') < current_date()
                     and lower(status) not in ('paid', 'void'))
            then true else false
        end                                             as is_overdue,
        _loaded_at
    from source
    where id is not null
)

select * from renamed
