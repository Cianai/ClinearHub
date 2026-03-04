# ClinearHub

Cowork-first PM methodology plugin for Claudian. ClinearHub (Claude + Linear + GitHub) handles triage, roadmap, incident response, analytics, and deployment verification — the interactive business workflow layer. Spec creation happens upstream in ChatPRD; autonomous implementation happens downstream via GitHub Agentic Workflows.

## Architecture (v2.0)

```
Phase 1: SPEC (ChatPRD)          → Phase 2: TRIAGE (Cowork + ClinearHub)
Phase 3: IMPLEMENT (GitHub gh-aw) → Phase 4: MERGE (GitHub CI)
Phase 5: RECONCILE (GitHub Actions) → Phase 6: REVIEW (Cowork + ClinearHub)
```

Human touches Phase 1 (write spec) and Phase 6 (review outcomes). Everything else is autonomous.

## Stack

| Category | Tool | Transport |
|----------|------|-----------|
| Project tracker | Linear | OAuth Connector |
| Source control | GitHub | OAuth Connector |
| Spec creation | ChatPRD | MCP Server (Claude Code) / Linear Agent |
| Implementation | GitHub Agentic Workflows (gh-aw) | GitHub Actions |
| Code review | GitHub Copilot | GitHub Ruleset |
| Analytics | PostHog | Desktop Connector |
| Error tracking | Sentry | OAuth Connector |
| CI/CD | GitHub Actions | OAuth Connector |
| Deployment | Vercel + Railway | Desktop Connector / CLI |
| Design | Figma + Magic Patterns | OAuth Connector |
| CRM | Linear Customer Requests + Notion | OAuth Connector |
| Email | Gmail | OAuth Connector |
| Calendar | Google Calendar | OAuth Connector |
| Meetings | Granola | Desktop Connector |
| Diagrams | Mermaid Chart | Desktop Connector |

## Agent Pipeline

Agents handle the spec-to-ship loop autonomously:

1. **ChatPRD** — Spec creation + enrichment. Triggered upstream by human or by `spec:draft` label in Linear. Pulls context from Linear, GitHub, Granola, Google Drive.
2. **gh-aw / Copilot Coding Agent** — Implementation. Triggered by `auto:implement` label via Linear↔GitHub two-way sync. Creates branch + PR.
3. **GitHub Copilot** — Code review. Auto-triggered on PR via `copilot-auto-review` ruleset.
4. **ClinearHubBot** — Post-merge reconciliation. Ticks ACs, posts evidence, cascades to parent/milestone.
5. **Sentry** — Error tracking. Auto-creates Linear issues from production errors.

## Components

### Reference Skills (9) — auto-loaded by model for context

| Skill | Purpose |
|-------|---------|
| `clinearhub-workflow` | Core 6-phase pipeline, triage rules, label taxonomy, agent dispatch |
| `plan-persistence` | Plan lifecycle, Linear Document promotion, session start context recovery |
| `issue-lifecycle` | Status transitions, ownership boundaries, closure protocol |
| `incident-response` | Sentry→Linear error pipeline, triage, severity classification, RCA |
| `task-management` | Daily standups, issue critique |
| `deployment-verification` | Vercel + Railway deploy checks, Supabase env sync, zero-touch loop |
| `data-analytics` | PostHog analytics, monitoring, data warehouse, notebooks |
| `roadmap-management` | Strategic roadmap via Linear Initiatives + Milestones, Now/Next/Later |
| `research-intelligence` | Research data pipeline, paper ingestion, RAG, Supabase pgvector |

### Archived Skills (2) — in `skills/_archived/`, kept for reference

| Skill | Reason Archived | Replacement |
|-------|-----------------|-------------|
| `spec-enrichment` | ChatPRD handles spec creation upstream | ChatPRD + @chatprd Linear agent |
| `discovery-digest` | `dependency-monitor.yml` handles this in GitHub Actions | Existing workflow |

### Action Skills (13) — user-invoked via `/clinearhub:<name>`

