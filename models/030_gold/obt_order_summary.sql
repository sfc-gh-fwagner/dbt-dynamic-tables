-- One-big-table: denormalized order summary for analytics
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    f.order_key,
    f.order_date,
    f.order_status,
    f.order_priority,
    f.line_item_count,
    f.total_quantity,
    f.gross_amount,
    f.net_amount,
    f.charged_amount,
    f.total_discount_amount,
    c.customer_name,
    c.market_segment,
    c.nation_name,
    c.region_name
from {{ ref('fct_orders') }} f
inner join {{ ref('dim_customers') }} c on f.customer_key = c.customer_key
