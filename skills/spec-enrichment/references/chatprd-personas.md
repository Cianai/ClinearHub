# ChatPRD Business Strategy Personas

Four personas that ChatPRD applies during spec enrichment. These stress-test the spec from different angles, producing a more robust proposal before implementation begins.

ChatPRD is triggered via Linear triage rule when `spec:draft` label is applied. It uses its connectors (Linear, Notion, GitHub, Google Drive, Granola) to gather context, then applies these personas.

## Persona 1: Working Backwards

**Focus:** Customer outcome clarity

**What it does:**
- Validates that the press release is written from the customer's perspective
- Checks that the problem statement does not mention the solution
- Ensures the "Getting Started" section describes a real user journey
- Verifies the customer quote sounds authentic and specific

**Key questions it asks:**
- "Who specifically is the customer and what job are they hiring this product to do?"
- "If you could only ship one thing, what would make the customer's life measurably better?"
- "What would the customer say in their own words about this problem?"

## Persona 2: Five Whys

**Focus:** Root cause analysis

**What it does:**
- Drills into the problem statement to find the underlying cause
- Ensures the solution addresses root cause, not symptoms
- Identifies whether the stated problem is actually a symptom of a deeper issue

**Method:**
1. "Why is this a problem?" → Surface-level answer
2. "Why does [answer 1] happen?" → Deeper cause
3. "Why does [answer 2] occur?" → Structural reason
4. "Why hasn't [answer 3] been addressed?" → Organizational/systemic factor
5. "Why is [answer 4] the case?" → Root cause

The spec should address the answer to Why #5, not Why #1.

## Persona 3: Pre-Mortem

**Focus:** Failure mode identification

**What it does:**
- Projects forward 6 months and imagines the feature has failed
- Generates 3-5 specific failure stories with root causes
- For each failure, identifies a mitigation that should be in the spec
- Checks whether the spec's existing mitigations are sufficient

**Output structure per failure:**
- Scenario: What went wrong (specific narrative)
- Root cause: Why it went wrong (assumption or design flaw)
- Mitigation: What the spec should include to prevent this
- Detection: How to know it's happening before catastrophic

## Persona 4: Layman Clarity

**Focus:** Accessibility and jargon elimination

**What it does:**
- Reads the spec as a non-technical stakeholder would
- Flags jargon, acronyms, and assumed knowledge
- Rewrites unclear sections in plain language
- Verifies that someone outside the team would understand why this matters

**Key checks:**
- Can a new team member understand the problem in under 2 minutes?
- Does the press release make sense without clicking any links?
- Are all acronyms defined on first use?
- Would a customer understand the value proposition from the headline alone?

## How Personas Flow Into the Spec

ChatPRD runs all four personas and produces:

1. **Refined problem statement** (Working Backwards + Five Whys)
2. **Strengthened FAQ** (Pre-Mortem failures become FAQ questions)
3. **Clarified language** (Layman Clarity rewrites)
4. **Additional acceptance criteria** (derived from Pre-Mortem mitigations)
5. **Child sub-issues** with `auto:implement` label (decomposed from the enriched spec)

The enriched spec is posted back to the Linear issue. Human reviews and approves by moving to `spec:ready`.
