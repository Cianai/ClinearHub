---
description: Multi-source status update from Linear + PostHog + Vercel + Sentry
argument-hint: "[--project <name>] [--audience <exec|team|customer>] [--post]"
---

# Stakeholder Update

Generate a status update by aggregating data from multiple sources: Linear (issues, milestones), PostHog (analytics, feature adoption), Vercel (deploy status), and Sentry (error rates). Tailor the format to the audience.

## Step 1: Determine Scope

| Argument | Behavior |
|----------|----------|
| (none) | Auto-detect projects with recent changes |
| `--project "Name"` | Specific project |
| `--audience exec` | Executive summary (metrics-focused, 3-5 bullets) |
| `--audience team` | Team update (detailed, includes blockers and next steps) |
| `--audience customer` | Customer-facing (outcomes-only, no internal details) |
| `--audience board` | Board/investor update (strategic narrative, metrics, risks, investment thesis) |
| `--post` | Post to Linear Updates tab (default: preview only) |
| `--post-email` | Compose and send via Gmail (requires Gmail connector) |

Default audience: `team`.

## Step 2: Gather Data

### From Linear
- Recent issue activity: completions, status changes, new issues
- Milestone progress: % complete, approaching deadlines
- Active blockers: blocking relationships on In Progress issues
- Cycle velocity: issues completed vs planned in current cycle

### From PostHog (if connected)
- Feature adoption metrics for recently shipped features
- Error rates and trends
- Key funnel metrics relevant to the project

### From Vercel (if connected)
- Latest deployment status and URL
- Deploy frequency this week
- Any failed deploys

### From Sentry (if connected)
- New errors since last update
- Error rate trends (improving/worsening)
- Unresolved critical issues

## Step 3: Calculate Health

| Signal | Condition |
|--------|-----------|
| On Track | No overdue milestones, no blockers, error rates stable |
| At Risk | Any blocker on active issue, milestone within 3 days, error spike |
| Off Track | Milestone past target date, critical Sentry issues unresolved |

## Step 4: Compose Update

### Executive Audience
```markdown
## [Project] — [Health Signal]

**Key Metrics:**
- Shipped: N features this cycle
- Velocity: N pts completed / N planned
- Adoption: [key metric from PostHog]
- Errors: [trend from Sentry]

**Highlights:** [2-3 bullets on major completions]
**Risks:** [1-2 bullets if any]
```

### Team Audience
```markdown
## [Project] Status — [Date]

**Health:** [Signal] | **Cycle:** [N/M] pts | **Deploy:** [status]

### Completed
- CIA-XXX: [title] (merged [date])

### In Progress
- CIA-YYY: [title] — [status note]

### Blocked
- CIA-ZZZ: [title] — blocked by [reason]

### Created
- CIA-AAA: [title] (new this period)

### Metrics
- PostHog: [key metric]
- Sentry: [error trend]
- Vercel: [deploy status]

### Next Steps
- [Priority 1]
- [Priority 2]
```

### Customer Audience
```markdown
## What's New — [Date]

- **[Feature name]**: [One sentence on what it does and why it matters]
- **[Improvement]**: [One sentence on the benefit]

Coming soon: [1-2 upcoming items relevant to the customer]
```

### Board Audience
```markdown
## [Project] — Board Update [Date]

### Strategic Position
[1-2 paragraphs: where are we, what's changed since last update, what's the trajectory]

### Key Metrics
| Metric | Current | Previous | Trend |
|--------|---------|----------|-------|
| [Primary metric] | [value] | [value] | [↑/↓/→] |

### ROAM Risk Register
| Risk | Status | Owner | Notes |
|------|--------|-------|-------|
| [Risk 1] | Resolved / Owned / Accepted / Mitigated | [person] | [action] |

### Investment Narrative
[How are we allocating resources? What's the ROI thesis for current work?]

### Asks
- [Specific, actionable request 1]
- [Specific, actionable request 2]
```

## Health Indicators

Use consistent G/Y/R indicators across all audiences:

| Indicator | Meaning | Concrete Definition |
|-----------|---------|---------------------|
| 🟢 Green | On Track | No overdue milestones, no blockers, error rates stable or improving |
| 🟡 Yellow | At Risk | Any blocker on active issue, milestone within 3 days, OR error rate elevated |
| 🔴 Red | Off Track | Milestone past target date, critical Sentry issues unresolved, OR velocity <50% of plan |

## ROAM Risk Framework

For `--audience exec` and `--audience board`, classify risks using ROAM:

| Status | Meaning | Action |
|--------|---------|--------|
| **Resolved** | Risk is no longer a concern | Document what fixed it |
| **Owned** | Someone is actively working on it | Name the owner + expected resolution |
| **Accepted** | Risk acknowledged, no action taken | Document why and what triggers re-evaluation |
| **Mitigated** | Actions taken to reduce probability/impact | Document mitigations applied |

## Language Adaptation

Adapt language to each audience:

| Audience | Style | Example |
|----------|-------|---------|
| **Executive** | Concise, no jargon, metrics-first | "Shipped 3 features, adoption up 15%" |
| **Team** | Detailed, link PRs/tickets, technical context OK | "Merged CIA-XXX (voice intake v2), CI now 40% faster" |
| **Customer** | Benefit-focused, no internal details | "You can now import distributors via spreadsheet" |
| **Board** | Strategic narrative, investment-grade language | "Platform investment yielding 3x dev velocity" |

## Asks Section

Every update (except customer) ends with specific, actionable requests:

```markdown
### Asks
- [Decision needed]: <specific question requiring a decision>
- [Resource needed]: <what's needed and why>
- [Feedback requested]: <specific item to review>
```

"No asks" is acceptable but must be stated explicitly: "**Asks:** None this period."

## Step 5: Preview or Post

Default: Preview the update. The user must explicitly use `--post` or `--post-email` to publish.

### --post
Post to Linear's native Updates tab for the project. Deduplicate against same-day updates (amend if exists, create if new).

For initiative-level updates, use:
```
save_status_update(
  type: "initiative",
  id: "<initiative_id>",
  health: "onTrack" | "atRisk" | "offTrack",
  body: "<update markdown>"
)
```

### --post-email
Compose the update as an email via Gmail connector. Adapt formatting for email (no markdown tables — use bullet lists instead). Ask for recipient before sending.

Apply sensitivity filtering before posting: no file paths, credentials, stack traces, or API keys.
