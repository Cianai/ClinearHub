# Notion Database Schema Reference

> Full property definitions for the 6 ClinearHub Notion databases.
> Design inspired by B2B CRM templates (Bozhedaroff, Startup Founder OS) and
> the Supabase research pipeline schema.

## DB1: Research Papers

Mirrors `research_papers` table in Supabase. Source of truth remains Supabase (pgvector, RAG).

| Property | Type | Notion Property Type | Notes |
|----------|------|---------------------|-------|
| Title | title | title | Paper title |
| Authors | text | rich_text | Comma-separated author names |
| DOI | url | url | Digital Object Identifier |
| arXiv ID | text | rich_text | arXiv identifier (e.g., 2401.12345) |
| Stage | select | select | discovered / screened / analyzed / promoted / rejected |
| Relevance Score | number | number | 0.0-1.0, from Supabase |
| Source API | select | select | semantic_scholar / arxiv / openalex / huggingface / zotero |
| Topics | multi-select | multi_select | ai-alignment, interpretability, governance, etc. |
| Abstract | text | rich_text | Full abstract text |
| Relevance Rationale | text | rich_text | Why this paper matters for Alteri |
| Supabase ID | text | rich_text | UUID from `research_papers.id` — used for sync dedup |
| Linear Issue | url | url | Link to ALT issue if one was created |
| Related Findings | relation | relation → Research Findings DB | One-to-many |
| Publication Date | date | date | Original publication date |
| Last Synced | date | date | Timestamp of last Notion sync |

**Views:**
- Default: Table sorted by Relevance Score descending
- By Stage: Board view grouped by Stage
- Recent: Table filtered to last 30 days, sorted by created date
- High Relevance: Table filtered to Relevance Score >= 0.7

### Supabase → Notion Property Mapping

| Supabase Column | Type | Notion Property | Conversion |
|----------------|------|-----------------|------------|
| `title` | text | Title (title) | Direct |
| `authors` | jsonb[] | Authors (rich_text) | `authors.map(a => a.name).join(', ')` |
| `doi` | text | DOI (url) | Prefix with `https://doi.org/` if not URL |
| `arxiv_id` | text | arXiv ID (rich_text) | Direct |
| `stage` | text | Stage (select) | Direct match |
| `relevance_score` | float | Relevance Score (number) | Direct |
| `source_api` | text | Source API (select) | Direct match |
| `topics` | text[] | Topics (multi_select) | Array → multi-select options |
| `abstract` | text | Abstract (rich_text) | Direct (truncate at 2000 chars for property, full in page body) |
| `relevance_rationale` | text | Relevance Rationale (rich_text) | Direct |
| `id` | uuid | Supabase ID (rich_text) | Direct |
| `publication_date` | date | Publication Date (date) | ISO 8601 |

## DB2: Research Findings

Mirrors `research_findings` table in Supabase.

| Property | Type | Notion Property Type | Notes |
|----------|------|---------------------|-------|
| Summary | title | title | 1-2 sentence finding summary |
| Finding Type | select | select | technique / empirical / theoretical / methodological / contradictory |
| Evidence Strength | select | select | proven / probable / possible / unresolved |
| Key Claims | text | rich_text | Bullet-separated claims |
| Paper | relation | relation → Research Papers DB | Many-to-one |
| Framework Connections | multi-select | multi_select | HSI / Constitutional AI / Hybrid |
| Scenario Categories | multi-select | multi_select | crisis / identity / boundaries / grief / relationships / existential |
| Application Notes | text | rich_text | How this finding informs Alteri |
| Supabase ID | text | rich_text | UUID from `research_findings.id` |
| Last Synced | date | date | Timestamp of last sync |

**Views:**
- Default: Table grouped by Finding Type
- By Evidence: Table sorted by Evidence Strength
- By Framework: Board grouped by Framework Connections

## DB3: CRM Contacts (Read-Only Summary)

**Source of truth: monday.com Contacts board.** This Notion database is a read-only summary view populated by `/crm-report`. Do NOT write directly — use the `crm-management` skill's monday.com integration instead. Bridges to Linear via Customer ID.

| Property | Type | Notion Property Type | Notes |
|----------|------|---------------------|-------|
| Name | title | title | Contact full name |
| Company | text | rich_text | Organization name |
| Role | select | select | user / stakeholder / advisor / researcher / investor / partner |
| Pipeline Stage | select | select | Contact Made / Needs Follow-Up / Pre-proposal / Proposal Sent / Won / Lost / Churned |
| Email | email | email | Primary email |
| LinkedIn | url | url | LinkedIn profile URL |
| Linear Customer ID | text | rich_text | Links to Linear Customer Requests |
| Last Contact | date | date | Date of most recent interaction |
| Deal Value | number | number | Estimated deal value (currency) |
| Notes | text | rich_text | Freeform notes |
| Interactions | relation | relation → CRM Interactions DB | One-to-many |

