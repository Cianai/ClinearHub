---
description: Pull Linear Triage inbox, categorize issues, apply labels, route
argument-hint: "[--project <name>] [--limit <N>]"
---

# Triage

Process the Linear Triage inbox. For each issue: categorize, apply labels, estimate, check for duplicates, and route to the appropriate agent or human.

## Step 1: Fetch Triage Inbox

```
list_issues(team: "Claudian", state: "Triage", limit: $1 or 10)
```

If `--project` specified, filter to that project.

Sort by: SLA breach approaching first, then Customer Requests, then creation date.

## Step 2: Process Each Issue

For each issue in the inbox, apply this checklist:

### 2a. Read Context
- Read the issue title and description
- Check for source context (Linear Asks source, Sentry stack trace, ChatPRD enrichment)
- Read recent comments (limit: 5) for additional context

### 2b. Duplicate Check
Search for existing issues covering the same scope:
```
list_issues(project: "<project>", query: "<key terms from title>", limit: 5)
```
If potential duplicate found, flag it. Propose: merge, link as related, or proceed.

### 2c. Apply Labels
Required:
- `type:*` — Exactly one: feature, bug, chore, or spike (use verb heuristic)

Optional but recommended:
- `exec:*` — Execution mode based on complexity
- `source:*` — Origin label if identifiable (cowork, voice, code-session, direct, vercel-comments)
- `app:*` — App routing label if applicable (soilworx, alteri, shared)
- `design` — Apply if the issue involves UI/UX work, new pages, visual changes, or component design. Issues with `design` label trigger a human-gated design step before `auto:implement` is applied.

### 2d. Estimate
Apply Fibonacci estimate based on complexity:
- 1-2pt: Quick, obvious fix
- 3pt: Moderate, testable scope
- 5pt: Significant, may need human input
- 8pt: Large, consider decomposing
- 13pt: Must decompose before implementation

### 2e. Route
| Condition | Action |
|-----------|--------|
| Needs spec enrichment | Apply `spec:draft` → ChatPRD enriches |
| Ready to implement (has ACs, clear scope) | Apply `auto:implement` → Codex implements |
| Needs human decision (priority, business context) | Assign to Cian, apply `ctx:human` |
| Needs investigation | Apply `type:spike`, assign appropriately |
| Is a Customer Request | Link to customer, ensure project assignment |
| Is noise / not actionable | Cancel with brief reason |

### 2f. Move Out of Triage
- **Todo**: Queued for upcoming work
- **Backlog**: Not urgent, revisit later
- **In Progress**: Starting immediately (apply `ctx:*`)

## Step 3: Report

After processing all issues, output a summary:

```
## Triage Summary

Processed: N issues
- Routed to ChatPRD (spec:draft): N
- Routed to Codex (auto:implement): N
- Assigned to human: N
- Duplicates found: N
- Canceled: N

| Issue | Type | Route | Estimate | Notes |
|-------|------|-------|----------|-------|
| CIA-XXX: Title | feature | spec:draft → ChatPRD | 3pt | — |
| CIA-YYY: Title | bug | auto:implement → Codex | 2pt | — |
```

## WIP Check

After routing, check WIP limits: maximum 5 issues In Progress across agents and humans. If at limit, warn and suggest which items to defer.

## Step 4: Branch Hygiene

Check for stale branches (automated weekly via `stale-branches.yml`, but verify during triage):

```bash
gh api repos/{owner}/{repo}/branches --paginate -q '.[].name' | grep -vE '^(main|deps-state)$'
```

For each non-protected branch:
- Has an open PR? → Leave it
- Has a closed/merged PR? → Delete the branch (should have been auto-deleted)
- Has no PR at all? → Agent left an orphan branch. Delete it and note the agent for follow-up

Report stale branches found in the triage summary.
