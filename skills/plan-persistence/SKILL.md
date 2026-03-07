---
name: plan-persistence
description: |
  Plan lifecycle management using Linear Documents as the single source of truth.
  Use when discussing session plans, plan promotion to Linear, plan versioning,
  plan finalization at session end, how plans link to issues, how agents consume
  plans, checkbox-to-AC mapping, or any question about preserving context across
  Cowork and Code sessions. Also triggers for questions about session handoff,
  session context preservation, or how to resume work from a previous session's plan.
---

# Plan Persistence

Plans are the bridge between session thinking and durable project state. ClinearHub uses Linear Documents as the canonical plan store — accessible from both Cowork and Code sessions, linked to issues, and consumable by agents.

## Plan Lifecycle

```
1. Create (session) → 2. Promote (Linear Document) → 3. Iterate (update_document)
→ 4. Finalize (rename to outcome summary) → 5. Consume (agents read via list_documents)
```

### 1. Create

Plans originate in sessions:
- **Cowork**: Compose from conversation context (no filesystem)
- **Code**: Read from `~/.claude/plans/` or compose inline

### 2. Promote

Push the plan to a Linear Document attached to the issue:

```
create_document(
  title: "Plan: <ISSUE-ID> — <summary>",
  content: <plan markdown>,
  issue: "<issue_id>"
)
```

`<ISSUE-ID>` uses the issue's team prefix: `CIA-XXX`, `ALT-XXX`, or `SWX-XXX`.

The plan appears in the issue's Resources section in Linear UI. Then backlink via comment:

```
create_comment(
  issueId: "<issue_id>",
  body: "Plan promoted: [Plan: <ISSUE-ID> — <summary>](<document_url>)\nReview & annotate: https://plan-review-cianai.vercel.app/plan/<doc-id>"
)
```

> Plans attach to **issues** (not projects). For reference documents (architecture, pipeline docs), use `create_document(project: "...")` instead.

After `create_document`, **always validate** the attachment:
```
get_issue(issueId, includeRelations: true)
→ Verify issue.documents contains the new document ID
```
If NOT found → see "Attachment Immutability Protocol" below.

### 3. Iterate

Update the document as the plan evolves:

```
update_document(id: "<document_id>", content: <updated plan markdown>)
```

Append to the `## History & References` section with each update:

```markdown
* **v2 (2026-03-04)**: Phase 1 complete, updated tasks, added findings
```

### 4. Finalize

At session end, rename the document to reflect outcomes:

```
update_document(id: "<document_id>", title: "Plan: <ISSUE-ID> — <outcome summary>")
```

### 5. Consume

Other sessions and agents find plans via:

```
list_documents(query: "Plan: <ISSUE-ID>", limit: 10)
```

## Plan vs. Comment Threshold

Not every session needs a full plan document. Use this decision rule:

| Condition | Artifact |
|-----------|----------|
| 5+ tasks OR multi-session OR decomposition into sub-issues | **Linear Document** (full plan format) |
| < 5 tasks, single session, no decomposition | **Closing comment** (wrap-up Phase 2b format) |
| Trivial fix (< 3 tasks, obvious scope) | **No plan artifact** — commit message suffices |

When in doubt, promote to a Document. It's never wrong to have more context.

## Plan Format

> See [references/plan-format.md](references/plan-format.md) for the full template.

Every promoted plan includes:

| Section | Purpose |
|---------|---------|
| **Summary** | 2-3 sentence plain-language overview |
| **Header** | Issue link, surface, author, status |
| **Decisions** | Key choices made (for future reference) |
| **Scope & Non-Goals** | What's included and explicitly excluded |
| **Tasks** | `[ ]` checkbox items — map to issue ACs |
| **Verification** | How to confirm the plan succeeded |
| **History & References** | Revision log + hyperlinked sources |

## Dual-Layer Plans

Plans serve two audiences:
1. **Humans** — read the Summary section (plain language)
2. **Agents** — consume Tasks, Scope, and Verification (full technical detail)

NEVER simplify technical sections for human readability — agents need precise instructions.

Dependencies in References MUST also be set as Linear relations via `save_issue(id, blockedBy: ["<ISSUE-ID>"])`.

## Inline Documentation

Each plan step's done = action + documentation. Never defer docs to a separate step.

> File references follow the [Cross-Surface Reference Discipline](../clinearhub-workflow/references/cross-surface-references.md).

## Checkbox Discipline

Plan `[ ]` / `[x]` checkboxes map bidirectionally with issue ACs:

1. **Plan → Issue**: Each `[ ]` task becomes an AC on the issue description
2. **Agent completion**: Tick `[x]` on both the plan document and issue ACs
3. **Verification**: `/verify` checks plan checkboxes and issue ACs are in sync

## Platform Behavior

