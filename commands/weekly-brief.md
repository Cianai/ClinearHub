---
description: Cross-project weekly digest from Linear + PostHog + Sentry + Vercel + GCal
argument-hint: "[--week <YYYY-WNN>]"
---

# Weekly Brief

Generate a comprehensive weekly digest across all projects, aggregating data from Linear, PostHog, Sentry, Vercel, and Google Calendar.

## Step 1: Determine Week

Default: current week (Monday to now, or previous full week if today is Monday).

If `--week` specified, use that ISO week.

## Step 2: Gather Data

### From Linear

For each active project (Claudian Platform, ClinearHub, Alteri, Cognito, CCC):

- Issues completed this week
- Issues created this week
- Current cycle progress (pts completed / planned)
- Milestone status changes
- Customer Requests received and resolved
- Initiative status (if applicable)

### From PostHog (if connected)

- Week-over-week metric trends for key dashboards
- Notable feature adoption changes
- Experiment results (if any concluded)
- Error rate trends

### From Sentry (if connected)

- New errors this week (count and severity)
- Error trends (improving/stable/worsening)
- Critical unresolved issues
- Releases with error impact

### From Vercel (if connected)

- Deployments this week (count, success rate)
- Notable deploy failures
- Preview deploy activity

### From Google Calendar (if connected)

- Key meetings this week (count, total hours)
- Upcoming meetings next week
- Meeting-free blocks for deep work

## Step 3: Compose Brief

```markdown
## Weekly Brief — Week of [Date]

### Highlights
- [Top 3-5 accomplishments across all projects]

### By Project

#### Claudian Platform
- Completed: N issues (N pts)
- Created: N issues
- Cycle: N/N pts (XX%)
- Key: [1-2 sentence summary]

#### [Other projects with activity...]

### Metrics
- PostHog: [Key metric trends]
- Sentry: [Error summary]
- Vercel: [Deploy summary]

### Customer Activity
- Requests received: N
- Requests resolved: N
- Outstanding: N

### Calendar
- Meetings this week: N (N hours)
- Next week: N meetings scheduled
- Deep work blocks available: [days/times]

### Upcoming
- [Key items for next week]
- [Deadlines approaching]
- [Spikes or research due]

### Risks
- [Any blockers, stale items, or SLA concerns]
```

## Step 4: Delivery

Present the brief in Cowork. Do not auto-post anywhere — the weekly brief is for the human's review.

If the user wants to share it:
- `/stakeholder-update` to post project-specific portions to Linear
- Copy to Notion for client-facing summaries
- Email via Gmail for external stakeholders
