---
title: Horizon Allied Health — Business Overview
---

```sql business_summary
select
    count(distinct practitioner_key)                          as active_practitioners,
    count(*)                                                  as total_appointments,
    sum(is_completed)                                         as completed_appointments,
    sum(is_cancelled + is_dna)                               as cancelled_dna,
    round(sum(is_completed)::float / nullif(count(*), 0) * 100, 1) as attendance_rate_pct
from snowflake.fact_appointments
```

```sql billing_summary
select
    sum(total_amount)                                                    as total_invoiced,
    sum(paid_amount)                                                     as total_collected,
    sum(outstanding)                                                     as total_outstanding,
    round(sum(paid_amount) / nullif(sum(total_amount), 0) * 100, 1)    as collection_rate_pct,
    count(*)                                                             as total_invoices,
    sum(is_overdue)                                                      as overdue_invoices
from snowflake.fact_billing
```

```sql revenue_by_week
select
    date_trunc('week', invoice_date_id)   as week,
    sum(total_amount)                      as revenue,
    sum(paid_amount)                       as collected
from snowflake.fact_billing
group by 1
order by 1
```

```sql appointments_by_week
select
    date_trunc('week', appointment_date_id)  as week,
    count(*)                                  as total,
    sum(is_completed)                         as completed,
    sum(is_cancelled + is_dna)               as cancelled_dna
from snowflake.fact_appointments
group by 1
order by 1
```

```sql revenue_by_fund_type
select
    fund_management,
    sum(total_amount)  as revenue,
    count(*)           as invoices
from snowflake.fact_billing
group by 1
order by 2 desc
```

```sql appointments_by_type
select
    appointment_type,
    count(*)          as total,
    sum(is_completed) as completed
from snowflake.fact_appointments
group by 1
order by 2 desc
```

```sql top_practitioners
select
    p.practitioner_name,
    p.discipline,
    count(fa.appointment_key)                                              as appointments,
    sum(fa.is_completed)                                                   as completed,
    round(sum(fa.is_completed)::float / nullif(count(fa.appointment_key), 0) * 100, 1) as attendance_pct,
    coalesce(sum(fb.total_amount), 0)                                      as revenue_generated
from snowflake.fact_appointments fa
join snowflake.dim_practitioner p on fa.practitioner_key = p.practitioner_key
left join snowflake.fact_billing fb on fb.practitioner_key = fa.practitioner_key
where p.practitioner_key != 'UNKNOWN'
group by 1, 2
order by revenue_generated desc
limit 10
```

# Horizon Allied Health

## At a Glance

<BigValue
    data={business_summary}
    value=active_practitioners
    title="Active Practitioners"
/>

<BigValue
    data={business_summary}
    value=total_appointments
    title="Total Appointments"
/>

<BigValue
    data={business_summary}
    value=attendance_rate_pct
    title="Attendance Rate"
    fmt=pct1
/>

<BigValue
    data={billing_summary}
    value=total_invoiced
    title="Total Invoiced"
    fmt=usd2k
/>

<BigValue
    data={billing_summary}
    value=collection_rate_pct
    title="Collection Rate"
    fmt=pct1
/>

<BigValue
    data={billing_summary}
    value=overdue_invoices
    title="Overdue Invoices"
/>

---

## Revenue Trend

<BarChart
    data={revenue_by_week}
    x=week
    y=revenue
    title="Weekly Revenue ($)"
    yFmt=usd0k
/>

## Appointment Volume

<BarChart
    data={appointments_by_week}
    x=week
    y={["completed","cancelled_dna"]}
    title="Appointments by Week"
    type=stacked
/>

---

## Revenue by Funding Type

<BarChart
    data={revenue_by_fund_type}
    x=fund_management
    y=revenue
    title="Revenue by Fund Management"
    yFmt=usd0k
    swapXY=true
/>

## Appointment Types

<DataTable data={appointments_by_type} rows=5>
    <Column id=appointment_type title="Type"/>
    <Column id=total title="Total"/>
    <Column id=completed title="Completed"/>
</DataTable>

---

## Top Practitioners by Revenue

<DataTable data={top_practitioners}>
    <Column id=practitioner_name title="Practitioner"/>
    <Column id=discipline title="Discipline"/>
    <Column id=appointments title="Appointments" align=right/>
    <Column id=attendance_pct title="Attendance %" fmt=pct1 align=right/>
    <Column id=revenue_generated title="Revenue" fmt=usd0k align=right/>
</DataTable>

[View Practitioner Detail →](/practitioners)
