---
description: Break a spec into sub-issues with auto:implement label for Codex dispatch
argument-hint: "<CIA-XXX issue ID>"
---

# Decompose

Break an approved spec into atomic, implementable sub-issues. Each sub-issue gets an execution mode, estimate, acceptance criteria, and the `auto:implement` label for Codex dispatch.

## Step 1: Read the Spec

Fetch the issue from Linear:
```
get_issue(id: "$1", includeRelations: true)
list_comments(issueId: "$1", limit: 10)
```

Extract:
- All acceptance criteria (from description)
- Scope boundaries (non-goals)
- Dependencies on external systems
- Any existing sub-issues already created
- ChatPRD enrichment (from comments, if `spec:draft` was processed)

If the spec has no acceptance criteria, warn and suggest running `/write-spec` first.

## Step 2: Identify Atomic Tasks

Break the spec into tasks where each satisfies ALL criteria:
1. **Well-scoped** — Modifies a predictable set of files
2. **Clear AC** — At least one testable criterion from the parent spec
3. **Independent or explicitly dependent** — Can be done alone, or has explicit dependency
4. **Right-sized** — No more than ~4 hours of focused work
5. **Single concern** — One logical concern per task

Common patterns: schema changes, API endpoints, UI components, business logic, test suites, config/setup, migrations.

## Step 3: Assign Execution Modes

For each task, apply the decision heuristic:

| Condition | Mode | Estimate |
|-----------|------|----------|
| Well-defined, clear requirements | `exec:quick` | 1-2pt |
| Testable ACs, moderate scope | `exec:tdd` | 3pt |
| Uncertain scope, needs human input | `exec:pair` | 5pt |
| High-risk, needs approval at milestones | `exec:checkpoint` | 8pt |

## Step 4: Analyze Dependencies

Build a dependency graph:
1. Which tasks block others?
2. Which are independent (can run in parallel)?
3. Any shared prerequisites?
4. Flag circular dependencies as errors needing clarification.

Group into implementation phases:
- Phase 1: No dependencies (start immediately)
- Phase 2: Depends on Phase 1
- Phase N: Depends on Phase N-1

## Step 5: Create Sub-Issues in Linear

For each sub-issue:
1. **Title**: Verb-first, specific (e.g., "Add user preference schema migration")
2. **Description**: What, why, connection to parent spec, specific ACs for this task
3. **Labels**: `type:*`, `exec:*`, `auto:implement`
4. **Estimate**: Based on execution mode
5. **Parent link**: Connected to the parent issue
6. **Dependencies**: `blocks`/`blockedBy` relations (use safe read-merge-write protocol)

After creation, update parent issue:
- Apply `spec:implementing` label
- Post comment linking to all sub-issues

The `auto:implement` label on each sub-issue triggers Codex dispatch via Linear triage rules.

## Step 6: Report

```markdown
## Decomposition Summary

**Parent:** CIA-XXX — [Title]
**Total tasks:** N
**Critical path:** N tasks
**Parallel opportunities:** N tasks can run simultaneously

| # | Task | Mode | Phase | Blocked By | Est. |
|---|------|------|-------|------------|------|
| 1 | CIA-YYY: [Title] | quick | 1 | — | 1pt |
| 2 | CIA-ZZZ: [Title] | tdd | 1 | — | 3pt |
| 3 | CIA-AAA: [Title] | tdd | 2 | #1 | 3pt |

Codex will pick up Phase 1 tasks automatically via auto:implement.
```
