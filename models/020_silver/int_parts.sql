-- Silver: cleaned part catalog with standardized text and size buckets
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    part_key,
    trim(part_name) as part_name,
    trim(manufacturer) as manufacturer,
    trim(brand) as brand,
    trim(part_type) as part_type,
    part_size,
    trim(container) as container,
    retail_price,
    case
        when part_size <= 10 then 'SMALL'
        when part_size <= 30 then 'MEDIUM'
        else 'LARGE'
    end as size_bucket
from {{ ref('stg_parts') }}
