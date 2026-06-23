-- Silver: cleaned region reference data with standardized text
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
    trim(initcap(region_name)) as region_name,
    trim(comment) as region_comment
from {{ ref('stg_regions') }}
