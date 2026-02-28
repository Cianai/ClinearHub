# Root Cause Analysis Protocol

Structured approach to identifying and documenting root causes for production incidents.

## When to Perform RCA

| Severity | RCA Type | Required |
|----------|----------|----------|
| P1 Critical | Full RCA (Linear document) | Always |
| P2 High | Quick RCA (issue comment) | Always |
| P3 Medium | Quick RCA | If recurring (3+ occurrences) |
| P4 Low | None | Unless pattern emerges |

## Quick RCA Template

Post as a comment on the Linear issue after the fix is merged:

```markdown
## Root Cause Analysis

**Error:** [ExceptionType]: [message]
**Impact:** [N users affected, N sessions, duration from first_seen to fix deployed]
**Root cause:** [One sentence explaining why the error occurred]
**Fix:** [Link to PR]
**Prevention:** [What would have caught this earlier — missing test, alert, validation]
```

## Full RCA Process

For P1 incidents, create a Linear document attached to the issue.

### Step 1: Timeline

Build the incident timeline using:
- Sentry: `first_seen`, event timestamps, release correlation
- GitHub: commit timestamps, PR merge time, deploy time
- Vercel: deployment logs, deploy timestamps
- PostHog: user impact timeline (if session replay available)

### Step 2: Five Whys

Apply iterative "why" questioning to find the root cause, not just the proximate cause.

Example:
1. **Why did the page crash?** → Unhandled null reference in UserProfile component
2. **Why was the value null?** → API response didn't include the `preferences` field
3. **Why was the field missing?** → Database migration added the column but didn't backfill existing rows
4. **Why wasn't it backfilled?** → Migration script only handles new rows, no backfill step
5. **Why wasn't this caught in testing?** → Test fixtures always include `preferences`, doesn't match production data shape

Root cause: Test fixtures don't reflect real production data patterns. Proximate fix: add null check. Systemic fix: add production data shape validation to test setup.

### Step 3: Categorize

| Category | Description |
|----------|-------------|
| Code defect | Logic error, missing validation, race condition |
| Data issue | Missing migration, schema mismatch, corrupt data |
| Integration failure | External API change, timeout, auth expiry |
| Configuration | Wrong env var, feature flag, deployment config |
| Infrastructure | Memory, CPU, disk, network, DNS |
| Dependencies | Package update broke API, version conflict |

### Step 4: Prevention Actions

For each finding, define concrete prevention:

| Prevention Type | Example |
|----------------|---------|
| Test coverage | Add integration test for null `preferences` path |
| Alert rule | Alert when API response shape changes |
| Validation | Runtime schema validation on API responses |
| Process | Add backfill step to migration template |
| Monitoring | Dashboard panel for response shape anomalies |

Each prevention action becomes a Linear issue (type:chore) linked to the incident issue.

### Step 5: Document

Full RCA document structure:

```markdown
# Incident Report — CIA-XXX: [Title]

## Summary
[2-3 sentences: what happened, impact, resolution]

## Severity: P[1-4]
## Duration: [start] to [resolution]
## Users Affected: [count]

## Timeline
- [YYYY-MM-DD HH:MM] First error detected by Sentry
- [YYYY-MM-DD HH:MM] Linear issue auto-created
- [YYYY-MM-DD HH:MM] Triaged as P[N]
- [YYYY-MM-DD HH:MM] Root cause identified
- [YYYY-MM-DD HH:MM] Fix PR opened: [link]
- [YYYY-MM-DD HH:MM] PR merged and deployed
- [YYYY-MM-DD HH:MM] Error rate returned to baseline
- [YYYY-MM-DD HH:MM] Verification complete

## Root Cause
[Detailed explanation from Five Whys analysis]

## Category: [from categorization above]

## Fix Applied
[Link to PR, what changed and why]

## Prevention Actions
- [ ] CIA-YYY: [prevention action 1]
- [ ] CIA-ZZZ: [prevention action 2]

## Lessons Learned
[What to apply to future incidents]
```
