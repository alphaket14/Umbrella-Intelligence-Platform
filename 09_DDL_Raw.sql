-- DDL — RAW

CREATE TABLE IF NOT EXISTS raw.raw_dns_activity (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  natural_id TEXT NOT NULL,
  event_at TIMESTAMPTZ NOT NULL,
  payload JSONB NOT NULL,
  action_code SMALLINT NOT NULL CHECK (action_code IN (0,1)),
  category TEXT,
  identity_id TEXT,
  domain TEXT,
  src_ip INET,
  dst_ip INET,
  _hash TEXT,
  schema_version INT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  src_batch_id TEXT,
  PRIMARY KEY (tenant_id, natural_id)
);
CREATE INDEX IF NOT EXISTS idx_raw_dns_activity_tenant_time ON raw.raw_dns_activity (tenant_id, event_at DESC);
CREATE INDEX IF NOT EXISTS idx_raw_dns_activity_tenant_domain ON raw.raw_dns_activity (tenant_id, domain);

CREATE TABLE IF NOT EXISTS raw.raw_identities (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  identity_id TEXT NOT NULL,
  label TEXT,
  type TEXT,
  payload JSONB,
  _hash TEXT,
  schema_version INT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  src_batch_id TEXT,
  PRIMARY KEY (tenant_id, org_id, identity_id)
);

CREATE TABLE IF NOT EXISTS raw.raw_roaming_clients (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  client_id TEXT NOT NULL,
  hostname TEXT,
  version TEXT,
  last_seen_at TIMESTAMPTZ,
  status TEXT,
  payload JSONB,
  _hash TEXT,
  schema_version INT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  src_batch_id TEXT,
  PRIMARY KEY (tenant_id, org_id, client_id)
);

CREATE TABLE IF NOT EXISTS raw.raw_casb_app_usage (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  date_id DATE NOT NULL,
  app_key TEXT NOT NULL,
  users_count INT,
  sessions BIGINT,
  bytes_up BIGINT,
  bytes_down BIGINT,
  risk_level TEXT,
  payload JSONB,
  _hash TEXT,
  schema_version INT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  src_batch_id TEXT,
  PRIMARY KEY (tenant_id, org_id, date_id, app_key)
);

CREATE TABLE IF NOT EXISTS raw.raw_cdfw_events (
  tenant_id UUID NOT NULL,
  org_id TEXT NOT NULL,
  natural_id TEXT NOT NULL,
  event_at TIMESTAMPTZ NOT NULL,
  rule_id TEXT,
  src_ip INET,
  dst_ip INET,
  proto TEXT,
  action TEXT,
  bytes BIGINT,
  payload JSONB,
  _hash TEXT,
  schema_version INT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  src_batch_id TEXT,
  PRIMARY KEY (tenant_id, natural_id)
);

-- Investigate raw snapshots
CREATE TABLE IF NOT EXISTS raw.raw_inv_domain_status (
  domain TEXT NOT NULL,
  status SMALLINT,
  categories JSONB,
  risk_score INT,
  tenant_id UUID NOT NULL,
  date_id DATE NOT NULL,
  payload JSONB,
  _hash TEXT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  src_batch_id TEXT,
  PRIMARY KEY (tenant_id, date_id, domain)
);

CREATE TABLE IF NOT EXISTS raw.raw_inv_security_info (
  domain TEXT NOT NULL,
  dga_score INT,
  fast_flux BOOLEAN,
  popularity NUMERIC,
  tenant_id UUID NOT NULL,
  date_id DATE NOT NULL,
  payload JSONB,
  _hash TEXT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (tenant_id, date_id, domain)
);

CREATE TABLE IF NOT EXISTS raw.raw_inv_whois (
  domain TEXT NOT NULL,
  registrar TEXT,
  created_on DATE,
  updated_on DATE,
  emails JSONB, -- hashed list
  tenant_id UUID NOT NULL,
  date_id DATE NOT NULL,
  payload JSONB,
  _hash TEXT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (tenant_id, date_id, domain)
);

CREATE TABLE IF NOT EXISTS raw.raw_inv_related_domains (
  domain TEXT NOT NULL,
  related_domain TEXT NOT NULL,
  weight NUMERIC,
  tenant_id UUID NOT NULL,
  date_id DATE NOT NULL,
  payload JSONB,
  _hash TEXT,
  ingested_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (tenant_id, date_id, domain, related_domain)
);

CREATE TABLE IF NOT EXISTS raw.raw_dlq (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,
  original_table TEXT NOT NULL,
  payload JSONB NOT NULL,
  error_code TEXT,
  error_message TEXT,
  retry_count INT DEFAULT 0,
  first_seen_at TIMESTAMPTZ DEFAULT now(),
  last_error_at TIMESTAMPTZ DEFAULT now()
);
