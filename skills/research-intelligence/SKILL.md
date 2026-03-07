---
name: research-intelligence
description: |
  Research intelligence for the Alteri platform. Provides context about the research
  data pipeline, paper ingestion, RAG-enhanced comparisons, and research surfaces.
  Use when discussing research papers, literature search, research findings,
  paper ingestion, research database, Supabase research tables, vector search,
  embeddings, or any question about how research data flows through the system.
  Also triggers for questions about Semantic Scholar, arXiv, OpenAlex, HuggingFace
  papers, Zotero integration, Notion research hub, or Obsidian research vault (deprecated).
---

# Research Intelligence

## Architecture

```
AUTONOMOUS INGESTION                    INTERACTIVE RESEARCH
========================               ========================
weekly-research.md (GAW)               ClinearHub /research cmd
  └─ paper-search MCP                    └─ S2, OpenAlex, arXiv
daily-paper-digest.md (GAW)            Claude Code sessions
  └─ HF Daily Papers + arXiv              └─ Perplexity, Zotero
                                            OpenNotebook MCPs
         │                                       │
         ▼                                       ▼
┌─────────────────────────────────────────────────────┐
│              Supabase (pgvector)                     │
│  research_papers │ research_findings │ connections   │
│  prompt_versions │ research_sessions                 │
└──────────┬───────────┬──────────┬───────────────────┘
           │           │          │
     ┌─────┘     ┌─────┘    ┌────┘
     ▼           ▼          ▼
  Alteri App   Notion      OpenNotebook
  RAG inject   Research     weekly digest
               Hub (MCP)
```

## Research Database (Supabase)

**Project:** `heesyjucnsatjjolyztt.supabase.co` (eu-west-1)

### Tables

| Table | Purpose |
|-------|---------|
| `research_papers` | Paper metadata + embeddings (vector 768, gemini-embedding-001) |
| `research_findings` | Extracted insights from papers |
| `research_connections` | Links findings → frameworks/scenarios |
| `research_sessions` | Audit trail for research activity |
| `prompt_versions` | Versioned prompts with research grounding |
| `research_session_papers` | Papers discovered in each session |
| `notebook_sources` | OpenNotebook integration tracking |
| `paper_resources` | Supplementary resources for papers |
| `routing_knowledge` | Clinical sensitivity routing rules |

### Edge Functions

| Function | Purpose | Endpoint |
|----------|---------|----------|
| `ingest-paper` | Paper ingestion + dedup | POST `/functions/v1/ingest-paper` |
| `discover-connections` | Finding→framework/scenario mapping | POST `/functions/v1/discover-connections` |

### Paper Stage Workflow

```
discovered → screened → analyzed → promoted
                                 → rejected
```

Papers with `relevance_score >= 0.7` are automatically set to `analyzed`.

## RAG Pipeline

The Alteri app's `/api/compare` route supports research-augmented generation:

1. Feature flag `ragEnabled` in `apps/alteri/lib/config/registry.ts` gates the feature
2. When enabled, `modules/research-context/query.ts` searches `research_findings` by relevance
3. `modules/research-context/inject.ts` formats findings into a `## Research Context` section
4. The section is appended to each framework's system prompt before streaming

Uses vector similarity search (gemini-embedding-001, 768 dims) with keyword fallback when embeddings are unavailable.

## Autonomous Pipelines

| Pipeline | Trigger | Frequency | Budget |
|----------|---------|-----------|--------|
| `weekly-research.md` | Cron Monday | Weekly | 0x premium (gpt-4.1) |
| `daily-paper-digest.md` | Cron daily 08:00 UTC | Daily | 0x premium (gpt-4.1) |
| Connection discovery | Via Edge Function | On demand / weekly | Edge Function only |

## Research Connector Tiers

| Tier | Connectors | Surface |
|------|-----------|---------|
| **Core** | Linear (issue creation) | All |
| **Enhanced** | Semantic Scholar, arXiv, OpenAlex | Code/Antigravity |
| **Supplementary** | HuggingFace, Perplexity, Zotero | Per-session |

## Interactive Research Surfaces

| Surface | Tools | Use Case |
|---------|-------|----------|
| Cowork | `/research` + OAuth connectors | Ad-hoc literature search |
| Claude Code | Perplexity, Zotero, OpenNotebook MCPs | Deep exploration |
| Positron | R + `httr2` → Supabase REST | Statistical analysis |
| Notion | Research Papers + Findings DBs via MCP | Browsable research hub |
| Obsidian | Vault at `01-Projects/Claudian/Alteri/Research/` (deprecated) | Legacy knowledge graph |

## Research Labels

| Label | Meaning |
|-------|---------|
| `research:needs-grounding` | Issue needs literature review |
| `research:literature-mapped` | Papers identified, findings extracted |
| `research:methodology-validated` | Research supports the approach |
| `research:expert-reviewed` | Human researcher has validated |

## Notion Research Hub (Phase 4.5)

After Supabase ingestion (Phase 4 of `/research`), sync papers and findings to Notion:

1. For each ingested paper:
   a. `notion-search` for existing page by Supabase ID
   b. If found → `notion-update-page` with updated properties (stage, relevance_score)
   c. If not found → `notion-create-pages` in Research Papers DB with full metadata + abstract as page body
2. For each finding:
   a. `notion-search` for existing page by Supabase ID
   b. Create or update in Research Findings DB with relation to parent paper
3. Log sync summary: "Synced N papers and M findings to Notion Research Hub"

If Notion connector unavailable: skip silently, log "Notion unavailable — research data persisted to Supabase only."

> See [notion-hub](../notion-hub/SKILL.md) for database schema and MCP tool reference.

See also: `research-ideation` skill for hypothesis generation from literature gaps.
