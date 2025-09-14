# Umbrella Intelligence Platform Backend

This repository contains the backend implementation for a multi-tenant, executive-grade security intelligence dashboard. Powered exclusively by **Cisco Umbrella telemetry** (Reports v2 + Investigate), this platform materializes weekly "gold marts" and exposes **Bubble-ready APIs**. Its core purpose is to fuse "posture at a glance with deep, analyst-level drill-downs and an AI narrative that tells leaders what changed, why it matters, and what to do next". The entire backend is built on **Xano (PostgreSQL)**.

## Key Features

The project delivers an end-to-end backend solution, encompassing:

*   **Robust Data Ingestion**: Connecting to external security telemetry APIs with token-based authentication, handling pagination, retries with backoff, idempotent upserts, and historical backfills. This includes scheduling incremental and full loads with watermarking and checkpoints.
*   **Layered Data Modeling**: Designing a clear schema strategy from staging (RAW) to core (dimensions/facts) and **read-optimized analytic marts (MART)** for KPIs, trends, and top lists. This incorporates star schemas and Slowly Changing Dimensions (SCD2) where appropriate.
*   **ETL/ELT Processing**: Building background jobs for normalization, deduplication, time alignment, and weekly rollups, with robust handling for late-arriving data and reconciliation.
*   **AI Insights Layer**: A provider-agnostic AI layer that computes statistical baselines, detects anomalies/outliers on core KPIs, and produces executive summaries and actionable recommendations as **deterministic, schema-validated JSON**.
*   **Dashboard-Ready REST Services**: Exposing versioned, public APIs with predictable JSON response contracts, server-side filtering/sorting, efficient pagination, **lightweight caching (ETag/If-None-Match)**, and stable error handling.
*   **Strict Multitenancy & Security**: Enforcing tenant isolation at every layer, implementing least-privilege secret management, API middleware/guards, PII minimization, and auditing.
*   **Observability & Data Quality**: Instrumenting ingest/transforms with run logs, metrics, and alerts (e.g., lag thresholds, reconciliation gaps), and defining DQ checks with runbooks for remediation.
*   **Performance & Scalability**: Planning indexing, partitioning, and sensible retention/downsampling strategies to meet latency and freshness targets suitable for executive reporting.

## Technologies Used

*   **Backend Database & Platform**: **Xano (PostgreSQL)**
*   **Primary Data Source**: **Cisco Umbrella** (Reports v2 + Investigate)
*   **API Documentation**: OpenAPI/Swagger or Postman collection
*   **Diagrams**: Mermaid (for ERD)
*   **Expected Frontend Consumer**: Bubble (low-code/no-code platform)

## Repository Structure

This pack splits the large blueprint into multiple small files to avoid UI size limits. You can open the Markdown files directly or import the SQL into Xano/PostgreSQL.

*   `00_README.md` — This file
*   `01_ERD.mmd` — Mermaid ER diagram (paste into Mermaid live editor or compatible tools)
*   `02_Conventions.md` — Conventions, time semantics, codes
*   `03_TableCatalog_META_RAW.md` — meta & raw schemas
*   `04_TableCatalog_CORE.md` — core schema (dimensions, facts, bridges)
*   `05_TableCatalog_MART.md` — mart schema (weekly/report marts)
*   `06_TableCatalog_AI.md` — ai schema
*   `07_DDL_Core.sql` — DDL for core dimensions/facts
*   `08_DDL_Marts.sql` — DDL for marts
*   `09_DDL_Raw.sql` — DDL for raw
*   `10_DDL_Ai.sql` — DDL for ai
*   `11_Indexing_Retention.sql` — Indexes, BRIN, partitioning & retention helpers
*   `12_OpenAPI_Notes.md` — Response contracts and endpoint list

## Data Model Overview

The data model follows a layered approach (RAW → CORE → MART → AI) to ensure clarity, efficiency, and scalability.

