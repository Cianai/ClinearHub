---
name: client-review
description: Generate a client health review for Cognito consultancy engagements.
---

# /client-review

Generate a client health check for a Cognito consultancy engagement. Pulls context from Linear projects, monday.com CRM, and Granola meeting notes.

## Usage

```
/client-review [client name]
```

## Workflow

1. **Identify the client** from user input
2. **Pull context** from available connectors:
   - monday.com: contact details, deal stage, contract dates, billing info
   - Linear: project issues (open, in progress, completed), milestones, blockers
   - Granola: recent meeting notes, action items, sentiment
   - GCal: upcoming meetings scheduled
3. **Assess client health** using signals:

| Signal | Source | Health Impact |
|--------|--------|--------------|
| Issues on track | Linear | Green if >80% on schedule |
| Overdue items | Linear | Red if any P1/P2 overdue |
| Recent communication | Granola/GCal | Yellow if >2 weeks since last contact |
| Open blockers | Linear | Red if any unresolved blockers |
| Billing current | monday.com | Red if overdue invoices |

4. **Generate the review**:

```markdown
## Client Review — [Client Name] — [Date]

### Health: [Green/Yellow/Red]

### Summary
[2-3 sentence overview of engagement status]

### Project Status
| Issue | Status | Priority | Last Updated |
|-------|--------|----------|-------------|
| [CIA-XXX: Title](url) | [status] | [priority] | [date] |

### Milestones
| Milestone | Target | Status | Progress |
|-----------|--------|--------|----------|
| [name] | [date] | On Track/At Risk/Overdue | [N/M issues done] |

### Recent Activity
- Last meeting: [date] — [key topics from Granola]
- Outstanding action items: [items with owners]
- Next scheduled: [date from GCal]

### Financials
- Contract value: [from monday.com]
- Invoiced: [amount]
- Outstanding: [amount]
- Next invoice due: [date]

### Recommendations
- [ ] [proactive action to strengthen relationship]
- [ ] [risk mitigation if any yellow/red signals]
```

## Connector Dependencies

| Source | Tier | Access |
|--------|------|--------|
| Linear | Core | R (project issues, milestones) |
| monday.com | Enhanced | R (contact, deal, billing) |
| Granola | Supplementary | R (meeting notes, action items) |
| GCal | Supplementary | R (upcoming meetings) |
