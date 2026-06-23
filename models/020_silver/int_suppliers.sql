-- Silver: cleaned suppliers enriched with nation and region
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    s.supplier_key,
    trim(s.supplier_name) as supplier_name,
    trim(s.address) as address,
    s.nation_key,
    n.nation_name,
    n.region_name,
    trim(s.phone) as phone,
    s.account_balance,
    case when s.account_balance < 0 then true else false end as has_negative_balance
from {{ ref('stg_suppliers') }} s
inner join {{ ref('int_nations') }} n on s.nation_key = n.nation_key
