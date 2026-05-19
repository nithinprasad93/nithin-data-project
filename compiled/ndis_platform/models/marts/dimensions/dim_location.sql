with locations as (
    select
        id          as location_id,
        name        as location_name,
        address,
        suburb,
        upper(state) as state,
        postcode,
        phone,
        case when lower(is_active) = 'true' then true else false end as is_active,
        _loaded_at
    from NDIS_DB.RAW.sp_locations
),

final as (
    select
        md5(cast(coalesce(cast(location_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as location_key,
        location_id,
        location_name,
        address,
        suburb,
        state,
        postcode,
        phone,
        is_active,
        _loaded_at
    from locations
)

select * from final