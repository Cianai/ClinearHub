---
description: Manage session plans — promote to Linear Documents, review plans, list promoted plans, finalize at session end
argument-hint: "<--promote [CIA-XXX] | --review [CIA-XXX] | --list [--project <name>] | --index | --finalize [CIA-XXX]>"
---

# Plan

Manage ClinearHub plans: promote session plans to durable Linear Documents, review plans from any surface, list existing plans, and finalize plans at session end.

## Mode: --promote [CIA-XXX]

Create or update a Linear Document linked to an issue.

### Step 1: Resolve Plan Content

**Cowork:** Summarize the current conversation into plan format (see plan-persistence skill for template). Include: decisions made, scope, tasks with `[ ]` checkboxes, verification criteria.

**Code:** Check for a plan file in `~/.claude/plans/`. If found, read it. If not, compose from session context.

### Step 1.5: Canonical Plan File Naming (Code Sessions Only)

If the local plan file has an auto-generated name (e.g., `tingly-leaping-hippo.md`), copy it to a canonical name:

```bash
cp ~/.claude/plans/<auto-name>.md ~/.claude/plans/CIA-XXX-<slug>.md
```

**Naming convention:** `CIA-XXX-<short-descriptive-slug>.md`

The auto-generated file stays (Claude Code references it), but the canonical copy has a human-readable name. For Cowork sessions, skip this step — no filesystem access.

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

### Step 5: Validate Attachment

After creating a new document, verify it attached to the issue correctly:

```
get_issue(issueId, includeRelations: true)
→ Check issue.documents contains the new document ID
```

If the document is NOT found in the issue's documents:
1. Alert the user: "Plan created at wrong level (project instead of issue)."
2. Read the document content via `get_document`
3. Create a new document with `issue: "<issue_id>"` parameter
4. Delete the incorrectly-attached document
5. Post a comment explaining the recovery

> **API limitation:** `update_document` cannot change a document's attachment (project → issue or vice versa). The only recovery is delete + recreate.

### Step 6: Backlink

```
create_comment(
  issueId: "<issue_id>",
  body: "Plan promoted to Linear Document: [Plan: CIA-XXX — <summary>](<doc_url>)"
)
```

### Step 7.5: Update Plan Index (Code Sessions Only)

