---
name: business-development
description: |
  Prospect research, call preparation, client management, competitive battlecards, pipeline tracking, business development, sales process, client lifecycle, BANT qualification, proposal creation, or any question about consultancy operations and client relationships. Also triggers for questions about monday.com CRM data, deal stages, pipeline health, or client management.
---

# Business Development

Consultancy business development: prospect research, call preparation, client management, competitive positioning, and pipeline tracking. This skill provides structured workflows for every stage of the client lifecycle, from initial outreach through retention and expansion.

> **Claudian default:** This skill is configured for Cognito AI Consultancy (3-person team, AI strategy/implementation/integration services). Marketplace users should adapt company name, service catalog, and team size references to their own consultancy.

## Client Lifecycle

### 1. Prospect

Research the target company and identify pain points before any outreach.

**Actions:**
- **Tier 1 (Crunchbase, built-in):** Check monday.com Accounts — Crunchbase auto-enriches company data (funding, industry, employee count, revenue). Free, 1K item lifetime cap.
- **Tier 2 (Lusha, marketplace):** For contact enrichment (email, phone, job title, seniority), add LinkedIn URL → Lusha auto-enriches. Free tier: 50 credits/month.
- **Tier 3 (Clay, high-volume):** If deeper research needed (tech stack, buying intent, 100+ sources), use Clay MCP for one-time enrichment. For ongoing pipeline (750+/month), route via n8n → monday.com.
- **Fallback (Perplexity):** Use Perplexity (Code: MCP; Cowork: built-in web search) for company news, recent developments, industry context
- Check monday.com Contacts + Accounts boards for existing records or prior interactions
- Search Linear for any historical client project with the same company or industry
- Draft personalized outreach that references a specific pain point or opportunity

**Output:** Prospect brief with company overview, identified pain points, and tailored outreach message.

### 2. Qualify

Apply the BANT framework to assess fit before investing in a proposal.

| Dimension | Key Questions | Green Flag | Red Flag |
|-----------|--------------|------------|----------|
| **Budget** | What is their budget range? Have they allocated funds? | Defined budget, prior AI spend | "No budget yet", "exploring options" |
| **Authority** | Who makes the decision? Are we talking to them? | Direct access to decision-maker | Multiple approval layers, no executive sponsor |
| **Need** | Is this a real pain point or a nice-to-have? | Quantified cost of problem, urgency | Vague interest, "just exploring AI" |
| **Timeline** | When do they need a solution? What is driving the timeline? | Defined deadline, external driver | "Sometime this year", no urgency |

**Scoring:** 4/4 = pursue aggressively, 3/4 = pursue with caution (identify the gap), 2/4 = nurture only, 1/4 or 0/4 = decline politely.

**Fit Assessment** (beyond BANT):
- Does the project align with your consultancy's capabilities (AI strategy, implementation, integration)?
- Is the project scope realistic for your team size?
- Does the client's industry offer portfolio value or repeat opportunity?

### 3. Propose

Structure every proposal consistently to build trust and enable comparison.

**Proposal Structure:**
1. **Context** — Client situation, how we understand their challenge (proves we listened)
2. **Problem** — Specific pain points with quantified impact where possible
3. **Solution** — What we will build/deliver, broken into phases
4. **Timeline** — Phase durations, milestones, key dates
5. **Pricing** — Per-phase or fixed, with clear scope boundaries
6. **Success Metrics** — How both parties will measure success (KPIs, acceptance criteria)

**Tooling:**
- Use Gamma (if connected) for deck generation from proposal outline
- Store proposal docs in Google Drive (if connected) for client sharing
- Track the deal stage in monday.com Deals board
- Reference Products & Services board for service catalog and pricing

### 4. Win

When a proposal is accepted, execute the onboarding sequence.

**Onboarding Checklist:**
- [ ] Create Linear project under your consultancy's Linear project with client name
- [ ] Create kickoff meeting agenda (see Call Prep Format below)
- [ ] Set up communication channels (email, Slack/Teams as appropriate)
- [ ] Define milestone schedule in Linear
- [ ] Establish reporting cadence (weekly status, monthly review)
- [ ] Document key contacts, roles, and escalation paths in Linear project description
- [ ] Update monday.com: Deal → "Closed Won", Contact → "Active", Account → "Active"
- [ ] monday.com automation creates Client Projects item and triggers welcome campaign

### 5. Deliver

Track all client work through Linear with structured status updates.

**Delivery Pattern:**
- Each deliverable = Linear issue under the client's Linear project
- Milestone reviews at agreed checkpoints
- Status updates via `/stakeholder-update` skill (adapts voice for client audience)
- Client/sales calls: monday.com AI Notetaker → auto-feeds Activities board + deal timeline
- Internal meetings: Granola (if connected) → action items synced to Linear via Claude

**Escalation Rules:**
- Blocked > 2 business days = escalate to Cian
- Scope change request = new issue, re-estimate, client approval before work begins
- Budget risk (>80% consumed with work remaining) = immediate flag

### 6. Retain

Proactive relationship management after delivery completes.

**Quarterly Business Review (QBR) Agenda:**
1. Results vs. success metrics from proposal
2. ROI analysis (quantified where possible)
3. Lessons learned and process improvements
4. Upcoming opportunities or expansion areas
5. Satisfaction check and feedback

**Expansion Signals:**
- Client asks "can you also..." during delivery
- New department or team member joins meetings
- Client references Cognito positively to peers
- Usage metrics (if applicable) exceed projections

**Referral Request:** After a successful QBR with positive feedback, ask: "Is there anyone in your network facing similar challenges who might benefit from a conversation?"

## Data Sources

