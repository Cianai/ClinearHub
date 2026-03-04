# Plan Document Format

Template for promoted plan documents. All sections are required.

## Sections

| Section | Purpose |
|---------|---------|
| **Summary** | 2-3 sentence plain-language overview for non-technical reviewers |
| **Header** | Issue link, session surface, author, status |
| **Decisions** | Key choices made (for future reference) |
| **Scope & Non-Goals** | What this plan covers and what's explicitly excluded |
| **Tasks** | `[ ]` checkbox items — map to issue ACs |
| **Verification** | How to confirm the plan succeeded |
| **History & References** | Revision log + hyperlinked sources |

## Template

```markdown
# <Plan Title>

## Summary

<2-3 sentences in plain language. No jargon. A non-technical stakeholder should understand the purpose from this section alone.>

**Issue:** [<ISSUE-ID>: <title>](<linear_url>)
**Session:** <Cowork|Claude Code|VS Code>, <date>
**Author:** <ClinearHubBot | Codex | ChatPRD | Copilot | Claude (interactive)>
**Status:** <In Progress|Complete>

## Decisions

* **<Decision 1>**: <what was decided and why>
* **<Decision 2>**: <what was decided and why>

## Scope & Non-Goals

### Scope
1. **<Area 1>** — <brief description>
2. **<Area 2>** — <brief description>

### Non-Goals
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

## History & References

### Revision History
* **v1 (<date>)**: <Initial plan summary>

### References
* [<ISSUE-ID>: Parent Issue](linear://claudian/issue/<ISSUE-ID>) — parent issue
* [Document Title](linear://claudian/document/...) — reference document
* [External Source](https://example.com) — web resource consulted
```

## Section Guidelines

### Summary

Plain language only. No technical jargon.

Bad: "Refactors the plan-persistence SKILL.md to use issue-level create_document with Linear MCP attachment parameters"
Good: "Changes how session plans are saved so they appear directly on the issue they belong to, instead of cluttering the project's document list."

### Decisions

Capture choices future sessions need to know. Format: bold key + explanation.

Bad: "Decided to use Redis"
Good: "**Cache layer**: Redis via Upstash — chosen over in-memory because agents restart between sessions"

### Tasks

Each task must be independently completable and verifiable.

Bad: `- [ ] Do the backend work`
Good: `- [ ] Create /api/plans endpoint returning paginated plan list`

### Non-Goals

At least 3. Each must be specific and falsifiable.

Bad: "Won't make it too complex"
Good: "No real-time collaboration on plan documents (single-author per session)"

### Verification

Concrete, observable criteria. Not "verify it works" but specific measurable outcomes.

## Title Convention

| Stage | Format |
|-------|--------|
| Working | `Plan: <ISSUE-ID> — <descriptive working title>` |
| Finalized | `Plan: <ISSUE-ID> — <outcome summary>` |

`<ISSUE-ID>` matches the team prefix: CIA-XXX, ALT-XXX, or SWX-XXX.

## Checkbox → AC Mapping

1. On promote: each `- [ ]` task → AC line in issue description
2. On completion: tick `[x]` in both plan doc and issue
3. On `/verify`: cross-check for coverage gaps

## Hyperlink Rules

Every plan MUST hyperlink:
- **Linear issues**: `[<ISSUE-ID>: Title](url)` — never bare IDs
- **Linear documents**: `[Doc title](url)`
- **Web sources**: `[Page title](url)`
- **GitHub resources**: `[PR/issue title](url)`
- **MCP tools**: backtick formatting `create_document` (no link needed)
