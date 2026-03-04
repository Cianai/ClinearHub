# Triage Rules

## Triage Intelligence (Auto-Apply)

TI processes new issues within 1-4 minutes of creation. Configured on Claudian parent team, inherited by ALT and SWX sub-teams.

| Suggestion | Mode | Effect |
|------------|------|--------|
| Team | Auto-apply | Routes to CIA/ALT/SWX based on issue content |
| Project | Auto-apply | Maps to Claudian Platform/ClinearHub/Alteri/Cognito |
| Labels | Auto-apply | Suggests Type, Exec, Spec, Context labels |
| Assignee | Show | Suggests but doesn't auto-assign |
| Duplicates | Show | Flags potential duplicates for human review |
| Related Issues | Show | Shows related context |

**Additional Guidance** is configured at workspace level with sub-team overrides. TI uses this guidance to improve routing accuracy for ALT (Alteri-specific keywords) and SWX (SoilWorx-specific keywords).

## Triage Rules (Automated)

Fire after TI completes, before human review. Configured on Claudian team (inherited by sub-teams).

| # | Trigger | Actions |
|---|---------|---------|
| 1 | Label = `type:bug` AND Priority = Urgent | Set status: Todo, Add label: `exec:quick`, Assign: Copilot |
| 2 | Label = `type:bug` AND Priority = High | Set status: Todo, Add label: `exec:quick` |

## Agent Dispatch (Label-Triggered)

### Spec Enrichment

- **Trigger:** Issue has `spec:draft` label
- **Action:** ChatPRD agent enriches via Linear MCP connector
- **What ChatPRD does:**
  - Reads issue description via Linear connector
  - Pulls context from GitHub (repo structure), Google Drive (product docs), Granola (recent meeting notes)
  - Applies business strategy personas (Working Backwards, Five Whys, Pre-Mortem, Layman Clarity)
  - Enriches the spec with refined problem statement, acceptance criteria, non-goals
  - Creates child sub-issues with `auto:implement` label
  - Each sub-issue enters Linear Triage as a fresh item

### Implementation Dispatch

- **Trigger:** Issue has `auto:implement` label
- **Action:** Routes to GitHub agents via Linear ↔ GitHub two-way sync
- **Agent selection** (by exec label):
  - `exec:quick` → Copilot Coding Agent (assign to `@github`)
  - `exec:tdd` → gh-aw + Claude engine (`.github/workflows/implement-issue.md`)
  - `exec:pair` → Claude Code Desktop (human + agent)
- **What agents do:**
  - Read issue description and acceptance criteria
  - Create branch and implement the feature/fix
  - Open PR with `Closes <ISSUE-ID>` in body
  - PR enters Copilot auto-review + CI pipeline

## Manual Triage Protocol

Daily sweep of the Linear Triage view (keyboard shortcut: `G T`). TI has already auto-applied team, project, and labels by the time human reviews.

### Processing Order

1. **SLA first** — Issues approaching breach (`slaBreachesAt` field in Linear MCP)
2. **Customer Requests** — External-facing items from Linear Asks or Customer Requests
3. **Agent-created** — Sub-issues created by ChatPRD or Sentry that need human review
4. **Internal** — Feature ideas, bugs, chores from team

### Per-Issue Triage Checklist

For each issue in Triage:

1. **Review TI suggestions**: Check auto-applied team, project, and labels. Correct if wrong.
2. **Type label** (required): Confirm TI-applied type or set one of `type:feature`, `type:bug`, `type:chore`, `type:spike`
3. **Duplicate check**: Review TI duplicate suggestions. If none flagged, search `list_issues(project, query: "<key terms>", limit: 10)` for overlapping scope
4. **Estimate**: Fibonacci (1, 2, 3, 5, 8, 13) based on complexity assessment
5. **Route decision**:
   - Needs spec enrichment → apply `spec:draft` → ChatPRD handles
   - Ready to implement → apply `auto:implement` → gh-aw / Copilot handles
   - Needs human attention → assign to person, apply `ctx:human`
   - Needs investigation → apply `type:spike`, assign to appropriate agent or human
6. **Move out of Triage**: To Todo (queued), In Progress (starting now), or Backlog (not urgent)

### Triage Inbox (Linear Asks)

Linear Asks creates issues from email and Slack messages. These appear in Triage with source context. Requires Business+ plan (confirmed active).

