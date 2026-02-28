---
name: incident-response
description: |
  Sentry-to-Linear error pipeline, triage, root cause analysis, and incident management. Use when discussing production errors, Sentry issues, error triage, incident severity, root cause analysis, hotfix priority, error rate spikes, regression detection, on-call response, post-mortem analysis, or the Sentry→Linear auto-issue pipeline. Also triggers for questions about Sentry integration, error monitoring, suspect commits, stack trace linking, or how production errors flow through the system.
---

# Incident Response

Production error management spanning Sentry (detection), Linear (tracking), and GitHub (resolution). This skill covers the error pipeline from alert to resolution, including triage, severity classification, root cause analysis, and the hotfix loop.

## Error Pipeline

```
Sentry detects error → Auto-creates Linear issue (via integration)
  → Triage: classify severity, check for regressions
  → Route: hotfix (critical) or backlog (low)
  → Fix: branch, implement, PR with "Closes CIA-XXX"
  → Verify: Sentry issue resolved, error rate drops
```

### Pipeline Surfaces

| Surface | Role | Tools |
|---------|------|-------|
| Sentry | Detection, alerting, stack traces, suspect commits | Sentry MCP (OAuth Connector) |
| Linear | Issue tracking, assignment, status transitions | Linear MCP (OAuth Connector) |
| GitHub | PRs, code review, merge, deploy | GitHub MCP (OAuth Connector) |
| Vercel | Deploy verification, preview URLs | Vercel (Desktop Connector) |
| PostHog | Impact assessment (affected users, sessions) | PostHog (Desktop Connector) |

## Severity Classification

When triaging a Sentry-created Linear issue, classify by impact:

| Severity | Criteria | Response Time | Action |
|----------|----------|---------------|--------|
| **Critical (P1)** | App crash, data loss, auth broken, >10% users affected | Immediate | Hotfix PR, skip queue, apply `urgent` label |
| **High (P2)** | Feature broken, degraded experience, >1% users affected | Same day | Priority queue, apply `type:bug` + estimate |
| **Medium (P3)** | Non-critical feature issue, workaround exists | This cycle | Normal triage flow |
| **Low (P4)** | Cosmetic, edge case, <0.1% users | Backlog | Backlog unless pattern emerges |

### Regression Detection

An error is a regression if:
1. The Sentry issue was previously resolved and has reopened
2. The error signature matches a recently-fixed issue (check `first_seen` vs `last_seen`)
3. Suspect commits show changes to previously-stable code

Regressions are automatically elevated one severity level (P3 → P2, P2 → P1).

## Triage Protocol

When processing a Sentry-created issue in Linear Triage:

### Step 1: Gather Context from Sentry

```
Search Sentry for the issue details:
- Error message and type
- Stack trace (file paths, line numbers)
- Affected users count
- First seen / last seen timestamps
- Suspect commits (if Sentry↔GitHub configured)
- Tags: browser, OS, release version
```

### Step 2: Assess Impact

Using PostHog (if connected):
- How many active users are affected?
- Is the error rate increasing or stable?
- Which user flows are broken?
- Are there session replay recordings showing the error?

### Step 3: Classify and Label

Apply to the Linear issue:
- `type:bug` (always for production errors)
- `urgent` (if P1 or P2)
- Estimate based on stack trace complexity
- `exec:quick` (obvious fix) or `exec:tdd` (needs investigation)

### Step 4: Route

| Severity | Route |
|----------|-------|
| P1 Critical | Assign immediately. Apply `auto:implement` if fix is obvious from stack trace. Otherwise assign to human with `ctx:human`. |
| P2 High | Apply `auto:implement` with fix hints in comments. Or assign for next available slot. |
| P3 Medium | Normal triage. Queue for current cycle if capacity allows. |
| P4 Low | Backlog. Link to parent issue if pattern exists. |

## Root Cause Analysis

> See [references/rca-protocol.md](references/rca-protocol.md) for the full RCA process.

For P1/P2 incidents, perform RCA before closing:

### Quick RCA (P2, simple issues)

Post a comment on the Linear issue:
```markdown
## Root Cause Analysis

**Error:** [error type and message]
**Impact:** [N users, N sessions, duration]
**Root cause:** [one sentence]
**Fix:** [PR link]
**Prevention:** [what would have caught this earlier]
```

### Full RCA (P1, complex issues)

Create a separate Linear document attached to the issue:
```markdown
## Incident Report — CIA-XXX

### Timeline
- [HH:MM] Error first detected by Sentry
- [HH:MM] Linear issue auto-created
- [HH:MM] Triaged as P1
- [HH:MM] Fix PR opened
- [HH:MM] Merged and deployed
- [HH:MM] Error rate returned to baseline

### Impact
- Users affected: N
- Duration: X minutes/hours
- Revenue impact: [if applicable]

### Root Cause
[Detailed explanation]

### Fix Applied
[Link to PR, what changed]

### Prevention
- [ ] Test coverage for this path
- [ ] Alert rule for early detection
- [ ] Monitoring dashboard update
```

## Hotfix Loop

For P1/P2 issues requiring immediate action:

1. **Create branch**: `CIA-XXX-hotfix-slug`
2. **Fix**: Minimal change to resolve the error (no refactoring)
3. **Test**: Run affected test suite. Add regression test.
4. **PR**: Body includes `Closes CIA-XXX`. Request expedited review.
5. **Merge**: Skip auto-merge queue if P1 — merge immediately after CI passes.
6. **Verify**: Check Sentry for error rate drop. Confirm fix in production.
7. **Follow-up**: If the minimal fix warrants a proper refactor, create a separate `type:chore` issue.

## Sentry↔GitHub Integration

> See [references/sentry-github-pipeline.md](references/sentry-github-pipeline.md) for configuration details.

The Sentry↔GitHub integration (configured in Sentry Settings > Integrations > GitHub) provides:

| Feature | What It Does |
|---------|-------------|
| Suspect commits | Identifies recent code changes in files appearing in stack traces |
| Stack trace linking | Links error frames to source code with version-specific GitHub URLs |
| PR comments | Surfaces Sentry issues on merged PRs (<2 weeks) and open PRs |
| Resolve via commit | `fixes SENTRY-ID` in commit messages auto-resolves the Sentry issue |
| AI code review (Seer) | AI-generated root cause analysis and fix suggestions on PRs |

## Alert Configuration

> See the `sentry-create-alert` repo skill for alert rule creation patterns.

Recommended alerts for the Claudian stack:

| Alert | Condition | Action |
|-------|-----------|--------|
| New error spike | >10 events in 5 minutes for a new issue | Notify + create Linear issue |
| Regression | Previously resolved issue reopens | Notify + P2 minimum severity |
| Performance | P95 response time >3s for any route | Notify |
| Release health | Error rate >1% within 1 hour of deploy | Notify + consider rollback |

## Cross-Skill References

- **clinearhub-workflow** — Overall triage flow (Step 2 and 5 involve Sentry)
- **issue-lifecycle** — Status transitions for bug issues, closure protocol
- **deployment-verification** — Post-deploy error rate checks (Phase 2)
