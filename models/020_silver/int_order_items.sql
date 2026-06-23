-- Silver: line items joined to order context, built on cleaned entities
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    li.order_key,
    li.line_number,
    li.part_key,
    li.supplier_key,
    li.quantity,
    li.extended_price,
    li.discount,
    li.tax,
    li.net_price,
    li.charged_price,
    li.return_flag,
    li.line_status,
    li.ship_date,
    li.commit_date,
    li.receipt_date,
    li.shipping_days,
    li.is_late_receipt,
    li.ship_mode,
    o.customer_key,
    o.order_date,
    o.order_year,
    o.order_month,
    o.order_status,
    o.order_status_desc,
    o.order_priority
from {{ ref('int_lineitems') }} li
inner join {{ ref('int_orders') }} o on li.order_key = o.order_key