**Views:**
- Pipeline (Kanban): Board grouped by Pipeline Stage
- By Role: Table filtered by Role
- Stale Leads: Table sorted by Last Contact ascending, filtered to >30 days ago
- All Contacts: Default table view

**Page Templates:**
- New Customer: Pipeline Stage = Contact Made, Role = user
- New Advisor: Pipeline Stage = Contact Made, Role = advisor
- New Research Collaborator: Pipeline Stage = Contact Made, Role = researcher

## DB4: CRM Interactions (Read-Only Summary)

**Source of truth: monday.com Interactions board.** This Notion database is a read-only summary view populated by `/crm-report`. Do NOT write directly — use the `crm-management` skill's monday.com integration instead. Activity log linked to CRM Contacts.

| Property | Type | Notion Property Type | Notes |
|----------|------|---------------------|-------|
| Description | title | title | Brief interaction description |
| Contact | relation | relation → CRM Contacts DB | Many-to-one |
| Type | select | select | meeting / email / feedback / support / demo / call |
| Date | date | date | When the interaction occurred |
| Source | select | select | granola / gmail / linear / manual / notion-ai |
| Linear Issue | url | url | Related Linear issue URL |
| Next Action | text | rich_text | Follow-up action item |
| Outcome | text | rich_text | What happened, key takeaways |

**Views:**
- Timeline: Table sorted by Date descending
- By Type: Table filtered by Type
- By Contact: Table grouped by Contact relation

## DB5: Specs & Plans

Human-readable mirror of Linear Documents. Source of truth remains Linear.

| Property | Type | Notion Property Type | Notes |
|----------|------|---------------------|-------|
| Title | title | title | Plan/spec title |
| Status | select | select | draft / active / finalized / archived |
| Linear Document URL | url | url | Link to Linear Document |
| Linear Issue ID | text | rich_text | CIA-XXX, ALT-XXX, or SWX-XXX |
| Author | text | rich_text | Who created the plan |
| Tags | multi-select | multi_select | Freeform tags |
| Last Synced | date | date | When last synced from Linear |

Page body contains the full plan markdown rendered as Notion blocks.

**Views:**
- Active: Table filtered to Status = active or draft
- Archive: Table filtered to Status = finalized or archived
- By Issue: Table sorted by Linear Issue ID

## DB6: Stakeholder Dashboard

Persists outputs from `/stakeholder-update`, `/weekly-brief`, `/roadmap-update`.

| Property | Type | Notion Property Type | Notes |
|----------|------|---------------------|-------|
| Period | title | title | e.g., "Week 10 2026", "Sprint 2026-Q1-3" |
| Type | select | select | weekly-brief / sprint-review / stakeholder-update / incident-report / analytics-snapshot |
| Audience | select | select | executive / team / customer / board |
| Linear Cycle | text | rich_text | Linear cycle reference |
| Metrics Snapshot | text | rich_text | Velocity, completion %, error rate, etc. |
| Created | date | date | When the dashboard entry was created |

Page body contains the full report/brief content.

**Views:**
- Recent: Table sorted by Created descending
- By Type: Board grouped by Type
- By Audience: Table filtered by Audience

## Relation Map

```
Research Papers ◄──────── Research Findings
    (one)          relation       (many)

CRM Contacts (read-only) ◄──── CRM Interactions (read-only)
    (one)              relation       (many)
    │ source: monday.com /crm-report

CRM Contacts ──── text ref ──── Linear Customer Requests
monday.com Contacts ──── source of truth ──── Notion CRM Contacts (summary)
Specs & Plans ──── url ref ──── Linear Documents
Research Papers ── url ref ──── Linear Issues (ALT-XXX)
Stakeholder Dashboard ── text ref ──── Linear Cycles
```

## MCP Tool Patterns

### Create a research paper page

```
notion-create-pages({
  database: "<NOTION_DB_RESEARCH_PAPERS>",
  pages: [{
    properties: {
      Title: { title: [{ text: { content: paper.title } }] },
      Stage: { select: { name: paper.stage } },
      "Relevance Score": { number: paper.relevance_score },
      "Source API": { select: { name: paper.source_api } },
      Topics: { multi_select: paper.topics.map(t => ({ name: t })) },
      "Supabase ID": { rich_text: [{ text: { content: paper.id } }] },
      "Last Synced": { date: { start: new Date().toISOString() } }
    },
    content: paper.abstract  // rendered as page body
  }]
})
```

### Search before create (dedup)

```
notion-search({
  query: paper.supabase_id,
  filter: { property: "object", value: "page" }
})
// If found → notion-update-page instead of create
```

### Query papers by stage (Business plan)

```
notion-query-database-view({
  database: "<NOTION_DB_RESEARCH_PAPERS>",
  view: "By Stage",
  filter: { Stage: { equals: "analyzed" } }
})
```
