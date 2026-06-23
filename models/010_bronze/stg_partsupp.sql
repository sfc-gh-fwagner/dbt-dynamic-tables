-- Staging model: clean column names for part-supplier relationships
-- Co-authored with CoCo
{{
    config(
        materialized='view'
    )
}}

select
    ps_partkey as part_key,
    ps_suppkey as supplier_key,
    ps_availqty as available_quantity,
    ps_supplycost as supply_cost,
    ps_comment as comment
from {{ source('tpch', 'PARTSUPP') }}
