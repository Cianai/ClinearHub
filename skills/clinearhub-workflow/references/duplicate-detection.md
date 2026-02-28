# Duplicate Detection

Before creating any new issue, check Linear for existing coverage. Duplicates waste agent capacity and create confusion about which issue is the source of truth.

## Detection Protocol

### Step 1: Title Search

Query Linear for issues with overlapping titles:

```
list_issues(project: "<project>", query: "<2-3 distinctive terms>", limit: 10)
```

Use 2-3 distinctive terms from the proposed title, not common words. For example, if creating "Build PostHog dashboard for retention metrics", search for "PostHog retention" or "retention dashboard".

### Step 2: Label Overlap Check

Higher duplicate risk when an existing issue has:
- Same `type:*` label AND same milestone
- Same `type:*` label AND same project AND similar title terms

### Step 3: Acceptance Criteria Overlap

If the title search returns potential matches, compare acceptance criteria:
- Read each candidate's description
- If more than 60% of the proposed AC terms appear in an existing issue, flag as potential duplicate
- Pay attention to exact AC wording — "implement X" and "add X" covering the same behavior are duplicates

### Step 4: Stale Duplicate Check

Issues with identical titles but different statuses need context:
- One Done + one Todo with same title = the Todo may be intentional follow-up, NOT a duplicate
- Both in Todo/Backlog with same title = likely duplicate
- One Canceled + one Todo = the Todo may be a retry, check cancel reason

## Resolution Protocol

### Exact Duplicate
Mark as `duplicateOf` via `update_issue(duplicateOf: "SURVIVOR_ID")`. This auto-closes the duplicate. Keep the issue with more context as the survivor.

### Partial Overlap
- Merge acceptance criteria into the more complete issue (the "survivor")
- Link as `relatedTo` for traceability
- Cancel the less-complete issue with a comment explaining the merge

### Intentional Split
If both issues exist for valid reasons (e.g., Phase 1 vs Phase 2 of the same feature):
- Add a comment on both documenting why they're separate
- Link as `relatedTo`
- Consider adding dependency: Phase 1 `blocks` Phase 2

## When to Run Dedup

- **Before creating any issue** — always search first
- **During triage** — check each incoming issue against existing ones
- **During `/update --comprehensive`** — periodic full scan across project
- **During sprint planning** — verify no duplicate work being planned

## Common Duplicate Patterns

| Pattern | Example | Resolution |
|---------|---------|-----------|
| Renamed issue | "Build X" vs "Implement X" (same scope) | Merge into one |
| Split scope | Parent created, then sub-issue duplicates parent scope | Clarify parent/child boundaries |
| Agent-created | ChatPRD creates sub-issue that overlaps existing | Cancel agent-created, link to existing |
| Cross-project | Same feature tracked in two projects | Move to correct project, cancel other |
