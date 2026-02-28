# Plan Promotion Protocol

CLH-native 6-step protocol for promoting session plans to Linear Documents.

## Steps

### 1. Resolve Plan Content

| Platform | How |
|----------|-----|
| **Cowork** | Summarize conversation context into plan markdown. Include: decisions made, scope agreed, tasks identified, verification criteria. |
| **Code** | Read from `~/.claude/plans/<plan-file>.md`. If no plan file exists, compose from session context. |

### 2. Resolve Target Issue

- If `--promote CIA-XXX` argument provided, use that issue
- Otherwise, check for active issues in the session (In Progress, assigned to current agent)
- If ambiguous, ask the user which issue to link

```
get_issue(id: "CIA-XXX", includeRelations: true)
```

Verify the issue exists and is in an active state (Todo, In Progress, In Review).

### 3. Determine Project

Read the project from the issue's project field. Plans attach to the same project as their linked issue.

```
# Project comes from the issue metadata
project_id = issue.project.id
project_name = issue.project.name
```

### 4. Check for Existing Plan Document

Search for an existing plan document for this issue:

```
list_documents(query: "Plan: CIA-XXX", limit: 10)
```

If a matching document exists:
- **Update** the existing document (preserves revision history)
- Append to `## Revision History` with new dated entry

If no matching document:
- **Create** a new document

### 5. Create or Update Linear Document

**New document:**
```
create_document(
  title: "Plan: CIA-XXX — <summary>",
  content: <plan markdown>,
  project: "<project_name>"
)
```

**Existing document:**
```
update_document(
  id: "<existing_doc_id>",
  content: <updated plan markdown>
)
```

**Title format:** `Plan: CIA-XXX — <descriptive summary>`

### 6. Backlink

Post a comment on the issue linking to the plan document:

```
create_comment(
  issueId: "<issue_id>",
  body: "Plan promoted to Linear Document: [Plan: CIA-XXX — <summary>](<document_url>)"
)
```

If updating an existing plan, post:
```
create_comment(
  issueId: "<issue_id>",
  body: "Plan updated: [Plan: CIA-XXX — <summary>](<document_url>) — v<N>: <change summary>"
)
```

## Finalization Protocol

At session end, `/plan --finalize` does:

1. **Summarize session**: What was accomplished, key decisions, next steps
2. **Update plan content**: Mark completed tasks `[x]`, add session summary
3. **Rename document**: Change title to reflect outcomes
   ```
   update_document(
     id: "<doc_id>",
     title: "Plan: CIA-XXX — <outcome summary>"
   )
   ```
4. **Update issue**: Post session summary comment on the linked issue
5. **Update context labels**: If session surface is changing, swap `ctx:*` labels

## Notes

- Linear Documents are the single source of truth. No `.ccc-state.json` or filesystem markers.
- Linear Documents have built-in revision history visible in the UI. The `## Revision History` section in the document content provides human-readable change summaries in addition to Linear's built-in versioning.
- Plans are NOT attached to issues via the document `issue` field (API rejects dual project+issue attachment). Instead, linking is done via comments and title convention.
