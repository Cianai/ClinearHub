---
name: customer-ops
description: |
  Customer operations: support triage, ticket management, customer health monitoring, knowledge base, SLA tracking, and customer success. Two-tier design: Tier 1 (always available) routes support through Linear + Sentry + monday.com CRM Activities. Tier 2 (if monday.com Service enabled) adds full ticketing, AI Service Agent, customer portal, and SLA management. Triggers for customer support, support triage, customer success, knowledge base, FAQ generation, customer health, support tickets, bug reports from customers, customer satisfaction, SLA, or any question about handling customer issues and building support processes.
---

# Customer Ops

Customer support and success operations. Two-tier architecture: Tier 1 always works with Linear + Sentry + monday.com CRM. Tier 2 activates if monday.com Service product is purchased.

## Two-Tier Architecture

```
                    Customer Reports Issue
                           │
                    ┌──────┴──────┐
                    │             │
              Tier 1 (always)  Tier 2 (if Service)
                    │             │
              Linear Issue    monday.com Ticket
              + CRM Activity  + AI Service Agent
              + Sentry Link   + SLA Tracking
                    │             │
                    └──────┬──────┘
                           │
                    Resolution + Knowledge Base
```

**Tier detection:** At skill invocation, check for monday.com Service boards (Tickets, Knowledge Base) via `get_board_schema`. If present, use Tier 2. If absent, use Tier 1.

## Tier 1 — Linear + Sentry + CRM (Always Available)

Support requests flow into Linear as issues, enriched with CRM and error context.

### Support Flow

1. Customer reports issue (email, in-app, direct message)
2. Create Linear issue with `type:bug` + relevant team (ALT/SWX/CIA)
3. Triage Intelligence auto-applies labels and routing
4. Check monday.com CRM for customer context:
   - `get_board_items_by_name` on Contacts board
   - Include: role, pipeline stage, deal value, account info, recent interactions
5. Check Sentry for related production errors (if applicable)
6. Log interaction on monday.com Activities board via `/crm-log`
7. Resolution follows standard issue lifecycle

### CRM Enrichment During Triage

When processing a customer-reported issue in `/triage`:

```
1. get_board_items_by_name on Contacts board for reporter name/email
2. If found:
   - Read contact: role, stage, deal value, last contact date
   - Read account: active deals, total relationship value, active projects
   - Include in triage notes: "Customer context: [role] at [company], [stage], deal value $[X]"
3. This informs priority — a $50K prospect's bug may warrant higher priority
```

### Contact Resolution via Lusha

If a customer-reported issue arrives with only a name or email (no monday.com Contact match):
- **Lusha** (monday.com Marketplace, free tier 50 credits/month) can resolve LinkedIn URL → email, phone, job title, seniority, department
- Use to create a new Contact entry before proceeding with triage
- Crunchbase (monday.com built-in) auto-enriches the Account with company data

### Escalation

- Bug confirmed → Linear issue with `type:bug`, assign based on severity
- Feature request → Linear issue with `type:feature`, feed into roadmap
- Urgent (production down) → `type:bug` + Priority: Urgent + `exec:quick` + `auto:implement`

## Tier 2 — monday.com Service (If Enabled)

Full ticketing with AI agent, customer portal, SLA management, and knowledge base.

### Service Boards

| Board | Purpose | Groups |
|-------|---------|--------|
| **Tickets** | Customer support requests | Open, In Progress, Waiting on Customer, Resolved, Closed |
| **Knowledge Base** | FAQ and support articles | Getting Started, Troubleshooting, Features, Integrations |

### Ticket Columns

- Ticket Name (item name)
- Customer (connect boards → Contacts)
- Account (connect boards → Accounts)
- Priority (status: Low, Medium, High, Critical)
- Category (dropdown: bug, question, feature-request, billing, onboarding)
- Channel (dropdown: email, portal, in-app, chat)
- SLA Status (formula: based on priority → response time)
- Assigned To (people)
- Related Linear Issue (link)
- Resolution Notes (long text)

### AI Service Agent

monday.com's native AI Service Agent handles routine support:

- Auto-categorizes incoming tickets
- Generates personalized responses from Knowledge Base
- Resolves simple questions without human intervention
- Escalates complex issues by updating ticket priority and notifying team

**When to use AI Service Agent vs Claude:**
- Routine support questions → AI Service Agent (native, zero-touch)
- Issues needing cross-system context (CRM + Linear + Sentry) → Claude
- Escalation to engineering → Claude creates Linear issue

### Customer Portal

monday.com Service includes a customer-facing portal:
- Customers submit tickets directly
- Track ticket status
- Browse Knowledge Base articles
- Self-service before human intervention

