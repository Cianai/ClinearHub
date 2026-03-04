# Research Ideation Protocol

> 3-phase hypothesis generation from literature gaps.
> Sources: letitbk/research-ideation, huifer/WellAlly, emaynard/family-history.

## Phase 1: Scope the Domain

Given a research area or existing evidence table (from `/research`), map the known territory:

1. **Extract answered questions** — What distinct research questions has existing evidence already addressed?
2. **Map methodologies** — What approaches are represented? (computational, RCT, observational, theoretical, meta-analysis)
3. **Map populations/contexts** — Which AI models, user populations, task domains, and deployment contexts are covered?
4. **Map temporal coverage** — When were the key studies published? Are findings recent or dated?
5. **Map evidence quality** — Distribution of evidence levels (proven/probable/possible/unresolved)

**Output**: A structured "known territory" map with 5-10 dimensions. Present as a markdown table:

```markdown
| Dimension | Coverage | Gaps |
|-----------|----------|------|
| Models tested | GPT-4, Claude 3 | No open-source models |
| Study design | Mostly computational | No human-subject validation |
| Time range | 2024-2026 | Pre-2024 foundations not reviewed |
| Evidence quality | 60% possible, 30% probable | No proven-level findings |
| ...        | ...      | ...  |
```

## Phase 2: Map Gaps

Systematically identify what is absent from the known territory map. For each gap type, look for specific instances:

### Gap Types

1. **Methodological gaps** — Questions answered only by one approach with no triangulation
   - Example: "Alignment evaluation studied only computationally — no user studies measuring perceived alignment"

2. **Population gaps** — Findings limited to one model family, user group, or deployment context
   - Example: "Constitutional AI studied only on Claude — no cross-architecture replication on open models"

3. **Temporal gaps** — Key findings older than 2 years in a fast-moving field, or no recent replication
   - Example: "RLHF effectiveness benchmarks all pre-date GPT-4 release"

4. **Contradiction voids** — Two or more findings that conflict with no resolution study
   - Example: "Study A finds RLHF improves safety; Study B finds it introduces sycophancy — no study addresses both"

5. **Adjacent territory** — Topics from neighbouring disciplines (clinical psychology, decision theory, HCI, philosophy of mind) not yet applied to AI alignment
   - Example: "Moral foundations theory (Haidt) extensively studied in psychology but not applied to evaluate AI framework responses"

### Output

A prioritised gap list, each entry containing:
- **Gap ID**: G1, G2, ...
- **Type**: methodological / population / temporal / contradiction / adjacent
- **Description**: What is missing
- **What would fill it**: Study design needed (e.g., "Cross-model RCT with 200 participants")
- **Impact if filled**: How it would change Alteri's understanding or features

Rank gaps by impact (high → low).

## Phase 3: Generate & Score Hypotheses

For each top-priority gap (top 3-5), generate a testable hypothesis:

### Hypothesis Format

> **H[N]**: If [intervention/condition], then [measurable outcome], because [mechanism].

Example:
> **H1**: If constitutional AI principles are evaluated against open-source models (Llama 3, Mistral), then alignment scores will differ by >15% from Claude benchmarks, because model architecture constrains which ethical reasoning patterns can be expressed.

### Feasibility Rubric

Score each hypothesis on 4 dimensions (1-3 each, total 4-12):

| Dimension | 1 (Hard) | 2 (Moderate) | 3 (Easy) |
|-----------|----------|--------------|----------|
| **Data availability** | No suitable dataset exists | Dataset exists but requires curation | Ready-to-use dataset available |
| **Compute requirement** | Requires frontier-scale compute | Requires GPU cluster | Runs on consumer hardware or API calls |
| **Timeline** | >12 months | 3-12 months | <3 months |
| **Alteri platform fit** | Tangential (no feature tie-in) | Indirect (informs a feature) | Direct (becomes a feature or evaluation) |

### Tier Classification

| Score | Tier | Action |
|-------|------|--------|
| 10-12 | **Tier 1: Pursue now** | Create ALT issue: `type:spike`, `research:needs-grounding`, assign estimate |
| 6-9 | **Tier 2: Queue** | Add to backlog notes, revisit next quarter |
| 4-5 | **Tier 3: Document only** | Record in research session for future reference |

### Output per Hypothesis

```markdown
### H[N]: [One-line summary]

**Gap addressed**: G[X] ([type])
**Hypothesis**: If [condition], then [outcome], because [mechanism].
**Suggested study design**: [computational / user study / meta-analysis / etc.]
**Feasibility**: Data [1-3] + Compute [1-3] + Timeline [1-3] + Fit [1-3] = **[total]/12**
**Tier**: [1/2/3]
**Alteri integration**: [Which feature/surface this would enhance]
**Suggested ALT issue title**: [verb-first title for Linear]
```

## Quality Guidelines

- **Testability**: Every hypothesis must be falsifiable with a concrete experiment
- **Grounding**: Hypotheses must emerge from identified gaps, not speculation
- **Scope discipline**: Generate 3-5 hypotheses max per session — quality over quantity
- **Existing work check**: Before finalising, search Supabase `research_findings` to confirm the gap hasn't been filled since the evidence table was built
- **Negative results matter**: Include hypotheses that might produce null results — these are still valuable for Alteri's evidence base
