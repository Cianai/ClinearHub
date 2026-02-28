---
description: Triage production errors from Sentry, classify severity, perform RCA, route fixes
argument-hint: "[<CIA-XXX issue ID> | --sweep] [--severity <P1|P2|P3|P4>]"
---

# Incident

Triage and manage production errors from the Sentry→Linear pipeline. Can process a single incident or sweep all unresolved error issues.

## Step 1: Identify Incidents

### Single Incident Mode (default)

If an issue ID is provided:
```
get_issue(id: "$1", includeRelations: true)
list_comments(issueId: "$1", limit: 10)
```

### Sweep Mode (`--sweep`)

Find all Sentry-created issues in Triage or Todo:
```
list_issues(team: "Claudian", state: "Triage", label: "type:bug", limit: 10)
list_issues(team: "Claudian", state: "Todo", label: "type:bug", limit: 10)
```

Filter to issues with Sentry source context (stack traces, error fingerprints).

## Step 2: Gather Sentry Context

For each incident, query Sentry for details:
- Error type and message
- Stack trace (file paths, line numbers)
- Affected users and event count
- First seen / last seen timestamps
- Tags (browser, OS, release, environment)
- Suspect commits (if Sentry↔GitHub integration configured)

If PostHog is connected, also check:
- Active user impact (what % of sessions are affected)
- Error rate trend (increasing, stable, decreasing)
- Affected user flows

## Step 3: Classify Severity

Apply severity classification:

| Severity | Criteria |
|----------|----------|
| **P1 Critical** | App crash, data loss, auth broken, >10% users |
| **P2 High** | Feature broken, degraded experience, >1% users |
| **P3 Medium** | Non-critical issue, workaround exists |
| **P4 Low** | Cosmetic, edge case, <0.1% users |

If `--severity` is provided, use the specified severity. Otherwise, auto-classify based on Sentry data.

Check for regressions: If this error was previously resolved and reopened, elevate severity by one level.

## Step 4: Update Linear Issue

Apply labels and metadata:
- `type:bug` (if not already applied)
- `urgent` (if P1 or P2)
- Estimate based on stack trace complexity and fix difficulty
- `exec:quick` (obvious fix from stack trace) or `exec:tdd` (needs investigation)

Post a classification comment:
```markdown
## Incident Classification

**Severity:** P[N] — [Critical/High/Medium/Low]
**Error:** [type]: [message]
**Impact:** [N users, N events, first seen [date]]
**Regression:** [Yes/No]
**Suspect commits:** [commit links if available]

**Recommended action:** [Route to Codex / Assign to human / Backlog]
```

## Step 5: Route

| Severity | Route |
|----------|-------|
| P1 | Assign immediately. If fix is obvious: apply `auto:implement`. If not: assign to human with `ctx:human`. |
| P2 | Apply `auto:implement` with fix hints in comment. Or assign for next slot. |
| P3 | Normal triage queue. Move to Todo for current cycle. |
| P4 | Move to Backlog. Link to parent if pattern exists. |

## Step 6: Perform RCA (P1/P2 only)

For P1: Create a full incident report as a Linear document attached to the issue.
For P2: Post a quick RCA comment on the issue.

See the `incident-response` skill's `references/rca-protocol.md` for the full RCA process.

## Step 7: Report

```markdown
## Incident Triage Summary

Processed: N incidents

| Issue | Error | Severity | Impact | Route | RCA |
|-------|-------|----------|--------|-------|-----|
| [CIA-XXX](url) | TypeError: x | P2 High | 45 users | auto:implement | Quick |
| [CIA-YYY](url) | 500 /api/chat | P3 Medium | 12 users | Todo | — |

**Actions Taken:**
- [N] issues classified and labeled
- [N] routed to Codex (auto:implement)
- [N] assigned to human
- [N] moved to backlog
- [N] RCA documents created
```
