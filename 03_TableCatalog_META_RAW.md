# Table Catalog — META & RAW

## meta.tenants
- `tenant_id UUID PK`, `name TEXT`, `status TEXT`, `timezone TEXT`, timestamps

## meta.orgs
- `org_id TEXT PK`, `tenant_id UUID`, `region TEXT`, `investigate_enabled BOOL`, `features JSONB`

## meta.feature_flags
- `(id UUID PK, tenant_id, org_id, flag, value JSONB, timestamps)`

## meta.ingest_runs
- `(run_id UUID PK, tenant_id, stream, status, started_at, finished_at, rows_read, rows_written, error)`

## meta.ingest_checkpoints
- `(id UUID PK, tenant_id, stream, watermark_at, cursor, updated_at)`

## meta.ingest_metrics
- `(id UUID PK, tenant_id, stream, window_start, rows, latency_ms, errors)`

## meta.dq_violations
- `(id UUID PK, tenant_id, check_name, severity, occurred_at, details JSONB)`

## audit_api_calls
- `(id UUID PK, tenant_id, endpoint, params_hash, http_status, rate_limit_remaining, trace_id, rows, duration_ms, at)`

## meta.dq_snapshots
- `(id UUID PK, tenant_id, date_id, check_name, value, status, details JSONB, created_at)`

## meta.retention_policies
- `(id UUID PK, tenant_id, table_pattern, retain_days, created_at)`

---

## raw.raw_dns_activity
- Unique by `(tenant_id, natural_id)`; indexes: `(tenant_id, event_at DESC)`, `(tenant_id, domain)`, `(tenant_id, identity_id)`
- Columns: `tenant_id UUID, org_id TEXT, natural_id TEXT, event_at TIMESTAMPTZ, payload JSONB, action_code SMALLINT, category TEXT, identity_id TEXT, domain TEXT, src_ip INET, dst_ip INET, _hash TEXT, schema_version INT, ingested_at TIMESTAMPTZ, src_batch_id TEXT`

## raw.raw_identities
- `(tenant_id, org_id, identity_id)` unique; snapshot payload

## raw.raw_roaming_clients
- `(tenant_id, org_id, client_id)` unique; health/version

## raw.raw_casb_app_usage
- `(tenant_id, org_id, date_id, app_key)` unique; daily usage

## raw.raw_cdfw_events` (optional)
- `(tenant_id, natural_id)` unique; flows, rule_id, bytes

## raw_inv_* (Investigate snapshots by day)
- `raw_inv_domain_status`, `raw_inv_security_info`, `raw_inv_whois` (emails hashed), `raw_inv_related_domains`

## raw.raw_dlq
- DLQ with `error_code`, `retry_count`, `original_table`, timestamps
