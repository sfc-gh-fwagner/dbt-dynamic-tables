-- Silver: cleaned line items with computed pricing and shipping lag
-- Co-authored with CoCo
{{
    config(
        materialized='dynamic_table',
        snowflake_warehouse='ADAPT_WH',
        target_lag='downstream'
    )
}}

select
    order_key,
    line_number,
    part_key,
    supplier_key,
    quantity,
    extended_price,
    discount,
    tax,
    round(extended_price * (1 - discount), 2) as net_price,
    round(extended_price * (1 - discount) * (1 + tax), 2) as charged_price,
    return_flag,
    line_status,
    ship_date,
    commit_date,
    receipt_date,
    datediff('day', ship_date, receipt_date) as shipping_days,
    case when receipt_date > commit_date then true else false end as is_late_receipt,
    trim(ship_mode) as ship_mode
from {{ ref('stg_lineitems') }}
