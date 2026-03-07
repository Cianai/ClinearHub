---
name: crm-management
description: |
  CRM operations using monday.com as the data store, with Linear Customer Requests
  as the work-item bridge. Use when discussing contacts, customers, leads, interactions,
  CRM pipeline, deal tracking, stakeholder relationships, lead conversion, contact enrichment,
  or any question about customer management. Triggers for /crm-log, /crm-lookup, /crm-report,
  /crm-lead, /crm-convert, /crm-enrich, /crm-pipeline, or questions about monday.com CRM boards
  (Contacts, Leads, Deals, Activities, Accounts).
  Falls back to Notion CRM databases if monday.com connector is unavailable.
---

# CRM Management

CRM built on monday.com CRM Pro, designed for solo founder / small team use. monday.com provides purpose-built deal pipeline, email sync, automations, forecasting, and native AI (Sales Advisor, AI Blocks, AI Notetaker). Campaigns (email marketing) is included with CRM Pro.

## Architecture

```
monday.com Leads Board ──convert──► monday.com Contacts Board
        │                                  │
        │                                  ├── Activities Board (interaction log)
        │                                  ├── Accounts Board (company grouping)
        │                                  │
        │                                  ▼
        │                          monday.com Deals Board
        │                                  │
        │                                  ├── Client Projects Board
        │                                  ├── Products & Services Board
        │                                  └── Quotes & Invoices Board
        │                                  │
        ▼                                  ▼
Linear Customer Requests ◄──bridge──► Linear Issues (feedback, support)
```

**Source of truth:** monday.com (for all customer/relationship data)
**Work-item bridge:** Linear Customer Requests (for issue tracking)
**Summary views:** Notion CRM Contacts/Interactions DBs (read-only, populated by `/crm-report`)
**Access patterns:**
- Humans browse CRM in monday.com (Kanban pipeline, timeline view, Sales Dashboard)
- Agents read/write CRM via monday.com MCP during `/triage`, `/crm-log`, `/crm-lookup`, etc.
- Humans browse summaries in Notion (read-only views)

## monday.com MCP Tools

| Tool | Purpose |
|------|---------|
| `get_board_items_by_name` | Search contacts, leads, deals by name |
| `create_item` | Add contacts, leads, interactions, deals |
| `change_item_column_values` | Update pipeline stage, last contact, deal value |
| `move_item_to_group` | Move deals between pipeline stages, convert leads |
| `create_update` | Add notes/comments to items |
| `get_board_schema` | Read board structure for reporting |
| `all_monday_api` | GraphQL for complex queries, cross-board joins |
| `search` | Global search across workspace |
| `get_board_activity` | Activity feed for audit trail |
| `get_notetaker_meetings` | Retrieve AI Notetaker transcripts |

## Board Architecture

### Contacts Board
**Groups:** Active Clients, Advisors, Researchers, Partners, Inactive

**Columns:**
- Name (item name)
- Company (connect boards → Accounts)
- Role (dropdown: user, advisor, researcher, investor, partner)
- Email (email)
- Phone (phone)
- LinkedIn (link)
- Stage (status: Contact Made, Needs Follow-Up, Active, Churned)
- Deal Value (numbers, currency)
- Last Contact (date) — auto-updated by automations
- Linear Customer ID (text) — bridge to Linear Customer Requests
- Source (dropdown: referral, inbound, outbound, conference, community)
- Tags (tags) — freeform categorization

### Leads Board
**Groups:** New, Contacted, Qualifying, Converted, Disqualified

**Columns:**
- Name (item name)
- Company (text)
- Email (email)
- Phone (phone)
- Source (dropdown: referral, inbound, outbound, conference, community, linkedin, website)
- Lead Score (numbers) — manual or AI Block auto-scored
- Status (status: New, Contacted, Qualifying, Converted, Disqualified)
- Assigned To (people)
- First Contact (date)
- Notes (long text)
- Conversion Date (date) — set when converted to Contact

### Deals Board
**Groups:** Lead, Qualified, Proposal Sent, Negotiation, Closed Won, Closed Lost

**Columns:**
- Deal Name (item name)
- Contact (connect boards → Contacts)
- Account (connect boards → Accounts)
- Value (numbers, currency)
- Expected Close (date)
- Close Probability (numbers, %)
- Forecast Value (formula: Value × Probability)
- Stage (status: Lead, Qualified, Proposal Sent, Negotiation, Won, Lost)
- Owner (people)
- Source (dropdown)
- Products (connect boards → Products & Services)
- Notes (long text)