**Channels configured:**
- **Email:** Asks email address routes inbound email → Triage issue
- **Slack:** Connected Slack workspace routes messages → Triage issue

**Verify routing:** Test that email → Triage and Slack message → Triage both create issues in the Claudian team with correct source context.

**Processing:**
- Check the Asks source (email sender, Slack thread) for context
- If it's a customer request: link to the customer in Linear Customer Requests
- If it's a feature request: create a proper issue with `spec:draft`
- If it's a bug report: create with `type:bug`, include reproduction steps
- If it's noise: archive or cancel with a brief reason

## Sentry Bug Routing

Sentry-created issues enter Triage automatically via the Linear↔Sentry integration. Route these autonomously:

1. **Auto-label:** Apply `type:bug` + estimate (1-2pt for clear stack traces, 3pt for ambiguous)
2. **Route decision by clarity:**
   - **Clear fix** (obvious stack trace, single file, reproduction steps) → apply `auto:implement` directly → Copilot handles
   - **Needs investigation** → apply `type:spike` first, assign to appropriate agent or human
   - **Duplicate** → link to existing issue, cancel with note
3. **Sentry Agent enrichment:** @mention Sentry Agent on the issue for root cause analysis before routing to Copilot
4. **End-to-end autonomous path:** Sentry error → Linear issue → ChatPRD enrichment (if `spec:draft`) or Copilot direct (if `auto:implement`) → PR → merge → deploy. No human gate for clear 1-2pt bugs.

## Auto-Close Rationale

| Setting | Value | Why |
|---------|-------|-----|
| Auto-close parent when all children Done | **OFF** | Phase 8 ChatPRD validation must run before parent closes. `/verify` is the human gate. |
| Auto-close sub-issues when parent closes | **OFF** | Parent closure should not cascade — children may be in different states. |

## Phase 8: Business Validation (Post-Merge Cascade)

After all child sub-issues of a parent spec are merged and Done:

1. **Trigger:** `post-merge-reconciliation.yml` GitHub Action fires on each PR merge. After reconciling the sub-issue (Tier 1), it checks sibling status (Tier 2).
2. **Detection:** When the last sub-issue's PR merges and all siblings are Done, the Action posts an "All Sub-Issues Complete" comment on the parent issue.
3. **Human gate:** Human runs `/verify` on the parent to review synthesized outcomes, verify business intent alignment, and close if satisfied.

```
PR merged → Reconciliation Action (Tier 2)
  → Count sibling statuses
  → All Done? → Post "All Sub-Issues Complete" on parent
  → Human reviews via /verify → Close parent if satisfied
```

**Edge case:** Sub-issues closed without PRs (spikes, manual closures) don't trigger the Action. For these, `/plan --finalize` checks sibling status as part of its session close protocol.

**Previous approach (superseded):** n8n webhook bridge was planned to detect "all children Done" via Linear webhooks. This is no longer needed — the GitHub Action handles the same detection at PR merge time, with full PR context (diff, review comments, CI status).

## SLA Integration

**Configuration:** Settings > Workspace > SLAs (workspace-level, applies to all teams)

| Rule | Filter | SLA Duration | Rationale |
|------|--------|-------------|-----------|
| 1 | Priority = Urgent | 24 hours | Standard urgent response |
| 2 | Priority = High | 1 week | Standard high-priority deadline |
| 3 | Label = `urgent` | 24 hours | Catch issues with `urgent` label regardless of priority |
| 4 | Label = `type:bug` + Priority = Urgent | 12 hours | Critical bugs get tighter window |

**Business days:** Monday-Friday. SLA calculations exclude weekends.

**SLA fields** (available in Linear MCP and API):
- `slaStartedAt` — when the SLA timer began
- `slaMediumRiskAt` — approaching deadline
- `slaHighRiskAt` — deadline imminent
- `slaBreachesAt` — SLA deadline timestamp

**Triage priority:** The Processing Order above lists "SLA first" — use `slaBreachesAt` to sort issues approaching breach to the top.

**Monitoring:** Create a saved view "SLA Tracker" filtered to `SLA Status is not empty`, grouped by SLA status. Pin to sidebar.

## WIP Limits

- Maximum 5 issues In Progress across all agents and humans
- If WIP limit is reached, new items stay in Todo until capacity frees up
- Agent-dispatched items (Copilot, ChatPRD) count toward WIP but typically complete quickly
