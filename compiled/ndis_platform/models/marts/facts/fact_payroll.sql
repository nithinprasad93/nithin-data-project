

with payslips as (
    select * from NDIS_DB.STAGING.stg_eh_payslips
    
        where _loaded_at > (select max(_loaded_at) from NDIS_DB.MARTS.fact_payroll)
    
),

practitioners as (
    select practitioner_key, eh_employee_id from NDIS_DB.MARTS.dim_practitioner
),

final as (
    select
        md5(cast(coalesce(cast(ps.payslip_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as payroll_key,
        ps.payslip_id,
        ps.pay_period_start                             as pay_period_start_id,
        ps.pay_period_end                               as pay_period_end_id,
        ps.payment_date                                 as payment_date_id,
        coalesce(p.practitioner_key, 'UNKNOWN')         as practitioner_key,
        ps.employee_id,
        -- measures
        ps.gross_earnings,
        ps.net_earnings,
        ps.tax_withheld,
        ps.superannuation,
        ps.total_deductions,
        -- derived
        round(ps.tax_withheld / nullif(ps.gross_earnings, 0) * 100, 2) as effective_tax_rate_pct,
        round(ps.superannuation / nullif(ps.gross_earnings, 0) * 100, 2) as super_rate_pct,
        ps.status,
        ps._loaded_at
    from payslips ps
    left join practitioners p on ps.employee_id = p.eh_employee_id
)

select * from final