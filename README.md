# dbt + Snowflake Dynamic Tables Demo

A reference dbt project that builds an end-to-end **medallion (bronze → silver → gold)**
analytics pipeline on Snowflake, materialized almost entirely as **Snowflake Dynamic
Tables**. It demonstrates how dbt models map onto Dynamic Tables, how `target_lag`
propagation (`downstream`) creates an auto-refreshing dependency chain, and how a single
source insert cascades a refresh all the way to the gold aggregates.

The dataset is Snowflake's built-in **TPC-H SF1** sample (customers, orders, line items,
parts, suppliers, and nation/region reference data).

---

## Scope

- **29 models** organized into three medallion layers, plus schema/test definitions.
- **Source:** `DBT_DYNAMIC_TABLES.TPCH_SF1` (a local copy of `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`
  with change tracking enabled — required for Dynamic Tables).
- **Target database:** `DBT_DYNAMIC_TABLES`, with models written to `BRONZE`, `SILVER`,
  and `GOLD` schemas.
- **Compute:** a dedicated warehouse `ADAPT_WH` drives all Dynamic Table refreshes.

This is a demo / teaching project, not a production deployment. It focuses on the
mechanics of Dynamic Tables under dbt rather than on business completeness.

---

## Snowflake & dbt features used

| Feature | How it's used |
| --- | --- |
| **Dynamic Tables** | Default materialization for the project (`+materialized: dynamic_table`). All silver and gold models are Dynamic Tables. |
| **`target_lag: downstream`** | Most models inherit `downstream` lag, so they refresh only when a downstream consumer needs fresh data — Snowflake schedules the whole chain automatically. |
| **Concrete `target_lag`** | `agg_revenue_by_nation` sets `target_lag='1 minute'`, anchoring the refresh cadence for the entire upstream tree feeding it. |
| **Change tracking** | The setup script enables `CHANGE_TRACKING = TRUE` on all source tables — a prerequisite for incremental Dynamic Table refreshes. |
| **Medallion architecture** | Bronze (views) → Silver (cleaned/enriched Dynamic Tables) → Gold (dimensions, facts, OBT, aggregates). |
| **Custom schema macro** | `generate_schema_name.sql` overrides dbt's default so custom schemas are used as-is (`BRONZE`/`SILVER`/`GOLD`) instead of being prefixed. |
| **Sources** | `models/sources.yml` declares the eight TPC-H source tables. |
| **Data tests** | `unique` and `not_null` tests on key columns across all layers. |
| **dbt_semantic_view (optional)** | `packages.yml` includes a commented-out reference to `Snowflake-Labs/dbt_semantic_view` for adding a semantic view materialization. |

---

## Project structure

```
dbt-dynamic-tables/
├── dbt_project.yml              # Project config; per-layer materialization & schema
├── profiles.yml                 # Snowflake connection (db DBT_DYNAMIC_TABLES, wh ADAPT_WH)
├── packages.yml                 # Optional dbt_semantic_view package (commented out)
├── macros/
│   └── generate_schema_name.sql # Use custom schema names as-is
├── models/
│   ├── sources.yml              # TPC-H SF1 source definitions
│   ├── 010_bronze/              # Views: 1:1 cleaned staging of each source table
│   │   ├── _bronze.yml
│   │   └── stg_*.sql            # stg_customers, stg_orders, stg_lineitems, ...
│   ├── 020_silver/              # Dynamic Tables: cleaned & enriched entities
│   │   ├── _silver.yml
│   │   └── int_*.sql            # int_customers, int_orders, int_order_items, ...
│   └── 030_gold/                # Dynamic Tables: dims, facts, OBT, aggregates
│       ├── _gold.yml
│       ├── dim_*.sql            # dim_customers, dim_parts, dim_nations, ...
│       ├── fct_*.sql            # fct_orders, fct_line_items
│       ├── obt_order_summary.sql
│       └── agg_*.sql            # agg_revenue_by_nation, agg_top_customers
├── scripts/
│   ├── Copy TPC-H SF1.sql       # One-time setup: copy sample data + enable change tracking
│   └── Trigger Demo Refresh.sql # Insert ~10% of LINEITEM rows to fire the refresh chain
└── analyses/ seeds/ snapshots/ tests/   # Standard dbt dirs (placeholders)
```

---

## Layer summary

### Bronze (`010_bronze`) — Views
One staging model per source table. Renames columns to friendly names and standardizes
text. Materialized as **views** (lightweight, always reflect the latest source).

`stg_customers`, `stg_orders`, `stg_lineitems`, `stg_parts`, `stg_partsupp`,
`stg_suppliers`, `stg_nations`, `stg_regions`

### Silver (`020_silver`) — Dynamic Tables
Cleaned and enriched entities, plus joined models that feed gold.

- **Entity models:** `int_regions`, `int_nations`, `int_customers`, `int_suppliers`,
  `int_parts`, `int_partsupp`, `int_orders`, `int_lineitems` (geography enrichment,
  derived date parts, computed pricing, size buckets, etc.)
- **Enriched/joined models:** `int_order_items`, `int_customer_orders`,
  `int_part_suppliers`

### Gold (`030_gold`) — Dynamic Tables
Analytics-ready star schema and reporting tables.

- **Dimensions:** `dim_customers`, `dim_suppliers`, `dim_parts`, `dim_nations`,
  `dim_regions`
- **Facts:** `fct_orders` (order grain), `fct_line_items` (line-item grain)
- **Reporting:** `obt_order_summary` (one-big-table for BI), `agg_revenue_by_nation`,
  `agg_top_customers`

---

## How the refresh chain works

Because the project default is `target_lag: downstream`, each Dynamic Table refreshes
only when something downstream needs it. The one model with a concrete lag —
`agg_revenue_by_nation` (`1 minute`) — acts as the anchor that pulls fresh data through
its entire upstream lineage:

```
LINEITEM (source, change-tracked)
  → stg_lineitems (bronze view)
    → int_lineitems → int_order_items (silver)
      → fct_orders (gold)
        → agg_revenue_by_nation (gold, target_lag = 1 min)
```

Inserting rows into the source `LINEITEM` table automatically cascades a refresh up this
tree within ~1 minute — no manual `dbt run` required.

---

## Getting started

### Prerequisites
- A Snowflake account with access to `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`.
- A warehouse named `ADAPT_WH` (or edit `profiles.yml` / `dbt_project.yml` to use yours).
- dbt with the `dbt-snowflake` adapter installed.

### 1. Load the sample data (one time)
Run `scripts/Copy TPC-H SF1.sql` in Snowflake. This copies the eight TPC-H tables into
`DBT_DYNAMIC_TABLES.TPCH_SF1` and enables `CHANGE_TRACKING` on each (required for
Dynamic Tables).

### 2. Build the project
```bash
dbt deps      # only needed if you enable the dbt_semantic_view package
dbt build     # runs all models and tests
```

### 3. See the Dynamic Tables refresh in action
Run `scripts/Trigger Demo Refresh.sql`. It inserts ~10% more `LINEITEM` rows and prints
before/after counts. Within ~1 minute, the change propagates through silver and gold and
`agg_revenue_by_nation` reflects the new data automatically.

---

## Notes

- The TPC-H sample lives in a share, so it can't be cloned or change-tracked directly —
  hence the copy-then-enable-tracking step in the setup script.
- All connection settings (role `ACCOUNTADMIN`, warehouse `ADAPT_WH`, database
  `DBT_DYNAMIC_TABLES`) are in `profiles.yml`; adjust to match your environment.
