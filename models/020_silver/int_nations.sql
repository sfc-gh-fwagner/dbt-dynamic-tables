-- Silver: cleaned nation reference data enriched with region name
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    n.nation_key,
    trim(initcap(n.nation_name)) as nation_name,
    n.region_key,
    r.region_name,
    trim(n.comment) as nation_comment
from {{ ref('stg_nations') }} n
inner join {{ ref('int_regions') }} r on n.region_key = r.region_key
