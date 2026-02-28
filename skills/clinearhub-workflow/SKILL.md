---
name: clinearhub-workflow
description: |
  Core ClinearHub methodology: the 6-step flow from ideation through delivery, agent pipeline, triage protocol, label system, execution modes, and duplicate detection. Use when discussing workflow, process, methodology, sprint planning context, how issues move through the pipeline, what labels to apply, how agents are dispatched, triage rules, routing decisions, estimation, scope discipline, WIP limits, or any question about how ClinearHub works end-to-end. Also triggers for questions about ChatPRD, Codex, or Copilot dispatch.
---

# ClinearHub Workflow

ClinearHub (Claude + Linear + GitHub) is a Cowork-first PM methodology. Cowork and Linear are the only human-interactive surfaces. Four autonomous agents handle the spec-to-ship loop via Linear triage rules.

## The Pipeline

```
1. Ideation (Cowork) → 2. Spec Enrichment (ChatPRD) → 3. Implementation (Codex)
→ 4. Review + Merge (GitHub) → 4.5. Reconciliation (ClinearHubBot) → 5. PM Review (Cowork)
→ 6. Customer Loop (Cowork)
```

### Step 1: Ideation (Cowork)

Human drafts the idea in Cowork. Creates a Linear issue with `spec:draft` label.

**Inputs:** Voice memos, cowork sessions, customer feedback, meeting notes (Granola), direct input.

**Outputs:** Linear issue with title (verb-first), problem statement, initial acceptance criteria, `spec:draft` label, `type:*` label, project assignment.

**Tools:** Linear (create issue), Notion (context lookup), Google Calendar (meeting prep).

### Step 2: Spec Enrichment (ChatPRD)

Linear triage rule triggers ChatPRD when `spec:draft` is applied. ChatPRD enriches the spec using its connectors (Linear, Notion, GitHub, Google Drive, Granola).

**ChatPRD enrichment:**
- Applies business strategy personas (Working Backwards, Five Whys, Pre-Mortem, Layman Clarity)
- Refines acceptance criteria
- Creates child sub-issues with `auto:implement` label
- Each sub-issue enters Linear Triage as a fresh item

**Human gate:** Review enriched spec. Approve by moving parent to `spec:ready`. Reject by returning to `spec:draft` with feedback comment.

### Step 3: Implementation (Codex)

Linear triage rule triggers Codex when `auto:implement` is applied to sub-issues. Codex reads the issue description, creates a branch, implements, and opens a PR.

**PR requirements:** Body includes `Closes CIA-XXX`. Branch follows `CIA-XXX-slug` pattern.

### Step 4: Review + Merge (GitHub)

GitHub Copilot auto-reviews via `copilot-auto-review` ruleset. CI runs. Auto-merge enabled via `gh pr merge --squash --auto --delete-branch`.

**Zero-touch loop:** Push → PR → Copilot review → CI → Auto-merge → Linear auto-close (via `Closes CIA-XXX`).

### Step 4.5: Reconciliation (ClinearHubBot)

Fully automated — no human interaction. The `post-merge-reconciliation.yml` GitHub Action fires on PR merge and runs a 3-tier cascade:

| Tier | What | When |
|------|------|------|
| **1: Issue Reconciliation** | Tick [x] ACs on issue + plan, post evidence comment with quality scoring | Always |
| **2: Parent & Project Cascade** | Check all siblings Done → post on parent (Phase 8), update milestone/initiative progress | If parent/milestone exists |
| **3: Documentation Sync** | Update GitHub README CLH section, append to release draft | If CLH markers exist |

This bridges the gap between GitHub merge and Linear issue quality. Without reconciliation, `Closes CIA-XXX` only changes status to Done — ACs remain unticked, no evidence is posted, and parent issues don't know their children are complete.

For non-PR closures (spikes, manual completions), `/plan --finalize` performs the same checks as part of its session close protocol.

### Step 5: PM Review (Cowork)

Human reviews completed work in Cowork. Checks PostHog analytics, Vercel deploy preview, Sentry error rates.

**Verification sources:** PostHog (feature adoption, errors), Vercel (deploy status, preview URL), Sentry (new errors, regressions).

### Step 6: Customer Loop (Cowork)

Communicate outcomes to customers via Linear Customer Requests, Notion CRM updates, email (Gmail).

**Tools:** Linear (close Customer Requests), Notion (update client profiles), Gmail (customer communication).

## Agent Pipeline

