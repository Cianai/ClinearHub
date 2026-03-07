# Connectors & Configuration Surfaces

> **Pipeline Architecture:** [Pipeline Architecture: Spec-to-Ship](linear://claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f) — canonical 6-phase pipeline reference (Linear Document, ClinearHub project). v2.0: upstream spec creation (ChatPRD), GitHub Agentic Workflows for implementation, ClinearHub for interactive business layer.

ClinearHub's stack spans 5 distinct configuration surfaces. Each surface serves different agents with different tools.

## Surface A: Global OAuth Connectors — Cowork & Desktop Sessions

ClinearHub's `.mcp.json` is **intentionally empty** — all connectors should be configured globally in Claude Desktop > Settings > Connectors to avoid duplicate tool registrations ([#2093](https://github.com/anthropics/claude-code/issues/2093)). The connectors listed below are required/recommended but must be set up globally, not bundled in the plugin.
ClinearHub does **not** bundle its own MCP servers (`.mcp.json` is empty). All connectors are configured globally in Claude Desktop > Settings > Connectors (or `claude.ai/settings/connectors`). This avoids duplicate tool registrations — see [Known Issues in README](README.md#known-issues--caveats).

> **Why not plugin-bundled?** Plugin `.mcp.json` servers duplicate global OAuth connectors with no deduplication logic ([#2093](https://github.com/anthropics/claude-code/issues/2093)). Each duplicate adds ~30 deferred tools to the context window. With 7 bundled connectors, that's ~210 extra tools registered for nothing.

### Required (core workflow)

| Tool | Connect via | Purpose |
|------|-----------|---------|
| Linear | Settings > Connectors | Issue tracking, triage, specs, agent dispatch |
| GitHub | Settings > Connectors | PRs, code review, zero-touch loop |

### Enhanced (degrades gracefully)

| Tool | Connect via | Purpose |
|------|-----------|---------|
| monday.com | Settings > Connectors / CLI (`~/.mcp.json`) | CRM: contacts, deals, pipeline, interactions (14-day Pro trial, then free or $28/seat/mo) |
| Sentry | Settings > Connectors | Error tracking, alerting, root cause analysis |
| PostHog | Settings > Connectors | Product analytics, feature adoption, funnel analysis |
| Vercel | Settings > Connectors | Deployment status, preview verification |
| Notion | Settings > Connectors | Knowledge hub: research, specs, stakeholder dashboards, read-only CRM summaries (Business plan recommended for AI Connectors + `notion-query-database-view`) |
| Perplexity | CLI (`~/.mcp.json`) / built-in | Web research, competitor intel. **Code sessions:** Perplexity MCP (citation-rich, deeper). **Cowork sessions:** Claude built-in web search (automatic fallback, always available). Skills degrade gracefully across surfaces. |

### Supplementary (optional)

| Tool | Connect via | Purpose |
|------|-----------|---------|
| Cloudflare | Settings > Connectors | Domain/DNS management, Workers, D1 |
| Figma | Settings > Connectors | Design handoff, component specs (add when designer joins) |
| Google Calendar | Settings > Connectors | Sprint planning, standups |
| Gmail | Settings > Connectors | Stakeholder updates |
| Granola | Settings > Connectors | Meeting notes → Linear issue pipeline |
| Gamma | Settings > Connectors | Presentation, proposal, and document generation |
| Mermaid Chart | Settings > Connectors | Architecture and process diagrams |
| Google Drive | Settings > Connectors | Document storage and sharing |
| HuggingFace | Settings > Connectors | ML model discovery and evaluation |
| Excalidraw | Settings > Connectors | Wireframing, whiteboarding (Interactive — non-designer prototyping) |
| Clay | Settings > Connectors | Prospect research, enrichment from 100+ sources. **No native monday.com push** — route via n8n (Interactive) |
| Stripe | Settings > Connectors | Payments, invoicing, subscriptions (R/W + Skills, $1000 GitHub credits). Native monday.com Stripe integration syncs charges/invoices to Quotes & Invoices board. |
| Railway | CLI (`~/.mcp.json`) | Deployment platform (no OAuth connector available) |
| ChatPRD | CLI (`~/.mcp.json`) | Spec querying during Claude Code sessions |
| Supabase | CLI (`~/.mcp.json`) / Plugin | Database, pgvector, edge functions (Code plugin + Cowork plugin) |
| Slack | Settings > Connectors | Async client/team comms (DEFERRED — add when team grows or clients need it) |
| Mobbin | User (manual) | Design inspiration library. User browses by industry, screenshots patterns. No MCP — user shares screenshots in conversation. See `design-workflow` skill. |
| v0.dev | User (manual) | Rapid UI prototyping from text/image prompts. User generates 2-3 variations, shares with agent for comparison. No MCP — user operates directly. See `design-workflow` skill. |
| Claude Preview | Code (MCP plugin) | Frontend verification: `preview_start`, `preview_screenshot`, `preview_click`, `preview_fill`. Agent uses for section checkpoints during builds. See `design-workflow` skill. |

## Surface B: Linear Agents & Integrations

Configuration lives in Linear Team Settings UI. Version-controlled reference: `skills/clinearhub-workflow/references/linear-agent-config.md`.

### Coding Tools (Settings > Preferences)

| Tool | Status | Role |
|------|--------|------|
| Codex | Enabled | Primary implementation via `auto:implement` triage rule |
| Cursor | Enabled | IDE-based interactive implementation |
| Cto.new | Enabled | Background agent execution |
| GitHub Copilot | Enabled | Code review + coding agent |
| v0 | Enabled | UI component generation |
| Claude Code | Disabled | Reserved for Cowork/Desktop |

Prompt template passes issue ID, description, comments, updates, linked references, and images automatically to all coding tools.

### Triage Rules (Settings > Team > Triage)

1. `spec:draft` label → ChatPRD (spec enrichment with personas)
2. `auto:implement` label → Codex (implementation, creates PR) — also triggers gh-aw via Linear↔GitHub two-way sync

### Native Integrations (Settings > Integrations)

| Integration | Purpose | Status |
|------------|---------|--------|
| GitHub | Bidirectional sync: PR status → issue transitions, synced comments, `Closes CIA-XXX` magic words | Enabled, needs config verification |
| Figma | Create issues from Figma, link designs, embedded previews | Enabled, needs config verification |
| Sentry | Auto-create issues from production errors | Enabled, needs config verification |
| PostHog | Create issues from PostHog, bidirectional links | Enabled, needs configuration |
| Vercel | Link deployments to issues, status sync | Enabled, needs configuration |

## Surface C: GitHub Repo Config

Configuration lives in the repo's `.github/` directory and GitHub Settings.

### Copilot Instructions

| File | Scope |
|------|-------|
| `.github/copilot-instructions.md` | All files — stack, conventions, security review |
| `.github/instructions/apps.instructions.md` | `apps/**` — app-specific patterns |
| `.github/instructions/packages.instructions.md` | `packages/**` — shared package patterns |

### Rulesets (applied via ClinearHubBot API)

| Ruleset | Purpose |
|---------|---------|
| `copilot-auto-review` | Auto-request Copilot review on push + drafts |
| `main-protection` | Deletion prevention, block force push, require PRs, required status checks |

### Workflows

| Workflow | Purpose |
|---------|---------|
| `ci.yml` | Lint + typecheck + build on every push/PR |
| `implement-issue.md` | **gh-aw:** Autonomous implementation of `auto:implement` labeled issues |
| `auto-merge-bots.yml` | Zero-touch loop: bot PR → auto-merge (self-contained) |
| `post-merge-reconciliation.yml` | **Post-merge 3-tier cascade:** tick ACs, post evidence, update milestone/initiative, sync README/releases |
| `dependabot-linear.yml` | Bridge Dependabot PRs → Linear issues (majors) + release log |
| `dependency-monitor.yml` | External repo release monitoring (15-min cron, Atom feeds) |

### Dependabot

`dependabot.yml` — Weekly Monday, npm + github-actions ecosystems. Minor+patch grouped to reduce noise.

## Surface D: Claude Code Repo Config

Configuration for interactive dev sessions (Claude Code, Cursor IDE).

### Project Instructions

- `CLAUDE.md` — comprehensive project instructions (stack, conventions, CI, issue tracker)
- `.claude/settings.json` — plugin/MCP enablement

### Repo-Scoped Skills (`.claude/skills/`)

14 installed skills covering stack best practices: React, Next.js, Supabase, shadcn, Turborepo, pnpm, Vercel patterns, AI SDK, Sentry SDK setup, Sentry issue fixing, Sentry alert creation, Railway deployment.

### User-Level Plugins

| Plugin | Role | Status |
|--------|------|--------|
| `sentry-mcp` | Subagent delegation to Sentry MCP | Installed |
| `frontend-design` | Production-grade frontend craft | Installed |
| `typescript-lsp` | Code intelligence | Installed |
| `engineering` (customized) | Code review, system design, tech debt, testing strategy, docs | Install (strip overlapping ClinearHub commands) |
| `design` | Design handoff, design system management, UX writing | Per-session enable for design work |
| `Supabase` | DB, auth, edge functions, migrations | Installed |
| `Vercel` | Deploy, logs, setup | Installed |
| `claude-md-management` | CLAUDE.md auditor | Install |

**Not installed (cherry-pick into ClinearHub instead):** product-management (merge into stakeholder-update), customer-support (merge into knowledge-management).

**Skipped:** productivity, data, operations, finance, legal, marketing, HR, sales, enterprise-search, bio-research.

## Cross-Surface Integrations

These integrations span multiple surfaces and need configuration in each:

### Sentry ↔ GitHub

Connects error tracking to source code across Surface B (Linear) + Surface C (GitHub).

| Feature | What it does |
|---------|-------------|
| Suspect commits | Identifies recent code changes in stack trace files |
| Stack trace linking | Links errors to source code with version-specific URLs |
| PR comments | Surfaces issues on merged PRs (< 2 weeks) and open PRs |
| Resolve via commit | `fixes SENTRY-ID` in commits auto-resolves Sentry issues |
| AI code review (Seer) | AI-generated code review feedback on PRs |

**Setup:** Sentry Settings > Integrations > GitHub > Configure code mappings, enable PR comments, enable suspect commits.

**Docs:** https://docs.sentry.io/organization/integrations/source-code-mgmt/github/

### Figma ↔ GitHub (Code Connect)

Bridges design system to production code (Surface B + Surface C).

| Feature | What it does |
|---------|-------------|
| Code Connect | Shows production `@claudian/ui` snippets in Figma Dev Mode |
| Asset sync | Figma assets → GitHub repo via community plugins |

**Setup:** Install `figma/code-connect`, create config mapping `@claudian/ui` components.

**Docs:** https://github.com/figma/code-connect

**Note:** Requires Figma Organization or Enterprise plan (full Design or Dev Mode seat).

### Vercel ↔ Git

Deployment automation via GitHub integration (Surface C).

| Feature | What it does |
|---------|-------------|
| Auto deploy | Every push creates a deployment |
| Preview per PR | Preview URL posted on every PR |
| Production deploy | Merge to main triggers production deployment |
| Status checks | Deploy status reported on PR |

**Setup:** Verify GitHub integration configured for Claudian repo in Vercel dashboard.

**Docs:** https://vercel.com/docs/git

### PostHog Session Replay

**Status:** Disabled in Alteri for privacy (research participants must not be recorded). PII scrubbing configured in `apps/alteri/instrumentation-client.ts`. Do not enable without explicit approval.

**Docs:** https://posthog.com/docs/session-replay/integrations

## Connector Interaction Patterns

### Three-Tier Model

| Tier | Connectors | Availability | Failure Mode |
|------|-----------|-------------|--------------|
| **Core** (pipeline breaks without) | Linear, GitHub | Global OAuth | Command fails with error — cannot proceed |
| **Enhanced** (richer output, degrades gracefully) | monday.com, Sentry, PostHog, Vercel, Notion, Perplexity (Code: MCP / Cowork: built-in web search) | Global OAuth / CLI / built-in | Command completes with reduced data, notes missing source |
| **Supplementary** (optional enrichment) | Cloudflare, Figma, GCal, Gmail, Granola, Gamma, Mermaid, Excalidraw, Clay, Stripe, Railway, Supabase | Global OAuth / CLI | Command completes normally, skips section |

### Command → Connector Cross-Reference

| Command | Core | Enhanced | Supplementary |
|---------|------|----------|--------------|
| `/triage` | Linear (R/W) | Sentry (R), monday.com (R) | — |
| `/write-spec` | Linear (W) | Notion (R) | Granola (R) |
| `/decompose` | Linear (R/W) | — | — |
| `/stakeholder-update` | Linear (R) | Sentry (R), PostHog (R), Vercel (R), Notion (W) | Gmail (W), GCal (R) |
| `/sprint-planning` | Linear (R/W) | — | GCal (R) |
| `/update` | Linear (R) | Sentry (R), PostHog (R), Vercel (R) | — |
| `/weekly-brief` | Linear (R) | Sentry (R), PostHog (R), Vercel (R), Notion (W) | GCal (R) |
| `/standup` | Linear (R) | Sentry (R), PostHog (R), Vercel (R) | — |
| `/incident` | Linear (R/W) | Sentry (R/W) | — |
| `/critique` | Linear (R) | — | — |
| `/deploy-checklist` | GitHub (R) | Vercel (R), Sentry (R), PostHog (R) | Railway (R) |
| `/analyze` | — | PostHog (R/W) | — |
| `/verify` | Linear (R/W), GitHub (R) | Sentry (R), PostHog (R), Vercel (R) | Figma (R) |
| `/plan` | Linear (R/W) | — | — |
| `/roadmap-update` | Linear (R/W) | Notion (W) | — |
| `/sync-status` | Linear (R/W), GitHub (R/W) | Vercel (R), Sentry (R) | — |
| `/sync-docs` | — | — | — (file-only) |
| `/sync-notion` | — | Notion (W) | — |
| `/research` | Linear (W) | Semantic Scholar (R), arXiv (R), OpenAlex (R) | Perplexity (R), Zotero (R), HuggingFace (R) |
| `/crm-log` | — | monday.com (W) | Notion (W, fallback), Granola (R) |
| `/crm-lookup` | — | monday.com (R) | Notion (R, fallback) |
| `/crm-report` | — | monday.com (R), Notion (W) | PostHog (R), Stripe (R) |
| `/call-prep` | Linear (R) | monday.com (R) | Granola (R), GCal (R) |
| `/competitive-brief` | Linear (R) | monday.com (R), Perplexity (R) | Clay (R) |
| `/content-plan` | Linear (R/W) | Perplexity (R), PostHog (R) | GCal (R), Gamma (W), Granola (R) |
| `/client-review` | Linear (R) | monday.com (R) | Granola (R), GCal (R) |
| `/launch-brief` | Linear (R), GitHub (R) | Vercel (R), Sentry (R), PostHog (R) | — |

**Legend:** R = read, W = write, R/W = both.

### Data Flow Directions

```
Inbound (→ Linear):
  ChatPRD → Linear issues (spec creation via "Open in → Linear Issue" or @chatprd agent)
  Sentry errors → Linear issues (auto-create)
  Linear Asks (email/Slack) → Linear issues
  GitHub PR merge → Linear issue Done (via "Closes CIA-XXX")
  GitHub PR open → Linear issue In Progress
  ClinearHubBot → evidence comments, ticked ACs, milestone/initiative updates (post-merge)

Outbound (Linear → GitHub, via two-way sync):
  auto:implement label → GitHub issue (two-way sync) → gh-aw / Copilot Coding Agent
  spec:draft label → ChatPRD enrichment (Linear triage rule)
  Issue context → v0/Codex/Cursor via coding tools button

Bidirectional:
  Linear ↔ GitHub (two-way issue sync + PR comments + status transitions)
  Linear ↔ Figma (issue↔design linking)

Upstream (ChatPRD → everything):
  ChatPRD MCP connectors ← Linear, GitHub, Granola, Google Drive (context sources)
  ChatPRD → Linear issues (primary output)
  ChatPRD → Google Drive (doc export)
  ChatPRD MCP server → Claude Code (spec querying)

Research Pipeline (→ Supabase → Alteri App):
  weekly-research.md (GAW) → paper-search MCP → Supabase research_papers (weekly)
  daily-paper-digest.md (GAW) → HF Daily Papers + arXiv → Supabase research_papers (daily)
  /research (Cowork) → Semantic Scholar/arXiv/OpenAlex → Supabase research_papers (on-demand)
  discover-connections (Edge Function) → research_connections (on-demand)
  Supabase research_findings → Alteri /api/compare RAG injection (on each request)
  Supabase → Obsidian vault (01-Projects/Claudian/Alteri/Research/) via export script
  Zotero (alteri tag) → Supabase research_papers (weekly sync)

CRM Pipeline (Clay → monday.com → Stripe):
  Clay (enrichment) → monday.com CRM (contacts, companies, tech stack, buying intent)
  Granola (meeting notes) → /crm-log → monday.com Activities board
  monday.com Contacts board → /crm-lookup → context for /triage, /call-prep
  monday.com Deals board → /crm-report → Notion Stakeholder Dashboard DB (read-only)
  monday.com Contacts ↔ Linear Customer Requests (bridge via contact ID)
  Stripe (payments) ↔ monday.com Quotes & Invoices (native integration, auto-sync)
  Stripe → /crm-report (payment status, revenue data)

Knowledge Hub (Notion):
  Supabase research_papers → /sync-notion → Notion Research Papers DB
  Linear Documents → /plan-persistence → Notion Specs & Plans DB
  /weekly-brief, /stakeholder-update → Notion Stakeholder Dashboard DB
  monday.com /crm-report → Notion CRM Contacts/Interactions DBs (read-only summaries)

Domain Management (Cloudflare):
  Cloudflare MCP → D1, KV, R2, Workers (dev platform)
  Cloudflare dashboard → DNS records, zones, redirect rules (no MCP tools for these)
  Vercel Plugin → domain mapping verification

Agent Identity (ClinearHubBot):
  GitHub Actions → commits/comments as ClinearHubBot (GitHub App)
  Linear comments → createAsUser: "ClinearHubBot"
```

### Graceful Degradation

When a connector is unavailable:
1. **Core tier missing:** Command aborts with clear error message identifying which connector is needed
2. **Enhanced tier missing:** Command completes but notes the missing data source in output (e.g., "Sentry connector unavailable — error check skipped")
3. **Supplementary tier missing:** Command completes normally, affected section silently omitted

### Design Tool Chain (No Designer Required)

| Step | Tool | Surface | Purpose |
|------|------|---------|---------|
| 1. Wireframe (optional) | **Excalidraw** | Cowork Interactive | Rough layout, whiteboarding. Or just describe in natural language. |
| 2. Spec | **ChatPRD** | Code MCP / Cowork | PR/FAQ with UI requirements (pulls context from Linear + Granola + Drive + CRM) |
| 3. Prototype | **v0** | Linear Coding Tool | Generate initial React/Tailwind/shadcn components from spec description |
| 4. Refine | **Claude Code** | Desktop + App Preview | Import v0 output into monorepo, iterate with auto-verify (screenshot, DOM inspect, click) |
| 5. PM review | **Claude Desktop** | App Preview | Preview at localhost (Alteri :3001, SoilWorx :3002, Plan Review :3003) → inline feedback |
| 6. Client review | **Vercel** | Preview URLs | Push to branch → auto-generated preview URL per PR → client views in browser (no login) |
| 7. Feedback | **Linear** | Comments | Client/PM feedback as Linear issue comments → feed back into step 4 |

**Design inspiration**: Client screenshots/URLs (Claude processes via file attachments), Mobbin for pattern reference (manual), shadcn/ui skill provides component patterns.

**Transfer pipeline**: v0 → monorepo code → Claude Code refine → Vercel preview URL → client. No Figma in the loop unless a designer joins the team.

**Pencil** (Claude Code plugin, `.pen` files) available for in-code design sketches. **Figma** connector available if needed for external design handoff.

All design work happens in **Cowork** (primary) or **Claude Desktop with Preview** (when Code is needed). See [Desktop Preview docs](https://code.claude.com/docs/en/desktop#preview-your-app).

### Integration Chain (Clay → n8n → monday.com → Stripe)

```
Clay (research & enrich 100+ sources)
  ↓ via n8n (Clay has NO native monday.com push — only HubSpot/Salesforce/Pipedrive)
monday.com CRM (store & manage — source of truth)
  ↓ native Stripe integration
Stripe (invoice creation, payment collection)
  ↓ auto-sync charges/invoices/subscriptions
monday.com Quotes & Invoices (track payment status)
  ↓ /crm-report
Notion Stakeholder Dashboard (read-only summaries)
```

**Enrichment Tiering** (prefer native tools, escalate to Clay for volume):

| Tier | Tool | Source | Limit | Use Case |
|------|------|--------|-------|----------|
| 1 (built-in) | **Crunchbase** | monday.com CRM Settings | 1,000 items lifetime (free) | Company: funding, industry, employee count, revenue |
| 2 (marketplace) | **Lusha** | monday.com Marketplace | 50 credits/month (free tier) | Contact: email, phone, job title, seniority, department |
| 3 (high-volume) | **Clay** | OAuth → n8n → monday.com | Pay-per-enrichment | Deep research: tech stack, buying intent, 100+ sources |

Tier 1+2 are native monday.com — zero middleware. Tier 3 requires n8n (`n8n-nodes-clay` community node) as Clay lacks native monday.com integration. Defer Tier 3 until outbound volume exceeds 750+/month.

### Notion Mail & Calendar — Advisory

**Notion Mail** and **Notion Calendar** are **personal-only** tools:
- **Notion Mail**: A Gmail client — no shared inboxes, no team collaboration, no CRM integration
- **Notion Calendar**: A Google Calendar wrapper — not a replacement, no team scheduling features

**Do NOT use these for CRM processes.** Instead:
- **CRM email tracking**: monday.com native Gmail integration (Emails & Activities — auto-logs sent/received on Contact/Deal timelines)
- **CRM calendar**: monday.com native GCal integration (client meetings auto-appear on Contact timelines)
- **Meeting scheduling**: Google Calendar directly (with GCal OAuth connector for agent access)

### Partner Skill Ecosystem

ClinearHub skills **orchestrate across** partner tools. Partner skills handle their own domain generically. Both coexist — specificity wins when Claude picks which skill to apply.

| Partner | Repository | Skills Provided | ClinearHub Complement |
|---------|-----------|-----------------|----------------------|
| **Sentry** | `getsentry/sentry-agent-skills` | `sentry-fix-issues`, `sentry-create-alert`, `sentry-react-sdk`, `sentry-nextjs-sdk` | `incident-response` (Sentry→Linear pipeline, severity classification, RCA) |
| **Vercel** | `vercel-labs/agent-skills` | `vercel-react-best-practices`, `vercel-composition-patterns`, `web-design-guidelines` | `deployment-verification` (deploy status in broader checklist) |
| **Stripe** | [`stripe/ai`](https://github.com/stripe/ai) | MCP at `mcp.stripe.com`, `@stripe/agent-toolkit`, Best Practices skill | `small-team-finance` (Stripe data + monday.com Quotes & Invoices + cash flow) |
| **Cloudflare** | [`cloudflare/skills`](https://github.com/cloudflare/skills) | Workers, D1, KV, R2, AI, Agents SDK, Wrangler, web-perf (8 skills, 4 remote MCPs) | `deployment-verification` references Cloudflare for DNS |
| **Notion** | [`makenotion/claude-code-notion-plugin`](https://github.com/makenotion/claude-code-notion-plugin) | Knowledge Capture, Meeting Intelligence, Research Documentation, Spec to Implementation (4 skills, 10 commands) | `notion-hub` (6-database architecture, stakeholder dashboards) |

**Integration principle**: Partner skill = "find and fix this error". ClinearHub skill = "triage severity → create Linear issue → check Vercel deploy → correlate PostHog user impact → post RCA to Linear".

## Setup Checklist

1. **Core Connectors** — Connect Linear, GitHub in Settings > Connectors
2. **Enhanced Connectors** — Connect monday.com, Sentry, PostHog, Vercel, Notion in Settings > Connectors
3. **monday.com CRM** — Create monday.com account (14-day Pro trial, no CC), set up 9 boards (Contacts, Leads, Deals, Activities, Accounts, Client Projects, Products & Services, Quotes & Invoices, Sales Dashboard), connect OAuth connector. Fallback: Notion CRM databases.
4. **Supplementary Connectors** — Connect Excalidraw, Clay, Stripe, GCal, Gmail, Granola, Gamma, Mermaid, Google Drive, HuggingFace, Cloudflare in Settings > Connectors. Optionally: Figma (if designer joins).
5. **Stripe↔monday.com** — Enable native Stripe integration in monday.com: auto-syncs charges/invoices/subscriptions to Quotes & Invoices board.
6. **Clay→n8n→monday.com** — Configure n8n workflow: Clay enrichment → n8n → monday.com CRM boards (`n8n-nodes-clay` community node). Clay has NO native monday.com push.
7. **Verify no plugin-bundled duplicates** — ClinearHub `.mcp.json` should be `{"mcpServers": {}}`. If upgrading from <v1.2, rebuild the plugin zip after clearing it.
8. **Linear Integrations** — Verify GitHub, Sentry, PostHog, Vercel configs (see `linear-agent-config.md`)
9. **Sentry↔GitHub** — Code mappings, PR comments, suspect commits in Sentry Settings
10. **Vercel↔Git** — Verify auto-deploy for Claudian repo
11. **Cloudflare Domains** — Create zones for cianos.ai + redirect domains, configure DNS records, set up iCloud+ email
12. **Repo secrets** — Add 5 Linear secrets for dependency monitoring workflows
13. **Partner Skills** — Install Stripe AI, Cloudflare (Workers + Wrangler), Notion (Knowledge Capture + Research Docs) in `.claude/skills/`
