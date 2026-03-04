---
name: clinearhub-workflow
description: |
  Core ClinearHub methodology: the 6-phase pipeline from spec creation through business review, agent pipeline, triage protocol, label system, execution modes, and duplicate detection. Use when discussing workflow, process, methodology, sprint planning context, how issues move through the pipeline, what labels to apply, how agents are dispatched, triage rules, routing decisions, estimation, scope discipline, WIP limits, or any question about how ClinearHub works end-to-end. Also triggers for questions about ChatPRD, gh-aw, Copilot, or agent dispatch.
---

# ClinearHub Workflow (v2.0)

ClinearHub (Claude + Linear + GitHub) is a Cowork-first PM methodology. Spec creation happens upstream in ChatPRD. Autonomous implementation happens via GitHub Agentic Workflows (gh-aw) and Copilot Coding Agent. ClinearHub handles the interactive business layer: triage, roadmap, incidents, analytics, and review.

## The Pipeline

```
Human ──────────────────────────────────────── Human
  │                                               ▲
  ▼                                               │
Phase 1: SPEC (ChatPRD)               Phase 6: REVIEW (Cowork)
  │                                               ▲
  ▼                                               │
Phase 2: TRIAGE (Cowork)              Phase 5: RECONCILE (GitHub Actions)
  │                                               ▲
  ▼                                               │
Phase 3: IMPLEMENT (GitHub Agents) ──► Phase 4: MERGE (GitHub CI)
```

**Human touches Phase 1 (write spec) and Phase 6 (review outcomes). Everything else is autonomous.**

### Phase 1: Spec Creation (ChatPRD)

**Actor:** Human + ChatPRD AI
**Surface:** ChatPRD (web app)

ChatPRD pulls context from all sources via MCP connectors:
- **Linear** (MCP): existing issues, sprint context, project state
- **GitHub** (MCP): repo structure, open PRs, code patterns
- **Granola** (MCP): meeting notes, decisions, action items
- **Google Drive** (OAuth): existing docs, research, customer data

ChatPRD creates an enriched spec with acceptance criteria, user stories, and technical context.

**Output destinations:**
1. **Linear issue** — via "Open in → Linear Issue" or @chatprd agent enriches directly
2. **Google Drive** — export as Google Doc for shareable reference
3. **ChatPRD itself** — queryable via ChatPRD MCP server

### Phase 2: Triage & Planning (Cowork)

**Actor:** Human + ClinearHub plugin + Triage Intelligence
**Surface:** Claude Desktop → Cowork tab

**Triage Intelligence (TI)** auto-processes new issues within 1-4 minutes:
- **Auto-applies:** team (CIA/ALT/SWX), project, labels (Type, Exec, Spec, Context)
- **Shows suggestions:** assignee, duplicates, related issues
- **Triage rules** fire after TI: urgent bugs auto-dispatch to Copilot

Human reviews TI results in Cowork, then confirms or corrects using **triage templates**:

**Triage templates** (apply via Template dropdown — preserves ChatPRD description, sets metadata only):

| Template | Labels | Status | Priority | Est | Delegate |
|----------|--------|--------|----------|-----|----------|
| Auto: Quick | `type:chore`, `exec:quick`, `auto:implement`, `ctx:autonomous`, `spec:ready` | Todo | Medium | 1 | Copilot |
| Auto: Feature | `type:feature`, `exec:quick`, `auto:implement`, `ctx:autonomous`, `spec:ready` | Todo | Medium | 2 | Copilot |
| Auto: TDD | `type:feature`, `exec:tdd`, `auto:implement`, `ctx:autonomous`, `spec:ready` | Todo | Medium | 3 | Claude |
| Auto: Bug | `type:bug`, `exec:quick`, `auto:implement`, `ctx:autonomous`, `spec:ready` | Todo | High | 1 | Copilot |
| Pair Session | `type:feature`, `exec:pair`, `ctx:interactive`, `spec:ready` | Todo | Medium | 5 | — |

