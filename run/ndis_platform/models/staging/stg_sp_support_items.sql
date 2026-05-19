
  create or replace   view NDIS_DB.STAGING.stg_sp_support_items
  
  
  
  
  as (
    with source as (
    select * from NDIS_DB.RAW.sp_support_items
),

renamed as (
    select
        id                                          as support_item_id,
        appointment_id,
        patient_id,
        support_item_number,
        support_item_name,
        lower(support_category)                    as support_category,
        upper(unit_of_measure)                     as unit_of_measure,
        try_to_decimal(quantity, 10, 2)            as quantity,
        try_to_decimal(rate, 12, 4)                as rate,
        try_to_decimal(total_amount, 12, 2)        as total_amount,
        upper(gst_code)                            as gst_code,
        lower(claim_type)                          as claim_type,
        _loaded_at
    from source
    where id is not null
    qualify row_number() over (partition by id order by _loaded_at desc) = 1
)

select * from renamed
  );