### Activities Board
**Groups:** This Week, Last Week, Older

**Columns:**
- Description (item name)
- Contact (connect boards → Contacts)
- Type (dropdown: meeting, email, feedback, support, demo, call, notetaker)
- Date (date)
- Source (dropdown: manual, granola, gmail, ai-notetaker, calendar)
- Next Action (text)
- Outcome (text)
- Linear Issue URL (link)

### Accounts Board
**Groups:** Active, Prospect, Former

**Columns:**
- Company Name (item name)
- Industry (dropdown)
- Size (dropdown: 1-10, 11-50, 51-200, 201-1000, 1000+)
- Website (link)
- Primary Contact (connect boards → Contacts)
- Deals (connect boards → Deals)
- Client Projects (connect boards → Client Projects)
- Notes (long text)

## Pipeline Stages

### Lead Pipeline (Leads Board)
```
New → Contacted → Qualifying → Converted (→ Contact + Deal created)
                              → Disqualified
```

### Deal Pipeline (Deals Board)
```
Lead → Qualified → Proposal Sent → Negotiation → Won
                                               → Lost
```

### Contact Lifecycle
```
Contact Made → Needs Follow-Up → Active → Churned
```

## monday.com Native Automations

These run in monday.com without Claude involvement:

| Trigger | Action |
|---------|--------|
| Activity created with Contact link | Update Contact "Last Contact" to today |
| Lead status → Converted | Create Contact item + Account (if new) |
| Deal stage → Closed Won | Create Client Projects item, send welcome campaign |
| Contact no activity > 14 days | Send notification "Follow up with {name}" |
| Contact no activity > 30 days | Move to "Needs Follow-Up" stage |
| Deal stage → Proposal Sent | Create Google Doc from template, notify |

## Actions

### /crm-log — Log an Interaction

Record a meeting, email, feedback session, or other contact with a person.

1. Ask for: contact name, interaction type, description, outcome, next action
2. `get_board_items_by_name` on Contacts board to find the contact
3. If contact not found: offer to create a new contact via `create_item`
4. `create_item` on Activities board:
   - Description, Contact (connect), Type, Date (today), Source (manual), Next Action, Outcome
5. `change_item_column_values` on the contact: set Last Contact to today
6. If a Linear issue is related, include the Linear Issue URL column

### /crm-lookup — Search Contacts

Look up a contact and show their interaction history.

1. `get_board_items_by_name` on Contacts board for the query
2. Read the contact's column values for full details
3. `get_board_items_by_name` on Activities board for related interactions
4. If the contact has an Account link, read Account details
5. Present: contact info, company, pipeline stage, interaction history (most recent first), next actions

### /crm-report — CRM Summary

Generate a CRM status report for stakeholder updates.

1. `get_board_schema` + `all_monday_api` on key boards — get stage distribution
2. Summarize: contacts by stage, deals by stage with total value, recent activities, stale leads (>30 days no contact)
3. If Notion connected: write summary to Notion Stakeholder Dashboard DB (read-only view)
4. Present inline in session

### /crm-lead — Create a New Lead

Capture a new unqualified lead.

1. Ask for: name, company, email, source, notes
2. `get_board_items_by_name` on Leads board to check for duplicates
3. If no duplicate: `create_item` on Leads board in "New" group
4. Set Lead Score if enough data (or leave for AI Block auto-scoring)
5. Confirm creation with lead details

### /crm-convert — Convert Lead to Contact

Promote a qualified lead to a contact with optional deal creation.

1. `get_board_items_by_name` on Leads board for the lead name
2. Confirm the lead to convert
3. `create_item` on Contacts board with lead data (name, company, email, source)
4. Check if Account exists for the company: `get_board_items_by_name` on Accounts
5. If no Account: `create_item` on Accounts board
6. Link Contact to Account
7. `change_item_column_values` on Lead: set status to "Converted", set Conversion Date
8. Ask if a Deal should be created — if yes, `create_item` on Deals board
9. Confirm conversion summary

### /crm-enrich — Enrich a Contact

Research a contact or company using the enrichment tiering hierarchy, and update monday.com.

**Enrichment Tiering** (prefer native tools, escalate for volume):

