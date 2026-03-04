---
name: wrap-up
description: |
  End-of-session checklist for shipping, Linear normalization, memory persistence,
  and self-improvement. Use when user says "wrap up", "close session", "end session",
  "wrap things up", "close out this task", or invokes /wrap-up. Also auto-triggered
  at context budget hard gates (60%+). Integrates with closure-protocol, proactive-checks,
  and the ClinearHub 6-phase pipeline.
---

# Session Wrap-Up

Run four phases in order. Each phase is conversational and inline — no separate
documents. All phases auto-apply without asking; present a consolidated report
at the end.

---

## Phase 1: Ship It

### 1a — Commit & Push

1. Run `git status` (never `-uall`) in the working directory
2. If uncommitted changes exist:
   - Stage specific files (never `git add -A` — check for `.env`, credentials, large binaries)
   - Commit with a descriptive message following the repo's commit style (check `git log --oneline -5`)
   - Append `Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>`
3. Push to remote
4. If changes warrant a PR (feature branch, not main):
   - `GH_TOKEN=$(~/.claude/scripts/gh-app-token.sh) gh pr create ...` for ClinearHubBot identity
   - PR body MUST include `Closes CIA-XXX` (or `ALT-XXX`/`SWX-XXX`)
   - Set `gh pr merge --squash --auto --delete-branch` for auto-merge

### 1b — File Placement Check

5. If files were created this session:
   - Verify naming follows project conventions (snake_case for scripts, kebab-case for components)
   - Verify placement: `.md` docs in appropriate `docs/` or `references/` dirs, not repo root
   - Auto-fix violations (rename/move), commit the fix

### 1c — Typecheck & Lint

6. Run `pnpm typecheck` — verify all packages pass
7. If failures, fix them before proceeding (this blocks)

### 1d — Task Cleanup

8. Check the todo list for in-progress or stale items
9. Mark completed tasks as done, flag orphaned ones
10. Clear the todo list (all items should be completed or explicitly deferred)

---

## Phase 2: Linear Normalization

Normalize all Linear issues touched during this session. This is the session-end
version of the closure protocol.

### 2a — Issue Status Audit

For each Linear issue worked on this session:

1. **Read current state**: `get_issue(includeRelations: true)` + `list_comments(limit: 5)`
2. **Apply correct status**:
   - PR merged → Done (only if merged, never before)
   - PR opened but not merged → In Progress
   - Work completed but no PR (spike/chore) → apply closure protocol
   - Work started but incomplete → In Progress with closing comment noting progress
   - Blocked → add blocking relation, assign to Cian if human action needed
3. **Never auto-close Cian's issues** regardless of completion state
4. **Never mark spike/research Done** unless findings are in the description or linked document

### 2b — Closing Comments

For each issue being closed or progressed, post a closing comment:

```markdown
## Session Summary

**Status:** [Done | In Progress | Blocked]
**Quality Score:** [Grade] ([Score]/100) — only for Done transitions

### Evidence
- PR: [link] or "No PR — [reason]"
- Deploy: [link] or "N/A"
- Typecheck: Pass/Fail
- Tests: [status] or "No test suite"

### Work Completed
- [x] Item 1: [evidence]
- [x] Item 2: [evidence]
- [ ] Item 3: [carried forward to CIA-YYY]

### Carry-Forward
- [CIA-YYY: Description] — if any work was deferred
```

### 2c — Label Updates

- Update `ctx:*` label to reflect session end state (`ctx:autonomous` for background, remove `ctx:interactive` if session ending)
- Update `spec:*` label if spec status changed
- Verify `exec:*` label is still accurate

### 2d — Session Exit Table

Present the summary table per proactive-checks format:

**Issues:**

| Title | Status | Assignee | Priority | Estimate | Blocking | Blocked By |
|-------|--------|----------|----------|----------|----------|------------|

All titles as clickable `[CIA-XXX: Title](linear-url)` links.

**Documents** (if any created/updated):

| Title | Project |
|-------|---------|

---

## Phase 3: Remember It

Review what was learned. Decide where each piece of knowledge belongs.

### Memory Placement Guide

