---
name: content-plan
description: Generate a monthly content calendar sourced from the roadmap, research findings, and client conversations.
---

# /content-plan

Generate a content calendar for the upcoming month, sourcing topics from shipped features, research findings, and client conversations.

## Usage

```
/content-plan [month] [product focus: cognito|alteri|soilworx|clinearhub|all]
```

## Workflow

1. **Gather source material** from available connectors:
   - Linear: recently shipped features (Done in last 30 days), upcoming milestones
   - Granola: client conversation themes, recurring questions
   - Perplexity: industry trends, competitor content gaps
   - PostHog: most-used features (content about what users already love)
2. **Match content to brand voice** (see `content-marketing` skill):
   - Cognito: professional, outcome-focused
   - Alteri: academic-adjacent, rigorous
   - SoilWorx: practical, industry-specific
   - ClinearHub: technical but accessible
3. **Generate the calendar**:

```markdown
## Content Plan — [Month Year]

### Theme: [monthly theme aligned to roadmap or market trend]

| # | Title | Channel | Voice | Status | Owner | Due |
|---|-------|---------|-------|--------|-------|-----|
| 1 | [title] | Blog/LinkedIn/Email/Gamma deck | [brand] | Idea/Draft/Review/Published | [person] | [date] |

### Source Material
- Shipped: [CIA-XXX: feature name](url), [ALT-XXX: feature name](url)
- Research: [paper title or finding]
- Client insights: [theme from Granola meetings]
- Trends: [industry trend from Perplexity]

### Content Briefs

#### [Content #1 Title]
- **Angle:** [what makes this interesting]
- **Audience:** [who reads this]
- **Key messages:** [2-3 bullets]
- **CTA:** [what the reader should do next]
- **Deadline:** [date]
```

4. **Create Linear issues** for each content piece (optional, if user approves):
   - Team: CIA (cross-cutting) or relevant sub-team
   - Labels: `type:chore`, `spec:ready`
   - Project: relevant product project

## Connector Dependencies

| Source | Tier | Access |
|--------|------|--------|
| Linear | Core | R (shipped features), W (optional issue creation) |
| GCal | Supplementary | R (scheduling context) |
| Gamma | Supplementary | W (deck generation) |
| Granola | Supplementary | R (meeting insights) |
| Perplexity | Enhanced | R (trend research) |
| PostHog | Enhanced | R (feature adoption data) |
