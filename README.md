# tcgcards-aws-dbt

AWS + dbt analytics engineering demo for trading card transaction modeling and feature marts.

## Overview

This project builds a small analytics engineering workflow for trading card transaction data.

It starts from raw transaction records and turns them into clean, analysis-ready tables using dbt and DuckDB. The project also mirrors a lightweight AWS workflow with S3, Glue, and Athena for raw ingestion, schema discovery, and querying.

The goal is to show:
- data cleaning and standardization
- explicit layered modeling in dbt
- feature engineering for pricing analytics
- basic data quality testing
- project documentation and lineage

## Tech Stack

- **dbt**
- **DuckDB**
- **SQL**
- **AWS S3**
- **AWS Glue Crawler / Data Catalog**
- **Amazon Athena**

## Project Structure

```text
.
├── analyses/
├── macros/
├── models/
│   ├── staging/
│   │   └── stg_transactions.sql
│   ├── intermediate/
│   │   └── int_transactions_enriched.sql
│   └── marts/
│       ├── dim_product.sql
│       ├── fct_transactions.sql
│       ├── mart_product_features.sql
│       └── mart_sku_features.sql
├── seeds/
├── snapshots/
├── tests/
├── dbt_project.yml
└── README.md