| Platform | Plan Source | Promotion | Visual Review |
|----------|------------|-----------|---------------|
| **Cowork** | Conversation context | `create_document` via Linear MCP | Plan Review App URL |
| **Code** | `~/.claude/plans/<name>.md` (plan mode) or inline | Read file → `create_document` | Plan Review App URL |
| **Code + Plannotator** | Plannotator annotation UI | Phase 1.5 reads annotated plan → `create_document` | Plannotator local UI |
| **Stakeholders** | N/A (consumers only) | N/A | Plan Review App or Plannotator share URL |

Both Cowork and Code use the same Linear MCP tools. Tool names have different prefixes per surface but identical functionality.

## Plan Review App

The hosted plan annotation UI at `apps/plan-review/` provides visual plan review from any browser:

- **URL**: `https://plan-review-cianai.vercel.app/plan/<document-id>`
- **Read**: Renders Linear Document markdown with section headings
- **Annotate**: Per-section comments written back as Linear comments
- **Access**: No auth required (document IDs are UUIDs)

Include the review URL in backlink comments when promoting plans. This enables Cowork users (no filesystem) to review and annotate plans visually.

## Plannotator Integration (Code Only)

[Plannotator](https://github.com/backnotprop/plannotator) provides visual plan annotation in Code sessions via hooks + local Bun server:

- **Install**: `/plugin marketplace add backnotprop/plannotator`
- **Usage**: Intercepts `ExitPlanMode` → opens browser annotation UI
- **Share URLs**: Generate E2E encrypted links for one-way stakeholder review
- **Complementary**: Plannotator handles visual review UX; ClinearHub handles Linear persistence

Plannotator cannot work in Cowork (requires filesystem + hooks). The Plan Review App fills this gap.

## Agent Consumption

Commands that check for plan documents before starting:

| Command | How It Uses Plans |
|---------|-------------------|
| `/decompose` | Reads plan tasks to inform sub-issue creation |
| `/critique` | Checks plan exists and tasks align with issue ACs |
| `/verify` | Validates plan checkboxes match issue AC completion |

## Issue Context Discovery

Before starting work on any issue, agents MUST check for attached context:

1. **Attachments**: `get_attachment(issueId)` — URLs, PDFs, screenshots
2. **Plan documents**: `list_documents(query: "Plan: <ISSUE-ID>")` — promoted session plans
3. **Comments**: `list_comments(issueId, limit: 20)` — session summaries, review feedback

Humans add context via Linear UI (drag-drop attachments, + Resources). Agents discover it automatically.

## Session Start Protocol

Before starting work, auto-recover full context from Linear.

### Per-Issue Context Recovery

For each issue in scope:

1. `get_issue(issueId, includeRelations: true)` — status, ACs, labels, relations
2. `list_comments(issueId, limit: 10)` — session summaries, evidence
3. `list_documents(query: "Plan: <ISSUE-ID>", limit: 5)` — plans (read the most recent)
4. `get_attachment(issueId)` — human-added resources
5. `get_issue(parentId, includeRelations: true)` — parent + sibling status (if child issue)
6. Read `carry-forward.md` from the project's auto-memory directory — include Active items in Known State

### Output: Known State

```markdown
## Known State

### Issues
| Issue | Status | Labels | Assignee | Milestone | Priority | Blocking | Blocked By |
|-------|--------|--------|----------|-----------|----------|----------|------------|

### Last Session Summary
<From most recent closing comment>

### Active Plan
<Title + task completion summary from most recent plan document>

### Attached Resources
<Attachments, linked docs, external links>
```

## Session Model: Closed-Loop Cowork

1. **Start**: Identify or create the parent issue
2. **Plan**: Compose and promote via Phase 1.5 or `/plan --promote`
3. **Work**: Create sub-issues as needed (children of parent)
4. **Track**: Update parent description with sub-issue status
5. **Finalize**: Run wrap-up Phase 1.5 to finalize the plan document
6. **Close**: All artifacts attached to the parent issue

### Sub-Issue Pattern
- **Parent** = spec/plan (immutable after creation)
- **Children** = work units (one PR each, `auto:implement` label)

## Agent Identity

| Surface | Attribution |
|---------|------------|
| **Linear comments** | `createAsUser: "ClinearHubBot"` |
| **Linear documents** | Author field in plan header (API limitation) |
| **GitHub** | ClinearHubBot App identity |

## Attachment Immutability Protocol

`update_document` cannot change attachment. Recovery:

1. `get_document(id)` → read content
2. `create_document(issue: "<correct_id>")` → recreate at issue level
3. Post comment explaining the move
4. Delete incorrectly-attached document

## Post-Merge Reconciliation

`post-merge-reconciliation.yml` auto-ticks plan checkboxes when PRs merge with `Closes <ISSUE-ID>`.

## Cross-Skill References

- **clinearhub-workflow** — 6-step pipeline, where plan persistence fits
- **issue-lifecycle** — Status transitions, closure protocol
- **wrap-up** — Phase 1.5 (Plan Promotion) auto-promotes at session end
- **notion-hub** — Phase 1.5d: Notion mirror of promoted plans to Specs & Plans DB
