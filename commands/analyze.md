---
description: Analyze product data from PostHog using HogQL queries, funnels, retention, monitoring alerts, notebooks, and dashboards
argument-hint: "<question about user behavior or metrics> [--app alteri|soilworx] [--period 7d|30d|90d] [--notebook for collaborative analysis]"
---

# Analyze

Query and interpret PostHog product data for the Claudian apps. Routes to the appropriate PostHog surface based on the question.

## Step 1: Parse Question

Identify the analysis type from the user's question:

| Question Pattern | Analysis Type | PostHog Surface |
|-----------------|---------------|-----------------|
| "How many users..." | Volume metric | Connector query |
| "What's the conversion..." | Funnel analysis | Connector query or Notebook |
| "Are users coming back..." | Retention analysis | Notebook (complex query) |
| "Is feature X working..." | Adoption analysis | Connector query |
| "Compare A vs B..." | A/B test results | Connector (experiment results) |
| "What happened after deploy..." | Post-deploy impact | Connector + Sentry cross-reference |
| "Deep dive into..." | Exploratory analysis | Notebook (collaborative) |
| "Build a dashboard for..." | Dashboard creation | PostHog UI |

### Determine App Scope

If `--app` is provided, scope to that app's events. Otherwise:
- Check if the question mentions app-specific features
- Default to all apps if unclear

### Determine Time Period

Priority: `--period` flag > question context > default 30d

## Step 2: Route to PostHog Surface

### Connector Query (default — quick answers)

Use for straightforward metric lookups, funnel checks, and event counts.

```
Query PostHog via OAuth Connector or Plugin:
- Construct HogQL query based on analysis type
- See data-analytics skill references/posthog-queries.md for patterns
- Execute query
```

### Notebook (--notebook flag or complex analysis)

Use for exploratory analysis, collaborative review, or multi-query investigations.

```
Create or update a PostHog Notebook:
- Title: "[App] [Analysis type] — [Date]"
- Include context section (what question we're answering)
- Add HogQL queries with inline visualizations
- Add interpretation notes between queries
- End with recommendations
```

## Step 3: Construct Query

Based on analysis type, build the appropriate HogQL query.

### Volume Metrics
```sql
SELECT toDate(timestamp) AS day, count() AS event_count
FROM events
WHERE event = '[target_event]'
  AND timestamp > now() - INTERVAL [period] DAY
GROUP BY day ORDER BY day
```

### Funnel Analysis
Use the PostHog Funnels insight or manual HogQL:
```sql
-- See references/posthog-queries.md for full funnel patterns
```

### Retention
```sql
-- See references/posthog-queries.md for retention cohort query
```

### A/B Test Results
```
Query PostHog experiment results:
- Variant performance (conversion rate per variant)
- Bayesian probability of improvement
- Credible intervals
- Sample size and SRM check
```

## Step 4: Execute and Interpret

### Run the Query
- Via Connector: direct PostHog API query
- Via Notebook: create Notebook with embedded query

### Interpret Results

Apply context from the `data-analytics` skill:
- **Statistical significance**: Is the sample large enough? (see references/statistical-analysis.md)
- **Trend vs noise**: Use rolling averages for noisy daily data
- **Confounding factors**: Deploy timing, day of week, marketing campaigns
- **Comparison baseline**: Previous period, previous year, target

## Step 5: Cross-Reference (if relevant)

For post-deploy or incident-related analysis:
- Cross-reference with Sentry error rates for the same period
- Check Vercel deployment timing for correlation
- Look at Linear issue activity for context

## Step 6: Output Analysis

```markdown
## Analysis — [Question Summary]

**App:** [Alteri / SoilWorx / All]
**Period:** [7d / 30d / 90d]
**Date:** [YYYY-MM-DD]

### Key Findings

1. [Primary finding with number]
2. [Secondary finding]
3. [Trend or pattern observed]

### Data

| Metric | Value | Change | Status |
|--------|-------|--------|--------|
| [metric] | [value] | [+/-X%] | [trend] |

### Funnel (if applicable)

| Step | Users | Conversion | Drop-off |
|------|-------|-----------|----------|
| [step 1] | N | — | — |
| [step 2] | N | X% | Y% |

### Statistical Notes

- Sample size: N (sufficient / insufficient for X% MDE)
- Confidence: [high / moderate / low]
- Caveats: [any limitations]

### Recommendations

1. [Actionable recommendation based on data]
2. [Follow-up analysis if needed]

[If --notebook: "Full analysis available in PostHog Notebook: [link]"]
```
