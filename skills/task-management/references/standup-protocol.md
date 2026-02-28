# Standup Protocol

Detailed reference for the daily standup data gathering and formatting process.

## Data Gathering Queries

### Linear (Required)

```
# Recently completed issues (since last standup, ~24h)
list_issues(team: "Claudian", state: "Done", limit: 10)
# Filter by updatedAt > last standup time

# Currently in progress
list_issues(team: "Claudian", state: "In Progress", limit: 10)

# Current cycle progress
list_cycles(team: "Claudian", limit: 1)
# Get active cycle, calculate velocity

# Blocked issues
list_issues(team: "Claudian", state: "In Progress", limit: 10)
# Check blockedBy relations via includeRelations: true
```

### GitHub (Optional)

Check for each In Progress issue:
- Open PRs: branch matches `CIA-XXX-*`
- PR status: reviews, CI checks
- Recent merges to main

### Sentry (Optional)

- New issues created since last standup
- Unresolved P1/P2 issues
- Error rate trend

### Vercel (Optional)

- Deployments since last standup
- Failed deployments
- Current production status

## Velocity Calculation

```
Cycle velocity = points completed / points planned × 100%

Current pace:
- Days elapsed in cycle
- Points completed
- Points remaining
- On track if: (points_completed / days_elapsed) >= (total_points / total_days)
```

## Stale Detection

Issues In Progress beyond their context threshold are flagged:

| Context | Stale After |
|---------|-------------|
| `ctx:interactive` | 2 hours with no activity |
| `ctx:autonomous` | 30 minutes with no activity |
| `ctx:review` | 1 hour with no activity |
| `ctx:human` | 48 hours with no activity |

"No activity" = no status change, no comments, no linked PR activity.

Action for stale items:
1. Check if the agent/human is still working (comments, PR activity)
2. If genuinely stale: move to Todo, remove ctx:* label, post comment
3. If blocked: identify the blocker, create blocking issue if needed

## Carry-Forward Detection

At cycle boundary (Monday), identify incomplete items:
- In Progress items not completed
- Todo items not started
- Backlog items that were planned for the cycle

For each: decide to carry forward (move to next cycle) or park (move to Backlog with reason).

## Standup Cadence

| Day | Focus |
|-----|-------|
| Monday | Cycle start — review carry-forward, plan new cycle, set WIP |
| Tuesday–Thursday | Progress check, blocker resolution |
| Friday | Cycle wrap-up candidate — identify items at risk, suggest scope cuts |

## Multi-Project Standup

When working across multiple projects, group by project:

```markdown
## Standup — [Date]

### Alteri
[Standard standup sections for Alteri issues]

### ClinearHub
[Standard standup sections for ClinearHub issues]

### Platform (shared)
[Standard standup sections for shared infrastructure]
```
