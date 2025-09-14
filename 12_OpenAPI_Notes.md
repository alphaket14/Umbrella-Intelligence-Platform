# OpenAPI / Endpoint Notes (for Bubble)

**List response contract**
```json
{ "items": [...], "meta": { "count": n, "page": 1, "page_size": 50, "next": 2 } }
```

**Key endpoints**
- `/v1/umbrella/kpis-weekly?tenant_id&iso_year&iso_week`
- `/v1/umbrella/risk-semaphore?tenant_id&iso_year&iso_week`
- `/v1/umbrella/trend-critical-4w?tenant_id`
- `/v1/umbrella/weekly-evolution?tenant_id&iso_year&iso_week`
- `/v1/umbrella/heatmap?tenant_id&iso_year&iso_week`
- `/v1/umbrella/top-identities?tenant_id&iso_year&iso_week&limit=10`
- `/v1/umbrella/top-domains?tenant_id&iso_year&iso_week&limit=10`
- `/v1/umbrella/nonsec-categories/top?tenant_id&iso_year&iso_week&limit=10`
- `/v1/shadow-it/flags?tenant_id&iso_year&iso_week`
- `/v1/shadow-it/top-apps?tenant_id&iso_year&iso_week&limit=20`
- `/v1/umbrella/rc/outdated?tenant_id&iso_year&iso_week`
- `/v1/umbrella/infra/status?tenant_id&iso_year&iso_week`
- `/v1/ai/insights?tenant_id&from&to&severity=HIGH,CRITICAL&page&page_size`
- `/v1/ai/recommendations?tenant_id&from&to`
- `/v1/ai/weekly-exec?tenant_id&iso_year&iso_week`

**Caching**: ETag/If-None-Match + TTL 60–300s.
