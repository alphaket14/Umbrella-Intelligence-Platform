-- DDL — AI

CREATE TABLE IF NOT EXISTS ai.models (
  model_id TEXT PRIMARY KEY,
  provider TEXT,
  name TEXT,
  version TEXT,
  params JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ai.runs (
  run_id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,
  model_id TEXT NOT NULL REFERENCES ai.models(model_id),
  started_at TIMESTAMPTZ DEFAULT now(),
  finished_at TIMESTAMPTZ,
  status TEXT,
  cost_usd NUMERIC(10,4),
  input_tokens BIGINT,
  output_tokens BIGINT,
  meta JSONB
);

CREATE TABLE IF NOT EXISTS ai.baselines (
  id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,
  metric TEXT NOT NULL,
  window_days INT NOT NULL,
  mean NUMERIC,
  stddev NUMERIC,
  p50 NUMERIC,
  p90 NUMERIC,
  p99 NUMERIC,
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS ai.insights (
  insight_id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  kind TEXT,
  severity TEXT,
  title TEXT,
  summary TEXT,
  evidence JSONB,
  recommended_action TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_ai_insights_tenant_week 
  ON ai.insights(tenant_id, iso_year, iso_week, severity);

CREATE TABLE IF NOT EXISTS ai.recommendations (
  rec_id UUID PRIMARY KEY,
  tenant_id UUID NOT NULL,
  insight_id UUID NOT NULL REFERENCES ai.insights(insight_id),
  title TEXT,
  priority TEXT,
  impact TEXT,
  effort TEXT,
  owner TEXT,
  eta DATE,
  status TEXT,
  closed_reason TEXT,
  evidence_links JSONB
);
CREATE INDEX IF NOT EXISTS idx_ai_recs_status_priority 
  ON ai.recommendations(tenant_id, status, priority);

CREATE TABLE IF NOT EXISTS ai.playbooks (
  playbook_id TEXT PRIMARY KEY,
  title TEXT,
  steps JSONB,
  references JSONB
);

CREATE TABLE IF NOT EXISTS ai.weekly_exec (
  tenant_id UUID NOT NULL,
  iso_year INT NOT NULL,
  iso_week INT NOT NULL,
  headline TEXT,
  bullets JSONB,
  kpi_snapshot JSONB,
  action_summary JSONB,
  generated_by_run UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (tenant_id, iso_year, iso_week)
);
