---
name: clinear-context
description: |
  Workspace identity, team structure, product portfolio, connector stack, pipeline overview, label conventions, issue naming, agent routing, and content voice. This skill provides foundational context that all other ClinearHub skills reference. Always loaded.
---

# ClinearHub Context

Foundation skill providing workspace identity and conventions for all ClinearHub operations. Other skills reference this for team structure, product context, and communication norms.

## Workspace Identity

**Claudian** is the Linear workspace and foundation monorepo. It serves as the technical platform for all products and internal tooling. The workspace is organized into three teams:

| Team | Prefix | Scope |
|------|--------|-------|
| **Claudian** (parent) | CIA | Shared infrastructure, cross-app concerns, ClinearHub methodology |
| **Alteri** (sub-team) | ALT | Alteri app — AI alignment research platform |
| **SoilWorx** (sub-team) | SWX | SoilWorx app — distributor finder |

Sub-teams inherit workflow states and settings from the parent but maintain separate backlogs and triage queues. Agent membership is NOT inherited — agents must be added to each sub-team explicitly.

## Team

- **Cian O'Sullivan** — Owner, PM, sole technical operator. Writes specs, reviews outcomes, makes all priority and business decisions.
- **Dad and brother** — Non-technical, Cognito operations. Handle client relationships, business development, and consultancy delivery. They interact with Linear through simplified views and stakeholder updates, not direct issue management.

## Products

### Alteri (ALT)
AI alignment research platform. Combines conversational elicitation (XState state machines, MI OARS methodology), academic literature integration (Zotero, OpenAlex, arXiv, Semantic Scholar), and structured research artifacts. Target users: alignment researchers, values-curious individuals. Voice: research-rigorous, academically grounded, but accessible to non-specialists.

### SoilWorx (SWX)
Distributor finder for the agricultural sector. Google Maps integration, XLSX import, location-based search. Target users: agricultural businesses seeking distribution partners. Voice: practical, industry-appropriate, no unnecessary technical jargon.

### ClinearHub
PM methodology and tooling layer. A Cowork-first plugin implementing the 6-phase spec-to-ship pipeline. Not a product sold to customers — it is the internal methodology that powers how Claudian builds everything else. Published publicly as a Claude plugin at `Cianai/ClinearHub`.

### Cognito
AI consultancy brand. Cognito is the business entity — it provides AI consulting services to external clients. Claudian is its technical foundation. Cognito does not have a dedicated app in the monorepo; its project in Linear tracks client work, proposals, and business operations.

## Connector Stack

### Core (required for pipeline operation)
| Connector | Purpose |
|-----------|---------|
| **Linear** | Issue tracking, project management, roadmap, triage |
| **GitHub** | Code, PRs, CI, agent dispatch, reconciliation |

### Enhanced (expand capability per domain)
| Connector | Purpose |
|-----------|---------|
| **monday.com** | CRM (contacts, leads, deals, pipeline), Service (tickets, SLA), Campaigns (email marketing). Source of truth for all customer data |
| **Sentry** | Error tracking, incident pipeline, production monitoring |
| **PostHog** | Product analytics, feature adoption, user behavior |
| **Vercel** | Deployment verification, preview URLs, production status |
| **Notion** | Knowledge hub — research papers, specs mirror, dashboards, read-only CRM summaries |
| **Perplexity** | Web research, competitor intel. Code: Perplexity MCP. Cowork: Claude built-in web search (automatic fallback) |

### Supplementary (context enrichment)
| Connector | Purpose |
|-----------|---------|
| **Granola** | Meeting transcripts (internal), action items, decision capture |
| **Gamma** | Presentation and deck generation for proposals |
| **Google Calendar** | Scheduling context, upcoming meetings |
| **Gmail** | Client communication history, follow-ups |
| **Google Drive** | Shared documents, research papers, client deliverables |
| **Mermaid** | Diagram generation and validation |
| **Excalidraw** | Wireframing, whiteboarding (Interactive — non-designer prototyping) |
| **Clay** | Prospect research, enrichment from 100+ sources → feeds monday.com CRM |
| **Stripe** | Payments, invoicing, subscriptions. Native monday.com integration syncs to Quotes & Invoices board |
| **Cloudflare** | Domain/DNS management, Workers, D1 |
| **Supabase** | Database, pgvector, edge functions (Code plugin + Cowork plugin) |
| **Figma** | Design assets, UI review (add when designer joins team) |

## monday.com Platform

monday.com serves as the **CRM and business operations platform** across three products:

| Product | Plan | What It Provides |
|---------|------|-----------------|
| **CRM Pro** | $84/mo (3 seats) | Contacts, Leads, Deals, Activities, Accounts, Client Projects, Products & Services, Quotes & Invoices, Sales Dashboard. Includes Campaigns (2K contacts, 20K emails/mo). Native AI: Sales Advisor, AI Blocks, AI Notetaker. |
| **Service** | Optional (+$84/mo) | Tickets, customer portal, AI Service Agent, SLA management, Knowledge Base. Graceful degradation: if not enabled, support routes through Linear + Sentry. |
| **Campaigns** | Included with CRM Pro | Email campaigns with CRM list segmentation, auto-refresh segments, campaign analytics tied to deal metrics. |

### monday.com Native AI (use in monday.com UI, not via Claude)

