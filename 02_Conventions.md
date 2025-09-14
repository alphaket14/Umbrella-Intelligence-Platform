# Conventions & Standards

**Schemas**
- `meta`, `raw`, `core`, `mart`, `ai`

**Column patterns**
- Common fields: `tenant_id UUID NOT NULL`, `created_at TIMESTAMPTZ DEFAULT now()`, `updated_at TIMESTAMPTZ DEFAULT now()`
- RAW control: `_hash TEXT`, `schema_version INT`, `ingested_at TIMESTAMPTZ`, `src_batch_id TEXT`
- Facts: bucketed `ts_15m TIMESTAMPTZ`, `date_id DATE`
- JSON: use `JSONB` sparingly; prefer child tables for arrays

**Keys & Indexes**
- PKs: UUID or composite natural keys (facts often: `(tenant_id, ts_15m, ...)`)
- Index patterns: `(tenant_id, occurred_at DESC)`, `(tenant_id, date_id)`
- Partitioning: monthly partitions on time-series facts (`_yymm` suffix)

**Enumerations & codes**
- `action_code`: 0=allowed, 1=blocked
- `inv_status`: -1=malicious, 0=unknown, 1=safe
- `risk_level`: LOW | MEDIUM | HIGH | CRITICAL
- `threat_family`: malware | phishing | commandandcontrol | cryptomining | other

**Time semantics**
- Store UTC; present Europe/Madrid; ISO Week (Mon–Sun)
