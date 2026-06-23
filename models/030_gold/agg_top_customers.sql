-- Aggregation: top customers ranked by total spend
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
    nation_name,
    region_name,
    market_segment,
    total_orders,
    total_spent,
    first_order_date,
    last_order_date,
    rank() over (order by total_spent desc) as spend_rank
from {{ ref('dim_customers') }}