**Additional manual steps** (if needed):
- Correct TI team/project/label suggestions if wrong
- Decompose into sub-issues
- Adjust priority, estimate, or assignee from template defaults
- Apply `Dispatch/auto:implement` label to trigger Phase 3 (already set by Auto: templates)

**Quick Capture** template: for rapid issue creation from Linear iOS app (typing/voice dictation). Sets `spec:draft` + `source:direct`, Status: Triage. Intended for later enrichment by @chatprd agent or Cowork triage.

**Context sources:**
- From project (via "Create task with context"): project instructions + static reference docs
- From MCP connectors (live data): Linear, GitHub, Sentry, PostHog
- Enriched specs live in Linear issues (from ChatPRD in Phase 1)

### Phase 3: Implementation (GitHub Agents)

**Actor:** Autonomous coding agents
**Surface:** GitHub (via Linear ↔ GitHub two-way sync)

Linear two-way sync makes issues with `auto:implement` appear as GitHub issues. Agents pick them up based on exec mode:

| Exec Mode | Agent | Mechanism |
|-----------|-------|-----------|
| `exec:quick` | Copilot Coding Agent | Assign to `@github` → WIP PR |
| `exec:tdd` | gh-aw + Claude engine | `.github/workflows/implement-issue.md` |
| `exec:pair` | Claude Code Desktop | Human uses preview + review |
| `exec:checkpoint` | gh-aw + Copilot | Workflow with approval gates |
| `exec:swarm` | Multiple gh-aw workflows | Parallel dispatch across sub-issues |

**PR requirements:** Body includes `Closes CIA-XXX` (or `ALT-XXX`/`SWX-XXX`).

### Phase 4: Review + Merge (GitHub)

**Actor:** Copilot (auto-review) + CI + optionally human
**Surface:** GitHub + Claude Code Desktop (for complex PRs)

- `copilot-auto-review` ruleset: auto-requests review on push
- `ci.yml`: lint + typecheck + build
- `auto-merge-bots.yml`: bot PR → auto-merge when CI green
- Claude Code Desktop: code review feature + CI auto-fix for complex PRs

**Zero-touch loop:** Agent PR → Copilot review → CI → Auto-merge → Linear auto-close.

### Phase 5: Post-Merge Reconciliation (GitHub Actions)

**Actor:** ClinearHubBot (GitHub App)
**Surface:** GitHub Actions → Linear API

`post-merge-reconciliation.yml` fires on PR merge, runs 3-tier cascade:

| Tier | What | When |
|------|------|------|
| **1: Issue Reconciliation** | Tick [x] ACs, post evidence comment with quality scoring | Always |
| **2: Parent & Project Cascade** | Check all siblings Done → post on parent, update milestone progress | If parent/milestone exists |
| **3: Documentation Sync** | Update GitHub README CLH section | If CLH markers exist |

### Phase 6: Business Review (Cowork)

**Actor:** Human
**Surface:** Claude Desktop → Cowork tab

Human returns when notified (Phase 8 comment = "all sub-issues complete"):
- Review outcomes, verify business acceptance criteria
- `/stakeholder-update` for status communication
- `/analyze` for PostHog data on feature adoption
- Plan next cycle

## Agent Pipeline

| Agent | Surface | Trigger | Input | Output |
|-------|---------|---------|-------|--------|
| ChatPRD | ChatPRD / Linear | Human / `spec:draft` label | Problem statement + context | Enriched spec + sub-issues |
| gh-aw / Copilot Agent | GitHub | `auto:implement` label (via two-way sync) | GitHub issue with ACs | Branch + PR with `Closes CIA-XXX` |
| Copilot Review | GitHub | PR opened | PR diff | Review comments, approval |
| ClinearHubBot | GitHub | PR merged | PR + Linear issue | Evidence comment, ticked ACs, cascade |
| Sentry | Sentry | Production error | Error event | Linear issue with stack trace |

