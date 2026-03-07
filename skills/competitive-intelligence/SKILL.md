---
name: competitive-intelligence
description: |
  Competitive analysis, market positioning, competitor research, battlecards, competitive landscape, market intelligence, win/loss analysis, feature comparison, market mapping, or any question about how our products compare to alternatives. Also triggers for questions about Product Hunt launches, competitor pricing, or market trends.
---

# Competitive Intelligence

Structured competitive analysis framework for all Claudian products (Alteri, SoilWorx, ClinearHub, Cognito). Covers direct competitor tracking, market positioning, intelligence gathering, and actionable competitive briefs.

## Competitive Analysis Framework

Classify competitors into three tiers to avoid tunnel vision on direct rivals:

| Tier | Definition | Example |
|------|-----------|---------|
| **Direct competitors** | Products competing for the same users and budget | Another AI alignment research tool vs. Alteri |
| **Indirect competitors** | Alternative approaches to the same underlying problem | General-purpose LLM chat vs. Alteri's structured elicitation |
| **Substitute solutions** | Manual processes or maintaining the status quo | Spreadsheets + email vs. SoilWorx distributor finder |

Always map all three tiers. The biggest threat is often a substitute solution, not a named competitor.

## Analysis Template

For each competitor, capture the following dimensions:

| Dimension | Details |
|-----------|---------|
| Product | Name, URL, tagline |
| Target segment | Who they serve |
| Pricing | Model, tiers, free tier? |
| Key features | Top 3-5 differentiators |
| Weaknesses | Known gaps or complaints |
| Market position | Leader/challenger/niche |
| Recent moves | Last 90 days: launches, funding, pivots |

**Data quality rule:** Every cell must cite a source (URL, date, or "internal observation"). Unsourced claims are flagged as assumptions.

## Positioning Matrix

Map competitors on two axes relevant to the product. Choose axes that highlight where we differentiate:

| Product | Axis X | Axis Y |
|---------|--------|--------|
| **Alteri** | Research Depth | User Accessibility |
| **SoilWorx** | Data Coverage | Ease of Use |
| **ClinearHub** | Automation Level | Methodology Depth |

Plot each competitor (including us) on the matrix. The goal is to find the quadrant where we have defensible positioning and identify white space.

## Intelligence Sources

| Source | Method | Frequency |
|--------|--------|-----------|
| Perplexity | Competitor news, product updates, funding rounds. Code: Perplexity MCP. Cowork: Claude built-in web search. | Per-request |
| Clay | Competitor tech stack, funding data, buying intent signals, LinkedIn enrichment (100+ sources) | Per-request |
| monday.com CRM | Win/loss data from Deals board (Closed Won / Closed Lost) | Quarterly |
| Linear | Feature requests mentioning competitors, client feedback | Ongoing |
| PostHog | User behavior patterns suggesting churn risk or feature gaps | Monthly |
| Product Hunt / HN | New entrant monitoring, launch analysis | Weekly |

### Source Priority

1. **First-party data** (Linear issues, PostHog events, monday.com deals) — highest signal
2. **Public filings and announcements** (funding, pricing pages, changelogs) — verified
3. **Web research** (Perplexity, HN discussions) — useful but verify claims
4. **Anecdotal** (user feedback, sales conversations) — directional only

## Competitive Brief Output Format

Use this template for all competitive briefs. Store as a Linear Document attached to the relevant project.

```markdown
## Competitive Brief — [Product] — [Date]

### Market Landscape
[2-3 sentence summary of competitive dynamics]

### Key Competitors
| Competitor | Position | Threat Level | Recent Move |
|-----------|----------|-------------|-------------|
| [name] | [position] | High/Med/Low | [what changed] |

### Our Differentiation
- [differentiator 1 with evidence]
- [differentiator 2 with evidence]

### Action Items
- [ ] [response to competitive move]
```

**Threat Level Criteria:**
| Level | Definition |
|-------|-----------|
| **High** | Competing for same segment, strong product, growing fast |
| **Medium** | Overlap exists but different positioning or weaker product |
| **Low** | Tangential overlap, early-stage, or declining |

## Connector Dependencies

| Source | Tier | Access | Notes |
|--------|------|--------|-------|
| Linear | Core | R | Feature requests, client feedback, competitor mentions in issues |
| Perplexity | Enhanced | R | Web research, competitor news, market trends (Code: MCP; Cowork: built-in web search) |
| monday.com CRM | Enhanced | R | Win/loss data from Deals board (Closed Won / Closed Lost groups) |
| PostHog | Enhanced | R | User behavior patterns, churn signals |
| Clay | Supplementary | R | Competitor enrichment: tech stack, funding, buying intent, LinkedIn profiles |

## Cross-Skill References

- **roadmap-management** — Competitive insights feed into initiative prioritization and trade-off analysis
- **data-analytics** — PostHog queries for competitive churn signals
- **content-marketing** — Competitive positioning informs brand voice and differentiation messaging
