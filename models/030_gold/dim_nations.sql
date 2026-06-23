-- Gold: nation dimension with region context
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    nation_key,
    nation_name,
    region_key,
    region_name
from {{ ref('int_nations') }}
