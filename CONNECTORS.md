# Connectors & Configuration Surfaces

> **Pipeline Architecture:** [Pipeline Architecture: Spec-to-Ship](https://linear.app/claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f) — canonical 10-phase pipeline reference (Linear Document, ClinearHub project).

ClinearHub's stack spans 4 distinct configuration surfaces. Each surface serves different agents with different tools.

## Surface A: ClinearHub Plugin (`.mcp.json`) — Cowork Sessions

OAuth Connectors bundled with the plugin. Auto-prompt for OAuth on first use in Cowork/Desktop.

### Required (core workflow)

| Tool | MCP endpoint | Purpose |
|------|-------------|---------|
| Linear | `mcp.linear.app/mcp` | Issue tracking, triage, specs, agent dispatch |
| GitHub | `api.githubcopilot.com/mcp/` | PRs, code review, zero-touch loop |
| Sentry | `mcp.sentry.dev/mcp` | Error tracking, alerting, root cause analysis |

### Recommended (enhanced workflow)

| Tool | MCP endpoint | Purpose |
|------|-------------|---------|
| Notion | `mcp.notion.com/mcp` | Knowledge base, meeting notes |
| Figma | `mcp.figma.com/mcp` | Design handoff, component specs |
| Google Calendar | `gcal.mcp.claude.com/mcp` | Sprint planning, standups |
| Gmail | `gmail.mcp.claude.com/mcp` | Stakeholder updates |

### Desktop Connectors (not plugin-bundled)

Configure manually in Claude Desktop > Settings > Connectors:

| Tool | Purpose |
|------|---------|
| PostHog | Product analytics, feature adoption, funnel analysis |
| Vercel | Deployment status, preview verification |
| Railway | Deployment platform, service management |
| Granola | Meeting notes → Linear issue pipeline |
| Mermaid Chart | Architecture and process diagrams |
| Google Drive | Document storage and sharing |
| HuggingFace | ML model discovery and evaluation |

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
2. `auto:implement` label → Codex (implementation, creates PR)

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

### Rulesets (applied via claudegbot API)

| Ruleset | Purpose |
|---------|---------|
| `copilot-auto-review` | Auto-request Copilot review on push + drafts |
| `main-protection` | Deletion prevention, block force push, require PRs, required status checks |

### Workflows

| Workflow | Purpose |
|---------|---------|
| `ci.yml` | Lint + typecheck + build on every push/PR |
| `auto-merge-bots.yml` | Zero-touch loop: bot PR → auto-merge (self-contained, no CCC dependency) |
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

**Not installed (cherry-pick into ClinearHub instead):** product-management (merge into spec-enrichment + stakeholder-update), customer-support (merge into Phase 2c customer-intelligence + knowledge-management).

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

**Setup:** Verify GitHub integration configured for Claudian-Clinear repo in Vercel dashboard.

**Docs:** https://vercel.com/docs/git

### PostHog Session Replay

**Status:** Disabled in Alteri for privacy (research participants must not be recorded). PII scrubbing configured in `apps/alteri/instrumentation-client.ts`. Do not enable without explicit approval.

**Docs:** https://posthog.com/docs/session-replay/integrations

## Connector Interaction Patterns

### Three-Tier Model

| Tier | Connectors | Availability | Failure Mode |
|------|-----------|-------------|--------------|
| **Core** (pipeline breaks without) | Linear, GitHub | OAuth (plugin) | Command fails with error — cannot proceed |
| **Enhanced** (richer output, degrades gracefully) | Sentry, PostHog, Vercel, Railway | OAuth/Desktop/CLI | Command completes with reduced data, notes missing source |
| **Supplementary** (optional enrichment) | Figma, Notion, GCal, Gmail, Granola, Mermaid | OAuth (plugin/desktop) | Command completes normally, skips section |

### Command → Connector Cross-Reference

| Command | Core | Enhanced | Supplementary |
|---------|------|----------|--------------|
| `/triage` | Linear (R/W) | Sentry (R) | — |
| `/write-spec` | Linear (W) | — | Notion (R), Granola (R) |
| `/decompose` | Linear (R/W) | — | — |
| `/stakeholder-update` | Linear (R) | Sentry (R), PostHog (R), Vercel (R) | Gmail (W), GCal (R) |
| `/sprint-planning` | Linear (R/W) | — | GCal (R) |
| `/update` | Linear (R) | Sentry (R), PostHog (R), Vercel (R) | — |
| `/weekly-brief` | Linear (R) | Sentry (R), PostHog (R), Vercel (R) | GCal (R) |
| `/standup` | Linear (R) | Sentry (R), PostHog (R), Vercel (R) | — |
| `/incident` | Linear (R/W) | Sentry (R/W) | — |
| `/critique` | Linear (R) | — | — |
| `/deploy-checklist` | GitHub (R) | Vercel (R), Railway (R), Sentry (R), PostHog (R) | — |
| `/analyze` | — | PostHog (R/W) | — |
| `/verify` | Linear (R/W), GitHub (R) | Sentry (R), PostHog (R), Vercel (R) | Figma (R) |
| `/plan` | Linear (R/W) | — | — |
| `/roadmap-update` | Linear (R/W) | — | — |
| `/sync-status` | Linear (R/W), GitHub (R/W) | Vercel (R), Sentry (R) | — |
| `/sync-docs` | — | — | — (file-only) |

**Legend:** R = read, W = write, R/W = both.

### Data Flow Directions

```
Inbound (→ Linear):
  Sentry errors → Linear issues (auto-create)
  Linear Asks (email/Slack) → Linear issues
  GitHub PR merge → Linear issue Done (via "Closes CIA-XXX")
  GitHub PR open → Linear issue In Progress

Outbound (Linear →):
  spec:draft label → ChatPRD enrichment
  auto:implement label → Codex implementation
  Issue context → v0/Codex/Cursor via coding tools button

Bidirectional:
  Linear ↔ GitHub (PR comments sync, status transitions)
  Linear ↔ Figma (issue↔design linking)
```

### Graceful Degradation

When a connector is unavailable:
1. **Core tier missing:** Command aborts with clear error message identifying which connector is needed
2. **Enhanced tier missing:** Command completes but notes the missing data source in output (e.g., "Sentry connector unavailable — error check skipped")
3. **Supplementary tier missing:** Command completes normally, affected section silently omitted

### Design Tool Chain

| Tool | Surface | Role | Figma Integration |
|------|---------|------|-------------------|
| **Figma** | OAuth Connector (Cowork + Desktop) | Production design hub | IS the hub |
| **Magic Patterns** | Cowork Connector | Rapid text→mockup | Via html.to.design Figma plugin |
| **v0** | Linear Coding Tool | React/shadcn scaffolding | Code to Canvas → Figma |
| **Pencil** | Claude Code Plugin (.pen) | In-code design sketches | Copy-paste preserving styles |
| **Mobbin** | Browser + Figma plugin | UI/UX reference library | Figma plugin: copy patterns |

**Transfer pipelines (no manual paste):** html.to.design (code→Figma layers), Code to Canvas (browser→Figma frame), Figma MCP `get_design_context` (Figma→React+Tailwind).

All design work happens in **Cowork** (primary) or **Claude Desktop with Preview** (when Code is needed). See [Desktop Preview docs](https://code.claude.com/docs/en/desktop#preview-your-app).

## Setup Checklist

1. **Plugin OAuth** — Connect all 7 plugin connectors on first Cowork session
2. **Desktop Connectors** — PostHog, Vercel, Granola, Mermaid Chart in Settings > Connectors
3. **Linear Integrations** — Verify GitHub, Figma, Sentry configs (see `linear-agent-config.md`)
4. **Linear Integrations** — Configure PostHog + Vercel integrations
5. **Sentry↔GitHub** — Code mappings, PR comments, suspect commits in Sentry Settings
6. **Vercel↔Git** — Verify auto-deploy for Claudian-Clinear repo
7. **Figma Code Connect** — Separate issue: map `@claudian/ui` components (design-system task)
8. **Repo secrets** — Add 5 Linear secrets for dependency monitoring workflows
