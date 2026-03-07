---
name: content-marketing
description: |
  Content marketing, brand voice, content calendar, content planning, blog posts, LinkedIn posts, newsletters, case studies, pitch decks, release notes, writing tone, content strategy, multi-channel content, email campaigns, campaign creation, audience segmentation, campaign analytics, or any question about creating and scheduling marketing content for Cognito, Alteri, SoilWorx, or ClinearHub. Also triggers for questions about brand guidelines, writing style, audience targeting, monday.com Campaigns, email marketing, or /campaign-create and /campaign-report.
---

# Content Marketing

Brand voice guidelines, content planning, multi-channel content strategy, and email campaigns for Cognito and all Claudian products. Covers the full content lifecycle from topic sourcing through publishing, campaign execution, and measurement.

## Brand Voice Guidelines

Each product has a distinct voice matched to its audience. Never blend voices across products in a single piece of content.

### Cognito (consultancy)
- **Tone:** Professional, authoritative, practical
- **Audience:** Business leaders, decision-makers, executives
- **Style rules:** Avoid jargon. Lead with outcomes, not technology. Use concrete numbers and case study references. Short paragraphs. Active voice.
- **Example:** "Our clients reduced decision latency by 40% in the first quarter" (not "We leverage AI to optimize decision-making processes")

### Alteri (research platform)
- **Tone:** Academic-adjacent, rigorous, exploratory
- **Audience:** Researchers, ethicists, alignment-focused practitioners
- **Style rules:** Citations expected. Hedging language appropriate ("suggests", "indicates"). Technical precision matters. Longer-form acceptable.
- **Example:** "Schwartz value mapping reveals systematic preference shifts under deliberative prompting (n=847, p<0.01)" (not "Our AI understands your values")

### SoilWorx (distributor finder)
- **Tone:** Practical, efficient, industry-specific
- **Audience:** Procurement teams, operations managers, supply chain professionals
- **Style rules:** Straightforward language. Focus on time saved and coverage. Industry terminology is fine. Short, scannable content.
- **Example:** "Find verified distributors in 12 countries. Upload your product list, get matched suppliers in minutes." (not "Revolutionizing global supply chain connectivity")

### ClinearHub (PM plugin)
- **Tone:** Technical but accessible, methodology-focused
- **Audience:** Product managers, engineering leaders, technical PMs
- **Style rules:** Process-oriented. Reference specific workflow patterns. Show, don't tell (screenshots, examples). Acknowledge complexity without drowning in it.
- **Example:** "The 6-phase pipeline moves specs from ChatPRD through autonomous implementation — here's how triage routing actually works" (not "AI-powered project management")

## Content Types

| Type | Channel | Frequency | Purpose |
|------|---------|-----------|---------|
| Blog post | Website/Medium | 2/month | Thought leadership, SEO |
| LinkedIn post | LinkedIn | 2/week | Professional visibility |
| Case study | Website | 1/quarter | Social proof |
| Newsletter | monday.com Campaigns | 1/month | Audience nurture |
| Release notes | Linear/GitHub | Per release | Product updates |
| Pitch deck | Gamma | Per prospect | Sales enablement |
| Email campaign | monday.com Campaigns | As needed | Lead nurture, onboarding, re-engagement |

### Content-to-Voice Mapping

| Type | Primary Voice | Secondary Voice |
|------|--------------|----------------|
| Blog post | Cognito or Alteri (depends on topic) | -- |
| LinkedIn post | Cognito | ClinearHub (for PM audience) |
| Case study | Cognito | -- |
| Newsletter | Cognito | All products (section-specific) |
| Release notes | Product-specific | -- |
| Pitch deck | Cognito | Product-specific slides |
| Email campaign | Audience-appropriate | -- |

## monday.com Campaigns

monday.com Campaigns (included with CRM Pro) is the primary email marketing channel. Provides CRM-native segmentation, campaign execution, and analytics tied to deal metrics.

### Capabilities

| Feature | What It Does |
|---------|-------------|
| **CRM Segmentation** | Auto-refreshing audience segments from CRM contact properties (stage, role, industry, tags) |
| **Email Builder** | Drag-and-drop email creation with templates |
| **Campaigns AI** | Email copy generation, subject line optimization, send-time optimization |
| **Analytics** | Open rate, click rate, unsubscribe rate — tied to CRM deal metrics |
| **Automation Triggers** | CRM event → campaign enrollment (deal won, lead contacted, contact inactive) |

### Capacity (CRM Pro)

- 2,000 marketing contacts
- 20,000 emails/month (10× send capacity)

### Campaign Types

| Campaign | Trigger | Audience Segment | Goal |
|----------|---------|-----------------|------|
| **Lead Nurture** | Lead status → Contacted | New leads | Move to Qualifying |
| **Onboarding** | Deal stage → Closed Won | New clients | Smooth activation |
| **Re-engagement** | Contact inactive > 60 days | Churned or dormant contacts | Reactivate relationship |
| **Newsletter** | Monthly schedule | All active contacts | Thought leadership |
| **Product Update** | Feature shipped (`spec:complete`) | Product-specific segment | Feature adoption |
| **Event Invitation** | Ad hoc | Role/industry segment | Registration |

