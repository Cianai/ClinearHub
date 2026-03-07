---
name: competitive-brief
description: |
  Generate a competitive analysis snapshot for a product or market segment.
---

# /competitive-brief

Generate a competitive intelligence brief for a specific product, feature, or market segment.

## Usage

```
/competitive-brief [product or topic]
```

## Workflow

1. **Identify the scope** — which product (Alteri, SoilWorx, ClinearHub, Cognito) and what aspect
2. **Gather intelligence** from available connectors:
   - Linear: feature requests mentioning competitors, win/loss notes
   - Perplexity: recent competitor news, product launches, funding
   - monday.com: win/loss data from deals (if available)
3. **Generate the brief**:

```markdown
## Competitive Brief — [Product/Topic] — [Date]

### Market Landscape
[2-3 sentence summary of competitive dynamics]

### Key Competitors
| Competitor | Position | Threat Level | Recent Move |
|-----------|----------|-------------|-------------|
| [name] | [leader/challenger/niche] | High/Med/Low | [what changed] |

### Feature Comparison
| Feature | Us | [Competitor 1] | [Competitor 2] |
|---------|-----|----------------|----------------|
| [feature] | [status] | [status] | [status] |

### Our Differentiation
- [differentiator 1 with evidence]

### Recommended Actions
- [ ] [response to competitive development]
```

## Connector Dependencies

| Source | Tier | Access |
|--------|------|--------|
| Linear | Core | R |
| Perplexity | Enhanced | R |
| monday.com | Enhanced | R |
