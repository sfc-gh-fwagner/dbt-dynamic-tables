-- Gold: region dimension
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    region_key,
    region_name
from {{ ref('int_regions') }}
