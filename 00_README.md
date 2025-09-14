# ERD & Table Catalog — Modular Pack (v1.1)
Generated: 2025-08-17T23:22:37.000143Z

This pack splits the large blueprint into multiple small files to avoid UI size limits.
You can open the Markdown files directly or import the SQL into Xano/PostgreSQL.

## File map
- 00_README.md — This file
- 01_ERD.mmd — Mermaid ER diagram (paste into Mermaid live editor or compatible tools)
- 02_Conventions.md — Conventions, time semantics, codes
- 03_TableCatalog_META_RAW.md — `meta` & `raw` schemas
- 04_TableCatalog_CORE.md — `core` schema (dimensions, facts, bridges)
- 05_TableCatalog_MART.md — `mart` schema (weekly/report marts)
- 06_TableCatalog_AI.md — `ai` schema
- 07_DDL_Core.sql — DDL for core dimensions/facts
- 08_DDL_Marts.sql — DDL for marts
- 09_DDL_Raw.sql — DDL for raw
- 10_DDL_Ai.sql — DDL for ai
- 11_Indexing_Retention.sql — Indexes, BRIN, partitioning & retention helpers
- 12_OpenAPI_Notes.md — Response contracts and endpoint list

Tip: keep everything in Git and version DDL using migrations.
