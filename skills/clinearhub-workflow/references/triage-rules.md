# Triage Rules

## Linear Triage Configuration

Two automated triage rules handle agent dispatch. Configure in Linear Settings > Team > Triage.

### Rule 1: Spec Enrichment

- **Trigger:** Issue receives `spec:draft` label
- **Action:** Delegate to ChatPRD agent
- **What ChatPRD does:**
  - Reads issue description via Linear connector
  - Pulls context from Notion (knowledge base), GitHub (repo structure), Google Drive (product docs), Granola (recent meeting notes)
  - Applies business strategy personas (Working Backwards, Five Whys, Pre-Mortem, Layman Clarity)
  - Enriches the spec with refined problem statement, acceptance criteria, non-goals
  - Creates child sub-issues with `auto:implement` label
  - Each sub-issue enters Linear Triage as a fresh item

### Rule 2: Implementation Dispatch

- **Trigger:** Issue receives `auto:implement` label
- **Action:** Delegate to Codex agent
- **What Codex does:**
  - Reads issue description and acceptance criteria
  - Creates branch: `CIA-XXX-short-slug` (lowercase, kebab-case)
  - Implements the feature/fix
  - Opens PR with `Closes CIA-XXX` in body
  - PR enters GitHub Copilot auto-review + CI pipeline

## Manual Triage Protocol

Daily sweep of the Linear Triage view (keyboard shortcut: `G T`).

### Processing Order

1. **SLA first** — Issues approaching breach (`slaBreachesAt` field in Linear MCP)
2. **Customer Requests** — External-facing items from Linear Asks or Customer Requests
3. **Agent-created** — Sub-issues created by ChatPRD or Sentry that need human review
4. **Internal** — Feature ideas, bugs, chores from team

### Per-Issue Triage Checklist

For each issue in Triage:

1. **Type label** (required): Apply exactly one of `type:feature`, `type:bug`, `type:chore`, `type:spike`
2. **Project assignment**: Assign to the correct project (Claudian Platform, ClinearHub, Alteri, Cognito, CCC)
3. **Duplicate check**: Search `list_issues(project, query: "<key terms>", limit: 10)` for overlapping scope
4. **Estimate**: Fibonacci (1, 2, 3, 5, 8, 13) based on complexity assessment
5. **Route decision**:
   - Needs spec enrichment → apply `spec:draft` → ChatPRD handles
   - Ready to implement → apply `auto:implement` → Codex handles
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
   - **Clear fix** (obvious stack trace, single file, reproduction steps) → apply `auto:implement` directly → Codex handles
   - **Needs investigation** → apply `type:spike` first, assign to appropriate agent or human
   - **Duplicate** → link to existing issue, cancel with note
3. **Sentry Agent enrichment:** @mention Sentry Agent on the issue for root cause analysis before routing to Codex
4. **End-to-end autonomous path:** Sentry error → Linear issue → ChatPRD enrichment (if `spec:draft`) or Codex direct (if `auto:implement`) → PR → merge → deploy. No human gate for clear 1-2pt bugs.

## Auto-Close Rationale

| Setting | Value | Why |
|---------|-------|-----|
| Auto-close parent when all children Done | **OFF** | Phase 8 ChatPRD validation must run before parent closes. `/verify` is the human gate. |
| Auto-close sub-issues when parent closes | **OFF** | Parent closure should not cascade — children may be in different states. |

## Phase 8: Business Validation Automation

After all child sub-issues of a parent spec close:

1. **Trigger:** n8n webhook bridge detects all children reach Done status
2. **Action:** Delegate parent spec issue to ChatPRD (or @mention)
3. **What ChatPRD does:**
   - Reviews completed feature against original spec
   - Verifies business intent alignment and customer outcome
   - Checks acceptance criteria coverage
   - Posts validation report as comment on parent issue
4. **Then:** Human runs `/verify` (Phase 10) to review the synthesized output

**Trigger mechanism:** Linear does not natively support "when all children Done" triggers. Triage rules fire only on Triage entry with matching label conditions. Status automations are strictly PR lifecycle (PR→In Progress, merge→Done) and cannot delegate to agents.

**Solution: n8n webhook bridge** (separate issue). n8n workflow listens for Linear webhooks on child issue status changes, checks if all siblings are Done, then delegates the parent to ChatPRD via Linear API.

**Interim:** Run `/verify` manually, which checks child status as part of its flow.

## WIP Limits

- Maximum 5 issues In Progress across all agents and humans
- If WIP limit is reached, new items stay in Todo until capacity frees up
- Agent-dispatched items (Codex, ChatPRD) count toward WIP but typically complete quickly
