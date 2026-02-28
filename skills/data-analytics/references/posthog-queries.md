# PostHog Query Reference

HogQL syntax reference and common query patterns for the Claudian apps.

## HogQL Basics

HogQL is a ClickHouse-compatible SQL dialect. All PostHog data is queryable.

### Core Tables

| Table | Contents |
|-------|----------|
| `events` | All tracked events with properties |
| `persons` | Identified users with merged properties |
| `sessions` | Session-level aggregations |
| `groups` | Group analytics entities |
| `raw_sessions` | Raw session data for custom aggregation |

### Common Functions

| Function | Description | Example |
|----------|-------------|---------|
| `count()` | Count events | `SELECT count() FROM events` |
| `countDistinct(distinct_id)` | Unique users | `SELECT countDistinct(distinct_id) FROM events` |
| `countDistinctIf(field, condition)` | Conditional unique count | `countDistinctIf(distinct_id, event = 'signup')` |
| `toDate(timestamp)` | Date truncation | `toDate(timestamp) AS day` |
| `toStartOfWeek(timestamp)` | Week start | `toStartOfWeek(timestamp)` |
| `dateDiff('day', a, b)` | Date difference | `dateDiff('day', first_seen, timestamp)` |
| `now()` | Current time | `timestamp > now() - INTERVAL 30 DAY` |
| `JSONExtractString(properties, 'key')` | Extract JSON property | Access event properties |

### Property Access

Event properties are JSON. Access patterns:

```sql
-- Direct property access (shorthand)
SELECT properties.$browser, properties.$os
FROM events

-- Custom properties
SELECT properties.scenario_id, properties.completion_time
FROM events
WHERE event = 'scenario_complete'

-- Nested JSON
SELECT JSONExtractString(properties, 'nested', 'key')
FROM events
```

## Common Query Patterns

### Daily Active Users (DAU)

```sql
SELECT
  toDate(timestamp) AS day,
  countDistinct(distinct_id) AS dau
FROM events
WHERE timestamp > now() - INTERVAL 30 DAY
GROUP BY day
ORDER BY day
```

### Weekly Active Users (WAU)

```sql
SELECT
  toStartOfWeek(timestamp) AS week,
  countDistinct(distinct_id) AS wau
FROM events
WHERE timestamp > now() - INTERVAL 12 WEEK
GROUP BY week
ORDER BY week
```

### Feature Adoption Rate

```sql
SELECT
  countDistinctIf(distinct_id, event = 'voice_memo_submitted') AS feature_users,
  countDistinct(distinct_id) AS total_users,
  round(feature_users / total_users * 100, 1) AS adoption_pct
FROM events
WHERE timestamp > now() - INTERVAL 30 DAY
```

### Event Count by Day with Rolling Average

```sql
SELECT
  day,
  daily_count,
  avg(daily_count) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS rolling_7d_avg
FROM (
  SELECT
    toDate(timestamp) AS day,
    count() AS daily_count
  FROM events
  WHERE event = 'scenario_complete'
    AND timestamp > now() - INTERVAL 30 DAY
  GROUP BY day
)
ORDER BY day
```

### Top Events by Volume

```sql
SELECT
  event,
  count() AS event_count,
  countDistinct(distinct_id) AS unique_users
FROM events
WHERE timestamp > now() - INTERVAL 7 DAY
  AND event NOT LIKE '$%'  -- Exclude auto-captured events
GROUP BY event
ORDER BY event_count DESC
LIMIT 20
```

## Funnel Queries

### Sequential Funnel (Alteri)

```sql
WITH funnel AS (
  SELECT
    distinct_id,
    minIf(timestamp, event = 'research_session_start') AS step_1_time,
    minIf(timestamp, event = 'scenario_view') AS step_2_time,
    minIf(timestamp, event = 'scenario_complete') AS step_3_time
  FROM events
  WHERE timestamp > now() - INTERVAL 30 DAY
    AND event IN ('research_session_start', 'scenario_view', 'scenario_complete')
  GROUP BY distinct_id
)
SELECT
  count() AS total_users,
  countIf(step_1_time IS NOT NULL) AS started,
  countIf(step_2_time IS NOT NULL AND step_2_time > step_1_time) AS viewed,
  countIf(step_3_time IS NOT NULL AND step_3_time > step_2_time) AS completed,
  round(viewed / started * 100, 1) AS start_to_view_pct,
  round(completed / viewed * 100, 1) AS view_to_complete_pct
FROM funnel
WHERE step_1_time IS NOT NULL
```

