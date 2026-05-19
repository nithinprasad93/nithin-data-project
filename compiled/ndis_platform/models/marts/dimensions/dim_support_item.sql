-- NDIS support item dimension
-- Deduplicates from support item transactions to build a catalogue dimension

with support_items as (
    select * from NDIS_DB.STAGING.stg_sp_support_items
),

-- One row per unique support item number (catalogue entry)
deduped as (
    select
        support_item_number,
        support_item_name,
        support_category,
        unit_of_measure,
        gst_code,
        claim_type,
        -- use the most recent rate as the current rate
        last_value(rate) over (
            partition by support_item_number
            order by _loaded_at
            rows between unbounded preceding and unbounded following
        ) as current_rate,
        row_number() over (
            partition by support_item_number
            order by _loaded_at desc
        ) as rn
    from support_items
    where support_item_number is not null
),

final as (
    select
        md5(cast(coalesce(cast(support_item_number as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as support_item_key,
        support_item_number,
        support_item_name,
        support_category,
        -- NDIS support category groups
        case
            when support_category like '%Daily%'       then '01 - Daily Activities'
            when support_category like '%Capacity%'    then '07 - Support Coordination'
            when support_category like '%Social%'      then '04 - Assistance with Social'
            when support_category like '%Transport%'   then '02 - Transport'
            when support_category like '%Home%'        then '05 - Assistive Technology'
            else support_category
        end                     as support_category_group,
        unit_of_measure,
        gst_code,
        claim_type,
        current_rate
    from deduped
    where rn = 1
)

select * from final