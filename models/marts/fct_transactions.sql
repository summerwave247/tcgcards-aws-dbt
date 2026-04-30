{{ config(materialized='table') }}

select
    order_id,
    product_id,
    sku,
    condition_category,
    condition_score,
    foil_status,
    language,
    order_date,
    order_hour,
    quantity,
    unit_price,
    total_product_price,
    market_price,
    residual,
    log_price,
    price_to_market_ratio
from {{ ref('int_transactions_enriched') }}