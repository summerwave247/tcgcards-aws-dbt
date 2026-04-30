{{ config(materialized='table') }}

select
    product_id,
    any_value(product_name)  as product_name,
    any_value(game_set)      as game_set,
    count(*)                 as total_transactions,
    sum(quantity)            as total_units_sold
from {{ ref('int_transactions_enriched') }}
group by product_id