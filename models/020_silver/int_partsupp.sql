-- Silver: cleaned part-supplier availability and cost
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
    supplier_key,
    available_quantity,
    supply_cost,
    case when available_quantity = 0 then true else false end as is_out_of_stock
from {{ ref('stg_partsupp') }}
