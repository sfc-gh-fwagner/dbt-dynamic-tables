-- Fact table: order-level grain with financial metrics
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    oi.order_key,
    oi.customer_key,
    oi.order_date,
    oi.order_status,
    oi.order_priority,
    count(oi.line_number) as line_item_count,
    sum(oi.quantity) as total_quantity,
    sum(oi.extended_price) as gross_amount,
    sum(oi.net_price) as net_amount,
    sum(oi.charged_price) as charged_amount,
    sum(oi.extended_price - oi.net_price) as total_discount_amount
from {{ ref('int_order_items') }} oi
group by 1, 2, 3, 4, 5