| Skill | Description |
|-------|-------------|
| `triage` | Pull Linear Triage inbox, categorize, apply labels, route |
| `stakeholder-update` | Multi-source status update with audience adaptation (exec, team, customer, board) |
| `decompose` | Spec to sub-issues with `auto:implement` label |
| `sprint-planning` | Cycle review, velocity analysis, capacity table, sprint goal, stretch items |
| `weekly-brief` | Cross-project digest: Linear + PostHog + Sentry + Vercel + GCal |
| `incident` | Triage production errors, classify severity, perform RCA, route fixes |
| `critique` | Review issue quality before agent dispatch |
| `deploy-checklist` | Pre/post-deploy verification for Vercel and Railway deployments |
| `analyze` | Analyze product data from PostHog using HogQL, funnels, notebooks |
| `verify` | Post-merge outcome validation — synthesize all AI + agent work for human review |
| `sync-docs` | Check and sync plugin reference files with external targets (Linear UI, Desktop) |
| `roadmap-update` | View, update, and manage strategic roadmap via Initiatives and Milestones |
| `sync-status` | Mechanical cross-surface status sync to Linear + GitHub |
| `research` | Ad-hoc literature search, scoring, Supabase ingestion, Linear issue creation |

### Query Skills (2) — auto-invocable by model

| Skill | Description |
|-------|-------------|
| `update` | Sync/digest from all sources, duplicate detection |
| `standup` | Daily standup summary from Linear + Sentry + Vercel + PostHog |

## Installation

### Claude Code (local development)

```bash
# From repo root
claude plugin add ./packages/clinear-plugin
```

### Cowork / Claude Desktop

