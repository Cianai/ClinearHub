---
name: task-management
description: |
  Linear-native task management for daily standups and issue critique. Use when discussing daily standup summaries, what was done yesterday, what's planned today, blockers, issue quality critique, WIP limits, cycle progress, velocity, burndown, carry-forward items, or any question about day-to-day task tracking and coordination. For session handoff and context preservation, see the plan-persistence skill.
---

# Task Management

Daily operational coordination using Linear as the single source of truth. Covers two workflows: standup (daily sync) and critique (issue quality). Session handoff is handled by the plan-persistence skill via `/plan --finalize`.

## Standup

Daily sync that answers three questions: What was completed? What's planned? What's blocked?

### Data Sources

All data comes from Linear. Optional enrichment from other connected tools.

| Source | What It Provides |
|--------|-----------------|
| Linear (required) | Issue status changes, completions, assignments, cycle progress |
| GitHub (if connected) | PR status, merge activity, CI results |
| Sentry (if connected) | New errors since last standup, unresolved criticals |
| Vercel (if connected) | Deploy count, failed deploys |
| PostHog (if connected) | Feature adoption for recently shipped items |

### Standup Format

```markdown
## Standup — [Date]

### Completed (since last standup)
- [CIA-XXX: Title](url) — merged [PR link]
- [CIA-YYY: Title](url) — closed (canceled, reason)

### In Progress
- [CIA-ZZZ: Title](url) — [status note, % done, PR status]
  - Assigned: [person/agent]
  - Context: ctx:[interactive|autonomous|review]

### Planned (today)
- [CIA-AAA: Title](url) — [what will be done]

### Blocked
- [CIA-BBB: Title](url) — blocked by [reason/issue link]
  - Action needed: [who needs to do what]

### Metrics
- Cycle: [N/M] pts completed ([X%])
- WIP: [N]/5 in progress
- New errors (Sentry): [N]
- Deploys (Vercel): [N] (failed: [N])
```

### WIP Check

Maximum 5 issues In Progress across all agents and humans. If over limit:
1. Identify stale items (In Progress but no activity for >2 hours for `ctx:interactive`, >30 min for `ctx:autonomous`)
2. Suggest: complete, park (move to Todo), or reassign

## Critique

Quality review of issue descriptions, acceptance criteria, and metadata completeness. Run this before dispatching to agents (Codex, ChatPRD) to catch issues that will fail or produce low-quality results.

### Critique Checklist

For each issue reviewed:

#### Description Quality
- [ ] **Problem statement** exists and doesn't mention the solution
- [ ] **Acceptance criteria** are present, testable, and independently verifiable
- [ ] **Non-goals** are listed (at least 1 for features, optional for bugs/chores)
- [ ] **No ambiguity** — could an agent implement this without asking questions?

#### Metadata Completeness
- [ ] **Type label** — Exactly one `type:*` label applied
- [ ] **Execution mode** — `exec:*` label matches complexity
- [ ] **Estimate** — Fibonacci estimate applied (1, 2, 3, 5, 8, 13)
- [ ] **Project** — Assigned to correct project
- [ ] **Priority** — Set (Urgent, High, Medium, Low, None)

#### Agent Readiness
- [ ] **Dependencies resolved** — All `blockedBy` issues are Done
- [ ] **Context sufficient** — Description + comments provide enough for implementation
- [ ] **Scope bounded** — No open questions that would cause scope creep

### Critique Scoring

| Score | Meaning | Action |
|-------|---------|--------|
| **Ready** (all checks pass) | Issue can be dispatched | Apply `auto:implement` or route |
| **Needs Work** (1-2 issues) | Minor gaps | Fix inline, then dispatch |
| **Not Ready** (3+ issues) | Significant gaps | Return to draft, add comment with findings |

### Critique Output

```markdown
## Issue Critique — CIA-XXX: [Title]

**Score:** [Ready / Needs Work / Not Ready]

### Findings
| Check | Status | Note |
|-------|--------|------|
| Problem statement | Pass | — |
| Acceptance criteria | Fail | ACs are vague — "should work well" is not testable |
| Non-goals | Pass | — |
| Type label | Pass | type:feature |
| Estimate | Missing | Suggest 3pt based on scope |
| Dependencies | Warning | CIA-YYY is In Progress, not Done |

### Recommended Actions
1. Rewrite AC #3 to be testable: "Response time < 200ms for P95"
2. Add estimate: 3pt
3. Wait for CIA-YYY before dispatching
```

## Cross-Skill References

- **clinearhub-workflow** — Label system, triage protocol, WIP limits
- **issue-lifecycle** — Status transitions, closure protocol, ctx:* labels
- **incident-response** — Error issues that may appear in standups
