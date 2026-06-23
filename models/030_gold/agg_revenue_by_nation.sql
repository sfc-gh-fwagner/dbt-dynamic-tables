-- Aggregation: total revenue by nation and region
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='1 minute'
    )
}}

select
    c.nation_name,
    c.region_name,
    count(distinct f.order_key) as total_orders,
    count(distinct f.customer_key) as total_customers,
    sum(f.gross_amount) as gross_revenue,
    sum(f.net_amount) as net_revenue,
    sum(f.charged_amount) as charged_revenue
from {{ ref('fct_orders') }} f
inner join {{ ref('dim_customers') }} c on f.customer_key = c.customer_key
group by 1, 2
