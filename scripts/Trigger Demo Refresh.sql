-- Demo trigger: insert ~10% more LINEITEM rows to fire the dynamic table refresh chain
-- Co-authored with CoCo

-- LINEITEM is the source for the bronze view stg_lineitems, which feeds the
-- silver and gold dynamic tables. Because agg_revenue_by_nation has a concrete
-- target_lag of 1 minute, this INSERT cascades a refresh up the whole tree
-- (int_lineitems -> int_order_items -> fct_orders -> agg_revenue_by_nation)
-- automatically within ~1 minute.

-- Before: check current row count
SELECT COUNT(*) AS lineitem_rows_before FROM DBT_DYNAMIC_TABLES.TPCH_SF1.LINEITEM;

-- Insert ~10% of existing rows (uses Bernoulli sampling)
INSERT INTO DBT_DYNAMIC_TABLES.TPCH_SF1.LINEITEM
SELECT * FROM DBT_DYNAMIC_TABLES.TPCH_SF1.LINEITEM SAMPLE (10);

-- After: verify ~10% increase
SELECT COUNT(*) AS lineitem_rows_after FROM DBT_DYNAMIC_TABLES.TPCH_SF1.LINEITEM;
