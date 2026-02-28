# PostHog Monitoring and Alerts Reference

Product-level monitoring configuration and alert patterns for the Claudian apps. Complements Sentry error monitoring with user behavior and product health signals.

## PostHog vs Sentry: Complementary Roles

| Domain | PostHog (Product Monitoring) | Sentry (Error Monitoring) |
|--------|------------------------------|--------------------------|
| **Signal type** | User behavior changes, metric anomalies | Errors, exceptions, stack traces |
| **Detection** | Funnel drops, adoption changes, latency | Error spikes, regressions, crashes |
| **Root cause** | "Users stopped completing scenarios" | "TypeError in scenario handler" |
| **User impact** | Session replays, cohort analysis | Affected user count, error frequency |
| **Auto-issue creation** | Manual (triggered from alert) | Automatic (Sentry→Linear integration) |

**Rule of thumb:** Sentry catches *errors*. PostHog catches *degraded experiences that may not throw errors.*

## Alert Types

### Threshold Alerts

Trigger when a metric crosses a fixed value.

| Alert | Condition | Severity | App |
|-------|-----------|----------|-----|
| Low DAU | DAU < 10 | Warning | Both |
| No signups | Signups = 0 for 24h | Warning | Both |
| Low search volume | Searches < 5/day | Warning | SoilWorx |
| No research sessions | Sessions = 0 for 24h | Warning | Alteri |

### Anomaly Alerts

Trigger when a metric deviates from its historical pattern (automatic baseline).

| Alert | Metric | Sensitivity | App |
|-------|--------|-------------|-----|
| Session duration anomaly | Median session duration | Medium | Both |
| Funnel conversion anomaly | Step-over-step conversion rate | High | Both |
| Page load anomaly | P95 page load time | Medium | Both |

### Relative Volume Alerts

Trigger when a metric changes by a percentage relative to the previous period.

| Alert | Condition | Period | App |
|-------|-----------|--------|-----|
| Event volume drop | >30% decrease in key events | Day-over-day | Both |
| Conversion drop | >20% decrease in funnel completion | Week-over-week | Both |
| Error rate increase | >50% increase in client-side errors | Hour-over-hour | Both |

## Alert Routing

### PostHog Alert Destinations

| Destination | Use For | Setup |
|-------------|---------|-------|
| Slack | Real-time team notifications | PostHog > Data Management > Actions > Slack webhook |
| Email | Daily/weekly digests | PostHog > Subscriptions on dashboards |
| Webhook | Custom integrations | PostHog > Actions > Webhook |

### Combined Alert Strategy

```
PostHog detects product metric anomaly
  → Slack notification to team channel
  → If severe: manually create Linear issue with PostHog link
  → Investigate using PostHog session replays + Sentry errors

Sentry detects error spike
  → Auto-creates Linear issue (via Sentry→Linear integration)
  → Check PostHog for user impact breadth
  → Triage per incident-response skill
```

## Key Metrics Per App

### Alteri

| Metric | Type | Healthy Range | Alert |
|--------|------|---------------|-------|
| Research session starts/day | Volume | >5 | <2 = warning |
| Session start→scenario view | Conversion | >60% | <40% = investigate |
| Scenario view→complete | Conversion | >40% | <20% = investigate |
| AI response latency P95 | Performance | <3000ms | >5000ms = alert |
| Voice memo submission rate | Adoption | Trending up | Week-over-week decline = warning |
| Session duration (median) | Engagement | 5-30 min | <1 min or >60 min = anomaly |

### SoilWorx

| Metric | Type | Healthy Range | Alert |
|--------|------|---------------|-------|
| Distributor searches/day | Volume | >10 | <3 = warning |
| Search→result view | Conversion | >70% | <50% = investigate |
| Result view→contact | Conversion | >15% | <5% = investigate |
| Search result relevance (CTR@3) | Quality | >40% | <20% = alert |
| XLSX import success rate | Operations | >95% | <80% = alert |

## Action-Based Alert Configuration

PostHog "Actions" define reusable event matchers. Use Actions as alert triggers.

### Creating an Alert Action

1. Define the Action (PostHog > Data Management > Actions):
   - Name: descriptive (e.g., "Scenario Completion")
   - Match: event name, property filters, URL patterns
   - Can combine multiple event conditions

2. Set up notification:
   - Slack webhook for immediate alerts
   - Dashboard subscription for periodic digests

### Recommended Actions for Claudian

| Action Name | Match Criteria | Alert |
|-------------|---------------|-------|
| `Critical Error Client` | Event: `$exception`, severity: error | Slack immediate |
| `Scenario Funnel Drop` | Funnel: start→view→complete, <20% completion | Slack + investigate |
| `Search No Results` | Event: `distributor_search`, results_count: 0 | Dashboard flag |
| `Slow AI Response` | Event: `ai_response_generated`, latency_ms: >5000 | Slack warning |
| `New User First Session` | Event: first `research_session_start` per user | Dashboard tracking |
