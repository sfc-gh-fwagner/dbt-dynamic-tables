-- Gold: supplier dimension with geography
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    supplier_key,
    supplier_name,
    address,
    nation_name,
    region_name,
    phone,
    account_balance,
    has_negative_balance
from {{ ref('int_suppliers') }}
