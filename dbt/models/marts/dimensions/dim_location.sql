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
    from {{ source('splose', 'sp_locations') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['location_id']) }} as location_key,
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
