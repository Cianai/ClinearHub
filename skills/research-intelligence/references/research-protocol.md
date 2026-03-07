# /research Protocol (v2.0)

> Systematic literature review protocol. Sources: letitbk/lit-review (5-phase structure, PRISMA),
> emaynard/family-history (evidence classification, conflict resolution),
> huifer/WellAlly (3-tier recommendation classification).

## Usage

```
/clinearhub:research "topic or query"
```

## Workflow

### Phase 0: Scope the Research Question

Before any search, clarify the research intent. Use AskUserQuestion to establish:

1. **Specific question** — what exactly are we trying to answer?
2. **Scope type** — systematic review (exhaustive) / scoping review (landscape) / quick search (targeted)
3. **Date range** — last 6 months (default) / last year / all time / custom
4. **Inclusion criteria** — what makes a paper relevant? (default: AI alignment, interpretability, governance, human-AI interaction, evaluation)
5. **Exclusion criteria** — what should be filtered out? (e.g., non-English, conference abstracts only, specific subfields)

If the user provides a quick topic without context, assume **scoping review** with **6-month** window and Alteri's default research areas as inclusion criteria. Skip the dialogue for quick searches.

### Phase 1: Search — Zotero First, Then External

Search in this priority order:

1. **Zotero library** (`zotero_search_items`, `zotero_advanced_search`) — check existing library FIRST
   - Search by title, author, and tag
   - Surface any existing annotations the user has already made
   - If sufficient coverage found in Zotero, skip external search
2. **Semantic Scholar** (`search_papers`) — primary for peer-reviewed papers
3. **OpenAlex** (`search_works`) — for broader coverage and citation data
4. **arXiv** (`search_papers`) — for preprints and recent submissions
5. **Perplexity** (`perplexity_research`) — for synthesised research summaries (fallback)

For each source, search with:
- The user's exact query
- 2-3 derived keyword variations
- Date filter per Phase 0 scope

Record: **N_found** = total papers found across all sources (before dedup).

### Phase 2: Screen — PRISMA-Style Filtering

Apply systematic screening to all results:

1. **Deduplication** — match by DOI, arXiv ID, or title similarity. Record: **N_dedup** = papers remaining after dedup.

2. **Abstract screening** — for each paper, assess against inclusion/exclusion criteria from Phase 0.
   Record: **N_screened** = papers passing abstract screening. For each excluded paper, note the exclusion reason (off-topic / wrong methodology / wrong date range / duplicate idea).

3. **Full-text assessment** (for systematic/scoping only) — if abstract is borderline, read full text via Zotero or source API.

Report the full screening funnel:
```
Papers found: N_found → After dedup: N_dedup → After screening: N_screened → Excluded: N_excluded (reasons: ...)
```

### Phase 3: Extract — Structured Evidence Table

For each paper passing screening, extract a structured evidence record:

| Field | Source | Notes |
|-------|--------|-------|
| Author (Year) | Paper metadata | Primary author + year |
| Study Design | Abstract/methods | RCT / observational / computational / theoretical / review |
| Sample/Scale | Abstract/methods | N participants, dataset size, model count |
| Key Finding | Results | 1-2 sentence core finding |
| Evidence Level | Assessment | proven (>75%) / probable (60-75%) / possible (50-60%) / unresolved (<50%) |
| Source Type | Classification | original research / systematic review / preprint / opinion |
| Relevance | Assessment | Score 0-1 against inclusion criteria |

#### Evidence Classification (from Genealogical Proof Standard adapted for research)

For each finding, classify on three dimensions:
- **Source type**: original paper / systematic review / preprint / opinion / dataset
- **Information type**: primary empirical data / secondary synthesis / meta-analysis / theoretical
- **Evidence type**: directly answers the research question / implies / contradicts / contextualises

#### Conflict Detection

If two findings contradict each other, explicitly note the conflict:
- Which papers disagree
- On what specific claim
- Which has stronger evidence (by study design, sample size, publication venue)
- Resolution status: resolved / unresolved / needs-investigation

### Phase 4: Ingest to Supabase

For papers scoring >= 0.7 relevance, call the ingest-paper Edge Function:

```bash
curl -X POST https://heesyjucnsatjjolyztt.supabase.co/functions/v1/ingest-paper \
  -H "Authorization: Bearer ${SUPABASE_ANON_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "...",
    "abstract": "...",
    "authors": [{"name": "..."}],
    "doi": "...",
    "arxiv_id": "...",
    "topics": ["ai-alignment"],
    "source_api": "semantic_scholar",
    "relevance_score": 0.85,
    "relevance_rationale": "...",
    "findings": [{
      "finding_type": "technique",
      "summary": "...",
      "evidence_strength": "strong",
      "key_claims": ["..."],
      "alteri_relevance": {
        "features": ["scenario_explorer"],
        "frameworkIds": ["constitutional"]
      }
    }]
  }'
```

