-- Dimension: customer attributes with order history summary
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    customer_key,
    customer_name,
    market_segment,
    nation_name,
    region_name,
    total_orders,
    total_spent,
    first_order_date,
    last_order_date
from {{ ref('int_customer_orders') }}