**Dispatch mechanisms:**
- **ChatPRD:** ChatPRD MCP connectors + Linear @chatprd agent + `spec:draft` triage rule
- **gh-aw:** `.github/workflows/implement-issue.md` triggered by `auto:implement` label on GitHub issues
- **Copilot Coding Agent:** Assign GitHub issue to `@github` (for `exec:quick`)
- **Copilot Review:** GitHub `copilot-auto-review` ruleset
- **ClinearHubBot:** `post-merge-reconciliation.yml` GitHub Action
- **Sentry:** Sentry → Linear native integration

## Triage Protocol

> See [references/triage-rules.md](references/triage-rules.md) for the full triage rule configuration.

Daily triage sweep of the Linear Triage view (`G T`). Triage Intelligence auto-applies team, project, and labels within 1-4 minutes of issue creation. Human process:

1. **SLA first** — Address issues with approaching SLA breach (`slaBreachesAt` field).
2. **Review TI** — Check auto-applied team, project, and labels. Correct if wrong.
3. **Label** — Confirm or adjust labels via label groups (single-select enforcement): `Type/*` (required), `Spec/*`, `Exec/*`, `Context/*`.
4. **Route** — Apply dispatch labels (`spec:draft` for ChatPRD, `auto:implement` for GitHub agents) or assign to human.
5. **Dedup** — TI flags potential duplicates. Verify before creating new issues.
6. **Estimate** — Apply Fibonacci estimate (1, 2, 3, 5, 8, 13) based on complexity.

**Triage rules** (fire after TI, before human review):
- `type:bug` + Urgent → auto-dispatch to Copilot (status: Todo, label: `exec:quick`)
- `type:bug` + High → set status: Todo, label: `exec:quick`

**WIP limit:** Maximum 5 issues In Progress across all agents and humans.

## Label System

> See [references/label-taxonomy.md](references/label-taxonomy.md) for the complete label inventory with descriptions.

**Required on every issue:** Exactly one `Type/*` label. Labels use Linear label groups (single-select per group).

| Group | Labels | Purpose |
|-------|--------|---------|
| Type | `type:feature`, `type:bug`, `type:chore`, `type:spike` | What kind of work |
| Spec | `spec:draft` → `spec:ready` → `spec:review` → `spec:implementing` → `spec:complete` | Spec lifecycle |
| Exec | `exec:quick`, `exec:tdd`, `exec:pair`, `exec:checkpoint`, `exec:swarm` | How to implement (routes to agent) |
| Context | `ctx:interactive`, `ctx:autonomous`, `ctx:review`, `ctx:human` | Who/where is working |
| Dispatch | `auto:implement` | Triggers gh-aw / Copilot Coding Agent |

## Execution Modes

> See [references/execution-modes.md](references/execution-modes.md) for the full decision heuristic.

Quick reference:

| Mode | When | Agent | Estimate |
|------|------|-------|----------|
| `exec:quick` | Small, obvious changes | Copilot Coding Agent | 1-2pt |
| `exec:tdd` | Testable AC, moderate scope | gh-aw + Claude | 3pt |
| `exec:pair` | Uncertain scope, needs human | Claude Code Desktop | 5pt |
| `exec:checkpoint` | High-risk, multi-milestone | gh-aw + approval gates | 8pt |
| `exec:swarm` | 5+ independent parallel tasks | Multiple gh-aw workflows | 5-8pt |

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

Every file reference in Linear issues, comments, and session output must be a clickable hyperlink to its source. Every CIA-XXX mention must be a clickable markdown link. Language must be adapted to the target surface (GitHub = technical, Linear = process-focused, Cowork = conversational, Stakeholder = strategic).

## Cross-Skill References

- **issue-lifecycle** — Governs status transitions, closure, session close protocol, issue content quality
- **incident-response** — Governs Sentry→Linear error pipeline, RCA protocol
- **data-analytics** — Governs PostHog queries, monitoring alerts
- **deployment-verification** — Governs deploy checks, zero-touch CI loop
- **roadmap-management** — Governs initiative/milestone tracking
- **task-management** — Governs standups, daily workflow
- **_archived/spec-enrichment** — Historical: PR/FAQ templates, ChatPRD personas (now handled by ChatPRD directly)
- **plan-persistence** — Plan lifecycle management, Linear Document promotion, session start context recovery