*   **`meta` Schema**: Contains metadata tables such as `meta.tenants`, `meta.orgs`, `meta.feature_flags`, `meta.ingest_runs`, `meta.ingest_checkpoints`, `meta.ingest_metrics`, `meta.dq_violations`, `meta.audit_api_calls`, `meta.dq_snapshots`, and `meta.retention_policies`.
*   **`raw` Schema (Bronze Layer)**: Stores 1:1 ingested Cisco Umbrella payloads, including control fields like `_hash`, `schema_version`, `ingested_at`, and `src_batch_id` for idempotent upserts. Examples include `raw.raw_dns_activity`, `raw.raw_identities`, `raw.raw_roaming_clients`, `raw.raw_casb_app_usage`, `raw.raw_cdfw_events`, `raw_inv_*` (Investigate snapshots), and `raw.raw_dlq`.
*   **`core` Schema (Silver Layer)**: Contains normalized dimensions and facts. Dimensions (SCD2 where appropriate) include `core.dim_time_utc`, `core.dim_identity`, `core.dim_domain`, `core.dim_category`, `core.dim_app_saas`, `core.dim_cdfw_rule`, `core.dim_site`, `core.dim_department`, `core.dim_policy`, and `core.dim_domain_tenant`. Facts capture activity at granular levels, such as `core.fact_dns_activity_15m` (monthly partitions), `core.fact_content_blocks_15m`, `core.fact_dns_activity_daily`, `core.fact_cdfw_events_15m`/`_daily`, `core.fact_casb_app_usage_daily`, `core.fact_rc_health_daily`, `core.fact_domain_enrich_daily`, and `core.fact_ioc_events`. Bridges define relationships between dimensions.
*   **`mart` Schema (Gold Layer)**: Weekly/report-ready aggregates optimized for dashboard consumption. Key marts include `mart.weekly_kpis_umbrella`, `mart.risk_semaphore_weekly`, `mart.trend_critical_blocks_4w`, `mart.weekly_evolution_blocks`, `mart.heatmap_hourly_week`, `mart.top_identities_weekly`, `mart.top_domains_weekly`, `mart.nonsec_block_categories_weekly`, `mart.shadowit_flags_weekly`, `mart.shadowit_top_apps_weekly`, `mart.rc_outdated_weekly`, `mart.advanced_detections_weekly`, `mart.exec_delta_weekly`, `mart.policy_simulation_weekly`, and `mart.domain_relation_weekly`.
*   **`ai` Schema (Governed Layer)**: Stores outputs from the AI layer, including `ai.models`, `ai.runs`, `ai.baselines`, `ai.insights`, `ai.recommendations`, `ai.playbooks`, and `ai.weekly_exec`.

### Conventions & Standards

*   **Time Semantics**: All timestamps are stored in **UTC**, presented in **Europe/Madrid** timezone, and weekly keys use **ISO Week (Mon–Sun)**.
*   **Column Patterns**: Common fields include `tenant_id` (UUID NOT NULL PK), `created_at` (TIMESTAMPTZ DEFAULT now()), `updated_at` (TIMESTAMPTZ DEFAULT now()). RAW control fields include `_hash` (TEXT), `schema_version` (INT), `ingested_at` (TIMESTAMPTZ), `src_batch_id` (TEXT). Facts use bucketed `ts_15m` (TIMESTAMPTZ) and `date_id` (DATE). JSONB should be used sparingly, preferring child tables for arrays.
*   **Keys & Indexes**: Primary keys are UUIDs or composite natural keys (e.g., facts often use `(tenant_id, ts_15m, ...)`). Index patterns often include `(tenant_id, occurred_at DESC)` or `(tenant_id, date_id)`. Time-series facts are partitioned monthly (`_yymm` suffix). **BRIN indexes** are used on time columns in high-volume facts.
*   **Enumerations**: Standardized codes are used for `action_code` (0=allowed, 1=blocked), `inv_status` (-1=malicious, 0=unknown, 1=safe), `risk_level` (LOW | MEDIUM | HIGH | CRITICAL), and `threat_family` (malware | phishing | commandandcontrol | cryptomining | other).

## Public API Endpoints (Phase 1)

The backend exposes a suite of Bubble-ready REST API endpoints. All list endpoints adhere to a standard envelope (`{ "items": [ ... ], "meta": { "count": 123, "page": 1, "page_size": 20, "next": 2 } }`), support ETag/If-None-Match caching with TTLs of 60-300 seconds, and enforce a multi-tenancy guard.

Key endpoints include:

*   **/v1/umbrella/kpis-weekly**: Returns executive KPI cards (e.g., block rate %, TLS inspection %, agent coverage %, GRI, high-risk destinations, Shadow-IT KPIs).
*   **/v1/umbrella/risk-semaphore**: Provides Malware/Phishing/C2/Cryptomining risk levels and RC outdated level.
*   **/v1/umbrella/trend-critical-4w**: Critical block trends over 4 weeks.
*   **/v1/umbrella/heatmap**: Hour × Day × Category heatmap.
*   **/v1/umbrella/top-identities**: Top identities by blocks/risk.
*   **/v1/umbrella/top-domains**: Top malicious destinations.
*   **/v1/shadow-it/flags**: Shadow-IT flags and KPIs.
*   **/v1/shadow-it/top-apps**: Top high-risk Shadow-IT applications.
*   **/v1/umbrella/rc/outdated**: Roaming Client outdated status.
*   **/v1/umbrella/infra/status**: Unified infrastructure status.
*   **/v1/umbrella/licensing**: Administrative snapshot to support KPIs requiring licensing data.
*   **/v1/ai/insights**: AI-generated security insights.
*   **/v1/ai/recommendations**: Actionable AI recommendations.
*   **/v1/ai/weekly-exec**: Executive summary and narrative from AI.

