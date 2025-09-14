# Table Catalog — CORE (Dimensions, Facts, Bridges)

## Dimensions
### core.dim_time_utc
- `ts_15m PK`, `date_id`, `iso_year`, `iso_week`, `week_start_date`, `month`, `year`, `dow`, `hour`, `is_weekend`

### core.dim_identity (SCD2)
- `identity_sk PK`, `tenant_id`, `org_id`, `identity_id`, `label`, `type`, `site_sk`, `department_sk`, `valid_from`, `valid_to`, `is_current`
- Partial unique index (current): `(tenant_id, org_id, identity_id) WHERE is_current`

### core.dim_domain
- `domain_sk PK`, `domain UNIQUE`, `tld`, `sld`, `is_malicious`

### core.dim_category
- `category_sk PK`, `vendor_key UNIQUE`, `group (security|content)`, `name`

### core.dim_app_saas
- `app_sk PK`, `app_key UNIQUE`, `name`, `risk_level`, `is_sanctioned`

### core.dim_cdfw_rule
- `rule_sk PK`, `rule_id UNIQUE`, `name`, `action`

### core.dim_site
- `site_sk PK`, `tenant_id`, `site_code UNIQUE`, `name`, `city`, `country`

### core.dim_department
- `department_sk PK`, `tenant_id`, `code UNIQUE`, `name`

### core.dim_policy
- `policy_sk PK`, `policy_id UNIQUE`, `name`, `type`, `action`, `scope JSONB`

### core.dim_domain_tenant
- `(tenant_id, domain_sk) PK`, `tags JSONB`, `notes`, `first_seen_tenant`, `last_seen_tenant`

## Facts
### core.fact_dns_activity_15m (monthly partitions)
PK `(tenant_id, org_id, ts_15m, identity_sk, domain_sk)`; BRIN(ts_15m)
- Columns: action_code, threat_family, requests_total, requests_blocked, security_blocks, malware_blocks, phishing_blocks, cc_blocks, nsd_blocks
- Content categories JSONB kept for cache; **normalized** table below
- Covering index: `(tenant_id, ts_15m DESC, action_code, threat_family) INCLUDE(requests_total, security_blocks)`

### core.fact_content_blocks_15m
PK `(tenant_id, org_id, ts_15m, identity_sk, category_sk)`
- Normalized non-security content blocks

### core.fact_dns_activity_daily
PK `(tenant_id, org_id, date_id)`; rolled up from 15m

### core.fact_cdfw_events_15m / _daily (optional)
- Sessions and bytes by rule/action

### core.fact_casb_app_usage_daily
PK `(tenant_id, org_id, date_id, app_sk)`

### core.fact_rc_health_daily
PK `(tenant_id, org_id, date_id)`; coverage_pct

### core.fact_domain_enrich_daily
PK `(tenant_id, date_id, domain_sk)`; inv_status, risk_score, dga_score, fast_flux, popularity, whois_age_days

### core.fact_ioc_events
PK `(tenant_id, date_id, domain_sk, signal)`; signals: DGA|FAST_FLUX|NEWLY_SEEN|TUNNELING|HIGH_RISK

## Bridges
### core.bridge_domain_relation
PK `(tenant_id, date_id, src_domain_sk, dst_domain_sk)`; weight

### core.bridge_identity_department
PK `(tenant_id, identity_sk, department_sk, valid_from)`

### core.bridge_identity_site
PK `(tenant_id, identity_sk, site_sk, valid_from)`
