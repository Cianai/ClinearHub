---
name: plan-persistence
description: |
  Plan lifecycle management using Linear Documents as the single source of truth. Use when discussing session plans, plan promotion to Linear, plan versioning, plan finalization at session end, how plans link to issues, how agents consume plans, checkbox-to-AC mapping, or any question about preserving context across Cowork and Code sessions. Also triggers for questions about session handoff, session context preservation, or how to resume work from a previous session's plan.
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
  title: "Plan: CIA-XXX — <summary>",
  content: <plan markdown>,
  issue: "<issue_id>"
)
```

The plan appears in the issue's Resources section in Linear UI, alongside PR links and attachments.

Then backlink via comment:
```
create_comment(
  issueId: "<issue_id>",
  body: "Plan promoted to Linear Document: [Plan: CIA-XXX — <summary>](<document_url>)"
)
```

> Plans attach to **issues** (not projects). For reference documents (architecture, pipeline docs), use `create_document(project: "...")` instead.

### 3. Iterate

Update the document as the plan evolves during the session:

```
update_document(
  id: "<document_id>",
  content: <updated plan markdown>
)
```

Linear Documents have built-in revision history visible in the document UI. Additionally, append to the `## Revision History` section with each update:

```markdown
## Revision History

* **v1 (2026-02-28)**: Initial plan — scope and tasks
* **v2 (2026-02-28)**: Phase 1 complete, updated tasks, added findings
```

### 4. Finalize

At session end, rename the document to reflect what was accomplished:

```
update_document(
  id: "<document_id>",
  title: "Plan: CIA-XXX — <session outcome summary>"
)
```

The title changes from a generic working title to a concrete outcome description. This makes plans searchable and meaningful in the document list.

### 5. Consume

Other sessions and agents find plans via:

```
# Find plans for a specific issue
list_documents(query: "Plan: CIA-XXX", limit: 10)
```

Or browse all plans for a project:

```
list_documents(projectId: "<project_id>", query: "Plan:", limit: 50)
```

Agents MUST also check for human-added context before starting work — see "Issue Context Discovery" below.

## Plan Format

> See [references/plan-format.md](references/plan-format.md) for the required section template.

Every promoted plan includes:

| Section | Required | Purpose |
|---------|----------|---------|
| **Summary** | Yes | 2-3 sentence plain-language overview for non-technical reviewers |
| **Header** | Yes | Issue link, session surface, status |
| **Decisions** | Yes | Key choices made (for future reference) |
| **Scope** | Yes | What this plan covers |
| **Non-Goals** | Yes | What's explicitly excluded |
| **Tasks** | Yes | `[ ]` checkbox items — map to issue ACs |
| **Verification** | Yes | How to confirm the plan succeeded |
| **Revision History** | Yes | Dated entries tracking plan evolution |
| **References** | Yes | Hyperlinked Linear items, web sources, documents cited |

## Dual-Layer Plans

Plans serve two audiences:
1. **Humans** (non-technical PMs, stakeholders) — read the Summary section
2. **Agents** (Codex, Copilot, ChatPRD) — consume Tasks, Scope, and Verification sections

The Summary section uses plain language. The rest of the plan maintains full technical detail. NEVER simplify the technical sections to match the Summary — agents need precise, unambiguous instructions.

Dependencies documented in the References section MUST also be set as actual Linear relations on the issue via `save_issue(id, blockedBy: ["CIA-YYY"])`. This ensures they appear in both the plan AND the Linear sidebar.

## Checkbox Discipline

Plan tasks use `[ ]` / `[x]` checkboxes. These map bidirectionally with issue acceptance criteria:

1. **Plan → Issue**: When promoting a plan, each `[ ]` task becomes an AC on the issue description
2. **Agent completion**: Agents tick `[x]` on both the plan document and issue ACs when completing work
3. **Verification**: `/verify` checks that plan checkboxes and issue ACs are in sync

## Platform Behavior

| Platform | Plan Source | Promotion Mechanism |
|----------|------------|---------------------|
| **Cowork** (primary) | Conversation context | Compose summary → `create_document` |
| **Code** (secondary) | `~/.claude/plans/` file | Read file → `create_document` |

Both platforms use the same Linear MCP tools (41 tools via `mcp.linear.app/mcp`). Tool names have different UUID prefixes per surface but identical functionality.

## Agent Consumption

Commands that check for plan documents before starting:

| Command | How It Uses Plans |
|---------|-------------------|
| `/decompose` | Reads plan tasks to inform sub-issue creation |
| `/critique` | Checks plan exists and tasks align with issue ACs |
| `/verify` | Validates plan checkboxes match issue AC completion |

## Issue Context Discovery

Before starting work on any issue, agents MUST check for attached context:

1. **Attachments**: `get_attachment(issueId)` — returns URLs, PDFs, screenshots, documents the human added
2. **Plan documents**: `list_documents(query: "Plan: CIA-XXX")` — promoted session plans
3. **Comments**: `list_comments(issueId, limit: 20)` — session summaries, review feedback, clarifications

Humans can add context at any time via:

| Method | What | How |
|--------|------|-----|
| Linear UI (📎) | Local files — PDFs, screenshots, images, spreadsheets, any file type Linear accepts | Drag-and-drop or click attachment icon on issue |
| Linear UI (+ Resources) | Links, documents, PRs | Click "+" in Resources section |
| ClinearHub plugin | URL-based attachments | `create_attachment(issueId, url, title)` via MCP |

**No prompting needed.** The human adds context; agents discover it automatically. The attachment check is part of every command that reads issue state (`/decompose`, `/critique`, `/verify`, `/plan --promote`).

## Accessibility for Non-Technical Users

### In Cowork (primary surface)
Cowork does not support output styles. ClinearHub addresses non-technical users through:
1. **Summary section** — plain-language overview at top of every plan
2. **Inline jargon definitions** — when technical terms are unavoidable, define them parenthetically
3. **Skill prompt engineering** — plan-persistence skill instructs Claude to explain context when composing plans

### In Claude Code (secondary surface)
Custom output styles can be created at `.claude/output-styles/`. ClinearHub ships a "PM Review" style for non-technical plan review. Users switch to it via `/output-style pm-review`. The recommended default for PM users is the built-in "Explanatory" style.

**Critical**: Output styles affect presentation, NOT technical content. The PM Review style adds explanatory context AROUND the same decisions. Agents always consume the canonical plan document (full technical detail in Linear), regardless of which style a human used to review it.

## Session Model: Closed-Loop Cowork

Each Cowork session should be self-contained:

1. **Start**: Identify or create the parent issue for the session's work
2. **Plan**: Compose a plan and promote it to the parent issue via `/plan --promote`
3. **Work**: Create sub-issues as needed — each sub-issue is a child of the parent
4. **Track**: Update parent description with sub-issue status as work progresses
5. **Finalize**: Run `/plan --finalize` to summarize outcomes and update the plan document
6. **Close**: All artifacts (plan, sub-issues, comments) are attached to the parent issue

### Sub-Issue Pattern
- **Parent issue** = the spec/plan (never modified by agents after creation)
- **Child issues** = implementation work units (one PR each, `auto:implement` label)
- When creating sub-issues mid-session, update the parent's description to reference them
- Use `create_attachment` to link relevant external resources to issues as needed

## Cross-Skill References

- **clinearhub-workflow** — Overall 6-step flow, where plan persistence fits (Step 1 and 5)
- **issue-lifecycle** — How plan-linked issues transition through statuses
- **spec-enrichment** — Plans may reference or extend PR/FAQ specs
