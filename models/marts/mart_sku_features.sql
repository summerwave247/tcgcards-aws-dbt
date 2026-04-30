{{ config(materialized='table') }}

with base as (
    select * from {{ ref('int_transactions_enriched') }}
),

agg as (
    select
        sku,
        avg(unit_price)                                          as mean_price,
        stddev(unit_price)                                       as price_std,
        avg(log_price)                                           as mean_log_price,
        stddev(log_price)                                        as log_price_std,
        date_diff('day', min(order_date), max(order_date)) + 1   as active_days,
        count(distinct order_date)                               as unique_days,
        count(*)                                                 as sales,
        avg(condition_score)                                     as condition_score,

        -- Forecast accuracy metrics
        avg(abs(residual))                                       as mae,
        sqrt(avg(power(residual, 2)))                            as rmse,
        avg(abs(residual) / nullif(unit_price, 0)) * 100         as mape
    from base
    group by sku
)

select
    sku,
    mean_price,
    price_std,
    mean_log_price,
    log_price_std,
    active_days,
    unique_days,
    sales,
    condition_score,
    cast(sales as double) / nullif(active_days, 0) as frequency_all_days,
    cast(sales as double) / nullif(unique_days, 0) as frequency_trade_days,
    mae,
    rmse,
    mape
from agg