-- Staging model: clean column names for nations
-- Co-authored with CoCo
{{
    config(
        materialized='view'
    )
}}

select
    n_nationkey as nation_key,
    n_name as nation_name,
    n_regionkey as region_key,
    n_comment as comment
from {{ source('tpch', 'NATION') }}
