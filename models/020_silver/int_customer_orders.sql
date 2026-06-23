-- Silver: per-customer order rollup built on cleaned entities
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    c.customer_key,
    c.customer_name,
    c.market_segment,
    c.nation_name,
    c.region_name,
    count(o.order_key) as total_orders,
    sum(o.total_price) as total_spent,
    min(o.order_date) as first_order_date,
    max(o.order_date) as last_order_date
from {{ ref('int_customers') }} c
left join {{ ref('int_orders') }} o on c.customer_key = o.customer_key
group by 1, 2, 3, 4, 5