Note: Embeddings are now generated automatically by the Edge Function (Google gemini-embedding-001, 768 dims, free tier). No separate embedding step needed.

### Phase 4.5: Sync to Notion Research Hub

After Supabase ingestion, mirror papers and findings to Notion for human browsing. This step is **optional** — it degrades gracefully if Notion is unavailable.

For each paper ingested in Phase 4:

1. **Dedup check**: `notion-search` for the paper's Supabase ID in the Research Papers DB
2. **If found**: `notion-update-page` — update Stage, Relevance Score, and Last Synced
3. **If not found**: `notion-create-pages` in Research Papers DB:
   - Properties: Title, Authors, DOI, arXiv ID, Stage, Relevance Score, Source API, Topics (multi_select), Supabase ID, Publication Date, Last Synced
   - Page body: Abstract + Relevance Rationale as formatted blocks
4. For each finding on the paper:
   - `notion-search` for finding's Supabase ID in Research Findings DB
   - Create or update with: Summary, Finding Type, Evidence Strength, Key Claims, Framework Connections, Scenario Categories
   - Set Paper relation to the parent paper's Notion page

**Graceful degradation**: If `notion-search` or `notion-create-pages` fails, log "Notion sync skipped — data persisted to Supabase only" and continue to Phase 5.

**Property mapping reference**: See `notion-hub/references/database-schema.md` for full Supabase → Notion column mapping.

### Phase 5: Log Research Session

**Always** record the search in `research_sessions` — even for zero-result searches (negative evidence is still evidence):

```sql
INSERT INTO research_sessions (name, description, keywords, surface, papers_found, findings_created)
VALUES ('Ad-hoc: [topic]', '[query + scope + inclusion criteria]', ARRAY['keyword1', 'keyword2'], 'cowork', X, Y);
```

### Phase 6: Present Results

Format output with PRISMA funnel, evidence table, 3-tier recommendations, and gaps:

```markdown
## Research: [Topic]

### Screening Funnel
Papers found: X → After dedup: Y → After screening: Z → Excluded: W
- Off-topic: A
- Wrong methodology: B
- [other reasons]: C

### Evidence Table

| Author (Year) | Design | Sample | Key Finding | Evidence Level | Relevance |
|---|---|---|---|---|---|
| Smith (2026) | Computational | 12 models | SAE features... | probable | 0.9 |
| Jones (2025) | Review | 45 papers | Alignment tax... | proven | 0.85 |

### Findings by Priority

#### Tier 1 — Act This Sprint (directly actionable, informs ALT issue creation)
- [Finding with specific feature/design implication]

#### Tier 2 — Monitor (design input, backlog)
- [Finding that informs future direction]

#### Tier 3 — Context Only (background knowledge)
- [Finding that adds understanding but no immediate action]

### Conflicts
- **[Claim X]**: Paper A says [position], Paper B says [counter-position]. Evidence favours [A/B/unresolved]. [Resolution needed / resolved by C]

### Gaps
What is ABSENT from the literature:
- No papers found on [specific angle]
- [Topic area] has only preprints, no peer-reviewed work
- [Methodology X] has not been applied to [domain Y]

### Session Details
- Scope: [systematic/scoping/quick] | Date range: [range]
- Sources searched: Zotero (N hits), Semantic Scholar (N), arXiv (N), ...
- Papers found: X | Ingested: Y | Duplicates: Z
- Conflicts detected: N | Gaps identified: M
- Session logged to Supabase
- Notion sync: X papers, Y findings synced (or "skipped — connector unavailable")
```

### Phase 7: Suggest Follow-ups

Based on findings and gaps:
- **Tier 1 findings** → offer to create ALT issues with `research:needs-grounding` label
- **Conflicts** → offer to create a research spike to resolve
- **Gaps** → note for next `weekly-research.md` search query refinement
- **Citation network** → for high-relevance papers, suggest following the citation network via Semantic Scholar `get_paper_citations` (FAN principle: follow the paper's references and citations to discover related work the keyword search missed)

## Error Handling

- If no connectors available: fall back to Perplexity web search
- If Supabase unavailable: skip ingestion, still present results
- If no papers found: report clearly in the PRISMA funnel, log the zero-result session, suggest alternative search terms and note this as a gap
