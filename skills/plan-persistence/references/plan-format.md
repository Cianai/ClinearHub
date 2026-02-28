# Plan Document Format

Template for promoted plan documents. All sections are required unless marked optional.

## Template

```markdown
# <Plan Title>

**Issue:** [CIA-XXX: <issue title>](<linear_url>)
**Session:** <Cowork|Claude Code>, <date>
**Status:** <In Progress|Complete>

## Decisions

* **<Decision 1>**: <what was decided and why>
* **<Decision 2>**: <what was decided and why>

## Scope

<1-3 sentences describing what this plan covers>

1. **<Area 1>** — <brief description>
2. **<Area 2>** — <brief description>

## Non-Goals

* <Explicit exclusion 1>
* <Explicit exclusion 2>
* <Explicit exclusion 3>

## Tasks

- [ ] <Task 1 with clear definition of done>
- [ ] <Task 2 with clear definition of done>
- [ ] <Task 3 with clear definition of done>

## Verification

* <How to confirm task 1 succeeded>
* <How to confirm task 2 succeeded>
* <Overall success criteria>

## Revision History

* **v1 (<date>)**: <Initial plan summary>
```

## Section Guidelines

### Header

- **Issue link**: Always a clickable markdown link to the Linear issue
- **Session surface**: "Cowork" or "Claude Code" — helps future readers understand context
- **Status**: Updated on finalization

### Decisions

Capture choices that future sessions need to know. Format: bold key + explanation.

Bad: "Decided to use Redis"
Good: "**Cache layer**: Redis via Upstash — chosen over in-memory because agents restart between sessions"

### Tasks

Each task must be independently completable and verifiable. Use `[ ]` checkboxes — these map to issue acceptance criteria.

Bad: `- [ ] Do the backend work`
Good: `- [ ] Create /api/plans endpoint returning paginated plan list`

### Non-Goals

At least 3. Each must be specific and falsifiable.

Bad: "Won't make it too complex"
Good: "No real-time collaboration on plan documents (single-author per session)"

### Verification

Concrete, observable criteria. Not "verify it works" but "17 commands listed in plugin manifest".

### Revision History

Append-only. Each entry: version number, date, and 1-sentence summary of what changed. Never remove or rewrite previous entries.

## Title Convention

| Stage | Title Format |
|-------|-------------|
| Working | `Plan: CIA-XXX — <descriptive working title>` |
| Finalized | `Plan: CIA-XXX — <outcome summary>` |

Examples:
- Working: `Plan: CIA-784 — ClinearHub v1.0 Native Alignment, Plan Persistence, Public Release`
- Finalized: `Plan: CIA-784 — Shipped ClinearHub v1.0 with 17 commands, 9 skills, public repo`

## Checkbox → AC Mapping

Plan checkboxes and issue acceptance criteria stay in sync:

1. On `/plan --promote`: each `- [ ]` task → AC line in issue description
2. On task completion: agent ticks `[x]` in both plan doc and issue
3. On `/verify`: cross-check plan checkboxes vs issue ACs for coverage gaps
