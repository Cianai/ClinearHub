---
name: small-team-finance
description: |
  Small team financial operations for Cognito's 3-person team. NOT enterprise accounting.
  Invoice tracking via monday.com Quotes & Invoices board, cash flow visibility, expense
  categorization, client billing, and revenue tracking. Triggers for invoice tracking, cash flow,
  billing, expenses, client billing status, financial overview, revenue tracking, accounts receivable,
  or any question about small team finances and Cognito business financials. Does NOT handle
  enterprise accounting, payroll, or tax.
---

# Small Team Finance

Lightweight financial tracking for micro-teams (1-5 people). Uses monday.com Quotes & Invoices board as the primary tracking surface.

## Scope

Covers invoicing, cash flow visibility, expense categorization, and client billing. Does NOT cover: payroll, tax filing, compliance reporting, or multi-entity consolidation.

## Invoice Tracking (monday.com Quotes & Invoices Board)

| Field | Source |
|-------|--------|
| Client | monday.com Contact/Account (connect boards) |
| Project | Linear project + monday.com Client Projects (connect boards) |
| Amount | Deal value or manual input |
| Status | Draft / Sent / Paid / Overdue |
| Due date | Net-30 default |
| Invoice # | Auto-generated or manual |

### Board Groups

| Group | Purpose |
|-------|---------|
| Draft | Invoices being prepared |
| Sent | Awaiting payment |
| Paid | Payment received |
| Overdue | Past due date, requires follow-up |

### Creating an Invoice

```
create_item({
  board_id: MONDAY_BOARD_QUOTES,
  group_id: "draft",
  item_name: "INV-[number] — [Client Name]",
  column_values: {
    "contact": { "item_ids": [contact_id] },
    "account": { "item_ids": [account_id] },
    "amount": invoice_amount,
    "status": { "label": "Draft" },
    "due_date": { "date": due_date_iso },
    "deal": { "item_ids": [deal_id] }
  }
})
```

### Invoice Lifecycle

```
Draft → Sent → Paid
              → Overdue → Paid (late)
                        → Written Off
```

### Stripe Integration (R/W + Skills)

Stripe is connected both directly (OAuth connector with $1000 GitHub credits) and via monday.com native integration:

**Direct Stripe Tools (via MCP):**
- Create invoices: `stripe.invoices.create({ customer, items })`
- Create payment links: `stripe.paymentLinks.create({ line_items })`
- List charges/payments: `stripe.charges.list({ customer })`
- Manage subscriptions: `stripe.subscriptions.create/update/cancel`
- Check balance: `stripe.balance.retrieve()`

**monday.com Native Stripe Integration (auto-sync):**
- Payment received → auto-update invoice status to "Paid" on Quotes & Invoices board
- Payment failed → flag as overdue, notify via monday.com automation
- New Stripe charge → auto-creates item on Quotes & Invoices board
- Subscription events → reflected on Client Projects board
- Stripe dashboard linked from invoice item

**Outbound Automation (monday.com → Stripe via n8n):**
```
Quotes & Invoices status = "Ready to Bill"
  → n8n trigger (webhook on status change)
  → n8n creates Stripe payment link (or invoice)
  → n8n pastes payment URL back into monday.com URL column
  → monday.com sends payment link to client (via email automation)
  → Stripe payment received → native integration updates status to "Paid"
  → monday.com notification to account owner + Client Projects status update
```

**Partner Skill:** Stripe AI skills (`stripe/ai`) provide best practices for payment patterns. ClinearHub's `small-team-finance` adds monday.com context + cash flow dashboard.

## Cash Flow Dashboard

```markdown
## Cash Flow — [Month]

### Income
| Client | Invoice # | Amount | Status | Due |
|--------|-----------|--------|--------|-----|
| [name] | [#] | [amount] | Paid/Pending | [date] |

**Total received:** [amount]
**Total outstanding:** [amount]
**Total overdue:** [amount]

### Expenses
| Category | Description | Amount |
|----------|-------------|--------|
| Infrastructure | Vercel/Railway/Supabase | [amount] |
| Tools | Linear/GitHub/Claude/monday.com | [amount] |
| Services | Domain registrations, email | [amount] |
| Other | [description] | [amount] |

**Total expenses:** [amount]
**Net:** [income - expenses]
```

### Generating the Dashboard

1. `all_monday_api` on Quotes & Invoices board — query items grouped by status
2. Sum amounts by status (Paid, Sent, Overdue)
3. Cross-reference with Deals board for pipeline revenue forecast
4. Present inline or persist to Notion Stakeholder Dashboard

## Products & Services Board

monday.com Products & Services board serves as the Cognito service catalog:

| Service | Description | Pricing Model |
|---------|-------------|---------------|
| AI Strategy | Strategic assessment and roadmap | Fixed fee |
| Implementation | Custom AI solution build | Per-phase |
| Integration | Connect AI to existing systems | Per-phase |
| Training | Team enablement and workshops | Per-session |

Reference this board when creating proposals and invoices to maintain consistent pricing.

## Connector Dependencies

| Source | Tier | Access | Notes |
|--------|------|--------|-------|
| monday.com CRM | Enhanced | R/W | Quotes & Invoices, Deals, Client Projects, Products & Services |
| Linear | Core | R | Project tracking, milestone completion |
| Stripe | Supplementary | R/W | Direct payment creation, invoice management, subscription CRUD, balance queries. Native monday.com integration handles auto-sync. $1000 GitHub credits available. |
| Clay | Supplementary | R | Client enrichment data (company revenue, funding, tech stack) for invoice context |

## Cross-Skill References

- **crm-management** — Contacts and Accounts for client billing, Deal values for invoice amounts
- **business-development** — Proposal pricing feeds into invoice creation, Products & Services catalog
- **customer-ops** — Billing issues may surface as support tickets
