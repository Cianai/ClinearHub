# ChatPRD Templates — Migration & Creation Guide

> **Purpose:** Reference for creating/migrating templates in ChatPRD's web UI at https://www.chatprd.ai/docs/create-and-use-templates. These templates are NOT used directly by ClinearHub — they are configured in ChatPRD and triggered when `spec:draft` label is applied to Linear issues.

## Existing Templates to Migrate

These 4 PRFAQ templates are currently archived at `skills/_archived/spec-enrichment/references/prfaq-templates.md`. Migrate them to ChatPRD's template system.

### 1. Feature Spec (Working Backwards)

**ChatPRD template name:** `Feature Spec (Working Backwards)`
**Linear label:** `template:prfaq-feature`

```markdown
# [Feature Name]

## Press Release
[Write as if announcing to customers. 1-2 paragraphs. Focus on the customer benefit, not the technology.]

## FAQ

### Customer Questions
1. [Question a customer would ask]
   - [Answer]

### Technical Questions
1. [Question about implementation]
   - [Answer]

### Business Questions
1. [Question about viability/ROI]
   - [Answer]

### Skeptic Questions
1. [Question challenging the premise]
   - [Answer]

## Pre-Mortem
[Project 6 months forward. What went wrong? List 3-5 failure scenarios with root cause, mitigation, and early warning signals.]

## Inversion Analysis
[What would we do if we wanted this to fail? List the anti-patterns, then invert them into success criteria.]

## Non-Goals (minimum 3)
- [Specific, falsifiable statement of what this does NOT do]

## Scale Declaration
- [ ] Personal  [ ] Team  [ ] Organization  [ ] Platform

## Acceptance Criteria (6-12)
- [ ] [Criterion derived from FAQ answers]
```

### 2. Research Feature Spec

**ChatPRD template name:** `Research Feature Spec`
**Linear label:** `template:prfaq-research`

```markdown
# [Feature Name]

## Press Release
[As above]

## Research Base
### Citations (minimum 3, at least 1 empirical)
1. [Author et al. (Year). Title. Journal. DOI/URL]
   - Key finding: [what this study shows]
   - Relevance: [why it matters for this feature]

### Contradictions
[Any findings that challenge the proposed approach]

### Methodology Notes
[Research methods relevant to the feature's design]

## FAQ
[Same 4-category structure as Feature Spec]

## Pre-Mortem
[Same as Feature Spec]

## Inversion Analysis
[Same as Feature Spec]

## Non-Goals (minimum 3)
- [Specific, falsifiable]

## Scale Declaration
- [ ] Personal  [ ] Team  [ ] Organization  [ ] Platform

## Acceptance Criteria (8-15)
- [ ] [Criterion]
```

### 3. Infrastructure Change

**ChatPRD template name:** `Infrastructure Change`
**Linear label:** `template:prfaq-infra`

```markdown
# [Change Name]

## Internal Press Release
[1 paragraph explaining the change and its impact to the team]

## Before / After

| Dimension | Before | After |
|-----------|--------|-------|
| [metric 1] | [current] | [expected] |
| [metric 2] | [current] | [expected] |

## Impact Assessment
- **Affected systems:** [list]
- **Affected teams:** [list]
- **Migration required:** Yes/No
- **Downtime expected:** Yes/No

## Rollback Plan
[Step-by-step rollback procedure if the change fails]

## FAQ (4-6 questions)
1. [Question]
   - [Answer]

## Non-Goals
- [What this change does NOT address]

## Acceptance Criteria (4-8)
- [ ] [Criterion]
```

### 4. Quick Change

**ChatPRD template name:** `Quick Change`
**Linear label:** `template:prfaq-quick`

```markdown
# [Change Name]

**One-line summary:** [What this does in one sentence]

## Problem
[1-2 sentences describing the problem]

## Solution
[1-2 sentences describing the fix]

## Key Questions
1. [Question]
2. [Question]

## Acceptance Criteria (2-4)
- [ ] [Criterion]
```

---

## New Templates to Create

### 5. Spike Investigation

**ChatPRD template name:** `Spike Investigation`
**When to use:** For `type:spike` issues that need structured research

