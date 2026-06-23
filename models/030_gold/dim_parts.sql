-- Dimension: part catalog with supplier availability
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
    part_name,
    manufacturer,
    brand,
    part_type,
    retail_price,
    count(distinct supplier_key) as supplier_count,
    sum(available_quantity) as total_available_quantity,
    avg(supply_cost) as avg_supply_cost
from {{ ref('int_part_suppliers') }}
group by 1, 2, 3, 4, 5, 6
