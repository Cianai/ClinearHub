---
description: Sync and digest from all sources, with duplicate detection
argument-hint: "[--comprehensive] [--project <name>]"
---

# Update

Pull recent activity from all connected sources and present a digest. Optionally run comprehensive duplicate detection across the project.

## Modes

| Flag | Behavior |
|------|----------|
| (none) | Quick digest of recent changes across all projects |
| `--comprehensive` | Deep scan: full dedup check, stale issue detection, label audit |
| `--project "Name"` | Scope to a specific project |

## Quick Digest (Default)

### Step 1: Gather Recent Activity

Pull from each connected source (last 24 hours unless specified):

**Linear:**
- Issues created, completed, or status-changed
- New comments on issues in current cycle
- Triage inbox count
- Customer Requests received

**GitHub (if connected):**
- PRs opened, merged, or with new reviews
- CI status on open PRs
- New issues filed

**PostHog (if connected):**
- Notable metric changes (feature adoption, error rates)
- New feature flag changes

**Sentry (if connected):**
- New errors or error spikes
- Unresolved critical issues

**Vercel (if connected):**
- Recent deployments and their status

### Step 2: Present Digest

```markdown
## Daily Digest — [Date]

### Linear
- N issues completed, N created, N in triage
- Current cycle: N/N pts (XX%)

### GitHub
- N PRs merged, N awaiting review
- CI: all green / N failures

### Alerts
- [PostHog: Feature X adoption dropped 15%]
- [Sentry: 3 new errors in production]
- [Vercel: Deploy failed on branch Y]

### Action Items
1. [Triage N items in inbox]
2. [Review PR #XXX]
3. [Investigate Sentry error Z]
```

## Comprehensive Mode (--comprehensive)

Runs all of the above PLUS:

### Duplicate Detection Scan

For each project in scope:
1. Fetch all open issues: `list_issues(project, state: "Todo", limit: 50)` + `list_issues(project, state: "In Progress", limit: 20)`
2. Compare each pair for title similarity
3. For high-similarity pairs, compare acceptance criteria overlap
4. Report potential duplicates with confidence level

```markdown
### Potential Duplicates Found

| Issue A | Issue B | Similarity | Recommendation |
|---------|---------|-----------|----------------|
| CIA-XXX: Title | CIA-YYY: Title | High (80%) | Merge — same scope |
| CIA-AAA: Title | CIA-BBB: Title | Medium (60%) | Review — partial overlap |
```

### Stale Issue Detection

Find issues that have been In Progress beyond their stale threshold:
- `ctx:interactive`: >2 hours since last update
- `ctx:autonomous`: >30 minutes since last update
- `ctx:review`: >1 hour since last update
- `ctx:human`: >48 hours since last update

### Label Audit

Check for issues missing required labels:
- Issues without `type:*` label
- In Progress issues without `ctx:*` label
- Issues with multiple conflicting labels (e.g., two `type:*` labels)

### Report

```markdown
## Comprehensive Audit — [Project] — [Date]

### Health
- Duplicates found: N
- Stale issues: N
- Missing labels: N

### Recommendations
1. [Merge CIA-XXX and CIA-YYY (duplicate)]
2. [Update or close CIA-ZZZ (stale 3 days)]
3. [Add type:* label to CIA-AAA]
```
