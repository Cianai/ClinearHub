---
name: call-prep
description: |
  Generate a pre-meeting brief for a client call. Pulls context from Linear, monday.com, and Granola. Use when preparing for client meetings, stakeholder calls, sales calls, discovery calls, check-in calls, quarterly reviews, or any upcoming meeting that needs preparation. Generates agenda suggestions, talking points, open item summaries, and follow-up templates. Cross-references crm-management for contact data and client-review for health context.
---

# /call-prep

Generate a comprehensive pre-meeting brief for an upcoming client or stakeholder call.

## Usage

```
/call-prep [client name or meeting context]
```

## Workflow

1. **Identify the client/meeting** from the user's input
2. **Pull context** from available connectors:
   - monday.com: contact details, company info, deal stage, recent activity
   - Linear: open issues for the client's project, recent completions, blockers
   - Granola: notes from last meeting, action items
   - GCal: meeting time, attendees, recurring?
3. **Generate the brief** using this format:

```markdown
## Call Prep — [Client/Stakeholder Name] — [Date]

### Context
- Company: [name], [industry], [size]
- Relationship: [prospect/active client/renewal]
- Deal stage: [from monday.com if available]
- Last interaction: [date, summary]

### Open Items
- [Issue link] — [status, what they expect]

### From Last Meeting
- [Action items from Granola, with completion status]

### Suggested Agenda
1. [topic] — [time]
2. [topic] — [time]

### Talking Points
- [key point with supporting data]

### Questions to Ask
- [discovery/qualifying/check-in question]

### Follow-up Template
- [ ] [post-meeting action, owner, deadline]
```

## Connector Dependencies

| Source | Tier | Access |
|--------|------|--------|
| Linear | Core | R |
| monday.com | Enhanced | R |
| Granola | Supplementary | R |
| GCal | Supplementary | R |
