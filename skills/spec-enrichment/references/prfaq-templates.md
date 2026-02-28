# PR/FAQ Templates

Four templates at different formality levels. Each encodes the Working Backwards methodology.

## prfaq-feature (Full Formality)

Use for customer-facing product features.

```markdown
---
linear: CIA-XXX
exec: <mode>
status: draft
created: <ISO 8601>
updated: <ISO 8601>
---

# [Feature Name]: Press Release

## Headline
[One sentence: what shipped and why it matters]

## Subheadline
[One sentence: who benefits and how]

## Problem
[2-3 paragraphs describing the pain. MUST NOT mention the solution.]

## Solution
[2-3 paragraphs describing what was built and how it works]

## Customer Quote
"[Fictional quote from a satisfied user describing the benefit in their words]"

## Getting Started
[How a user starts using this feature]

---

## FAQ

### Customer Questions
1. [Question about usage] — [Substantive answer]
2. [Question about migration/compatibility] — [Answer]
3. [Question about limitations] — [Answer]

### Technical Questions
4. [Question about scaling/performance] — [Answer]
5. [Question about failure modes] — [Answer]
6. [Question about data/security] — [Answer]

### Business Questions
7. [Question about cost/pricing] — [Answer]
8. [Question about success metrics] — [Answer]

### Skeptic Questions
9. [Why now?] — [Answer]
10. [Why not alternative X?] — [Answer]
11. [What if assumption Y is wrong?] — [Answer]
12. [Hardest question you can think of] — [Answer]

---

## Pre-Mortem

### Failure 1: [Name]
- **Scenario:** [Specific story of how this fails]
- **Root cause:** [Underlying assumption or design flaw]
- **Mitigation:** [What to change in the spec]
- **Detection:** [How to know before it's catastrophic]

### Failure 2: [Name]
[Same structure]

### Failure 3: [Name]
[Same structure]

---

## Inversion Analysis

| To guarantee failure... | Design principle derived |
|------------------------|------------------------|
| [Deliberate failure action] | [Opposite = constraint] |
| [Deliberate failure action] | [Opposite = constraint] |
| [Deliberate failure action] | [Opposite = constraint] |

---

## Non-Goals
1. [Specific thing] — [Why excluded]
2. [Specific thing] — [Why excluded]
3. [Specific thing] — [Why excluded]

## Scale: [Personal | Team | Organization | Platform]

---

## Acceptance Criteria
- [ ] [Derived from FAQ answer #X]
- [ ] [Derived from inversion principle]
- [ ] [Derived from pre-mortem mitigation]
- [ ] [Derived from FAQ answer #Y]
```

## prfaq-research (Full + Research)

Extends `prfaq-feature` with a Research Base section. Use for features requiring academic/literature grounding.

Additional section after FAQ:

```markdown
## Research Base

### [EV-001] [Citation]
- **Type:** empirical | theoretical | case-study
- **Source:** [DOI/URL]
- **Claim:** [What this evidence says]
- **Confidence:** high | medium | low
- **Relevance:** [How it supports or challenges the approach]

### [EV-002] [Citation]
[Same structure — minimum 3 citations, at least 1 empirical]

### Contradictions
[Any contradictions in the literature and how the spec resolves them]

### Methodology Notes
[Research instruments, statistical methods, study design if applicable]
```

## prfaq-infra (Internal Focus)

Use for infrastructure, tooling, and developer experience changes.

```markdown
---
linear: CIA-XXX
exec: <mode>
status: draft
---

# [Change Name]: Internal Press Release

## What Changed
[One paragraph: what was done and why]

## Before / After

| Aspect | Before | After |
|--------|--------|-------|
| [Metric/behavior] | [Old state] | [New state] |
| [Metric/behavior] | [Old state] | [New state] |

## Impact
[Who is affected and how their workflow changes]

## Rollback Plan
[Exact steps to revert if something goes wrong]

## FAQ
[4-6 questions focused on migration, compatibility, and operational impact]

## Non-Goals
[What this change explicitly does NOT do]

## Acceptance Criteria
- [ ] [Verifiable criterion]
```

## prfaq-quick (Minimal)

Use for small, well-understood changes (bug fixes, config tweaks, minor enhancements).

```markdown
---
linear: CIA-XXX
exec: quick
status: draft
---

# [One-Line Summary]

## Problem
[1-2 sentences]

## Solution
[1-2 sentences]

## Key Questions
1. [Most important question] — [Answer]
2. [Second question] — [Answer]

## Acceptance Criteria
- [ ] [Criterion]
- [ ] [Criterion]
```