Download `clinearhub-plugin.zip` from the [latest release](https://github.com/Cianai/ClinearHub/releases/latest), then drag it into Claude Desktop > Settings > Plugins > Upload.

Alternatively, build locally:

```bash
cd ~/Repositories/ClinearHub && ./packages/clinear-plugin/build-plugin.sh --open
```

### Updating

When a new version is tagged, CI auto-builds and publishes to [Releases](https://github.com/Cianai/ClinearHub/releases). Download the zip and re-upload to Claude Desktop. Restart your Cowork session to pick up changes.

### ClinearHubBot GitHub App

ClinearHubBot is a GitHub App that powers the automated parts of the Clinear pipeline:

- **Post-merge reconciliation**: Updates Linear issue statuses when PRs are merged
- **Dependency monitoring**: Daily ecosystem discovery via GitHub Search API + RSS feeds, auto-creates Linear `type:spike` issues for new tools/plugins/MCPs
- **Release automation**: Syncs version info to Linear project descriptions on release

**For Claudian contributors**: ClinearHubBot is already installed on the Claudian repo. No action needed.

**For other ClinearHub adopters**: Install the [ClinearHubBot GitHub App](https://github.com/apps/clinearhubbot) on your repo. The app needs:
- Read/write access to issues, PRs, and contents
- A `.github/monitored-repos.yml` file listing your dependency repos (see [example](../../.github/monitored-repos.yml))
- Linear API key and project ID configured as repository secrets (`LINEAR_API_KEY`, `LINEAR_PROJECT_ID`)

> **Note**: The app is currently configured for the Claudian workspace. Generalization for arbitrary Linear teams/projects (per-repo config via `.github/clinearhub.yml`) is tracked in [CIA-789](https://linear.app/claudian/issue/CIA-789/generalize-clinearhubbot-github-app-for-arbitrary-repos).

### Creating a Release

```bash
# 1. Bump version in packages/clinear-plugin/.claude-plugin/plugin.json
# 2. Commit and push
# 3. Tag and push the tag:
cd ~/Repositories/ClinearHub && git tag v1.0.0 && git push origin v1.0.0
```

CI will build the zip, generate release notes from commits, and publish the release.

## Setup

### Connectors (configure in Claude Desktop > Settings > Connectors)

All connectors should be configured globally — do **not** bundle them in the plugin `.mcp.json` to avoid duplicate tool registrations. See [Known Issues](#known-issues--caveats) for details.

OAuth Connectors (global): Linear, GitHub, Notion, Figma, Sentry, Google Calendar, Gmail

Desktop Connectors (Settings > Connectors): PostHog, Vercel, Granola, Mermaid Chart, Google Drive, HuggingFace
### Required Connectors

ClinearHub relies on global OAuth connectors — it does **not** bundle its own MCP servers. Connect these in Claude Desktop > Settings > Connectors (or `claude.ai/settings/connectors`):

| Tier | Connector | Purpose |
|------|-----------|---------|
| **Core** | Linear | Issue tracking, triage, specs, agent dispatch |
| **Core** | GitHub | PRs, code review, zero-touch loop |
| **Enhanced** | Sentry | Error tracking, alerting, root cause analysis |
| **Enhanced** | PostHog | Product analytics, feature adoption, funnels |
| **Enhanced** | Vercel | Deployment status, preview verification |
| **Supplementary** | Notion | Knowledge base, meeting notes |
| **Supplementary** | Figma | Design handoff, component specs |
| **Supplementary** | Google Calendar | Sprint planning, standups |
| **Supplementary** | Gmail | Stakeholder updates |
| **Supplementary** | Granola | Meeting notes → Linear issue pipeline |
| **Supplementary** | Mermaid Chart | Architecture and process diagrams |

Core connectors are required — commands fail without them. Enhanced connectors degrade gracefully (commands complete with reduced data). Supplementary connectors are optional (affected sections silently omitted).

### Linear Configuration

- **Team:** Claudian (CIA), sub-teams: Alteri (ALT), SoilWorx (SWX)
- **Triage Intelligence:** Auto-applies team, project, and labels. See [`linear-manual-config.md`](docs/linear-manual-config.md) for UI-only settings.
- **Triage Rules:** Bug routing (urgent/high → auto-dispatch to Copilot)
- **Labels:** Workspace-level labels (type, spec, exec, ctx, research, template, source, auto)
- **Full reference:** [`linear-agent-config.md`](skills/clinearhub-workflow/references/linear-agent-config.md)

### Secrets (Doppler)

ClinearHub uses [Doppler](https://www.doppler.com/) to manage API keys. Import the template for one-click project setup:

[![Import to Doppler](https://raw.githubusercontent.com/DopplerHQ/integration-logos/main/doppler/import-to-doppler.svg)](https://dashboard.doppler.com/workplace/template/import?template=https%3A%2F%2Fgithub.com%2FCianai%2FClinearHub%2Fblob%2Fmain%2Fdoppler-template.yaml)

This creates a `claude-tools` project with all required secret placeholders organized by tier. Fill in your API key values in the Doppler dashboard. See the [Operator Guide](skills/clinearhub-workflow/references/operator-guide.md#6-first-time-setup-onboarding) for step-by-step onboarding.

### Configuration Surfaces

See [CONNECTORS.md](CONNECTORS.md) for the full 4-surface configuration guide:
- **Surface A:** ClinearHub Plugin (`.mcp.json` is intentionally empty — use global OAuth connectors)
- **Surface A:** Global OAuth Connectors (Claude Desktop > Settings > Connectors)
- **Surface B:** Linear Agents & Integrations (Settings UI, documented in [`linear-agent-config.md`](skills/clinearhub-workflow/references/linear-agent-config.md))
- **Surface C:** GitHub Repo Config (Copilot, CI, Dependabot, auto-merge)
- **Surface D:** Claude Code Repo Config (`CLAUDE.md`, skills, plugins)

### Key References

| Reference | What | Link |
|-----------|------|------|
| Pipeline Architecture | 6-phase spec-to-ship pipeline (v2.0) | [Linear Document](linear://claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f) |
| CONNECTORS.md | 4-surface configuration guide | [CONNECTORS.md](CONNECTORS.md) |
| Agent Guidance | Text for Linear Settings > Team > Agents | [`linear-agent-config.md`](skills/clinearhub-workflow/references/linear-agent-config.md) |
| Cowork Instructions | Text for Claude Desktop > Settings > Instructions | [`cowork-instructions.md`](skills/clinearhub-workflow/references/cowork-instructions.md) |
| Triage Rules | Triage protocol, Sentry routing, Phase 8 automation | [`triage-rules.md`](skills/clinearhub-workflow/references/triage-rules.md) |
| Label Taxonomy | All workspace labels with rules | [`label-taxonomy.md`](skills/clinearhub-workflow/references/label-taxonomy.md) |
| Execution Modes | quick/tdd/pair/checkpoint/swarm/spike | [`execution-modes.md`](skills/clinearhub-workflow/references/execution-modes.md) |
| ChatPRD Personas | Working Backwards, Five Whys, Pre-Mortem, Layman Clarity | [`chatprd-personas.md`](skills/_archived/spec-enrichment/references/chatprd-personas.md) (archived) |
| PR/FAQ Templates | 4 spec templates (feature, infra, research, quick) | [`prfaq-templates.md`](skills/_archived/spec-enrichment/references/prfaq-templates.md) (archived) |
| Cross-Surface References | Link formatting, surface-aware language, multimedia processing | [`cross-surface-references.md`](skills/clinearhub-workflow/references/cross-surface-references.md) |
| Closure Protocol | Evidence requirements for issue closure | [`closure-protocol.md`](skills/issue-lifecycle/references/closure-protocol.md) |
| Sentry Pipeline | Sentry↔GitHub↔Linear error pipeline | [`sentry-github-pipeline.md`](skills/incident-response/references/sentry-github-pipeline.md) |
| PostHog Queries | HogQL patterns, funnel templates | [`posthog-queries.md`](skills/data-analytics/references/posthog-queries.md) |
| Vercel Checks | Deploy verification patterns | [`vercel-checks.md`](skills/deployment-verification/references/vercel-checks.md) |
| Railway Checks | Railway deployment verification | [`railway-checks.md`](skills/deployment-verification/references/railway-checks.md) |
| Plan Format | Plan document template and conventions | [`plan-format.md`](skills/plan-persistence/references/plan-format.md) |
| Promotion Protocol | Plan promotion to Linear Documents | [`promotion-protocol.md`](skills/plan-persistence/references/promotion-protocol.md) |
| Initiative Patterns | Initiative + Milestone management templates | [`initiative-patterns.md`](skills/roadmap-management/references/initiative-patterns.md) |
| Operator Guide | Human operator playbook — session lifecycle, releases, onboarding | [`operator-guide.md`](skills/clinearhub-workflow/references/operator-guide.md) |
| Manual Config | Linear UI settings not available via API (TI, triage rules, SLA) | [`linear-manual-config.md`](docs/linear-manual-config.md) |
| Doppler Template | One-click secret provisioning (Tiers 1-5, 24 secrets) | [`doppler-template.yaml`](./doppler-template.yaml) |
| Docs Sync Manifest | Source-target documentation sync | [`docs-sync.yml`](docs-sync.yml) |

## Stack Skills

ClinearHub handles PM methodology. Stack-specific coding skills (React, Next.js, Supabase, shadcn, etc.) are installed separately at the repo level in `.claude/skills/` via `npx skills add`. See the root `CLAUDE.md` for the full inventory.

## Known Issues & Caveats

### Plugin System Bugs (Claude Code)

These are upstream Claude Code issues that affect ClinearHub and all plugins:


These are upstream Claude Code issues that affect ClinearHub and all plugins:

| Issue | Impact | Workaround |
|-------|--------|------------|
| [Plugin duplication on reinstall](https://github.com/anthropics/claude-code/issues/26513) | Skills appear 2-4x in system prompt, wasting context | After reinstall, verify single entry in `~/.claude/plugins/installed_plugins.json` |
| [Disabled plugins still load skills](https://github.com/anthropics/claude-code/issues/13344) | `enabledPlugins: false` not fully respected | Fully uninstall disabled plugins, don't just toggle off |
| [Skills duplicated in system prompt](https://github.com/anthropics/claude-code/issues/29520) | Double context usage for all skills | No workaround — awaiting upstream fix |
| [Background subagents can't use MCP](https://github.com/anthropics/claude-code/issues/13254) | MCP tools unavailable in `run_in_background` agents | Use foreground subagents for any MCP-dependent task |

### Connector Duplication

**Do not bundle OAuth connectors in the plugin `.mcp.json`.** Claude Desktop global connectors and plugin-bundled connectors create duplicate tool registrations with no deduplication ([#2093](https://github.com/anthropics/claude-code/issues/2093)). ClinearHub's `.mcp.json` is intentionally empty — all connectors should be configured globally in Claude Desktop > Settings > Connectors.

If you previously had connectors bundled in the plugin, remove them and rely on global connectors to avoid:
- Triple tool registration on Code (stdio + OAuth + plugin)
- Double tool registration on Cowork (OAuth + plugin)
- ~90 extra deferred tools consuming context per session

### On-Demand MCP Loading

Tool Search (lazy schema loading) is available on **Claude Code only** — not on Desktop/Cowork. On Code, set `ENABLE_TOOL_SEARCH: "auto"` in settings to defer tool schemas until needed (~85% context reduction). Tool *names* still appear in every session regardless.

### Recommended Configuration

```jsonc
// ~/.claude/settings.json
{
  "env": {
    "ENABLE_TOOL_SEARCH": "auto"  // defer MCP tool schemas
  }
}
```

For Claude Code with stdio MCP servers (`~/.mcp.json`), avoid duplicating services already available as global OAuth connectors. If Linear is connected via OAuth, remove the Linear stdio server from `~/.mcp.json` to prevent duplicate tool registration.
