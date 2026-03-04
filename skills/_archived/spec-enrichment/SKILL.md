---
name: spec-enrichment
description: |
  Spec writing methodology combining Working Backwards PR/FAQ with structured PRD. Use when writing a new spec, creating a feature proposal, drafting acceptance criteria, choosing a PR/FAQ template, running a pre-mortem, doing inversion analysis, writing a press release for a proposed change, enriching a spec with ChatPRD personas, checking for duplicate issues before creating new ones, or helping structure any product requirement document.
---

# Spec Enrichment

Every feature begins as a spec. This skill covers the Working Backwards PR/FAQ methodology, structured PRD format, ChatPRD persona integration, and the duplicate detection gate that runs before any issue is created.

## Duplicate Detection Gate

Before creating any Linear issue, run the duplicate detection protocol from the clinearhub-workflow skill's `references/duplicate-detection.md`. This is not optional — creating duplicate issues wastes agent capacity and creates confusion.

Quick check: `list_issues(project: "<project>", query: "<2-3 key terms>", limit: 10)`. If matches found, evaluate before proceeding.

## PR/FAQ Core Principles

The PR/FAQ (Press Release / Frequently Asked Questions) method forces clear thinking by starting from the customer outcome and working backwards to the solution.

### 1. Write the Press Release First

Start from the customer outcome. What would the announcement say if this shipped tomorrow? Maximum one page, understandable by someone with no technical context. Write it before any design or architecture discussion.

### 2. Problem Statement Must Not Mention the Solution

The hardest discipline and the most important. The problem statement articulates pain, friction, or unmet need without hinting at the solution.

Bad: "Users need a dashboard to see analytics."
Good: "Users have no visibility into content performance after publishing. They make decisions based on intuition rather than evidence."

The first version has already decided the solution. The second opens the door to many possible solutions.

### 3. FAQ Forces Rigorous Questioning

Generate 10-15 candidate questions across categories:
- Customer: "How does this work?" / "What if I already use X?"
- Technical: "How does this scale?" / "What are the failure modes?"
- Business: "What does this cost?" / "How do we measure success?"
- Skeptic: "Why now?" / "What alternatives were considered?"

Select the 6-12 hardest to answer. Every selected question needs a substantive answer, not a deflection.

### 4. Pre-Mortem

"Imagine this shipped 6 months ago and failed. What went wrong?"

Generate at least 3 failure modes, each with:
- **Failure scenario**: A specific, plausible story of how this fails
- **Root cause**: The underlying assumption or design flaw
- **Mitigation**: What to change in the spec to prevent this
- **Detection**: How to know this failure is happening before it's catastrophic

### 5. Inversion Analysis

"How would we guarantee this fails?" Then derive design principles from the opposite.

Example: To guarantee failure: "Ship without onboarding. Drop users into a blank screen."
Design principle: "First-run experience must guide users to a meaningful outcome within 60 seconds."

Generate 3-5 inversions. Each produces a design constraint.

### 6. Acceptance Criteria From FAQ and Inversion

ACs are derived from FAQ answers (testable behaviors), inversion principles (verifiable constraints), and pre-mortem mitigations (monitoring requirements). They are not invented separately.

> See [references/acceptance-criteria.md](references/acceptance-criteria.md) for the AC writing guide.

## Template Selection

> See [references/prfaq-templates.md](references/prfaq-templates.md) for all 4 templates.

| Template | Use For | Key Sections |
|----------|---------|-------------|
| `prfaq-feature` | Customer-facing product features | Press Release, 12-Q FAQ, Pre-Mortem, Inversion, AC |
| `prfaq-research` | Features requiring literature grounding | Above + Research Base (3+ citations), Methodology |
| `prfaq-infra` | Internal infrastructure changes | Internal Press Release, Before/After, Rollback plan |
| `prfaq-quick` | Small scope (bug fixes, config changes) | One-Liner, Problem, Solution, Key Questions, AC |

Decision tree: Research-backed? -> `prfaq-research`. Customer-facing? -> `prfaq-feature`. Internal tooling? -> `prfaq-infra`. Small/obvious? -> `prfaq-quick`. When in doubt, use `prfaq-feature`.

## Mandatory Sections

Every spec must include:

### Non-Goals
At least 3 explicit non-goals, each citing why it's excluded. Non-goals must be specific and falsifiable, not vague ("won't be too complex").

### Scale Declaration
- **Personal** (1 user): Simple, local-first, minimal infra
- **Team** (2-10): Shared state, basic auth, simple deployment
- **Organization** (10-100): Multi-tenant, RBAC, monitoring
- **Platform** (100+): Distributed, high-availability, compliance

If declared scale is "Personal" or "Team", reject solutions requiring Kubernetes, message queues, microservices, or custom auth systems. The most common failure mode is enterprise architecture for a personal tool.

## ChatPRD Persona Integration

> See [references/chatprd-personas.md](references/chatprd-personas.md) for the 4 persona templates.

ChatPRD enriches specs via Linear delegation when the `spec:draft` label is applied. It uses 4 business strategy personas to stress-test the spec from different angles. The enriched spec is posted back to the Linear issue with refined AC and child sub-issues.

## Spec Frontmatter

All specs include YAML frontmatter for Linear integration:

```yaml
---
linear: CIA-XXX
exec: quick|tdd|pair|checkpoint|swarm|spike
status: draft
created: YYYY-MM-DDTHH:mm:ssZ
updated: YYYY-MM-DDTHH:mm:ssZ
research: needs-grounding|literature-mapped|methodology-validated|expert-reviewed
---
```

## Interactive Drafting Sequence

When drafting interactively in Cowork, follow this sequence. Do not skip steps.

**Phase 1 — Problem Discovery (3-5 min):** Who is the user? What's frustrating? How do they work around it? What if we do nothing?

**Phase 2 — Press Release (5-10 min):** One-sentence announcement? Single most important benefit? Satisfied user quote?

**Phase 3 — FAQ Generation (10-15 min):** Skeptical engineer question? New user question? Competitor weakness? Most expensive part?

**Phase 4 — Stress Testing (5-10 min):** Three failure stories. How to deliberately break it. What to change to prevent each failure.

**Phase 5 — Acceptance Criteria (5 min):** Derive from FAQ answers + inversion principles. Each criterion independently verifiable.

**Phase 6 — Linear Issue:** Select execution mode, create issue with `spec:draft` label. ChatPRD takes over for enrichment.

## Cross-Skill References

- **clinearhub-workflow** — Overall 6-step flow, where spec enrichment fits (Step 2)
- **issue-lifecycle** — How specs transition through status labels
