# Plan Document Format

Template for promoted plan documents. All sections are required unless marked optional.

## Required Sections

| Section | Required | Purpose |
|---------|----------|---------|
| **Summary** | Yes | 2-3 sentence plain-language overview for non-technical reviewers |
| **Header** | Yes | Issue link, session surface, status |
| **Decisions** | Yes | Key choices made (for future reference) |
| **Scope** | Yes | What this plan covers |
| **Non-Goals** | Yes | What's explicitly excluded |
| **Tasks** | Yes | `[ ]` checkbox items — map to issue ACs |
| **Verification** | Yes | How to confirm the plan succeeded |
| **Revision History** | Yes | Dated entries tracking plan evolution |
| **References** | Yes | Hyperlinked Linear items, web sources, documents cited |

## Template

```markdown
# <Plan Title>

## Summary

<2-3 sentences in plain language explaining what this plan does, why it matters, and what changes. No jargon. A non-technical stakeholder should understand the purpose from this section alone.>

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

## References

* [CIA-XXX: Parent Issue Title](https://linear.app/claudian/issue/CIA-XXX) — parent issue
* [CIA-YYY: Blocking Issue](https://linear.app/claudian/issue/CIA-YYY) — blocking dependency
* [Document Title](https://linear.app/claudian/document/...) — reference document
* [External Source](https://example.com) — web resource consulted
```

## Section Guidelines

### Summary

Plain language only. No technical jargon. A PM or stakeholder should understand what this plan accomplishes from this section alone. Think of it as an email subject line expanded to 2-3 sentences.

Bad: "Refactors the plan-persistence SKILL.md to use issue-level create_document with Linear MCP attachment parameters"
Good: "Changes how session plans are saved so they appear directly on the issue they belong to, instead of cluttering the project's document list. Also adds a references section to every plan so reviewers can click through to related items."

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

### References

Every item referenced in the plan — Linear issues, Linear documents, web pages, GitHub resources — listed with clickable hyperlinks. Dependencies documented here MUST also be set as actual Linear relations on the issue:

1. Document in `## References` (for human reading in the plan)
2. Set via `save_issue(id, blockedBy: ["CIA-YYY"])` (for Linear sidebar visibility)

This ensures dependencies appear in BOTH the plan document AND the Linear issue sidebar.

## Hyperlink Rules

Every plan MUST hyperlink:
- **Linear issues**: `[CIA-XXX: Title](linear_url)` — never bare CIA-XXX
- **Linear documents**: `[Doc title](linear_doc_url)` — never bare doc names
- **Web sources**: `[Page title](url)` — any external page referenced
- **GitHub resources**: `[PR/issue title](github_url)` — PRs, issues, files
- **MCP tool references**: backtick formatting `create_document` (no link needed)

Purpose: Humans review plans by clicking through references. Every reference must be one click away.

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
