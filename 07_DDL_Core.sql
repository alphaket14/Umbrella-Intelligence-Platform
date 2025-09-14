-- DDL — CORE (Dimensions, Facts, Bridges)

CREATE TABLE IF NOT EXISTS core.dim_time_utc (
  ts_15m TIMESTAMPTZ PRIMARY KEY,
  date_id DATE NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  week_start_date DATE NOT NULL,
  month INT NOT NULL CHECK (month BETWEEN 1 AND 12),
  year INT NOT NULL,
  dow INT NOT NULL CHECK (dow BETWEEN 1 AND 7),
  hour INT NOT NULL CHECK (hour BETWEEN 0 AND 23),
  is_weekend BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE IF NOT EXISTS core.dim_identity (
  identity_sk BIGSERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  identity_id TEXT NOT NULL,
  label TEXT,
  type TEXT,
  site_sk BIGINT,
  department_sk BIGINT,
  valid_from TIMESTAMPTZ NOT NULL,
  valid_to TIMESTAMPTZ,
  is_current BOOLEAN NOT NULL DEFAULT true
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_identity_current 
  ON core.dim_identity(tenant_id, org_id, identity_id) WHERE is_current;

CREATE TABLE IF NOT EXISTS core.dim_domain (
  domain_sk BIGSERIAL PRIMARY KEY,
  domain TEXT NOT NULL UNIQUE,
  tld TEXT, sld TEXT,
  is_malicious BOOLEAN
);

CREATE TABLE IF NOT EXISTS core.dim_category (
  category_sk BIGSERIAL PRIMARY KEY,
  vendor_key TEXT UNIQUE,
  "group" TEXT,
  name TEXT
);

CREATE TABLE IF NOT EXISTS core.dim_app_saas (
  app_sk BIGSERIAL PRIMARY KEY,
  app_key TEXT UNIQUE,
  name TEXT,
  risk_level TEXT,
  is_sanctioned BOOLEAN
);

CREATE TABLE IF NOT EXISTS core.dim_cdfw_rule (
  rule_sk BIGSERIAL PRIMARY KEY,
  rule_id TEXT UNIQUE,
  name TEXT,
  action TEXT
);

CREATE TABLE IF NOT EXISTS core.dim_site (
  site_sk BIGSERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL,
  site_code TEXT UNIQUE,
  name TEXT,
  city TEXT,
  country TEXT
);

CREATE TABLE IF NOT EXISTS core.dim_department (
  department_sk BIGSERIAL PRIMARY KEY,
  tenant_id UUID NOT NULL,
  code TEXT UNIQUE,
  name TEXT
);

CREATE TABLE IF NOT EXISTS core.dim_policy (
  policy_sk BIGSERIAL PRIMARY KEY,
  policy_id TEXT UNIQUE,
  name TEXT,
  type TEXT,
  action TEXT,
  scope JSONB
);

CREATE TABLE IF NOT EXISTS core.dim_domain_tenant (
  tenant_id UUID NOT NULL,
  domain_sk BIGINT NOT NULL,
  tags JSONB, notes TEXT,
  first_seen_tenant DATE,
  last_seen_tenant DATE,
  PRIMARY KEY(tenant_id, domain_sk)
);

-- Facts
CREATE TABLE IF NOT EXISTS core.fact_dns_activity_15m (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  ts_15m TIMESTAMPTZ NOT NULL REFERENCES core.dim_time_utc(ts_15m),
  identity_sk BIGINT NOT NULL REFERENCES core.dim_identity(identity_sk),
  domain_sk BIGINT NOT NULL REFERENCES core.dim_domain(domain_sk),
  policy_sk BIGINT REFERENCES core.dim_policy(policy_sk) DEFERRABLE INITIALLY DEFERRED,
  action_code SMALLINT NOT NULL,
  threat_family TEXT,
  requests_total BIGINT NOT NULL DEFAULT 0,
  requests_blocked BIGINT NOT NULL DEFAULT 0,
  security_blocks BIGINT NOT NULL DEFAULT 0,
  malware_blocks BIGINT NOT NULL DEFAULT 0,
  phishing_blocks BIGINT NOT NULL DEFAULT 0,
  cc_blocks BIGINT NOT NULL DEFAULT 0,
  nsd_blocks BIGINT NOT NULL DEFAULT 0,
  content_blocks_by_category JSONB,
  site_sk BIGINT,
  department_sk BIGINT,
  src_batch_id TEXT,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (tenant_id, org_id, ts_15m, identity_sk, domain_sk)
) PARTITION BY RANGE (ts_15m);

CREATE INDEX IF NOT EXISTS idx_fact_dns_15m_tenant_time 
  ON core.fact_dns_activity_15m(tenant_id, ts_15m DESC);
CREATE INDEX IF NOT EXISTS cvr_fact_dns_15m 
  ON core.fact_dns_activity_15m(tenant_id, ts_15m DESC, action_code, threat_family) 
  INCLUDE (requests_total, security_blocks);

CREATE TABLE IF NOT EXISTS core.fact_content_blocks_15m (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  ts_15m TIMESTAMPTZ NOT NULL REFERENCES core.dim_time_utc(ts_15m),
  identity_sk BIGINT NOT NULL REFERENCES core.dim_identity(identity_sk),
  category_sk BIGINT NOT NULL REFERENCES core.dim_category(category_sk),
  blocks BIGINT NOT NULL DEFAULT 0,
  site_sk BIGINT,
  department_sk BIGINT,
  src_batch_id TEXT,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (tenant_id, org_id, ts_15m, identity_sk, category_sk)
);

CREATE TABLE IF NOT EXISTS core.fact_dns_activity_daily (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  date_id DATE NOT NULL,
  requests_total BIGINT NOT NULL DEFAULT 0,
  requests_blocked BIGINT NOT NULL DEFAULT 0,
  security_blocks BIGINT NOT NULL DEFAULT 0,
  malware_blocks BIGINT NOT NULL DEFAULT 0,
  phishing_blocks BIGINT NOT NULL DEFAULT 0,
  cc_blocks BIGINT NOT NULL DEFAULT 0,
  nsd_blocks BIGINT NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (tenant_id, org_id, date_id)
);

CREATE TABLE IF NOT EXISTS core.fact_cdfw_events_15m (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  ts_15m TIMESTAMPTZ NOT NULL,
  rule_sk BIGINT NOT NULL REFERENCES core.dim_cdfw_rule(rule_sk),
  action TEXT NOT NULL,
  sessions BIGINT NOT NULL DEFAULT 0,
  bytes BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, org_id, ts_15m, rule_sk, action)
);

CREATE TABLE IF NOT EXISTS core.fact_cdfw_events_daily (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  date_id DATE NOT NULL,
  rule_sk BIGINT NOT NULL REFERENCES core.dim_cdfw_rule(rule_sk),
  action TEXT NOT NULL,
  sessions BIGINT NOT NULL DEFAULT 0,
  bytes BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, org_id, date_id, rule_sk, action)
);

