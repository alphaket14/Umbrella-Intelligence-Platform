# Table Catalog — AI

### ai.models
- `model_id PK`, `provider`, `name`, `version`, `params JSONB`

### ai.runs
- `run_id PK`, `tenant_id`, `model_id`, `started_at`, `finished_at`, `status`, `cost_usd`, `input_tokens`, `output_tokens`, `meta JSONB`

### ai.baselines
- `(id PK, tenant_id, metric, window_days, mean, stddev, p50, p90, p99, updated_at)`

### ai.insights
- `(insight_id PK, tenant_id, iso_year, iso_week, kind, severity, title, summary, evidence JSONB, recommended_action, created_at)`
- Index: `(tenant_id, iso_year, iso_week, severity)`

### ai.recommendations
- `(rec_id PK, tenant_id, insight_id, title, priority, impact, effort, owner, eta, status, closed_reason, evidence_links JSONB)`
- Index: `(tenant_id, status, priority)`

### ai.playbooks
- `(playbook_id PK, title, steps JSONB, references JSONB)`

### ai.weekly_exec
- PK `(tenant_id, iso_year, iso_week)`
- `headline, bullets JSONB, kpi_snapshot JSONB, action_summary JSONB, generated_by_run UUID, created_at`