### /campaign-create Action

Create an email campaign from Cowork via monday.com MCP.

1. Ask for: campaign name, type, target segment, subject line, key message
2. Define audience segment using CRM properties:
   - Stage (Contact Made, Active, Needs Follow-Up)
   - Role (user, advisor, researcher, investor, partner)
   - Tags, industry, source
3. `all_monday_api` to create campaign with segment and schedule
4. Optionally use Campaigns AI for copy generation and send-time optimization
5. Confirm campaign details, audience size, and scheduled send time

### /campaign-report Action

Campaign performance tied to CRM deal metrics.

1. `all_monday_api` to query campaign analytics
2. Report: open rate, click rate, unsubscribe rate, conversions
3. Cross-reference with CRM: did campaign recipients advance in pipeline?
4. Identify: top-performing content, segments with highest engagement
5. Present inline as campaign performance report

### Campaign Automations (monday.com Native)

| Trigger | Action |
|---------|--------|
| Lead status → Contacted | Add to lead nurture email sequence |
| Deal stage → Closed Won | Add to onboarding campaign |
| Contact inactive > 60 days | Add to re-engagement campaign |
| New blog post published | Trigger newsletter campaign |
| Contact tag added (e.g., "webinar-interest") | Add to event campaign |

## Content Calendar Process

### 1. Topic Sourcing
Pull content ideas from multiple internal sources:
- **Linear roadmap** — Shipped features worth announcing (`spec:complete` issues)
- **Customer conversations** — Insights from monday.com AI Notetaker transcripts and Granola meeting notes
- **Research findings** — Alteri pipeline outputs (papers, artifacts, connections)
- **Industry trends** — Perplexity research on market movements
- **Campaign analytics** — High-engagement topics from monday.com Campaigns

### 2. Content Brief
For each piece, document before writing:
- **Title** (working, may change)
- **Angle** — What makes this interesting now?
- **Audience** — Which product voice applies
- **Channel** — Where it publishes
- **Key messages** — 2-3 takeaways for the reader
- **CTA** — What should the reader do next?
- **Campaign tie-in** — Will this feed an email campaign?
- **Deadline** — Publish date

### 3. Draft
Write in the appropriate brand voice (see guidelines above). First drafts can be AI-assisted but must be reviewed for voice consistency.

### 4. Review
Apply the **humanizer** skill to remove AI patterns (filler phrases, hedge stacking, generic conclusions). Check for brand voice adherence.

### 5. Publish
Schedule across channels. LinkedIn posts should go out Tuesday-Thursday 8-10am for maximum reach. Email campaigns sent at Campaigns AI recommended times.

### 6. Track
- **Content engagement**: PostHog for page views, time on page, scroll depth, CTA clicks
- **Campaign performance**: monday.com Campaigns analytics (open rate, clicks, conversions)
- **Pipeline impact**: Cross-reference campaign recipients with CRM deal progression

## Content Plan Output Format

Use this template for monthly content plans. Store as a Linear Document attached to the relevant project.

```markdown
## Content Plan — [Month Year]

### Theme: [monthly theme aligned to roadmap]

| # | Title | Channel | Audience | Campaign? | Status | Owner | Due |
|---|-------|---------|----------|-----------|--------|-------|-----|
| 1 | [title] | [channel] | [audience] | [Yes/No] | Draft/Review/Published | [person] | [date] |

### Email Campaigns
| Campaign | Type | Segment | Scheduled | Status |
|----------|------|---------|-----------|--------|
| [name] | [nurture/onboarding/newsletter] | [segment] | [date] | Draft/Scheduled/Sent |

### Source Material
- Shipped features: [CIA-XXX, ALT-XXX]
- Research findings: [paper titles or Supabase IDs]
- Client conversations: [monday.com AI Notetaker / Granola refs]
- Campaign insights: [top-performing content from last month]
```

## Connector Dependencies

| Source | Tier | Access | Notes |
|--------|------|--------|-------|
| Linear | Core | R | Roadmap items, shipped features, release tracking |
| monday.com CRM | Enhanced | R | CRM segments for campaign targeting, contact properties |
| monday.com Campaigns | Enhanced | R/W | Email campaigns, audience segments, analytics |
| GCal | Supplementary | R | Publishing schedule, content deadlines |
| Gamma | Supplementary | W | Deck and document generation for pitch materials |
| Granola | Supplementary | R | Meeting insights for content ideas and case studies |
| Perplexity | Enhanced | R | Trend research, competitor content analysis (Code: MCP; Cowork: built-in web search) |
| PostHog | Enhanced | R | Content engagement metrics, funnel analysis |
| Slack | Supplementary | W | Content distribution, team notifications (DEFERRED — add when team grows) |

## Cross-Skill References

- **crm-management** — CRM segments feed campaign targeting, contact data for personalization
- **business-development** — Case studies from successful client engagements, pipeline events trigger campaigns
- **customer-ops** — Support patterns trigger re-engagement campaigns
- **competitive-intelligence** — Competitive positioning informs differentiation messaging
- **roadmap-management** — Shipped features and initiative updates as content source material
- **wrap-up** — Session summaries can surface content-worthy accomplishments