| Destination | What Goes There | Example |
|-------------|----------------|---------|
| **Auto memory** (`~/.claude/projects/.../memory/`) | Debugging insights, patterns, project quirks discovered this session | "Promptfoo v0.105 API types don't match docs — use CLI instead" |
| **CLAUDE.md** (repo root) | Permanent project conventions, architecture decisions | New package added, new command documented |
| **`.claude/rules/`** | Topic-specific instructions scoped to file types | Testing rules for `packages/evals/**` |
| **Plugin reference** (`skills/*/references/`) | Protocol updates, new procedures | Updated closure protocol |
| **Linear docs** | Decision records, spike findings | D-XXX decision log entries |

### Decision Framework

- Permanent project convention? → CLAUDE.md
- Scoped to specific files/areas? → `.claude/rules/` with `paths:` frontmatter
- Pattern or insight discovered? → Auto memory (topic file, link from MEMORY.md)
- Plugin protocol change? → Plugin reference file
- Architectural decision? → Linear Decision Log (D-XXX)

### Memory Hygiene

Before writing:
1. Check if existing memory already covers this (avoid duplicates)
2. Check MEMORY.md line count — must stay under 200 lines
3. If MEMORY.md is near limit, move detailed content to topic files
4. Update `> Last updated:` date in MEMORY.md

Auto-apply all memory updates. Present what was saved in the final report.

---

## Phase 4: Self-Improvement

Analyze the session for improvement findings. If the session was short or
routine with nothing notable, say "Nothing to improve" and proceed to the
final report.

### Finding Categories

| Category | What to Look For |
|----------|-----------------|
| **Skill gap** | Things Claude struggled with, needed multiple attempts, or got wrong |
| **Friction** | Repeated manual steps, things user had to ask for that should be automatic |
| **Knowledge** | Facts about the project/workspace Claude didn't know but should have |
| **Automation** | Repetitive patterns that could become skills, hooks, or gh-aw workflows |

### Action Types

| Finding → | Action |
|-----------|--------|
| Missing convention | → CLAUDE.md or `.claude/rules/` |
| Recurring pattern | → Auto memory |
| New procedure | → Plugin skill or reference file |
| Repetitive task | → Document as potential gh-aw workflow or hook |
| Tool/API quirk | → Auto memory topic file |

### Application

Auto-apply all actionable findings. Present a summary:

```
Findings (applied):

1. ✅ Knowledge: Promptfoo CLI is more reliable than programmatic API
   → [Memory] Added to eval-infrastructure.md

2. ✅ Friction: Had to manually check MEMORY.md line count
   → [Rules] Added memory hygiene reminder to wrap-up protocol

---
No action needed:

3. Knowledge: Supabase migration naming convention
   Already documented in MEMORY.md
```

---

## Final Report

Present a single consolidated report combining all phases:

```markdown
## Session Wrap-Up Report

### Ship
- Commits: [count] ([commit SHAs])
- PRs: [list with links]
- Typecheck: Pass ✅
- Files created/modified: [count]

### Linear
[Session Exit Table from Phase 2d]

### Memory
- Updated: [list of memory files touched]
- New entries: [count]

### Improvements
- Applied: [count]
- Deferred: [count]

### Next Session
[2-3 bullet points of recommended actions for the next session]
```

---

## Surface-Specific Behavior

### Code Sessions (Claude Code / Cursor)
- Full Phase 1 (commit, push, PR, typecheck)
- Full Phase 2 (Linear normalization)
- Full Phase 3 (memory)
- Full Phase 4 (self-improvement)

### Cowork Sessions (Claude Desktop)
- Skip Phase 1 (no filesystem access)
- Full Phase 2 (Linear normalization — primary focus)
- Phase 3: memory updates via conversation summary only (no file writes)
- Phase 4: findings noted for next Code session

### Context Budget Trigger (60%+)
- Abbreviated Phase 1 (commit current work, no PR)
- Phase 2: status updates only (no detailed closing comments)
- Phase 3: write critical memory only
- Skip Phase 4
- End with "Session split recommended — [summary of remaining work]"