### SLA Management

| Priority | First Response | Resolution Target |
|----------|---------------|-------------------|
| Critical | 1 hour | 4 hours |
| High | 4 hours | 24 hours |
| Medium | 8 hours | 72 hours |
| Low | 24 hours | 1 week |

### Service Automations

| Trigger | Action |
|---------|--------|
| New ticket created | AI Service Agent auto-categorizes, assigns based on type |
| Ticket SLA approaching | Escalate priority, notify team |
| Ticket status → Resolved | Send satisfaction survey, log Activity on Contact |
| Ticket status → Closed | Update Contact "Last Contact" date |
| 3+ similar tickets on same topic | Flag for Knowledge Base article creation |

### /support-ticket Action

Create a support ticket from Cowork.

1. Ask for: customer name, description, priority, category
2. `get_board_items_by_name` on Contacts board to resolve customer
3. `create_item` on Tickets board with customer link, priority, category
4. If engineering-related: also create Linear issue with `type:bug`, link back
5. Confirm ticket creation with ID and SLA timeline

### /support-status Action

Ticket queue summary and SLA health.

1. `all_monday_api` on Tickets board — query all items grouped by status
2. Calculate: open count, SLA at-risk count, average resolution time
3. Identify: tickets approaching SLA breach, tickets waiting on customer >3 days
4. Present inline as support dashboard

## Knowledge Base Generation

After resolving support issues, extract reusable knowledge:

- **Pattern**: 3+ similar issues on the same topic → create FAQ entry
- **Format**: Problem → Solution → Prevention
- **Storage**:
  - Tier 2: monday.com Knowledge Base board
  - Tier 1: Notion or Linear Document, linked to originating issues

## Customer Health Monitoring

### /crm-health Action

Aggregate health signals across all connected sources.

| Signal | Source | Tier | Action |
|--------|--------|------|--------|
| Bug frequency increasing | Linear (count by client tag) | 1 | Proactive outreach |
| Error spike | Sentry | 1 | Investigate + notify |
| Feature requests | Linear | 1 | Feed into roadmap |
| Usage drop | PostHog | 1 | Check-in call |
| Ticket volume spike | monday.com Tickets | 2 | Review patterns, add KB articles |
| SLA breaches | monday.com Tickets | 2 | Escalate, process review |
| Satisfaction scores | monday.com Tickets (survey) | 2 | QBR agenda item |

### Health Score (per client)

```markdown
## Client Health — [Client Name] — [Date]

### Signals
| Signal | Status | Detail |
|--------|--------|--------|
| Bug frequency | 🟢/🟡/🔴 | [N] bugs in last 30 days |
| Error rate | 🟢/🟡/🔴 | [N] Sentry events |
| Feature engagement | 🟢/🟡/🔴 | [PostHog metrics] |
| Support tickets | 🟢/🟡/🔴 | [N] tickets, avg resolution [X] hours |
| Last interaction | 🟢/🟡/🔴 | [date] ([days ago]) |

### Recommended Actions
- [action based on signals]
```

## Escalation Bridge: Service → Linear

When a support ticket requires engineering work:

1. Create Linear issue from ticket context (`type:bug` or `type:feature`)
2. Link Linear issue URL in ticket's "Related Linear Issue" column
3. When Linear issue is resolved, update ticket status
4. Log the resolution as an Activity on the Contact

## Connector Dependencies

| Source | Tier | Access | Notes |
|--------|------|--------|-------|
| Linear | Core | R/W | Support issues (Tier 1), escalation target (Tier 2) |
| monday.com CRM | Enhanced | R/W | Contact context, interaction logging |
| monday.com Service | Enhanced | R/W | Tickets, KB, SLA (Tier 2 only) |
| Sentry | Enhanced | R | Error correlation, production monitoring |
| PostHog | Enhanced | R | Usage signals, feature engagement |

## Graceful Degradation

| Scenario | Behavior |
|----------|----------|
| monday.com Service boards not found | Use Tier 1 (Linear + Sentry + CRM Activities) |
| monday.com CRM unavailable | Use Linear + Sentry only, note missing CRM context |
| Sentry unavailable | Skip error correlation, note gap |
| PostHog unavailable | Skip usage signals, note gap |

## Cross-Skill References

- **crm-management** — Contact lookup, interaction logging, pipeline context
- **incident-response** — Sentry error pipeline, severity classification
- **business-development** — Client lifecycle, QBR agenda includes support health
- **content-marketing** — Campaign triggers from support patterns (re-engagement)
- **clinearhub-workflow** — Triage protocol for customer-reported issues