CREATE TABLE IF NOT EXISTS core.fact_casb_app_usage_daily (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  date_id DATE NOT NULL,
  app_sk BIGINT NOT NULL REFERENCES core.dim_app_saas(app_sk),
  users_count INT,
  sessions BIGINT,
  bytes_up BIGINT,
  bytes_down BIGINT,
  risk_level TEXT,
  PRIMARY KEY (tenant_id, org_id, date_id, app_sk)
);

CREATE TABLE IF NOT EXISTS core.fact_rc_health_daily (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  date_id DATE NOT NULL,
  active INT,
  inactive INT,
  outdated INT,
  coverage_pct NUMERIC(5,2),
  PRIMARY KEY (tenant_id, org_id, date_id)
);

CREATE TABLE IF NOT EXISTS core.fact_domain_enrich_daily (
  tenant_id UUID NOT NULL,
  date_id DATE NOT NULL,
  domain_sk BIGINT NOT NULL REFERENCES core.dim_domain(domain_sk),
  inv_status SMALLINT,
  risk_score INT,
  dga_score INT,
  fast_flux BOOLEAN,
  popularity NUMERIC(8,5),
  whois_age_days INT,
  PRIMARY KEY (tenant_id, date_id, domain_sk)
);

CREATE TABLE IF NOT EXISTS core.fact_ioc_events (
  tenant_id UUID NOT NULL,
  date_id DATE NOT NULL,
  domain_sk BIGINT NOT NULL REFERENCES core.dim_domain(domain_sk),
  signal TEXT NOT NULL,
  value NUMERIC,
  PRIMARY KEY (tenant_id, date_id, domain_sk, signal)
);

CREATE TABLE IF NOT EXISTS core.bridge_domain_relation (
  tenant_id UUID NOT NULL,
  date_id DATE NOT NULL,
  src_domain_sk BIGINT NOT NULL REFERENCES core.dim_domain(domain_sk),
  dst_domain_sk BIGINT NOT NULL REFERENCES core.dim_domain(domain_sk),
  weight NUMERIC(6,3),
  PRIMARY KEY (tenant_id, date_id, src_domain_sk, dst_domain_sk)
);

CREATE TABLE IF NOT EXISTS core.bridge_identity_department (
  tenant_id UUID NOT NULL,
  identity_sk BIGINT NOT NULL REFERENCES core.dim_identity(identity_sk),
  department_sk BIGINT NOT NULL REFERENCES core.dim_department(department_sk),
  valid_from TIMESTAMPTZ NOT NULL,
  valid_to TIMESTAMPTZ,
  PRIMARY KEY (tenant_id, identity_sk, department_sk, valid_from)
);

CREATE TABLE IF NOT EXISTS core.bridge_identity_site (
  tenant_id UUID NOT NULL,
  identity_sk BIGINT NOT NULL REFERENCES core.dim_identity(identity_sk),
  site_sk BIGINT NOT NULL REFERENCES core.dim_site(site_sk),
  valid_from TIMESTAMPTZ NOT NULL,
  valid_to TIMESTAMPTZ,
  PRIMARY KEY (tenant_id, identity_sk, site_sk, valid_from)
);
