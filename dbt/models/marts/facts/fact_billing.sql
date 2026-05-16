{{
    config(
        materialized='incremental',
        unique_key='billing_key',
        incremental_strategy='merge',
        cluster_by=['invoice_date_id']
    )
}}

with invoices as (
    select * from {{ ref('stg_sp_invoices') }}
    {% if is_incremental() %}
        where _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}
),

practitioners as (
    select practitioner_key, practitioner_id from {{ ref('dim_practitioner') }}
),

clients as (
    select client_key, patient_id from {{ ref('dim_client') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['i.invoice_id']) }} as billing_key,
        i.invoice_id,
        i.invoice_number,
        -- FK to dimensions
        i.invoice_date                          as invoice_date_id,
        i.due_date                              as due_date_id,
        coalesce(p.practitioner_key, 'UNKNOWN') as practitioner_key,
        coalesce(c.client_key, 'UNKNOWN')       as client_key,
        -- degenerate dimensions
        i.status                                as invoice_status,
        i.fund_management,
        i.payment_method,
        i.ndis_claim_ref,
        -- measures
        i.subtotal,
        i.gst_amount,
        i.total_amount,
        i.paid_amount,
        i.outstanding,
        -- flags
        i.is_paid::int                          as is_paid,
        i.is_overdue::int                       as is_overdue,
        i._loaded_at
    from invoices i
    left join practitioners p on i.practitioner_id = p.practitioner_id
    left join clients c       on i.patient_id = c.patient_id
)

select * from final
