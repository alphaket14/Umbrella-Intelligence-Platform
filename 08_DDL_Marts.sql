-- DDL — MARTS

CREATE TABLE IF NOT EXISTS mart.weekly_kpis_umbrella (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  total_dns BIGINT NOT NULL DEFAULT 0,
  security_blocks BIGINT NOT NULL DEFAULT 0,
  block_rate_pct NUMERIC(5,2) CHECK (block_rate_pct >= 0 AND block_rate_pct <= 100),
  malicious_domains_blocked INT,
  at_risk_devices INT,
  rc_outdated INT,
  casb_new_high_risk_apps INT,
  cdfw_blocks BIGINT,
  tls_inspection_pct NUMERIC(5,2) CHECK (tls_inspection_pct >= 0 AND tls_inspection_pct <= 100),
  agent_coverage_pct NUMERIC(5,2) CHECK (agent_coverage_pct >= 0 AND agent_coverage_pct <= 100),
  global_risk_index NUMERIC(5,2),
  PRIMARY KEY (tenant_id, iso_year, iso_week)
);

CREATE TABLE IF NOT EXISTS mart.risk_semaphore_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  malware_level TEXT,
  phishing_level TEXT,
  cnc_level TEXT,
  cryptomining_level TEXT,
  rc_outdated_level TEXT,
  PRIMARY KEY (tenant_id, iso_year, iso_week)
);

CREATE TABLE IF NOT EXISTS mart.trend_critical_blocks_4w (
  tenant_id UUID NOT NULL,
  week_start DATE NOT NULL,
  threat_family TEXT NOT NULL,
  blocks BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, week_start, threat_family)
);

CREATE TABLE IF NOT EXISTS mart.weekly_evolution_blocks (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  dow INT NOT NULL CHECK (dow BETWEEN 1 AND 7),
  blocks BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, iso_year, iso_week, dow)
);

CREATE TABLE IF NOT EXISTS mart.heatmap_hourly_week (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  dow INT NOT NULL CHECK (dow BETWEEN 1 AND 7),
  hour INT NOT NULL CHECK (hour BETWEEN 0 AND 23),
  threat_family TEXT NOT NULL,
  value BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, iso_year, iso_week, dow, hour, threat_family)
);

CREATE TABLE IF NOT EXISTS mart.top_identities_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  identity_sk BIGINT NOT NULL,
  blocks BIGINT NOT NULL DEFAULT 0,
  risk_score NUMERIC(5,2),
  rank INT,
  PRIMARY KEY (tenant_id, iso_year, iso_week, identity_sk)
);
CREATE INDEX IF NOT EXISTS idx_mart_top_identities_weekly 
  ON mart.top_identities_weekly(tenant_id, iso_year, iso_week, blocks DESC, identity_sk);

CREATE TABLE IF NOT EXISTS mart.top_domains_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  domain_sk BIGINT NOT NULL,
  threat_family TEXT NOT NULL,
  blocks BIGINT NOT NULL DEFAULT 0,
  risk_rank NUMERIC(5,2),
  rank INT,
  PRIMARY KEY (tenant_id, iso_year, iso_week, domain_sk, threat_family)
);
CREATE INDEX IF NOT EXISTS idx_mart_top_domains_weekly 
  ON mart.top_domains_weekly(tenant_id, iso_year, iso_week, blocks DESC, domain_sk);

CREATE TABLE IF NOT EXISTS mart.nonsec_block_categories_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  category_sk BIGINT NOT NULL,
  blocks BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (tenant_id, iso_year, iso_week, category_sk)
);

CREATE TABLE IF NOT EXISTS mart.shadowit_flags_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  flags_total INT,
  high_risk_new INT,
  unsanctioned_increase INT,
  PRIMARY KEY (tenant_id, iso_year, iso_week)
);

CREATE TABLE IF NOT EXISTS mart.shadowit_top_apps_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  app_sk BIGINT NOT NULL,
  users_count INT,
  sessions BIGINT,
  risk_level TEXT,
  PRIMARY KEY (tenant_id, iso_year, iso_week, app_sk)
);

CREATE TABLE IF NOT EXISTS mart.rc_outdated_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  outdated_clients INT,
  total_clients INT,
  coverage_pct NUMERIC(5,2),
  PRIMARY KEY (tenant_id, iso_year, iso_week)
);

CREATE TABLE IF NOT EXISTS mart.advanced_detections_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  detection TEXT NOT NULL,
  count_domains INT,
  count_identities INT,
  top_examples JSONB,
  PRIMARY KEY (tenant_id, iso_year, iso_week, detection)
);

CREATE TABLE IF NOT EXISTS mart.exec_delta_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  kpi_key TEXT NOT NULL,
  value NUMERIC,
  wow_abs NUMERIC,
  wow_pct NUMERIC,
  PRIMARY KEY (tenant_id, iso_year, iso_week, kpi_key)
);

CREATE TABLE IF NOT EXISTS mart.policy_simulation_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  simulation_key TEXT NOT NULL,
  would_block_count BIGINT,
  fp_risk_estimate NUMERIC(5,2),
  top_examples JSONB,
  PRIMARY KEY (tenant_id, iso_year, iso_week, simulation_key)
);

CREATE TABLE IF NOT EXISTS mart.domain_relation_weekly (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  src_domain_sk BIGINT NOT NULL,
  dst_domain_sk BIGINT NOT NULL,
  edge_weight NUMERIC(6,3),
  PRIMARY KEY (tenant_id, iso_year, iso_week, src_domain_sk, dst_domain_sk)
);
