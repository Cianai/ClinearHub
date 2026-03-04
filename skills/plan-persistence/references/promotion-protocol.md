# Plan Promotion Protocol

6-step protocol for promoting session plans to Linear Documents.

## Steps

### 1. Resolve Plan Content

| Platform | How |
|----------|-----|
| **Cowork** | Summarize conversation context into plan markdown. Include: decisions, scope, tasks, verification. |
| **Code** | Read from `~/.claude/plans/<plan-file>.md`. If no plan file exists, compose from session context. |
| **Code + Plannotator** | If `~/.plannotator/history/` has a recent version for this project, read it. |

### 2. Resolve Target Issue

- If `--promote <ISSUE-ID>` argument provided, use that issue
- Otherwise, check for active issues in the session (In Progress, assigned to current agent)
- If ambiguous, ask the user which issue to link

```
get_issue(id: "<ISSUE-ID>", includeRelations: true)
```

Verify the issue exists and is in an active state (Todo, In Progress, In Review).

### 3. Check for Existing Plan Document

Search for an existing plan document for this issue:

```
list_documents(query: "Plan: <ISSUE-ID>", limit: 10)
```

If a matching document exists:
- **Update** the existing document (preserves revision history)
- Append to `## History & References` with new dated entry

If no matching document:
- **Create** a new document

### 4. Create or Update Linear Document

**New document:**
```
create_document(
  title: "Plan: <ISSUE-ID> — <summary>",
  content: <plan markdown>,
  issue: "<issue_id>"
)
```

**Existing document:**
```
update_document(
  id: "<existing_doc_id>",
  content: <updated plan markdown>
)
```

### 5. Validate Attachment

After creating a new document, verify it attached correctly:

```
get_issue(issueId, includeRelations: true)
→ Check issue.documents contains the new document ID
```

If NOT found:
1. Alert: "Plan attached at wrong level — recovering."
2. `get_document(id)` → read content
3. `create_document(issue: "<issue_id>")` → recreate at issue level
4. Delete the incorrectly-attached document
5. Post a comment explaining the recovery

> `update_document` cannot change attachment. Recovery = delete + recreate.

### 6. Backlink

Post a comment on the issue linking to the plan:

**New plan:**
```
create_comment(
  issueId: "<issue_id>",
  body: "Plan promoted: [Plan: <ISSUE-ID> — <summary>](<document_url>)\nReview & annotate: <plan-review-app-url>/plan/<doc-id>"
)
```

**Updated plan:**
```
create_comment(
  issueId: "<issue_id>",
  body: "Plan updated: [Plan: <ISSUE-ID> — <summary>](<document_url>) — v<N>: <change summary>"
)
```

## Finalization Protocol (Session Close)

At session end, wrap-up Phase 1.5 runs this checklist:

```
1. [ ] Plan document exists on the issue
2. [ ] Completed tasks ticked [x] in plan document
3. [ ] Issue ACs synced with plan tasks
4. [ ] Closing comment posted with evidence table
5. [ ] Context labels updated
6. [ ] Dependencies set as Linear relations
7. [ ] Plan title updated to outcome summary
8. [ ] Sibling check — if parent exists, check all siblings Done → post on parent
```

## Notes

- Linear Documents are the single source of truth. No local filesystem markers.
- Linear Documents have built-in revision history. The `## History & References` section provides human-readable change summaries in addition.
- Plans attach to issues via `create_document(issue: "<id>")`. Reference docs attach to projects via `create_document(project: "...")`. The API rejects dual project+issue attachment.
- `<ISSUE-ID>` matches the issue's team prefix: CIA-XXX, ALT-XXX, or SWX-XXX.
