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

### 3. Resolve Project Context

Read the project from the issue's project field. The project is used for context and logging — NOT for `create_document` (plans attach to issues, not projects). Project is used for: confirming the user is working in the right project, log output, and routing reference docs.

```
# Project comes from the issue metadata (for context only)
project_id = issue.project.id
project_name = issue.project.name
```

> For reference documents that should persist at project level (architecture docs, pipeline docs), use `create_document(project: "...")` instead. Plans are issue-scoped; reference docs are project-scoped.

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
  issue: "<issue_id>"
)
```

> Plans appear in the issue's Resources section in Linear UI, alongside PR links and attachments.

**Existing document:**
```
update_document(
  id: "<existing_doc_id>",
  content: <updated plan markdown>
)
```

**Title format:** `Plan: CIA-XXX — <descriptive summary>`

### 6. Validate Attachment

After creating a new document, verify it attached to the correct issue:

```
get_issue(issueId, includeRelations: true)
→ Check issue.documents contains the new document ID
```

If the document is NOT found in the issue's documents:
1. Alert: "Plan attached at wrong level — recovering."
2. `get_document(id)` → read content
3. `create_document(issue: "<issue_id>")` → recreate at issue level
4. Delete the incorrectly-attached document
5. Post a comment explaining the recovery

> `update_document` cannot change attachment. Recovery = delete + recreate.

### 7. Backlink

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

## Finalization Protocol (Session Close)

At session end, `/plan --finalize` runs a mandatory checklist. Reports failures inline.

```
Session Close Protocol:
1. [ ] Plan document exists on the issue
2. [ ] Completed tasks ticked [x] in plan document
3. [ ] Issue ACs synced with plan tasks
4. [ ] Closing comment posted with evidence table
5. [ ] Context labels updated
6. [ ] Dependencies set as Linear relations
7. [ ] Plan title updated to outcome summary
8. [ ] Sibling check — if parent exists, check all siblings Done → post on parent
```

See `/plan --finalize` command for full implementation details.

## Notes

- Linear Documents are the single source of truth. No `.ccc-state.json` or filesystem markers.
- Linear Documents have built-in revision history visible in the UI. The `## Revision History` section in the document content provides human-readable change summaries in addition to Linear's built-in versioning.
- Plans attach to issues via `create_document(issue: "<issue_id>")`. Reference docs attach to projects via `create_document(project: "...")`. The Linear API rejects dual project+issue attachment — pick one per document.
- Agents always check for attachments on issues via `get_attachment` before starting work. Human-added context (PDFs, screenshots, links) is discovered automatically — no prompting needed.
