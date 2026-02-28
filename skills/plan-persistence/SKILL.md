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

Push the plan to a Linear Document linked to an issue:

```
create_document(
  title: "Plan: CIA-XXX — <summary>",
  content: <plan markdown>,
  project: "<project name>"
)
```

Then backlink to the issue:
```
create_comment(
  issueId: "<issue_id>",
  body: "Plan promoted to Linear Document: [Plan: CIA-XXX — <summary>](<document_url>)"
)
```

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
list_documents(query: "Plan: CIA-XXX", limit: 10)
```

Or browse all plans for a project:

```
list_documents(projectId: "<project_id>", query: "Plan:", limit: 50)
```

## Plan Format

> See [references/plan-format.md](references/plan-format.md) for the required section template.

Every promoted plan includes:

| Section | Required | Purpose |
|---------|----------|---------|
| **Header** | Yes | Issue link, session surface, status |
| **Decisions** | Yes | Key choices made (for future reference) |
| **Scope** | Yes | What this plan covers |
| **Non-Goals** | Yes | What's explicitly excluded |
| **Tasks** | Yes | `[ ]` checkbox items — map to issue ACs |
| **Verification** | Yes | How to confirm the plan succeeded |
| **Revision History** | Yes | Dated entries tracking plan evolution |

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

## Cross-Skill References

- **clinearhub-workflow** — Overall 6-step flow, where plan persistence fits (Step 1 and 5)
- **issue-lifecycle** — How plan-linked issues transition through statuses
- **spec-enrichment** — Plans may reference or extend PR/FAQ specs
