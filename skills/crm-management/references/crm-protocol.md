# CRM Protocol

> Operational protocol for CRM actions using monday.com boards.
> Falls back to Notion CRM databases if monday.com connector is unavailable.

## Board IDs

Set these after connecting monday.com MCP and reading via `get_board_schema`:

```
MONDAY_BOARD_CONTACTS=<contacts-board-id>
MONDAY_BOARD_LEADS=<leads-board-id>
MONDAY_BOARD_DEALS=<deals-board-id>
MONDAY_BOARD_ACTIVITIES=<activities-board-id>
MONDAY_BOARD_ACCOUNTS=<accounts-board-id>
MONDAY_BOARD_CLIENT_PROJECTS=<client-projects-board-id>
MONDAY_BOARD_PRODUCTS=<products-services-board-id>
MONDAY_BOARD_QUOTES=<quotes-invoices-board-id>
```

Board IDs are numeric. Get them from the monday.com URL (`/boards/NNNNNN`) or via `get_board_schema`.

## /crm-log Workflow

### Input Collection

Ask the user for:
1. **Contact name** (required) — who was the interaction with?
2. **Type** (required) — meeting / email / feedback / support / demo / call / notetaker
3. **Description** (required) — brief description of the interaction
4. **Outcome** (optional) — what happened, key takeaways
5. **Next action** (optional) — follow-up action item
6. **Linear issue** (optional) — related Linear issue ID

### Contact Resolution

1. `get_board_items_by_name` with the contact name on Contacts board
2. If multiple matches: present options, ask user to confirm
3. If no match: ask "Create new contact for [name]?"
   - If yes: collect Company, Role, Email → `create_item` on Contacts board
   - Set Stage to "Contact Made" via `change_item_column_values`
   - Check if Account exists for company → if not, offer to create

### Interaction Creation

```
create_item({
  board_id: MONDAY_BOARD_ACTIVITIES,
  item_name: description,
  column_values: {
    "contact": { "item_ids": [contact_item_id] },
    "type": { "label": type },
    "date": { "date": today_iso },
    "source": { "label": "manual" },
    "next_action": next_action,
    "outcome": outcome,
    "linear_issue_url": { "url": linear_url, "text": issue_id }
  }
})
```

### Contact Update

After logging the interaction, update the contact's Last Contact date:

```
change_item_column_values({
  board_id: MONDAY_BOARD_CONTACTS,
  item_id: contact_item_id,
  column_values: {
    "last_contact": { "date": today_iso }
  }
})
```

## /crm-lookup Workflow

### Search

1. `get_board_items_by_name` with the query on Contacts board
2. For each matching contact: read column values for full properties
3. If contact has an Account link: read Account details
4. For the primary contact: `all_monday_api` with GraphQL to query Activities board filtered by contact connection

### Output Format

```markdown
## Contact: [Name]

**Company:** [Company] | **Role:** [Role] | **Stage:** [Stage]
**Email:** [Email] | **LinkedIn:** [LinkedIn]
**Linear Customer:** [ID or N/A] | **Deal Value:** [Value or N/A]
**Last Contact:** [Date] ([days ago])

### Account: [Company Name]
**Industry:** [Industry] | **Size:** [Size] | **Active Deals:** [N]

### Recent Interactions ([count] total)

| Date | Type | Description | Outcome |
|------|------|-------------|---------|
| 2026-03-05 | meeting | Sprint demo | Positive feedback |
| 2026-02-28 | email | Follow-up on proposal | Awaiting response |

### Next Actions
- [Next action from most recent interaction]
```

## /crm-report Workflow

### Data Collection

1. `get_board_schema` on Contacts and Deals boards
2. `all_monday_api` with GraphQL to query Contacts grouped by stage:
   ```graphql
   query {
     boards(ids: [MONDAY_BOARD_CONTACTS]) {
       groups { title items_page { items { name column_values { id text value } } } }
     }
   }
   ```
3. Query Deals board for pipeline stages and values
4. Count contacts per stage, deals per stage with total value
5. Identify stale contacts: Last Contact > 30 days ago
6. Query recent activities from last 7 days

### Output Format

