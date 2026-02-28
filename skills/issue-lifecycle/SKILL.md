---
name: issue-lifecycle
description: |
  Issue and project lifecycle management for Linear. Use when asking about status transitions, who can change what on issues, closure rules, evidence requirements for closing, ownership boundaries between agents and humans, quality scoring, label management, carry-forward protocol, sub-issue creation, dependency wiring, bulk operations, stale issue detection, or any question about how issues move through their lifecycle from creation to Done.
---

# Issue Lifecycle

Defines clear ownership boundaries between AI agents and humans, status transition rules, closure protocol with evidence requirements, and operational patterns for Linear issue management.

## Ownership Model

The agent owns **process and implementation artifacts** (status, labels, specs, estimates). The human owns **business judgement** (priority, deadlines, capacity). Either can create and assign work.

| Field | Owner | Agent Can | Human Must |
|-------|-------|-----------|-----------|
| Status | Agent | Move through workflow states | Override if agent moves incorrectly |
| Labels | Agent | Apply type, spec, exec, ctx labels | Set priority, approve urgent |
| Estimates | Agent | Propose Fibonacci estimates | Override if estimate seems wrong |
| Priority | Human | Suggest based on SLA/data | Set final priority |
| Assignee | Either | Self-assign, delegate to agents | Assign when blocked on human |
| Deadline | Human | Flag approaching deadlines | Set deadlines |
| Description | Agent | Enrich, never round-trip | Approve spec changes |

**Critical rule:** Never round-trip descriptions through `get_issue` then `update_issue` — this causes double-escaping. Always compose fresh markdown when updating descriptions.

## Status Transitions

| From | To | Who | Condition |
|------|-----|-----|----------|
| Triage | Todo | Agent/Human | Labels applied, estimate set |
| Triage | Backlog | Agent/Human | Not urgent, needs future planning |
| Todo | In Progress | Agent/Human | Work begins (apply `ctx:*` immediately) |
| In Progress | In Review | Agent | PR opened, awaiting review |
| In Review | In Progress | Agent/Human | Review requested changes |
| In Review | Done | Agent | PR merged AND deploy verified |
| Any | Canceled | Human | Issue no longer needed |

**Key rules:**
- Mark In Progress AND apply `ctx:*` as soon as work starts. Don't batch.
- Done requires evidence: PR merged is minimum. Spike Done requires findings visible in description or linked document.
- Never auto-close issues assigned to Cian.
- `Canceled` uses American English (single L). "Cancelled" fails silently in the Linear API.

## Context Labels on Transition

When an issue moves between execution contexts:
1. Remove the old `ctx:*` label
2. Apply the new `ctx:*` label
3. Post a comment documenting the transition

Example: Factory fails on an issue → Claude Code picks up → remove `ctx:autonomous`, apply `ctx:interactive`, comment "Transitioned from Factory to interactive session."

## Spec Label Lifecycle

| Transition | Trigger | Gate? |
|-----------|---------|-------|
| `spec:draft` → `spec:ready` | Human approves enriched spec | Yes — Gate 1 |
| `spec:ready` → `spec:review` | Reviewer begins adversarial review | No |
| `spec:review` → `spec:implementing` | Review passes | Yes — Gate 2 |
| `spec:implementing` → `spec:complete` | All ACs verified, PR merged | Yes — Gate 3 |
| `spec:review` → `spec:draft` | Fundamental gaps found in review | Rejection |

## Closure Protocol

> See [references/closure-protocol.md](references/closure-protocol.md) for the full closure rules and quality scoring.

Every Done transition requires a closing comment with evidence. The minimum evidence varies by issue type:

| Type | Minimum Evidence |
|------|-----------------|
| `type:feature` | PR merged link, deploy URL or verification, AC checklist |
| `type:bug` | PR merged link, confirmation bug no longer reproduces |
| `type:chore` | What was done, verification it worked |
| `type:spike` | Findings in description or linked document, recommendation |

**Quality scoring** uses three dimensions: Test (40%), Coverage (30%), Review (30%). Score determines closure action:
- 80-100: Auto-close eligible (still check ownership rules)
- 60-79: Propose closure to human with gap list
- 0-59: Block closure, list specific deficiencies

## Issue Naming

Titles start with an action verb, lowercase after first word. No bracket prefixes.

Common starters: Build, Implement, Fix, Add, Create, Evaluate, Survey, Design, Migrate, Configure, Audit, Ship, Set up, Wire up

Non-actionable content (research notes, decisions, session learnings) should be Linear Documents, not issues. Test: "Can someone mark this Done?" If no, it's a document.

## Carry-Forward Protocol

When work cannot be completed in the current issue's scope:
1. Create a new issue for each carry-forward item
2. Link as "related to" the source issue
3. Reference the source in the new issue's description
4. Add to the fix-forward summary in the source issue's closing comment
5. Apply appropriate labels

Never leave findings untracked or add carry-forward items to the source issue's scope.

## Dependency Management

Linear's `update_issue` with `blocks`/`blockedBy`/`relatedTo` **replaces** the entire existing array — it does not append. This is the most dangerous operation.

**Safe protocol:** READ existing relations → MERGE (add/remove) → WRITE the full merged array. Never write relation parameters without reading first.

## Bulk Operations

- Process in batches of 10-15 (context protection)
- Always read before write (labels and relations REPLACE, not append)
- Log every modification
- Pause between batches for rate limiting

## Session Close Protocol

Every session modifying Linear issues MUST run `/plan --finalize` before ending. The session close protocol ensures no work is lost and all artifacts are properly linked.

See the `/plan --finalize` command for the full 8-step checklist. Key requirements:
- Plan document exists on the issue
- Completed tasks ticked `[x]` in both plan document and issue ACs
- Evidence comment posted
- Context labels updated
- Sibling status checked (for non-PR closures)

For PR-based closures, the `post-merge-reconciliation.yml` GitHub Action handles this automatically. The session close protocol covers non-PR closures (spikes, manual completions, Cowork sessions).

## Post-Merge Reconciliation

When a PR merges with "Closes CIA-XXX", the GitHub Action automatically:
1. **Tier 1**: Ticks ACs, posts evidence comment, updates plan document
2. **Tier 2**: Checks parent (all siblings Done → Phase 8), updates milestone/initiative
3. **Tier 3**: Syncs GitHub README and release drafts

This bridges the gap between GitHub merge and Linear issue quality. See `.github/workflows/post-merge-reconciliation.yml`.

## Cross-Skill References

- **clinearhub-workflow** — Overall flow, where lifecycle fits (including Step 4.5 reconciliation)
- **spec-enrichment** — How specs enter the lifecycle
- **plan-persistence** — Plan lifecycle and session close protocol details