| Feature | When to Use | ClinearHub Complement |
|---------|------------|----------------------|
| **Sales Advisor** | Pipeline analysis, deal coaching, skill gap identification | Claude handles cross-system intelligence |
| **AI Service Agent** | Routine ticket resolution, personalized responses | Claude handles escalation to Linear |
| **AI Notetaker** | Client/sales call transcription → auto-feeds Activities board | Granola handles internal meetings |
| **AI Workflows** | CRM automations (stage changes, stale alerts, notifications) | Claude handles cross-system orchestration |
| **AI Blocks** | Column-level enrichment (sentiment, categorization, summarization) | No Claude equivalent — data enrichment |
| **Campaigns AI** | Email copy generation, send-time optimization | No Claude equivalent — marketing AI |
| **AI Agents (Sales/Lead)** | Automated outreach, lead nurturing at scale | Evaluate for Cognito pipeline |

### Meeting Transcription Split

| Meeting Type | Tool | Destination |
|-------------|------|-------------|
| Client/sales calls | monday.com AI Notetaker | Auto-feeds CRM Activities + deal timeline |
| Internal team meetings | Granola | Claude Cowork → Linear action items |
| Research/advisory | Granola | Claude Cowork → Notion knowledge hub |

## Pipeline Summary

```
SPEC (ChatPRD) --> TRIAGE (Cowork) --> IMPLEMENT (GitHub Agents) --> MERGE (CI) --> RECONCILE (GitHub Actions) --> REVIEW (Cowork)
```

- **Phase 1 — Spec:** Human writes spec with ChatPRD assistance. ChatPRD pulls context from Linear, GitHub, Granola, Google Drive via MCP connectors.
- **Phase 2 — Triage:** ClinearHub plugin in Cowork. Triage Intelligence auto-applies team, project, labels. Human confirms or corrects. Triage templates set metadata.
- **Phase 3 — Implement:** Autonomous agents (Copilot, gh-aw, Claude Code) pick up issues based on exec mode and `auto:implement` label.
- **Phase 4 — Merge:** Copilot auto-review, CI pipeline, auto-merge for bot PRs.
- **Phase 5 — Reconcile:** GitHub Actions post-merge: tick ACs, post evidence, cascade to parent issues.
- **Phase 6 — Review:** Human reviews outcomes in Cowork. Stakeholder updates, analytics review, next cycle planning.

Human touches Phase 1 (write spec) and Phase 6 (review outcomes). Everything else is autonomous.

## Label Conventions

Labels are workspace-level, organized into groups with **single-select enforcement** — only one label from each group per issue.

| Group | Labels | Notes |
|-------|--------|-------|
| **Type** (required) | `type:feature`, `type:bug`, `type:chore`, `type:spike` | Exactly one per issue |
| **Spec** | `spec:draft` `spec:ready` `spec:review` `spec:implementing` `spec:complete` | Progressive, replace on transition |
| **Exec** | `exec:quick` `exec:tdd` `exec:pair` `exec:checkpoint` `exec:swarm` | Set at triage, routes to agent |
| **Context** | `ctx:interactive` `ctx:autonomous` `ctx:review` `ctx:human` | Replace on surface change |
| **Dispatch** | `auto:implement`, `auto:investigate` | Triggers autonomous agents |
| **Research** | `research:needs-grounding` `research:literature-mapped` `research:methodology-validated` `research:expert-reviewed` | ALT primarily |
| **Template** | `template:prfaq-feature` `template:prfaq-infra` `template:prfaq-research` `template:prfaq-quick` | One per spec |

**Standalone labels** (no group, freely combinable): `urgent`, `dependencies`, `design`.

## Issue Naming

Verb-first, no bracket prefixes. Examples:

- `Build onboarding wizard for new users`
- `Implement paper artifact ingestion pipeline`
- `Survey distributor data sources in Ireland`
- `Fix authentication redirect loop on mobile`

Never use format like `[Alteri] Build X` or `CIA: Build X` — the team prefix and project assignment handle routing.

## Agent Routing

| Dispatch Label | Agent | Mechanism |
|----------------|-------|-----------|
| `auto:implement` + `exec:quick` | Copilot Coding Agent | Assign GitHub issue to `@github` |
| `auto:implement` + `exec:tdd` | gh-aw + Claude engine | `implement-issue.md` workflow |
| `auto:implement` + `exec:checkpoint` | gh-aw + approval gates | Workflow with human checkpoints |
| `auto:implement` + `exec:swarm` | Multiple gh-aw workflows | Parallel dispatch across sub-issues |
| `auto:investigate` | Spike investigation agent | `investigate-spike.md` workflow |
| `exec:pair` | Claude Code Desktop | Human-in-the-loop pairing session |

Estimate-to-mode mapping: 1-2pt = quick, 3pt = tdd, 5pt = tdd/pair, 8pt = pair/checkpoint, 13pt = decompose first.

## Content Voice

Adapt tone to the audience and product context:

| Context | Voice | Example |
|---------|-------|---------|
| **Alteri (research)** | Academically rigorous, evidence-based, precise terminology. Cite sources. | "The elicitation protocol implements motivational interviewing (MI) OARS techniques, validated by Miller & Rollnick (2012)." |
| **SoilWorx (industry)** | Practical, clear, industry-appropriate. Avoid unnecessary technical terms. | "Find distributors within 50km of your location, filtered by product category." |
| **Cognito (client-facing)** | Professional, accessible, solution-oriented. No internal jargon. | "We recommend a phased rollout starting with your highest-traffic workflows." |
| **ClinearHub (internal)** | Technical, precise, process-aware. Assume familiarity with the pipeline. | "Apply `exec:tdd` and `auto:implement` to dispatch via gh-aw." |
| **Stakeholder updates** | Strategic, outcome-focused, minimal technical detail. | "Three features shipped this sprint, reducing average onboarding time by 40%." |

When in doubt, optimize for clarity over impressiveness. Non-technical stakeholders (Cognito clients, family operations team) should never need to decode jargon to understand a communication.
