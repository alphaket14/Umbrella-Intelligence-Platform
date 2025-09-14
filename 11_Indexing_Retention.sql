-- Indexing, Partitioning & Retention Helpers

-- Example monthly partition for core.fact_dns_activity_15m (August 2025)
CREATE TABLE IF NOT EXISTS core.fact_dns_activity_15m_2025_08 PARTITION OF core.fact_dns_activity_15m
FOR VALUES FROM ('2025-08-01') TO ('2025-09-01');
CREATE INDEX IF NOT EXISTS brin_fact_dns_activity_15m_2025_08 
  ON core.fact_dns_activity_15m_2025_08 USING BRIN (ts_15m);
CREATE INDEX IF NOT EXISTS idx_fact_dns_15m_tenant_time_2025_08 
  ON core.fact_dns_activity_15m_2025_08 (tenant_id, ts_15m DESC);

-- Retention policy example (pseudo)
-- DELETE FROM core.fact_dns_activity_15m WHERE ts_15m < now() - interval '90 days';

-- Heatmap densification: add index for frequent filters
-- CREATE INDEX IF NOT EXISTS idx_heatmap_week_family ON mart.heatmap_hourly_week(tenant_id, iso_year, iso_week, threat_family, dow, hour);
