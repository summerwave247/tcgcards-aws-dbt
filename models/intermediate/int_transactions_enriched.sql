{{ config(materialized='view') }}

select
    order_id,
    product_id,
    product_name,
    game_set,
    condition_raw,
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

    -- SKU = Product ID + Condition (Cell 36)
    cast(product_id as varchar) || ' ' || condition_raw as sku,

    -- Residual = Unit Price - Market Price (Cell 27)
    unit_price - market_price as residual,

    -- Log Price = log1p(Unit Price) (Cell 38)
    ln(unit_price + 1) as log_price,

    -- Price-to-market ratio (衍生指标，分析常用)
    case
        when market_price > 0 then unit_price / market_price
        else null
    end as price_to_market_ratio
from {{ ref('stg_transactions') }}