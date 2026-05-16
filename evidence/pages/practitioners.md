---
title: Practitioner Performance
---

```sql practitioner_list
select
    practitioner_key,
    practitioner_name || ' — ' || discipline as label
from snowflake.dim_practitioner
where practitioner_key != 'UNKNOWN'
order by practitioner_name
```

<Dropdown
    data={practitioner_list}
    name=practitioner
    value=practitioner_key
    label=label
    title="Select Practitioner"
>
    <DropdownOption value="%" valueLabel="All Practitioners"/>
</Dropdown>

```sql practitioner_kpis
select
    p.practitioner_name,
    p.discipline,
    p.employment_type,
    count(fa.appointment_key)                                              as total_appointments,
    sum(fa.is_completed)                                                   as completed,
    sum(fa.is_cancelled)                                                   as cancelled,
    sum(fa.is_dna)                                                         as dna,
    round(sum(fa.is_completed)::float / nullif(count(fa.appointment_key), 0) * 100, 1) as attendance_rate_pct,
    coalesce(sum(fb.total_amount), 0)                                      as total_invoiced,
    coalesce(sum(fb.paid_amount), 0)                                       as total_collected,
    coalesce(sum(fb.outstanding), 0)                                       as outstanding
from snowflake.fact_appointments fa
join snowflake.dim_practitioner p on fa.practitioner_key = p.practitioner_key
left join snowflake.fact_billing fb on fb.practitioner_key = fa.practitioner_key
where fa.practitioner_key like '${inputs.practitioner.value}'
    and p.practitioner_key != 'UNKNOWN'
group by 1, 2, 3
```

```sql weekly_appointments
select
    date_trunc('week', appointment_date_id)  as week,
    sum(is_completed)                         as completed,
    sum(is_cancelled)                         as cancelled,
    sum(is_dna)                               as dna
from snowflake.fact_appointments
where practitioner_key like '${inputs.practitioner.value}'
group by 1
order by 1
```

```sql weekly_revenue
select
    date_trunc('week', invoice_date_id)  as week,
    sum(total_amount)                     as invoiced,
    sum(paid_amount)                      as collected
from snowflake.fact_billing
where practitioner_key like '${inputs.practitioner.value}'
group by 1
order by 1
```

```sql client_breakdown
select
    c.client_name                                    as client,
    c.fund_management                                as funding_type,
    count(fa.appointment_key)                        as appointments,
    sum(fa.is_completed)                             as completed,
    coalesce(sum(fb.total_amount), 0)                as invoiced
from snowflake.fact_appointments fa
join snowflake.dim_client c on fa.client_key = c.client_key
left join snowflake.fact_billing fb
    on fb.practitioner_key = fa.practitioner_key
    and fb.client_key = fa.client_key
where fa.practitioner_key like '${inputs.practitioner.value}'
    and c.client_key != 'UNKNOWN'
group by 1, 2
order by invoiced desc
```

# Practitioner Performance

## Summary

<BigValue
    data={practitioner_kpis}
    value=total_appointments
    title="Total Appointments"
/>

<BigValue
    data={practitioner_kpis}
    value=completed
    title="Completed"
/>

<BigValue
    data={practitioner_kpis}
    value=attendance_rate_pct
    title="Attendance Rate"
    fmt=pct1
/>

<BigValue
    data={practitioner_kpis}
    value=total_invoiced
    title="Total Invoiced"
    fmt=usd2k
/>

<BigValue
    data={practitioner_kpis}
    value=outstanding
    title="Outstanding"
    fmt=usd2k
/>

---

## Weekly Appointments

<BarChart
    data={weekly_appointments}
    x=week
    y={["completed","cancelled","dna"]}
    title="Appointments by Week"
    type=stacked
/>

## Weekly Revenue

<LineChart
    data={weekly_revenue}
    x=week
    y={["invoiced","collected"]}
    title="Revenue vs Collected ($)"
    yFmt=usd0k
/>

---

## Client Breakdown

<DataTable data={client_breakdown} rows=15>
    <Column id=client title="Client"/>
    <Column id=funding_type title="Funding"/>
    <Column id=appointments title="Appointments" align=right/>
    <Column id=completed title="Completed" align=right/>
    <Column id=invoiced title="Invoiced" fmt=usd0k align=right/>
</DataTable>

[← Back to Overview](/)
