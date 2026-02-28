---
description: Daily standup summary from Linear issues, cycle progress, blockers, and optional Sentry/Vercel/PostHog
argument-hint: "[--project <name>] [--since <date>]"
---

# Standup

Generate a daily standup summary from Linear and connected tools.

## Step 1: Determine Time Window

Default: since last standup (24 hours). Override with `--since`.

## Step 2: Gather Completed Work

```
list_issues(team: "Claudian", state: "Done", limit: 10)
```

Filter to issues updated within the time window. If `--project` specified, filter to that project.

For each completed issue, check GitHub for the merged PR link.

## Step 3: Gather In Progress

```
list_issues(team: "Claudian", state: "In Progress", limit: 10)
```

For each, check:
- Assigned to whom (person or agent)
- Context label (ctx:interactive, ctx:autonomous, ctx:review, ctx:human)
- Any open PR and its status (reviews, CI)
- Blocked by any other issue (check relations)
- Stale detection: is it past its context threshold without activity?

## Step 4: Identify Planned Work

```
list_issues(team: "Claudian", state: "Todo", limit: 10)
```

Sort by priority, then estimate. Top 3-5 items are "planned today."

## Step 5: Check Blockers

From Step 3, extract any issues with `blockedBy` relations where the blocking issue is not Done. Also check for:
- Issues assigned to human with `ctx:human` needing decision
- Issues with open questions in comments

## Step 6: Gather Metrics

### Cycle Progress
```
list_cycles(team: "Claudian", limit: 1)
```
Calculate: points completed / points planned, days remaining.

### Sentry (if connected)
- Count new errors since last standup
- Count unresolved P1/P2 issues

### Vercel (if connected)
- Count deployments since last standup
- Any failed deployments

### WIP Check
Count In Progress issues. Flag if over 5 (WIP limit).

## Step 7: Compose Standup

```markdown
## Standup — [Date]

### Completed (since [last standup date])
- [CIA-XXX: Title](url) — merged [PR link]

### In Progress
- [CIA-YYY: Title](url) — [status note]
  - Assigned: [person/agent] | Context: ctx:[label]

### Planned (today)
- [CIA-ZZZ: Title](url) — [priority, estimate]

### Blocked
- [CIA-AAA: Title](url) — blocked by [reason]

### Metrics
- Cycle: [N/M] pts ([X%]) | [N] days remaining
- WIP: [N]/5
- Sentry: [N] new errors | [N] unresolved P1/P2
- Vercel: [N] deploys | [N] failed
```

## Step 8: Flag Issues

If any of the following, call out explicitly:
- WIP limit exceeded (>5 in progress)
- Stale items (past context threshold)
- Cycle at risk (pace below target with <2 days remaining)
- P1/P2 Sentry issues unresolved