### Sequential Funnel (SoilWorx)

```sql
WITH funnel AS (
  SELECT
    distinct_id,
    minIf(timestamp, event = 'distributor_search') AS step_1_time,
    minIf(timestamp, event = 'distributor_result_view') AS step_2_time,
    minIf(timestamp, event = 'distributor_contact') AS step_3_time
  FROM events
  WHERE timestamp > now() - INTERVAL 30 DAY
    AND event IN ('distributor_search', 'distributor_result_view', 'distributor_contact')
  GROUP BY distinct_id
)
SELECT
  countIf(step_1_time IS NOT NULL) AS searched,
  countIf(step_2_time IS NOT NULL AND step_2_time > step_1_time) AS viewed,
  countIf(step_3_time IS NOT NULL AND step_3_time > step_2_time) AS contacted,
  round(viewed / searched * 100, 1) AS search_to_view_pct,
  round(contacted / viewed * 100, 1) AS view_to_contact_pct
FROM funnel
WHERE step_1_time IS NOT NULL
```

## Retention Queries

### Week-over-Week Retention

```sql
WITH cohorts AS (
  SELECT
    distinct_id,
    toStartOfWeek(min(timestamp)) AS cohort_week
  FROM events
  GROUP BY distinct_id
),
activity AS (
  SELECT
    distinct_id,
    toStartOfWeek(timestamp) AS active_week
  FROM events
  GROUP BY distinct_id, active_week
)
SELECT
  c.cohort_week,
  dateDiff('week', c.cohort_week, a.active_week) AS weeks_since,
  countDistinct(c.distinct_id) AS users
FROM cohorts c
JOIN activity a ON c.distinct_id = a.distinct_id
WHERE a.active_week >= c.cohort_week
GROUP BY c.cohort_week, weeks_since
ORDER BY c.cohort_week, weeks_since
```

## Data Warehouse Patterns

### Cross-Source Joins

PostHog data warehouse supports joining event data with external sources:

```sql
-- Example: Join PostHog events with Supabase user data
SELECT
  p.email,
  p.plan_type,
  count() AS events_30d
FROM events e
JOIN external_supabase.users p ON e.distinct_id = p.id
WHERE e.timestamp > now() - INTERVAL 30 DAY
GROUP BY p.email, p.plan_type
ORDER BY events_30d DESC
```

### Notebook-Specific Patterns

When writing queries for PostHog Notebooks, optimize for inline visualization:

```sql
-- Time series (auto-renders as line chart in Notebooks)
SELECT
  toDate(timestamp) AS day,
  count() AS signups
FROM events
WHERE event = 'signup'
  AND timestamp > now() - INTERVAL 30 DAY
GROUP BY day
ORDER BY day

-- Distribution (auto-renders as bar chart)
SELECT
  properties.$browser AS browser,
  count() AS sessions
FROM events
WHERE event = '$pageview'
  AND timestamp > now() - INTERVAL 7 DAY
GROUP BY browser
ORDER BY sessions DESC
LIMIT 10
```

## Date Range Filters

| Period | Filter |
|--------|--------|
| Last 7 days | `timestamp > now() - INTERVAL 7 DAY` |
| Last 30 days | `timestamp > now() - INTERVAL 30 DAY` |
| Last 90 days | `timestamp > now() - INTERVAL 90 DAY` |
| This week | `timestamp > toStartOfWeek(now())` |
| This month | `timestamp > toStartOfMonth(now())` |
| Specific range | `timestamp BETWEEN '2026-01-01' AND '2026-01-31'` |

## Property Filters

| Filter | Pattern |
|--------|---------|
| By app | `properties.$current_url LIKE '%alteri%'` or tag events per app |
| By browser | `properties.$browser = 'Chrome'` |
| By country | `properties.$geoip_country_code = 'IE'` |
| By release | `properties.$lib_version = '1.2.3'` |
| Custom property | `properties.plan_type = 'pro'` |
