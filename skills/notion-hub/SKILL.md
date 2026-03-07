---
name: notion-hub
description: |
  Notion workspace integration for ClinearHub. Provides context about the 6-database
  Notion architecture (knowledge hub), MCP tool patterns, schema mappings, and graceful
  degradation. Use when discussing Notion databases, research landing in Notion,
  stakeholder dashboards, spec/plan library, Notion AI Connectors, or any question
  about how data flows between Supabase/Linear and Notion. CRM databases in Notion are
  read-only summary views — source of truth is monday.com (see crm-management skill).
  Also triggers for questions about Notion MCP tools, notion-search, notion-create-pages,
  notion-query-database-view, or the /sync-notion command.
---

# Notion Hub

Notion is the **human-readable knowledge hub** in the ClinearHub stack. Linear handles agent-facing work tracking; Supabase holds data truth (pgvector, RAG); monday.com handles CRM; Notion provides browsable, shareable knowledge that both humans and agents can access. CRM databases in Notion are **read-only summary views** populated by `/crm-report` — source of truth is monday.com.

## Architecture

```
Supabase (data)    Linear (work)    monday.com (CRM)    Claude (agents)
     │                  │                  │                   │
     │    ┌─────────────┼──────────────────┼───────────────────┘
     │    │             │                  │       Notion MCP
     ▼    ▼             ▼                  ▼          │
┌──────────────────────────────────────────────────────────────┐
│                     Notion Workspace (Knowledge Hub)          │
│                                                               │
│  Research Papers DB ◄──► Research Findings DB                  │
│  CRM Contacts DB (read-only) ◄──► CRM Interactions (read-only)│
│  Specs & Plans DB              Stakeholder Dashboard DB       │
│                                                               │
│  AI Connectors: Linear, GitHub, GCal, Drive, Gmail,          │
│                 Slack (Business plan)                          │
└──────────────────────────────────────────────────────────────┘
```

## Connector Tier: Enhanced

Notion is **Enhanced** tier (not Core, not Supplementary):
- Commands that write to Notion **degrade gracefully** if the connector is unavailable
- Pattern: attempt Notion MCP call → catch failure → log "Notion unavailable, data persisted to [primary store] only" → continue
- Never fail a command because Notion is down

## Notion MCP Tools Reference

| Tool | Used For | Plan Required |
|------|----------|---------------|
| `notion-search` | Find existing pages, CRM lookups, spec searches | Plus |
| `notion-fetch` | Read page content, database schema, templates | Plus |
| `notion-create-pages` | Create papers, findings, CRM entries, specs, dashboards | Plus |
| `notion-update-page` | Update properties (stage, status, last_synced) | Plus |
| `notion-create-database` | Initial 6-database setup (one-time) | Plus |
| `notion-update-data-source` | Evolve database schema | Plus |
| `notion-query-database-view` | Filtered queries (papers by stage, contacts by status) | **Business** |
| `notion-create-comment` | Discussion threads on specs, flag findings | Plus |
| `notion-get-comments` | Read stakeholder feedback on specs/plans | Plus |
| `notion-get-self` | Verify connection, workspace info | Plus |

## Database IDs

Database IDs are stored in Doppler (`claude-tools` project, `dev` config). Reference them by name — the MCP tools accept database IDs or URLs.

| Constant | Doppler Secret | Database |
|----------|---------------|----------|
| Research Papers | `NOTION_DB_RESEARCH_PAPERS` | Papers with metadata, relevance scores, Supabase IDs |
| Research Findings | `NOTION_DB_RESEARCH_FINDINGS` | Extracted insights linked to papers |
| CRM Contacts | `NOTION_DB_CRM_CONTACTS` | People and organizations |
| CRM Interactions | `NOTION_DB_CRM_INTERACTIONS` | Activity log linked to contacts |
| Specs & Plans | `NOTION_DB_SPECS_PLANS` | Human-readable mirror of Linear Documents |
| Stakeholder Dashboard | `NOTION_DB_STAKEHOLDER_DASHBOARD` | Weekly briefs, sprint reviews, status updates |

