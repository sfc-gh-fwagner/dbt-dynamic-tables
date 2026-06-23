-- Gold: line-item grain fact table with pricing and shipping metrics
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
    oi.line_number,
    oi.part_key,
    oi.supplier_key,
    oi.customer_key,
    oi.order_date,
    oi.order_year,
    oi.order_month,
    oi.quantity,
    oi.extended_price as gross_amount,
    oi.net_price as net_amount,
    oi.charged_price as charged_amount,
    oi.discount,
    oi.tax,
    oi.shipping_days,
    oi.is_late_receipt,
    oi.return_flag,
    oi.ship_mode
from {{ ref('int_order_items') }} oi