| Source | What It Provides | Connector |
|--------|-----------------|-----------|
| monday.com CRM (required) | Contacts, deals, activities, accounts, pipeline stages, client projects | OAuth |
| Linear (required) | Client project issues, milestones, deliverables | OAuth |
| Clay (if connected) | Deep prospect enrichment: tech stack, funding, buying intent, LinkedIn (100+ sources) | OAuth |
| Stripe (if connected) | Payment status, invoice history, subscription data (native monday.com integration) | OAuth |
| Granola (if connected) | Internal meeting notes, transcript highlights, action items | OAuth |
| monday.com AI Notetaker | Client call transcripts → auto-feeds Activities board | Native (monday.com UI) |
| Perplexity (if connected) | Company research, industry trends, competitor intel (Code: MCP; Cowork: built-in web search) | stdio / built-in |
| GCal (if connected) | Upcoming meetings, scheduling context | OAuth |
| Gmail (if connected) | Client email threads, follow-up tracking | OAuth |
| Google Drive (if connected) | Proposals, SOWs, shared deliverables | OAuth |
| Gamma (if connected) | Presentation generation from outlines | OAuth |

When a connector is not available, note the gap and suggest manual alternatives. Never fail silently — always tell the user what additional context would be available with a connected source.

## Meeting Transcription

| Meeting Type | Tool | Destination | Why |
|-------------|------|-------------|-----|
| Client/sales calls | monday.com AI Notetaker | Auto-feeds CRM Activities + deal timeline | Native CRM integration, zero-touch |
| Internal team meetings | Granola | Claude Cowork → Linear action items | Better for internal context, decision capture |
| Research/advisory | Granola | Claude Cowork → Notion knowledge hub | Richer context for research synthesis |

No direct Granola ↔ monday.com integration exists. Zapier bridge (Granola → monday.com Activities) is possible but lower priority.

## Call Prep Format

Generate this format before any client or prospect meeting.

```markdown
## Call Prep — [Client Name] — [Date]

### Context
- Company: [name], [industry], [size] (from monday.com Accounts board)
- Relationship: [prospect/active client/renewal]
- Last interaction: [date, summary from monday.com Activities / Granola]
- Deal: [stage, value] (from monday.com Deals board)

### Open Items
- [CIA/ALT/SWX-XXX: Title](url) — [status, what client expects]

### Agenda (suggested)
1. [topic] — [5 min]
2. [topic] — [10 min]

### Talking Points
- [key point with supporting data]

### Questions to Ask
- [discovery/qualifying question]

### Follow-up Actions
- [ ] [action item, owner, deadline]
```

**Prep Sources** (check in order):
1. GCal — confirm meeting time, attendees, any agenda in invite
2. monday.com — Contact details, Account info, deal stage, last activity, AI Notetaker transcripts
3. Granola — previous internal meeting transcript, action items from last call
4. Linear — open issues under client's project
5. Perplexity — recent company news, industry developments

## Competitive Battlecard Format

Use this structure for any competitor analysis or positioning work.

```markdown
## [Competitor Name] Battlecard

### Positioning
- Their pitch: [what they say]
- Our differentiation: [why we're different]

### Strengths (theirs)
- [strength 1]

### Weaknesses (theirs, opportunity for us)
- [weakness 1]

### Common Objections
| Objection | Response |
|-----------|----------|
| "[objection]" | [response with evidence] |

### Win/Loss Patterns
- We win when: [pattern]
- We lose when: [pattern]
```

**Battlecard Maintenance:**
- Review and update after every competitive win or loss
- Source competitor intel from: Perplexity research, client feedback during sales process, public case studies, job postings (reveal tech stack and priorities)
- Store battlecards as Linear documents under the client/consultancy project
- Win/loss data sourced from monday.com Deals board (Closed Won / Closed Lost groups)

## Pipeline Tracking

### Deal Stages (monday.com Deals Board)

| Stage | Entry Criteria | Exit Criteria |
|-------|---------------|---------------|
| **Lead** | Initial contact or inbound interest | Qualifying conversation scheduled |
| **Qualified** | BANT score >= 3/4 | Proposal requested or agreed to present |
| **Proposal Sent** | Proposal delivered to decision-maker | Client responds with feedback or questions |
| **Negotiation** | Client engaged on terms | Agreement on scope, timeline, and price |
| **Closed Won** | Contract signed or verbal commitment | Linear project created, onboarding started |
| **Closed Lost** | Client declines or goes silent (>30 days) | Loss reason documented |

### Pipeline Health Indicators

| Metric | Healthy | Warning |
|--------|---------|---------|
| Deals in Qualified+ | >= 3 | < 2 |
| Average deal age (Qualified to Won) | < 45 days | > 60 days |
| Win rate (Proposal to Won) | > 40% | < 25% |
| Stale deals (no activity > 14 days) | 0 | >= 2 |

### Reporting

Use `/crm-pipeline` for quick pipeline snapshots. Use `/stakeholder-update` for client-facing status. For internal pipeline review, use monday.com Sales Dashboard (native) or `board_insights` MCP tool for AI-generated analysis.

## Cross-Skill References

- **crm-management** — CRM operations, contact/lead/deal management, interaction logging
- **clinear-context** — Workspace identity, team structure, consultancy positioning, content voice guidelines
- **task-management** — Daily workflow patterns, standup format
- **roadmap-management** — Initiative and milestone tracking for client projects
- **data-analytics** — PostHog queries for usage metrics during QBRs
- **content-marketing** — Case studies from successful client engagements
- **competitive-intelligence** — Win/loss data feeds competitive analysis
- **small-team-finance** — Quotes & Invoices board for client billing