> See [references/database-schema.md](references/database-schema.md) for full property definitions.

## Graceful Degradation Pattern

Every skill that writes to Notion MUST follow this pattern:

```
1. Attempt primary action (Supabase ingestion, Linear Document creation, etc.)
2. If primary succeeds AND Notion connector available:
   a. Search Notion for existing page (by Supabase ID or Linear Issue ID)
   b. If found → notion-update-page with updated properties
   c. If not found → notion-create-pages with full content
   d. Log: "Synced to Notion: <page_title> (<database_name>)"
3. If Notion connector unavailable:
   a. Log: "Notion connector unavailable — skipping Notion sync, data persisted to <primary_store> only"
   b. Continue without error
```

## Notion AI Connectors (Business Plan)

With Notion Business, 14 AI Connectors let Notion AI search across connected tools:

| Connector | What humans can query from Notion |
|-----------|----------------------------------|
| Linear | "What are the open issues for sprint X?" |
| GitHub | "Show me recent PRs for the alteri app" |
| Google Calendar | "What meetings do I have this week?" |
| Google Drive | "Find the design spec doc" |
| Gmail | "Any emails from [contact] about [topic]?" |
| Slack | "What was discussed in #engineering today?" |

These complement ClinearHub's Cowork connectors: agents write TO Notion via MCP, humans query FROM Notion via AI Connectors. Two access patterns, one knowledge hub.

## /sync-notion Action

Full sync between Supabase and Notion databases:

1. Query Supabase `research_papers` for papers modified since last sync
2. For each: search Notion by Supabase ID → create or update page
3. Query Supabase `research_findings` similarly → sync to Findings DB
4. Report sync summary: created/updated/skipped counts per DB
5. Update `last_synced` property on synced pages

**Trigger:** `/clinearhub:sync-notion` or automatically after `/research` ingestion.

## Cross-Surface Reference Conventions

Notion URLs follow the pattern: `https://www.notion.so/<workspace>/<page-id>`

In Linear issues and comments, link to Notion pages as:
```markdown
[Research: <paper_title>](https://www.notion.so/<page-url>)
[Dashboard: Week 10 2026](https://www.notion.so/<page-url>)
```

Surface-aware language for Notion content:
- **Notion pages** = stakeholder-friendly, visual, rich formatting
- **Linear issues** = process-focused, agent-readable
- **GitHub** = technical, code-centric

## Notion Mail & Calendar — Advisory

**Notion Mail** and **Notion Calendar** are **personal-only** tools — NOT suitable for CRM or team workflows:
- **Notion Mail**: A Gmail client with no shared inboxes, no team collaboration, and no CRM integration
- **Notion Calendar**: A Google Calendar wrapper, not a replacement — no team scheduling features

**For CRM email/calendar**, use monday.com native integrations:
- monday.com Gmail integration: auto-logs sent/received emails on Contact/Deal timelines
- monday.com GCal integration: client meetings auto-appear on Contact timelines
- These are CRM-native — zero additional configuration beyond OAuth

## Cross-Skill References

- **research-intelligence** — Phase 4.5: Notion sync after Supabase ingestion
- **plan-persistence** — Phase 1.5d: Notion mirror after Linear Document promotion
- **wrap-up** — Extends Phase 1.5 to include Notion mirror
- **crm-management** — CRM operations using monday.com (Notion CRM DBs are read-only summaries populated by `/crm-report`)
- **customer-ops** — Service ticket summaries optionally synced to Stakeholder Dashboard DB
- **content-marketing** — Campaign performance summaries optionally synced to dashboard
- **clinearhub-workflow** — `/stakeholder-update` writes to Stakeholder Dashboard DB
- **task-management** — `/weekly-brief` writes to Stakeholder Dashboard DB
- **roadmap-management** — `/roadmap-update` writes initiative snapshots to dashboard
- **data-analytics** — Analytics snapshots persist to Stakeholder Dashboard DB