Append a row to `~/.claude/plans/INDEX.md` (create if it doesn't exist):

```markdown
| CIA-XXX | [Plan: CIA-XXX — <summary>](<doc_url>) | CIA-XXX-<slug>.md | <date> | In Progress |
```

For Cowork sessions, skip — no filesystem access. Discovery happens via `list_documents(query: "Plan:")`.

### Step 8: Confirm

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

## Mode: --review [CIA-XXX]

Read and display a promoted plan for review, with inline status. Works from both Cowork and Code — the primary mechanism for cross-surface plan review.

### Step 1: Find Plan Document

```
list_documents(query: "Plan: CIA-XXX", limit: 5)
```

If `CIA-XXX` not provided, find the most recently updated plan for In Progress issues.

### Step 2: Read Plan and Issue State

```
get_document(id: "<doc_id>")
get_issue(issueId, includeRelations: true)
```

### Step 3: Display Plan with Status

Render the plan with inline status overlay:

```markdown
## Plan Review: CIA-XXX — <summary>

**Issue:** [CIA-XXX: <title>](<url>) — <status>
**Last updated:** <date> (<time since last update>)
**Blocking:** <blocking issues or "None">

### Tasks
- [x] <completed task>
- [ ] <pending task> ← next
- [ ] <pending task>

### Progress: N/M tasks complete
```

### Step 4: Offer Actions

Present options for the user:
- **(a) Update this plan** — modify content via `update_document`
- **(b) Add a comment** — post feedback on the issue via `create_comment`
- **(c) Finalize it** — run `--finalize` flow
- **(d) Continue reviewing** — no action, plan displayed for reference

> **Multi-surface usage:** In Cowork, this reads a plan created in Code (or vice versa). In Code, pair with `/output-style pm-review` for non-technical explanation. From Code, "Continue in" → VS Code/Cursor for line-by-line editing.

## Mode: --index

Display the local plan index showing all promoted plans with their lineage. Code sessions only.

### Step 1: Read INDEX.md

```
Read ~/.claude/plans/INDEX.md
```

If the file doesn't exist, output: "No plan index found. Run `/plan --promote` to create the first entry."

### Step 2: Display

Format as table with status indicators:

```markdown
## Plan Index

| Issue | Linear Document | Local File | Date | Status |
|-------|----------------|------------|------|--------|
| CIA-784 | [Plan: CIA-784 — ...](url) | CIA-784-plan-persistence-v2.md | 2026-02-28 | Complete |
| CIA-XXX | [Plan: CIA-XXX — ...](url) | CIA-XXX-slug.md | 2026-02-28 | In Progress |
```

> **Cowork alternative:** Use `--list` instead — it queries Linear Documents directly. `--index` reads the local filesystem which is only available in Code sessions.

## Mode: --finalize [CIA-XXX]

Finalize a plan at session end. Mandatory session close protocol — captures decisions, next steps, and outcome summary. Reports failures and blocks until addressed.

### Session Close Checklist

Run every item. Report failures inline and do NOT skip items.

```
Session Close Protocol:
1. [ ] Plan document exists on the issue (verified via get_issue documents array)
2. [ ] Completed tasks ticked [x] in plan document
3. [ ] Issue ACs synced with plan tasks (plan checkboxes ↔ issue description ACs)
4. [ ] Closing comment posted with evidence table
5. [ ] Context labels updated (remove stale ctx:*, apply new if needed)
6. [ ] Dependencies set as Linear relations (not just plan references)
7. [ ] Plan title updated to outcome summary
```

### Step 1: Find Plan Document

```
list_documents(query: "Plan: CIA-XXX", limit: 10)
```

If `CIA-XXX` not provided, find the most recently updated plan document for In Progress issues.

If NO plan document found: alert the user and offer to run `--promote` first.

### Step 2: Summarize Session

Compose a session summary:
- What was accomplished (tick `[x]` completed tasks)
- Key decisions made during the session
- Open questions or blockers
- Next steps (in priority order)

### Step 3: Sync ACs

Read both plan document and issue description. Ensure checkboxes are in sync:
- Plan `[x]` → issue AC should also be `[x]`
- Any new ACs discovered during session → add to both plan and issue

### Step 4: Update Plan Document

```
update_document(
  id: "<doc_id>",
  title: "Plan: CIA-XXX — <outcome summary>",
  content: <plan with completed tasks ticked, session summary, and revision history entry>
)
```

### Step 5: Post Evidence Comment

Post a closing comment with evidence table:

```
create_comment(
  issueId: "<issue_id>",
  body: "## Session Close — <date>\n\n| Item | Status |\n|------|--------|\n| Plan | [title](url) — updated |\n| ACs synced | Yes |\n| Tasks completed | N/M |\n| Next steps | <1-2 items> |\n\n**Session finalized:** <1-2 sentence summary>"
)
```

### Step 6: Update Context Labels

Remove current `ctx:*` label and apply appropriate new `ctx:*` label based on what happens next.

### Step 7: Check Sibling Status (non-PR closures)

If this issue has a parent, check if all siblings are Done:

```
get_issue(parentId, includeRelations: true)
→ List all children → count Done vs total
```

If all siblings Done → post "All sub-issues complete" comment on parent (same as post-merge-reconciliation Phase 8 but for non-PR closures like spikes and manual completions).

### Step 8: Report

Output a summary table of what was done:

```markdown
## Session Close Report

| Check | Status |
|-------|--------|
| Plan exists on issue | ✓ |
| Tasks ticked [x] | ✓ (N/M) |
| ACs synced | ✓ |
| Evidence posted | ✓ |
| Labels updated | ✓ |
| Dependencies set | ✓ / N/A |
| Title updated | ✓ |
| Sibling check | N/M Done |
```

### Connector Tier

| Connector | Tier | Access |
|-----------|------|--------|
| Linear | Core | R/W (documents, issues, comments) |