```markdown
## CRM Report — [Date]

### Contact Pipeline

| Stage | Count |
|-------|-------|
| Contact Made | X |
| Needs Follow-Up | X |
| Active | X |
| Churned | X |

### Deal Pipeline

| Stage | Count | Total Value | Weighted Forecast |
|-------|-------|-------------|-------------------|
| Lead | X | $XX,XXX | $XX,XXX |
| Qualified | X | $XX,XXX | $XX,XXX |
| Proposal Sent | X | $XX,XXX | $XX,XXX |
| Negotiation | X | $XX,XXX | $XX,XXX |
| Won | X | $XX,XXX | — |
| Lost | X | $XX,XXX | — |

### Recent Activity (Last 7 Days)
- [Date]: [Type] with [Contact] — [Description]

### Stale Contacts (>30 Days No Activity)
- [Contact] — Last contact: [Date] ([days ago])

### Key Metrics
- Total contacts: [N]
- Active pipeline: [N] deals, $[value] total
- Weighted forecast: $[value]
- Conversion rate: [Won / (Won + Lost)] %
```

### Persist to Notion Dashboard (if connected)

Write the report to Notion Stakeholder Dashboard DB as a read-only summary:
- Period: "CRM Report — [Date]"
- Type: stakeholder-update
- Audience: executive
- Content: report markdown as page body

## /crm-lead Workflow

### Input Collection

Ask the user for:
1. **Name** (required) — lead's name
2. **Company** (required) — company name
3. **Email** (optional) — email address
4. **Source** (required) — referral / inbound / outbound / conference / community / linkedin / website
5. **Notes** (optional) — initial context

### Duplicate Check

1. `get_board_items_by_name` on Leads board with the name
2. Also check Contacts board for existing contact
3. If duplicate found: present existing record, ask if this is a new lead or same person

### Lead Creation

```
create_item({
  board_id: MONDAY_BOARD_LEADS,
  group_id: "new",
  item_name: name,
  column_values: {
    "company": company,
    "email": { "email": email, "text": email },
    "source": { "label": source },
    "status": { "label": "New" },
    "first_contact": { "date": today_iso },
    "notes": notes
  }
})
```

## /crm-convert Workflow

### Lead Resolution

1. `get_board_items_by_name` on Leads board for the lead name
2. Confirm the lead to convert (present details)
3. Read all lead column values

### Conversion Steps

1. **Create Contact:**
```
create_item({
  board_id: MONDAY_BOARD_CONTACTS,
  group_id: "active_clients",
  item_name: lead_name,
  column_values: {
    "email": lead_email,
    "source": lead_source,
    "stage": { "label": "Contact Made" }
  }
})
```

2. **Check/Create Account:**
```
# Search for existing account
get_board_items_by_name({ board_id: MONDAY_BOARD_ACCOUNTS, name: company })

# If not found, create:
create_item({
  board_id: MONDAY_BOARD_ACCOUNTS,
  group_id: "prospect",
  item_name: company,
  column_values: {
    "primary_contact": { "item_ids": [new_contact_id] }
  }
})
```

3. **Link Contact to Account:**
```
change_item_column_values({
  board_id: MONDAY_BOARD_CONTACTS,
  item_id: new_contact_id,
  column_values: {
    "company": { "item_ids": [account_id] }
  }
})
```

4. **Update Lead Status:**
```
change_item_column_values({
  board_id: MONDAY_BOARD_LEADS,
  item_id: lead_id,
  column_values: {
    "status": { "label": "Converted" },
    "conversion_date": { "date": today_iso }
  }
})
```

5. **Optional Deal Creation:** Ask if a Deal should be created. If yes:
```
create_item({
  board_id: MONDAY_BOARD_DEALS,
  group_id: "qualified",
  item_name: "Deal — [Company Name]",
  column_values: {
    "contact": { "item_ids": [new_contact_id] },
    "account": { "item_ids": [account_id] },
    "stage": { "label": "Qualified" },
    "source": lead_source
  }
})
```

## /crm-enrich Workflow

### Contact Resolution

1. `get_board_items_by_name` on Contacts (or Accounts) board
2. Read existing column values

### Research

Use Perplexity to gather:
- Company details: industry, size, website, recent news
- Contact details: LinkedIn profile, role, background
- Business context: funding, growth stage, tech stack, public challenges

### Update

1. Present findings to user, ask which to update
2. `change_item_column_values` on Contact: LinkedIn URL, role, tags
3. If Account exists: `change_item_column_values` on Account: industry, size, website, notes
4. `create_update` on Contact item: add research summary as a comment

## /crm-pipeline Workflow

### Data Collection