| Tier | Tool | What It Provides | Limit |
|------|------|-----------------|-------|
| 1 (built-in) | **Crunchbase** (monday.com CRM Settings) | Company: funding, industry, employee count, revenue | 1,000 items lifetime (free) |
| 2 (marketplace) | **Lusha** (monday.com Marketplace) | Contact: email, phone, job title, seniority, department | 50 credits/month (free tier) |
| 3 (high-volume) | **Clay** (OAuth → n8n → monday.com) | Deep: tech stack, buying intent, LinkedIn, 100+ sources | Pay-per-enrichment |
| Fallback | **Perplexity** (Code: MCP; Cowork: built-in web search) | Company news, industry context, public info | Unlimited |

1. `get_board_items_by_name` on Contacts (or Accounts) board
2. **Tier 1 (Crunchbase):** Check if monday.com Crunchbase enrichment has already populated company data (runs automatically on Accounts board)
3. **Tier 2 (Lusha):** For contact-level enrichment (email, phone, job title), use Lusha native recipe in monday.com (add LinkedIn URL → auto-enriches)
4. **Tier 3 (Clay):** If deeper enrichment needed (tech stack, buying intent, funding details) and Clay is connected, use Clay MCP for one-time research. For ongoing pipeline, route via n8n.
5. **Fallback (Perplexity):** Use for company news, recent developments, industry context
6. Present findings and ask which to update
7. `change_item_column_values` to update: company details, industry, LinkedIn URL, notes, tech stack
8. If an Account exists, update Account details too
9. If a Deal exists for this contact, update deal notes with enrichment context

### /crm-pipeline — Quick Pipeline Overview

Snapshot of current pipeline health.

1. `all_monday_api` on Deals board — query all items grouped by stage
2. Calculate: count per stage, total value per stage, weighted forecast (value × probability)
3. Identify: stale deals (no activity > 14 days), upcoming closes (next 30 days)
4. Present inline as pipeline summary table

## Triage Integration

During `/triage`, when processing customer-reported issues:

1. Check if the reporter has a monday.com Contact entry (`get_board_items_by_name`)
2. If found: include contact context (role, pipeline stage, deal value, recent interactions) in triage notes
3. This helps prioritize — a $50K prospect's bug report may warrant higher priority than an anonymous report
4. If the contact has an Account, include account-level context (active projects, total relationship value)

## Linear Customer Requests Bridge

- monday.com Contacts have a `Linear Customer ID` column linking to Linear's native Customer Requests
- When creating a new contact in monday.com, also check if a Linear Customer Request exists
- Customer Requests in Linear feed into RICE scoring (Reach metric in roadmap-management)

## Graceful Degradation

**Primary fallback (monday.com unavailable → Notion):**
- `/crm-log`: Fall back to Notion CRM Contacts/Interactions DBs (see notion-hub skill for schema)
- `/crm-lookup`: Fall back to Notion search, then Linear Customer Requests
- `/crm-report`: Fall back to Notion data if available, note partial data

**Secondary fallback (both unavailable):**
- `/crm-log`: "CRM unavailable — note the interaction in session memory for later entry"
- `/crm-lookup`: "CRM unavailable — check Linear Customer Requests for basic info"
- `/crm-report`: "CRM unavailable — report requires monday.com or Notion access"

## Marketplace Configuration

Board names, group names, and column names in this skill reflect default monday.com CRM Pro templates. Marketplace users should adapt:

- **Board names**: Contacts, Leads, Deals, Activities, Accounts, Client Projects, Products & Services, Quotes & Invoices
- **Group names**: Pipeline stages per board (e.g., Deals: Lead, Qualified, Proposal Sent, Negotiation, Won, Lost)
- **Column names**: Match your monday.com board schema — use `get_board_schema` to discover

Board IDs are resolved at runtime via `get_board_items_by_name` and `get_board_schema`, not hardcoded.

## Cross-Skill References

- **business-development** — Client lifecycle, BANT qualification, battlecards, pipeline tracking, call prep
- **customer-ops** — Support ticket management, customer health monitoring
- **content-marketing** — Campaigns uses CRM segments for email targeting
- **competitive-intelligence** — Win/loss data from Deals board; Clay enrichment for competitor intel
- **small-team-finance** — Quotes & Invoices board, client billing, Stripe integration
- **notion-hub** — Notion databases hold read-only CRM summaries (populated by `/crm-report`)
- **clinearhub-workflow** — Triage rules reference CRM context for customer issues
- **roadmap-management** — RICE scoring uses Customer Requests count for Reach
- **task-management** — `/stakeholder-update` can include CRM status via `/crm-report`
