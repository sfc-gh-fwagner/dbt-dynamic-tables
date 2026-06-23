-- Silver: cleaned customers enriched with nation and region
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
    trim(c.customer_name) as customer_name,
    trim(c.address) as address,
    c.nation_key,
    n.nation_name,
    n.region_name,
    trim(c.phone) as phone,
    c.account_balance,
    upper(trim(c.market_segment)) as market_segment,
    case when c.account_balance < 0 then true else false end as has_negative_balance
from {{ ref('stg_customers') }} c
inner join {{ ref('int_nations') }} n on c.nation_key = n.nation_key
