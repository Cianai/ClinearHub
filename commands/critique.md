---
description: Review issue quality — description, ACs, metadata — before agent dispatch
argument-hint: "<CIA-XXX issue ID> [--batch]"
---

# Critique

Review a Linear issue for quality, completeness, and agent-readiness before dispatch.

## Step 1: Fetch Issue

```
get_issue(id: "$1", includeRelations: true)
list_comments(issueId: "$1", limit: 10)
```

If `--batch`: fetch multiple Todo issues ready for dispatch:
```
list_issues(team: "Claudian", state: "Todo", limit: 5)
```

## Step 2: Description Quality

Check each criterion:

| Check | Pass Criteria |
|-------|--------------|
| Problem statement | Exists, does not mention the solution |
| Acceptance criteria | Present, each independently testable |
| Non-goals | At least 1 for features (optional for bugs/chores) |
| Clarity | An agent could implement without asking questions |
| Scope | Bounded — no open-ended exploration implied |

## Step 3: Metadata Completeness

| Check | Pass Criteria |
|-------|--------------|
| Type label | Exactly one `type:*` label |
| Execution mode | `exec:*` label present and matches complexity |
| Estimate | Fibonacci estimate applied |
| Project | Assigned to a project |
| Priority | Set (not None, unless intentional) |

## Step 4: Agent Readiness

| Check | Pass Criteria |
|-------|--------------|
| Dependencies | All `blockedBy` issues are Done |
| Context | Description + comments provide sufficient implementation context |
| Scope | No open questions in comments without answers |
| Size | Estimate <= 5pt (larger should be decomposed first) |

## Step 5: Score

| Score | Criteria | Action |
|-------|----------|--------|
| **Ready** | All checks pass | Can apply `auto:implement` |
| **Needs Work** | 1-2 minor gaps | Fix inline, then dispatch |
| **Not Ready** | 3+ gaps or any critical gap | Return to draft with findings |

Critical gaps (always "Not Ready"):
- No acceptance criteria
- No type label
- Blocking dependency unresolved
- Estimate >8pt without decomposition

## Step 6: Output

```markdown
## Issue Critique — [CIA-XXX: Title](url)

**Score:** [Ready / Needs Work / Not Ready]

### Description Quality
| Check | Status | Note |
|-------|--------|------|
| Problem statement | [Pass/Fail] | [note] |
| Acceptance criteria | [Pass/Fail] | [note] |
| Non-goals | [Pass/Fail/N/A] | [note] |
| Clarity | [Pass/Fail] | [note] |

### Metadata
| Check | Status | Note |
|-------|--------|------|
| Type label | [Pass/Fail] | [current value] |
| Execution mode | [Pass/Fail] | [current/suggested] |
| Estimate | [Pass/Fail] | [current/suggested] |
| Project | [Pass/Fail] | [current value] |

### Agent Readiness
| Check | Status | Note |
|-------|--------|------|
| Dependencies | [Pass/Fail/Warning] | [details] |
| Context | [Pass/Fail] | [details] |
| Size | [Pass/Fail] | [details] |

### Recommended Actions
1. [Action 1]
2. [Action 2]
```

If `--batch`, output a summary table:

```markdown
## Batch Critique — [N] Issues

| Issue | Score | Key Gaps | Recommended |
|-------|-------|----------|-------------|
| [CIA-XXX](url) | Ready | — | Dispatch |
| [CIA-YYY](url) | Needs Work | Missing estimate | Fix, then dispatch |
| [CIA-ZZZ](url) | Not Ready | No ACs, no type | Return to draft |
```