1. `all_monday_api` on Deals board — query all items with stage, value, probability, expected close, last activity:
   ```graphql
   query {
     boards(ids: [MONDAY_BOARD_DEALS]) {
       groups { title items_page { items { name column_values { id text value } } } }
     }
   }
   ```

### Calculations

- Count per stage
- Total value per stage
- Weighted forecast: value × close probability per deal, summed by stage
- Stale deals: no activity > 14 days
- Upcoming closes: expected close within next 30 days

### Output Format

```markdown
## Pipeline — [Date]

| Stage | Deals | Value | Weighted |
|-------|-------|-------|----------|
| Lead | X | $XX,XXX | $XX,XXX |
| Qualified | X | $XX,XXX | $XX,XXX |
| Proposal Sent | X | $XX,XXX | $XX,XXX |
| Negotiation | X | $XX,XXX | $XX,XXX |
| **Total Active** | **X** | **$XX,XXX** | **$XX,XXX** |

### Upcoming Closes (Next 30 Days)
- [Deal Name] — $[value] — Expected: [date] — Probability: [%]

### Stale Deals (>14 Days No Activity)
- [Deal Name] — Last activity: [date] ([days ago])

### Won/Lost This Month
- Won: [N] deals, $[value]
- Lost: [N] deals, $[value]
```

## New Contact Templates

When creating contacts via `create_item`, use these defaults by role:

| Template | Group | Default Fields |
|----------|-------|----------------|
| New Customer | Active Clients | Role: user, Stage: Contact Made |
| New Advisor | Advisors | Role: advisor, Stage: Contact Made |
| New Research Collaborator | Researchers | Role: researcher, Stage: Contact Made |
| New Partner | Partners | Role: partner, Stage: Contact Made |
| New Investor | Active Clients | Role: investor, Stage: Contact Made, Deal Value: prompt |

## Deal Management

### Creating a Deal

When a contact progresses to a qualified opportunity:

```
create_item({
  board_id: MONDAY_BOARD_DEALS,
  group_id: "qualified",
  item_name: "Deal — [Client Name]",
  column_values: {
    "contact": { "item_ids": [contact_item_id] },
    "account": { "item_ids": [account_id] },
    "value": deal_amount,
    "expected_close": { "date": expected_date },
    "close_probability": probability_pct,
    "stage": { "label": "Qualified" },
    "source": { "label": source }
  }
})
```

### Advancing a Deal

```
move_item_to_group({
  item_id: deal_item_id,
  group_id: target_group_id
})
change_item_column_values({
  board_id: MONDAY_BOARD_DEALS,
  item_id: deal_item_id,
  column_values: {
    "stage": { "label": new_stage }
  }
})
```

### Closing a Deal

**Won:**
```
move_item_to_group({ item_id: deal_id, group_id: "closed_won" })
change_item_column_values({
  board_id: MONDAY_BOARD_DEALS,
  item_id: deal_id,
  column_values: { "stage": { "label": "Won" } }
})
# Automation creates Client Projects item and triggers welcome campaign
```

**Lost:**
```
move_item_to_group({ item_id: deal_id, group_id: "closed_lost" })
change_item_column_values({
  board_id: MONDAY_BOARD_DEALS,
  item_id: deal_id,
  column_values: { "stage": { "label": "Lost" } }
})
create_update({ item_id: deal_id, body: "Loss reason: [reason]" })
```

## Fallback: Notion CRM

If monday.com connector is unavailable, use Notion CRM databases as fallback:

1. Check for monday.com MCP tools first
2. If unavailable, check for Notion MCP tools
3. Use the same workflows but substitute:
   - `get_board_items_by_name` → `notion-search`
   - `create_item` → `notion-create-pages`
   - `change_item_column_values` → `notion-update-page`
4. Note in output: "Using Notion CRM (monday.com unavailable)"

If both unavailable: "CRM unavailable — note the interaction in session memory for later entry"

See `notion-hub/references/database-schema.md` for Notion CRM property definitions.

## Data Hygiene

- Review stale leads monthly (run `/crm-report`)
- Update pipeline stages as deals progress (via `/crm-log` or monday.com UI)
- Merge duplicate contacts when discovered during `/crm-lookup`
- monday.com automations handle: stale contact alerts (14 days), stage-change notifications, last contact updates
- Review Leads board weekly: move stale leads (>30 days) to Disqualified or re-engage
