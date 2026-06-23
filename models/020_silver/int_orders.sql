-- Silver: cleaned orders with derived date parts and status flags
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    order_key,
    customer_key,
    order_status,
    case
        when order_status = 'O' then 'Open'
        when order_status = 'F' then 'Fulfilled'
        when order_status = 'P' then 'Partial'
        else 'Unknown'
    end as order_status_desc,
    total_price,
    order_date,
    year(order_date) as order_year,
    month(order_date) as order_month,
    trim(order_priority) as order_priority,
    trim(clerk) as clerk,
    ship_priority
from {{ ref('stg_orders') }}
