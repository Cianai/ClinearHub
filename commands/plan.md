---
description: Manage session plans — promote to Linear Documents, list promoted plans, finalize at session end
argument-hint: "<--promote [CIA-XXX] | --list [--project <name>] | --finalize [CIA-XXX]>"
---

# Plan

Manage ClinearHub plans: promote session plans to durable Linear Documents, list existing plans, and finalize plans at session end.

## Mode: --promote [CIA-XXX]

Create or update a Linear Document linked to an issue.

### Step 1: Resolve Plan Content

**Cowork:** Summarize the current conversation into plan format (see plan-persistence skill for template). Include: decisions made, scope, tasks with `[ ]` checkboxes, verification criteria.

**Code:** Check for a plan file in `~/.claude/plans/`. If found, read it. If not, compose from session context.

### Step 2: Resolve Target Issue

If `CIA-XXX` provided, use it. Otherwise:

```
list_issues(team: "Claudian", state: "In Progress", assignee: "me", limit: 5)
```

If multiple candidates, ask the user which issue to link.

### Step 3: Check for Existing Plan

```
list_documents(query: "Plan: CIA-XXX", limit: 10)
```

If found: update the existing document (preserves history).
If not found: create a new document.

### Step 4: Create or Update Document

**New:**
```
create_document(
  title: "Plan: CIA-XXX — <summary>",
  content: <plan markdown>,
  issue: "<issue_id>"
)
```

> Plans attach to issues (not projects). The plan appears in the issue's Resources section. For reference documents that should persist at project level (architecture docs, pipeline docs), use `create_document(project: "...")` instead.

**Update:**
```
update_document(
  id: "<existing_doc_id>",
  content: <updated plan with revision history entry>
)
```

### Step 5: Backlink

```
create_comment(
  issueId: "<issue_id>",
  body: "Plan promoted to Linear Document: [Plan: CIA-XXX — <summary>](<doc_url>)"
)
```

### Step 6: Confirm

Output the document URL and linked issue.

## Mode: --list [--project <name>]

List promoted plans via Linear Documents.

### Step 1: Query Documents

```
list_documents(query: "Plan:", limit: 50)
```

If `--project` specified:
```
list_documents(projectId: "<project_id>", query: "Plan:", limit: 50)
```

### Step 2: Format Output

```markdown
## Promoted Plans

| Plan | Issue | Project | Updated |
|------|-------|---------|---------|
| [Plan: CIA-XXX — Summary](url) | [CIA-XXX](url) | ProjectName | 2026-02-28 |
```

## Mode: --finalize [CIA-XXX]

Finalize a plan at session end. Replaces `/handoff` — captures decisions, next steps, and outcome summary in the plan document.

### Step 1: Find Plan Document

```
list_documents(query: "Plan: CIA-XXX", limit: 10)
```

If `CIA-XXX` not provided, find the most recently updated plan document for In Progress issues.

### Step 2: Summarize Session

Compose a session summary:
- What was accomplished (tick `[x]` completed tasks)
- Key decisions made during the session
- Open questions or blockers
- Next steps (in priority order)

### Step 3: Update Plan Document

```
update_document(
  id: "<doc_id>",
  title: "Plan: CIA-XXX — <outcome summary>",
  content: <plan with completed tasks ticked and session summary appended>
)
```

### Step 4: Update Issue

Post a session summary comment on the linked issue:

```
create_comment(
  issueId: "<issue_id>",
  body: "**Session finalized:** <1-2 sentence summary>. Plan: [<plan title>](<doc_url>)"
)
```

### Step 5: Update Context Labels

If the session surface is changing (e.g., switching from interactive to human review):
- Remove current `ctx:*` label
- Apply appropriate new `ctx:*` label

### Connector Tier

| Connector | Tier | Access |
|-----------|------|--------|
| Linear | Core | R/W (documents, issues, comments) |
