{{ config(materialized='view') }}

with source as (
    select * from {{ ref('merged_cards_data') }}
),

cleaned as (
    select
        trim("Seller Order Number") as order_id,
        try_cast("Product ID" as bigint) as product_id,
        trim("Product Name") as product_name,
        trim("Condition") as condition_raw,
        trim("Game") as game,
        trim("Set") as game_set,

        coalesce(
            try_cast("Ordered At Date" as date),
            cast(try_strptime(cast("Ordered At Date" as varchar), '%m/%d/%y') as date),
            cast(try_strptime(cast("Ordered At Date" as varchar), '%m/%d/%Y') as date),
            cast(try_strptime(cast("Ordered At Date" as varchar), '%Y-%m-%d') as date)
        ) as order_date,

        case
            when cast("Second of Ordered At Time" as varchar) like '%:%' then
                try_cast(split_part(cast("Second of Ordered At Time" as varchar), ':', 1) as integer)
            else
                floor(try_cast("Second of Ordered At Time" as double) / 3600)
        end as order_hour,

        try_cast("Quantity" as integer) as quantity,
        try_cast("Unit Price" as double) as unit_price,
        try_cast("Total Product Price" as double) as total_product_price,
        try_cast("Market Price (From Day of Sale)" as double) as market_price
    from source
    where try_cast("Unit Price" as double) > 0
      and try_cast("Quantity" as integer) > 0
      and "Product ID" is not null
      and try_cast("Market Price (From Day of Sale)" as double) is not null
),

parsed as (
    select
        *,

        case
            when lower(condition_raw) like '%foil%' then 'Foil'
            else 'Non-Foil'
        end as foil_status,

        case
            when lower(condition_raw) like '%near mint%' then 'Near Mint'
            when lower(condition_raw) like '%lightly played%' then 'Lightly Played'
            when lower(condition_raw) like '%moderately played%' then 'Moderately Played'
            when lower(condition_raw) like '%heavily played%' then 'Heavily Played'
            when lower(condition_raw) like '%damaged%' then 'Damaged'
            when lower(condition_raw) like '%unopened%' then 'Unopened'
            else 'Other'
        end as condition_category,

        case
            when lower(condition_raw) like '%damaged%' then 1
            when lower(condition_raw) like '%heavily played%' then 2
            when lower(condition_raw) like '%moderately played%' then 3
            when lower(condition_raw) like '%lightly played%' then 4
            when lower(condition_raw) like '%near mint%' then 5
            when lower(condition_raw) like '%unopened%' then 6
            else null
        end as condition_score,

        case
            when lower(condition_raw) like '%japanese%' then 'Japanese'
            when lower(condition_raw) like '%german%' then 'German'
            when lower(condition_raw) like '%french%' then 'French'
            when lower(condition_raw) like '%italian%' then 'Italian'
            when lower(condition_raw) like '%spanish%' then 'Spanish'
            when lower(condition_raw) like '%korean%' then 'Korean'
            when lower(condition_raw) like '%chinese (s)%' then 'Chinese (Simplified)'
            when lower(condition_raw) like '%chinese (t)%' then 'Chinese (Traditional)'
            when lower(condition_raw) like '%chinese%' then 'Chinese'
            when lower(condition_raw) like '%russian%' then 'Russian'
            when lower(condition_raw) like '%portuguese%' then 'Portuguese'
            else 'English'
        end as language
    from cleaned
)

select *
from parsed
where order_date is not null