---
name: data-analytics
description: |
  PostHog product analytics, monitoring, and data warehouse for Claudian apps. Use when discussing analytics queries, HogQL, feature adoption metrics, conversion funnels, A/B tests, user behavior, dashboards, event tracking, cohort analysis, retention, monitoring alerts, data warehouse queries, PostHog notebooks, or any question about product data and observability. Also triggers for questions about what users are doing, which features are popular, drop-off points, statistical significance, or data export. Covers both Alteri research platform and SoilWorx distributor finder.
---

# Data Analytics

PostHog product analytics, monitoring, and data warehouse for the Claudian apps. Three access surfaces: OAuth Connector (Cowork/Desktop), Plugin (Claude Code), and PostHog Notebooks (collaborative analysis).

## PostHog Surfaces

| Surface | Access | Use When |
|---------|--------|----------|
| [OAuth Connector](https://claude.com/connectors/posthog) | Cowork, Desktop Chat | Quick analytics queries, dashboard checks, funnel reviews |
| [Plugin](https://claude.com/plugins/posthog) | Claude Code | Deeper integration, automated queries in dev sessions |
| [Notebooks](https://posthog.com/docs/notebooks) | PostHog UI | Collaborative analysis, data warehouse queries, shareable reports |

## PostHog Data Model

### Core Entities

| Entity | What It Is | Key Properties |
|--------|-----------|---------------|
| **Events** | User actions (`$pageview`, `$autocapture`, custom) | `event`, `timestamp`, `distinct_id`, `properties` |
| **Persons** | Identified users (merged across sessions) | `distinct_id`, `email`, custom properties |
| **Groups** | Organization-level entities (e.g., teams, companies) | `group_type`, `group_key`, `group_properties` |
| **Sessions** | Grouped events by session ID | `$session_id`, `$session_duration`, entry/exit URLs |

### Alteri-Specific Events

| Event | Trigger | Key Properties |
|-------|---------|---------------|
| `research_session_start` | User begins a research session | `session_type`, `topic` |
| `scenario_view` | User views a scenario | `scenario_id`, `scenario_name` |
| `scenario_complete` | User completes a scenario | `scenario_id`, `completion_time` |
| `voice_memo_submitted` | Voice memo recorded | `duration`, `language` |
| `ai_response_generated` | AI response served | `model`, `latency_ms`, `token_count` |

### SoilWorx-Specific Events

| Event | Trigger | Key Properties |
|-------|---------|---------------|
| `distributor_search` | User searches for distributors | `query`, `location`, `radius` |
| `distributor_result_view` | User views a search result | `distributor_id`, `rank` |
| `distributor_contact` | User contacts a distributor | `distributor_id`, `contact_method` |
| `xlsx_import` | Admin imports distributor data | `row_count`, `status` |

## HogQL Query Patterns

HogQL is PostHog's SQL-like query language that serves as a data warehouse query layer over all PostHog data.

### Common Patterns

**Event counts by day:**
```sql
SELECT
  toDate(timestamp) AS day,
  count() AS event_count
FROM events
WHERE event = 'scenario_complete'
  AND timestamp > now() - INTERVAL 30 DAY
GROUP BY day
ORDER BY day
```

**Funnel conversion (manual):**
```sql
SELECT
  countDistinctIf(distinct_id, event = 'research_session_start') AS step_1,
  countDistinctIf(distinct_id, event = 'scenario_view') AS step_2,
  countDistinctIf(distinct_id, event = 'scenario_complete') AS step_3
FROM events
WHERE timestamp > now() - INTERVAL 7 DAY
```

**User retention (week over week):**
```sql
SELECT
  toStartOfWeek(first_seen) AS cohort_week,
  dateDiff('week', first_seen, return_week) AS weeks_since,
  count(DISTINCT person_id) AS users
FROM (
  SELECT person_id, min(timestamp) AS first_seen
  FROM events GROUP BY person_id
) cohorts
JOIN (
  SELECT person_id, toStartOfWeek(timestamp) AS return_week
  FROM events GROUP BY person_id, return_week
) returns USING person_id
GROUP BY cohort_week, weeks_since
ORDER BY cohort_week, weeks_since
```

### Data Warehouse Queries

PostHog can query external data sources linked via the data warehouse:

```sql
-- Cross-source join: PostHog events + Supabase users
SELECT
  e.distinct_id,
  s.plan_type,
  count() AS actions
FROM events e
JOIN supabase_users s ON e.distinct_id = s.id
WHERE e.timestamp > now() - INTERVAL 30 DAY
GROUP BY e.distinct_id, s.plan_type
```

## Monitoring and Alerting

PostHog provides product-level monitoring that complements Sentry's error monitoring.

### Alert Types

| Type | Trigger | Use For |
|------|---------|---------|
| **Threshold** | Metric crosses absolute value | "Fewer than 10 signups per day" |
| **Anomaly** | Metric deviates from historical pattern | "Unusual drop in session duration" |
| **Relative volume** | Metric changes by percentage | "30% drop in scenario completions" |

### Complementary Roles

| Signal | PostHog | Sentry |
|--------|---------|--------|
| Feature broken | Funnel drop-off, event count drop | Error spike, stack traces |
| Performance degradation | Session duration changes, page load times | P95 response time, timeout errors |
| User impact | Affected unique users, session replays | Affected users count, error frequency |
| New deploy issues | Funnel completion rate by release | Error rate by release, regressions |

### Alert Routing

| Severity | PostHog Action | Sentry Action |
|----------|---------------|---------------|
| Critical | Slack notification + manual Linear issue | Auto-create Linear issue (via integration) |
| Warning | Slack notification | — |
| Info | Dashboard flag | — |

### Key Metrics Per App

**Alteri:**
- Research session start → scenario view → scenario complete (conversion funnel)
- AI response latency (P50, P95)
- Voice memo submission rate
- Daily/weekly active researchers

**SoilWorx:**
- Search → results → contact (conversion funnel)
- Search result relevance (click-through rate by rank)
- Distributor contact method distribution
- XLSX import success rate

## PostHog Notebooks

Notebooks combine HogQL queries, visualizations, markdown notes, and PostHog insights in a single collaborative document.

**Docs:** https://posthog.com/docs/notebooks

### Use Cases

| Use Case | What to Include |
|----------|----------------|
| Feature launch analysis | Adoption funnel, event counts by day, session replays, cohort comparison |
| A/B test report | Experiment results, statistical significance, revenue impact, recommendation |
| Weekly product review | Dashboard snapshots, key metric trends, anomaly investigations |
| Incident impact assessment | Pre/post error rates, affected user analysis, funnel impact |

### Notebook Best Practices

- Title format: `[App] [Type] — [Date/Feature]` (e.g., "Alteri Feature Launch — Voice Memo v2")
- Include context at the top: what question are we answering?
- Embed PostHog insights (live-updating) rather than static screenshots
- End with a recommendation or next steps section
- Share via PostHog URL for team review

## Dashboard Templates

### Product Health Dashboard

| Panel | Metric | Alert Threshold |
|-------|--------|-----------------|
| DAU/WAU/MAU | Unique users by period | <10 DAU warning |
| Session duration | Median and P95 | P95 >30min investigate |
| Error rate | PostHog + Sentry combined | >1% alert |
| Page load time | P50 and P95 | P95 >3s alert |
| Feature adoption | % of users using key features | — |

### Feature Adoption Dashboard

| Panel | Metric |
|-------|--------|
| New feature event count | Daily trend since launch |
| Adoption funnel | Exposure → first use → repeat use |
| Cohort comparison | Users with feature vs without |
| Feedback signals | Related support requests, error rates |

## Statistical Analysis

> See [references/statistical-analysis.md](references/statistical-analysis.md) for formulas and methodology.

PostHog uses **Bayesian statistics** for A/B test analysis:
- Results show probability of variant being better (not p-values)
- No fixed sample size requirement — results update continuously
- Default credible interval: 95%
- Minimum recommended sample: 100 per variant for meaningful results

### Key Concepts

| Concept | PostHog Approach |
|---------|-----------------|
| Significance | Bayesian posterior probability >95% |
| Sample size | Adaptive — results improve with more data |
| Multiple variants | Supported — pairwise comparisons |
| Sequential testing | Built-in — safe to check results early |
| Confidence intervals | Credible intervals (Bayesian) |

## Cross-Skill References

- **clinearhub-workflow** — Step 5 (human review) uses analytics data for verification
- **deployment-verification** — Post-deploy funnel checks use PostHog
- **incident-response** — PostHog provides user impact assessment for errors