| Agent | Surface | Trigger | Input | Output |
|-------|---------|---------|-------|--------|
| ChatPRD | Linear | `spec:draft` label | Issue with problem statement | Enriched spec + sub-issues with `auto:implement` |
| Codex | Linear | `auto:implement` label | Sub-issue with ACs | Branch + PR with `Closes CIA-XXX` |
| Copilot | GitHub | PR opened | PR diff | Review comments, approval |
| ClinearHubBot | GitHub | PR merged | PR + Linear issue | Evidence comment, ticked ACs, project cascade |
| Sentry | Sentry | Production error | Error event | Linear issue with stack trace |

**Dispatch mechanisms:**
- **ChatPRD + Codex:** Linear triage rules (Settings > Team > Triage)
- **Copilot:** GitHub `copilot-auto-review` ruleset
- **ClinearHubBot:** `post-merge-reconciliation.yml` GitHub Action
- **Sentry:** Sentry → Linear native integration

## Triage Protocol

> See [references/triage-rules.md](references/triage-rules.md) for the full triage rule configuration.

Daily triage sweep of the Linear Triage view (`G T`). Process:

1. **SLA first** — Address issues with approaching SLA breach (`slaBreachesAt` field).
2. **Label** — Apply `type:*` (required), `spec:*`, `exec:*`, `ctx:*` as appropriate.
3. **Route** — Apply dispatch labels (`spec:draft` for ChatPRD, `auto:implement` for Codex) or assign to human.
4. **Dedup** — Check for existing issues covering the same scope before creating new ones.
5. **Estimate** — Apply Fibonacci estimate (1, 2, 3, 5, 8, 13) based on complexity.

**WIP limit:** Maximum 5 issues In Progress across all agents and humans.

## Label System

> See [references/label-taxonomy.md](references/label-taxonomy.md) for the complete label inventory with descriptions.

**Required on every issue:** Exactly one `type:*` label.

| Category | Labels | Purpose |
|----------|--------|---------|
| Type | `type:feature`, `type:bug`, `type:chore`, `type:spike` | What kind of work |
| Spec | `spec:draft` → `spec:ready` → `spec:review` → `spec:implementing` → `spec:complete` | Spec lifecycle |
| Execution | `exec:quick`, `exec:tdd`, `exec:pair`, `exec:checkpoint`, `exec:swarm` | How to implement |
| Context | `ctx:interactive`, `ctx:autonomous`, `ctx:review`, `ctx:human` | Who/where is working |
| Auto | `auto:implement` | Triggers Codex dispatch |

## Execution Modes

> See [references/execution-modes.md](references/execution-modes.md) for the full decision heuristic.

Quick reference:

| Mode | When | Estimate |
|------|------|----------|
| `exec:quick` | Small, obvious changes | 1-2pt |
| `exec:tdd` | Testable AC, moderate scope | 3pt |
| `exec:pair` | Uncertain scope, needs human | 5pt |
| `exec:checkpoint` | High-risk, multi-milestone | 8pt |
| `exec:swarm` | 5+ independent parallel tasks | 5-8pt |

**Estimate mapping:** 1-2pt = quick, 3pt = tdd, 5pt = tdd/pair, 8pt = pair/checkpoint, 13pt = checkpoint (decompose first).

## Duplicate Detection

> See [references/duplicate-detection.md](references/duplicate-detection.md) for the full detection protocol.

Before creating any issue, search Linear for existing coverage:
1. Query `list_issues(project, query: "<key terms>", limit: 10)`
2. Check title similarity and label overlap
3. If >60% AC term overlap with existing issue, flag as potential duplicate

## Scope Discipline

- **One PR per issue.** Each CIA issue gets its own branch and PR.
- **Scope creep guard.** Discovered work → new sub-issue, never added to parent.
- **Pilot before bulk.** Tasks affecting 10+ items → pilot batch of 3-5 first.
- **Verb-first naming.** `Build X`, `Implement Y`, `Fix Z`. No bracket prefixes.

## Cross-Surface References

> See [references/cross-surface-references.md](references/cross-surface-references.md) for the full convention.

Every file reference in Linear issues, comments, and session output must be a clickable hyperlink to its source. Every CIA-XXX mention must be a clickable markdown link. Language must be adapted to the target surface (GitHub = technical, Linear = process-focused, Cowork = conversational, Stakeholder = strategic). See the reference file for patterns, examples, and operational discipline rules.

## Cross-Skill References

- **spec-enrichment** — Governs Step 2 (PR/FAQ templates, ChatPRD personas, AC writing)
- **issue-lifecycle** — Governs status transitions, closure, session close protocol, issue content quality
- **plan-persistence** — Governs plan lifecycle, Step 4.5 reconciliation, agent identity, multimedia attachments
