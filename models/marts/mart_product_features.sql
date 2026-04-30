{{ config(materialized='table') }}

with base as (
    select * from {{ ref('int_transactions_enriched') }}
),

agg as (
    select
        product_id,
        count(*)                                                                  as orders,
        date_diff('day', min(order_date), max(order_date)) + 1                     as active_days,
        avg(unit_price)                                                            as mean_price,
        stddev(unit_price)                                                         as price_std,

        -- Mix ratios (Cell 29)
        avg(case when condition_category = 'Near Mint' then 1.0 else 0.0 end)     as nm_ratio,
        avg(case when foil_status        = 'Foil'      then 1.0 else 0.0 end)     as foil_ratio,
        avg(case when language           = 'English'   then 1.0 else 0.0 end)     as english_ratio,
        avg(condition_score)                                                       as avg_condition_score,

        -- Forecast accuracy: market price 当作 baseline forecast (Cell 29)
        avg(abs(residual))                                                         as mae,
        sqrt(avg(power(residual, 2)))                                              as rmse,
        avg(abs(residual) / nullif(unit_price, 0)) * 100                           as mape
    from base
    group by product_id
)

select
    product_id,
    mean_price,
    price_std,
    cast(orders as double) / nullif(active_days, 0) as frequency,
    active_days,
    orders,
    nm_ratio,
    foil_ratio,
    english_ratio,
    avg_condition_score,
    mae,
    rmse,
    mape
from agg