```markdown
# [Investigation Title]

## Research Question
[Clear, specific question this spike aims to answer]

## Hypothesis
[What we expect to find and why]

## Method
- **Approach:** [How we'll investigate — code spike, literature review, prototype, user interviews]
- **Tools/data sources:** [What we'll use]
- **Constraints:** [Time-box, budget, scope limits]

## Expected Output
- [ ] [Deliverable 1 — e.g., decision document, prototype, comparison matrix]
- [ ] [Deliverable 2]

## Time-box
- **Estimate:** [hours/days]
- **Hard stop:** [date — after this, document findings as-is]

## Success Criteria
- [ ] Research question answered with evidence
- [ ] Recommendation documented with trade-offs
- [ ] Next steps identified (build, defer, or abandon)
```

### 6. Cognito Client Proposal

**ChatPRD template name:** `Client Proposal`
**When to use:** When Cognito takes on a new client engagement

```markdown
# Proposal — [Client Name]

## Client Context
- **Company:** [name, industry, size]
- **Contact:** [name, role]
- **Source:** [referral, inbound, outbound]
- **Current situation:** [what they do now]

## Problem Assessment
[2-3 paragraphs describing the client's challenges, grounded in discovery conversations]

## Proposed Solution
### Approach
[What we'll do and how]

### Deliverables
| # | Deliverable | Timeline | Description |
|---|-------------|----------|-------------|
| 1 | [deliverable] | [week/month] | [what it includes] |

### Out of Scope
- [What we won't do]

## Timeline
| Phase | Duration | Milestone |
|-------|----------|-----------|
| Discovery | [time] | [output] |
| Build | [time] | [output] |
| Deliver | [time] | [output] |

## Pricing
| Item | Rate | Estimate | Total |
|------|------|----------|-------|
| [work item] | [rate] | [hours/days] | [amount] |

**Total:** [amount]
**Payment terms:** [terms]

## Success Metrics
- [How we'll measure success for the client]
- [Quantifiable where possible]

## Next Steps
1. [Action item, owner, date]
```

### 7. GTM Launch Brief

**ChatPRD template name:** `GTM Launch Brief`
**When to use:** When launching a new feature or product to market

```markdown
# GTM Launch Brief — [Feature/Product]

## Target Segment
- **Who:** [specific audience]
- **Pain point:** [what they struggle with]
- **Current alternative:** [what they do today]

## Positioning
**For** [target audience] **who** [need/pain], **[product]** **is a** [category] **that** [key benefit]. **Unlike** [alternative], **we** [differentiator].

## Channels
| Channel | Content Type | Owner | Launch Date |
|---------|-------------|-------|-------------|
| [channel] | [what we'll publish] | [person] | [date] |

## Timeline
| Date | Action | Owner |
|------|--------|-------|
| [date] | [action] | [person] |

## Success Metrics
| Metric | Target | Measurement |
|--------|--------|-------------|
| [metric] | [number] | [how we track] |

## Risks
| Risk | Impact | Mitigation |
|------|--------|-----------|
| [risk] | High/Med/Low | [what we'll do] |
```

### 8. Customer Feedback Synthesis

**ChatPRD template name:** `Feedback Synthesis`
**When to use:** When synthesizing customer/user feedback into actionable items

```markdown
# Feedback Synthesis — [Topic/Period]

## Sources
| Source | Volume | Period |
|--------|--------|--------|
| [support tickets, interviews, surveys, etc.] | [count] | [date range] |

## Theme Clusters

### Theme 1: [Name]
- **Frequency:** [N mentions]
- **Sentiment:** Positive/Negative/Mixed
- **Representative quotes:**
  - "[quote]" — [source]
- **Implication:** [what this means for the product]

### Theme 2: [Name]
[Same structure]

## Priority Matrix

| Theme | Frequency | Impact | Effort | Priority |
|-------|-----------|--------|--------|----------|
| [theme] | High/Med/Low | High/Med/Low | High/Med/Low | P1/P2/P3 |

## Recommendations
1. **[Action]** — addresses [theme], estimated [effort]
2. **[Action]** — addresses [theme], estimated [effort]

## Follow-up Actions
- [ ] [Create Linear issue for recommendation 1]
- [ ] [Schedule follow-up with customer X]
- [ ] [Update roadmap based on findings]
```

---

## ChatPRD Personas

### Existing (configured in ChatPRD)
1. **Working Backwards** — validates customer outcome clarity
2. **Five Whys** — drills to root cause
3. **Pre-Mortem** — identifies failure modes
4. **Layman Clarity** — eliminates jargon

### New Personas to Add
5. **Revenue Lens** — validates monetization model, pricing, unit economics. Apply to GTM and pricing specs.
6. **User Empathy** — validates from user's emotional journey. Apply to feature specs touching UX.
7. **Ops Feasibility** — validates operational burden for small teams. Apply to any spec for 3-person team context.
