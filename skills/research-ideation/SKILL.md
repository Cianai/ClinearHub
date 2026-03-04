---
name: research-ideation
description: |
  Hypothesis and research question generation for the Alteri platform.
  Use when generating new research questions, mapping literature gaps to hypotheses,
  brainstorming alignment research directions, or evaluating the feasibility of
  a proposed research question. Triggers for: "generate hypotheses", "research ideas",
  "what should we study", "gap analysis", "ideation", "brainstorm research".
  Sources: letitbk/research-ideation (scope-map-generate pattern),
  huifer/WellAlly (3-tier feasibility classification),
  emaynard/family-history (evidence gap detection).
---

# Research Ideation

Generates testable hypotheses and research questions from literature gaps. Designed to follow a `/research` session — uses the evidence table as input.

## Usage

```
/clinearhub:research-ideation "AI alignment evaluation methods"
```

Or as a follow-up to `/research`:

```
/clinearhub:research      → produces evidence table
/clinearhub:research-ideation  → uses the session's evidence as input
```

## Protocol

See [references/ideation-protocol.md](references/ideation-protocol.md) for the full 3-phase methodology.

**Phase 1: Scope the Domain** — Map the known territory from existing evidence.
**Phase 2: Map Gaps** — Systematically identify what is absent (methodological, population, temporal, contradiction, adjacent territory).
**Phase 3: Generate & Score Hypotheses** — Produce testable hypotheses with feasibility rubric (4-12 scale).

## Output

Each hypothesis includes:
- Testable statement: "If [condition], then [outcome], because [mechanism]"
- Feasibility score (4-12) across 4 dimensions
- Tier classification: 10-12 = pursue now, 6-9 = queue, 4-5 = document only
- Suggested study design and Alteri platform integration point

Tier 1 hypotheses automatically suggest ALT issues with `type:spike` + `research:needs-grounding` labels.

## Integration

- **Input**: Evidence tables from `research-intelligence` skill or `/research` sessions
- **Output**: Hypotheses → ALT spike issues (via Linear), research questions → future `/research` queries
- **Data**: Queries `research_findings` and `research_papers` in Supabase for existing coverage