## Getting Started (Development & Operations)

*   **Setup**: The project uses **Xano (PostgreSQL)**. You can import the provided DDL SQL files (`07_DDL_Core.sql`, `08_DDL_Marts.sql`, `09_DDL_Raw.sql`, `10_DDL_Ai.sql`, `11_Indexing_Retention.sql`) directly into your Xano/PostgreSQL instance.
*   **Data Ingestion & ETL**: Background tasks (crons) are scheduled hourly for streams like DNS activity, identities, roaming clients, and CASB data. Nightly jobs handle Investigate enrichment and weekly mart materialization. **Idempotent upserts** (`UPSERT by (tenant_id, natural_id) with _hash`) and a dead-letter queue (DLQ) manage data quality.
*   **Database Versioning**: **Keep everything in Git and version DDL using migrations**.
*   **Security & Multitenancy**: Ensure all tables are keyed by `tenant_id`, and every endpoint enforces a tenant guard via middleware. Secrets (e.g., Umbrella, Investigate API keys) must be stored in **environment variables** and rotated regularly, adhering to least privilege principles. PII minimization practices are followed, such as hashing WHOIS emails. Row-Level Security (RLS) policies are recommended for PostgreSQL if available.
*   **Caching**: Implement **ETag/If-None-Match** with TTLs of 60–300 seconds for API responses to optimize frontend performance. A private cache-bust webhook (HMAC) should be provided after weekly mart materialization.
*   **Observability**: Monitor ingress/transform metrics (rows/sec, lag, duplicates, error rates), define data quality rules (e.g., totals reconciliation, identity/domain cardinalities, freshness checks), and use per-stream watermarks for checkpoints.
*   **Performance**: Utilize **BRIN indexes** on time columns for high-volume facts, composite indexes on marts, and consider monthly partitioning for time-series data.
*   **Error Handling**: Implement robust error handling for API calls, including **exponential backoff with jitter** for rate-limited (429) and server-side (5xx) errors from Cisco APIs, with circuit breaker mechanisms for sustained failures.

## Acceptance Criteria (Key UI-Facing Aspects)

For the dashboard consuming this backend, key acceptance criteria include:

*   **KPI Card Presentation**: KPI cards must show value, **ΔWoW (Week-over-Week)**, and sparklines, with tooltips explaining the formula and data source; the Global Risk Index (GRI) must match the materialized value.
*   **AI Narrative & Recommendations**: AI narratives and recommendations must populate executive sections, with evidence links opening the correct filtered views.
*   **API Conformance**: API responses must conform to the defined contracts (e.g., list envelope), and **ETags must be honored** (returning 304 Not Modified for unchanged data).
*   **Data Freshness Indicators**: Widgets dependent on Investigate enrichment (or other external sources) should display a "stale badge" if the `enrichment_last_updated` timestamp indicates data older than 24 hours.
*   **Risk Semaphores**: Risk semaphore and Roaming Client outdated levels should render as server payload (LOW/MED/HIGH/CRIT).
*   **Empty/Partial Data Handling**: Empty or partial data states should render gracefully without console errors, and stale badges should appear if enrichment is older than the policy threshold.

## Future Roadmap (Phase 2)

The backend specification outlines a Phase 2 roadmap, which includes:

*   **Controls & Policy**: End-to-end controls funnel and policy simulation APIs.
*   **Visual Analytics**: Sankey diagrams (Identity → Threat Category → Verdict) and Sunburst charts (Security Category → Destination Domains).
*   **SWG/CDFW Supporting Marts & Routes**: Additional marts and routes for SWG traffic, TLS coverage, latency outliers, CDFW blocked sessions, and geo-exposure.
*   **Incident Response**: Optional integration for local incidents, SLA tracking, and incident detail views.
*   **Benchmarks & Policy Diff**: APIs for industry benchmarking and policy "diff" views.

---

**Note**: *This project is a multi-tenant data platform backend focusing on Cisco Umbrella telemetry. Contributions for expanding data sources, enhancing AI capabilities, and improving operational resilience are highly valued.*
