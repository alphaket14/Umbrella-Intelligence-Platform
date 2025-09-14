# Table Catalog — MART (Weekly/Report-Ready)

### mart.weekly_kpis_umbrella
PK `(tenant_id, iso_year, iso_week)`; checks on percentages [0..100]
- total_dns, security_blocks, block_rate_pct, malicious_domains_blocked, at_risk_devices, rc_outdated, casb_new_high_risk_apps, cdfw_blocks, tls_inspection_pct, agent_coverage_pct, global_risk_index

### mart.risk_semaphore_weekly
PK `(tenant_id, iso_year, iso_week)`
- malware_level, phishing_level, cnc_level, cryptomining_level, rc_outdated_level

### mart.trend_critical_blocks_4w
PK `(tenant_id, week_start, threat_family)`

### mart.weekly_evolution_blocks
PK `(tenant_id, iso_year, iso_week, dow)`

### mart.heatmap_hourly_week
PK `(tenant_id, iso_year, iso_week, dow, hour, threat_family)`

### mart.top_identities_weekly
PK `(tenant_id, iso_year, iso_week, identity_sk)`
- blocks, risk_score, rank
- Index for Top-N: `(tenant_id, iso_year, iso_week, blocks DESC, identity_sk)`

### mart.top_domains_weekly
PK `(tenant_id, iso_year, iso_week, domain_sk, threat_family)`
- blocks, risk_rank, rank
- Index for Top-N: `(tenant_id, iso_year, iso_week, blocks DESC, domain_sk)`

### mart.nonsec_block_categories_weekly
PK `(tenant_id, iso_year, iso_week, category_sk)`

### mart.shadowit_flags_weekly
PK `(tenant_id, iso_year, iso_week)`; flags_total, high_risk_new, unsanctioned_increase

### mart.shadowit_top_apps_weekly
PK `(tenant_id, iso_year, iso_week, app_sk)`; users_count, sessions, risk_level

### mart.rc_outdated_weekly
PK `(tenant_id, iso_year, iso_week)`; outdated_clients, total_clients, coverage_pct

### mart.advanced_detections_weekly
PK `(tenant_id, iso_year, iso_week, detection)`
- detection ∈ {DGA, FAST_FLUX, NEWLY_SEEN, TUNNELING}
- count_domains, count_identities, top_examples JSONB

### mart.exec_delta_weekly
PK `(tenant_id, iso_year, iso_week, kpi_key)`; value, wow_abs, wow_pct

### mart.policy_simulation_weekly
PK `(tenant_id, iso_year, iso_week, simulation_key)`; would_block_count, fp_risk_estimate, top_examples

### mart.domain_relation_weekly
PK `(tenant_id, iso_year, iso_week, src_domain_sk, dst_domain_sk)`; edge_weight
