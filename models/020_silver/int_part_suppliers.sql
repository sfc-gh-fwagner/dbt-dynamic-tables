-- Silver: part-supplier records enriched with part, supplier, and geography
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    ps.part_key,
    ps.supplier_key,
    ps.available_quantity,
    ps.supply_cost,
    ps.is_out_of_stock,
    p.part_name,
    p.manufacturer,
    p.brand,
    p.part_type,
    p.size_bucket,
    p.retail_price,
    s.supplier_name,
    s.nation_name,
    s.region_name
from {{ ref('int_partsupp') }} ps
inner join {{ ref('int_parts') }} p on ps.part_key = p.part_key
inner join {{ ref('int_suppliers') }} s on ps.supplier_key = s.supplier_key
