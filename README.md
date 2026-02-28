# ClinearHub

Cowork-first PM methodology plugin for Claudian. ClinearHub (Claude + Linear + GitHub) consolidates product management, engineering ops, design, data analytics, customer support, and operations into one opinionated plugin built for our stack.

## Stack (Hardcoded — No Placeholders)

| Category | Tool | Transport |
|----------|------|-----------|
| Project tracker | Linear | OAuth Connector |
| Source control | GitHub | OAuth Connector |
| CRM | Linear Customer Requests + Notion | OAuth Connector |
| Knowledge base | Notion + GitHub | OAuth Connector |
| Design | Figma + Magic Patterns | OAuth Connector |
| Analytics | PostHog | Desktop Connector |
| Error tracking | Sentry | OAuth Connector |
| CI/CD | GitHub Actions | OAuth Connector |
| Deployment | Vercel + Railway | Desktop Connector / CLI |
| Email | Gmail | OAuth Connector |
| Calendar | Google Calendar | OAuth Connector |
| Meetings | Granola | Desktop Connector |
| Spec enrichment | ChatPRD | Linear Agent |
| Diagrams | Mermaid Chart | Desktop Connector |

## Agent Pipeline

Four agents handle the spec-to-ship loop autonomously via Linear triage rules:

1. **ChatPRD** — Spec enrichment. Triggered by `spec:draft` label. Enriches specs with personas, creates sub-issues with `auto:implement`.
2. **Codex** — Implementation. Triggered by `auto:implement` label. Implements sub-issues, creates PRs.
3. **GitHub Copilot** — Code review. Auto-triggered on PR via `copilot-auto-review` ruleset.
4. **Sentry** — Error tracking. Auto-creates Linear issues from production errors.

## Components

### Skills (9)

| Skill | Purpose |
|-------|---------|
| `clinearhub-workflow` | Core 6-step methodology, triage rules, label taxonomy |
| `spec-enrichment` | PR/FAQ + PRD templates, acceptance criteria, ChatPRD personas |
| `issue-lifecycle` | Status transitions, ownership boundaries, closure protocol |
| `incident-response` | Sentry→Linear error pipeline, triage, severity classification, RCA |
| `task-management` | Daily standups, issue critique |
| `deployment-verification` | Vercel + Railway deploy checks, Supabase env sync, zero-touch loop |
| `data-analytics` | PostHog analytics, monitoring, data warehouse, notebooks |
| `plan-persistence` | Session plan lifecycle — promote to Linear Documents, versioning, finalize |
| `roadmap-management` | Strategic roadmap via Linear Initiatives + Milestones, Now/Next/Later |

### Commands (17)

| Command | Description |
|---------|-------------|
| `/write-spec` | Guided spec creation, push to Linear with `spec:draft` |
| `/triage` | Pull Linear Triage inbox, categorize, apply labels, route |
| `/stakeholder-update` | Multi-source status update with audience adaptation (exec, team, customer, board) |
| `/decompose` | Spec to sub-issues with `auto:implement` label |
| `/sprint-planning` | Cycle review, velocity analysis, capacity table, sprint goal, stretch items |
| `/update` | Sync/digest from all sources, duplicate detection |
| `/weekly-brief` | Cross-project digest: Linear + PostHog + Sentry + Vercel + GCal |
| `/incident` | Triage production errors, classify severity, perform RCA, route fixes |
| `/standup` | Daily standup summary from Linear + Sentry + Vercel + PostHog |
| `/critique` | Review issue quality before agent dispatch |
| `/deploy-checklist` | Pre/post-deploy verification for Vercel and Railway deployments |
| `/analyze` | Analyze product data from PostHog using HogQL, funnels, notebooks |
| `/verify` | Post-merge outcome validation — synthesize all AI + agent work for human review |
| `/sync-docs` | Check and sync plugin reference files with external targets (Linear UI, Desktop) |
| `/plan` | Manage session plans — promote, review, list, index, finalize |
| `/roadmap-update` | View, update, and manage strategic roadmap via Initiatives and Milestones |
| `/sync-status` | Mechanical cross-surface status sync to Linear + GitHub |

### Planned Skills

| Skill | Purpose |
|-------|---------|
| `customer-intelligence` | Linear Customer Requests + Notion CRM + Asks |
| `knowledge-management` | Notion + Linear docs |
| `design-workflow` | Figma + Magic Patterns + UX writing |
| `meeting-intelligence` | Granola to Linear issue pipeline |

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

### Creating a Release

```bash
# 1. Bump version in packages/clinear-plugin/.claude-plugin/plugin.json
# 2. Commit and push
# 3. Tag and push the tag:
cd ~/Repositories/ClinearHub && git tag v1.0.0 && git push origin v1.0.0
```

CI will build the zip, generate release notes from commits, and publish the release.

## Setup

### OAuth Connectors (in plugin .mcp.json)

Linear, GitHub, Notion, Figma, Sentry, Google Calendar, Gmail — these are bundled with the plugin and connect via OAuth on first use.

### Desktop Connectors (configure in Settings > Connectors)

PostHog, Vercel, Notion, Granola, Mermaid Chart, Google Drive, HuggingFace — connect these manually in Claude Desktop or Cowork settings.

### Linear Configuration

- **Team:** Claudian (CIA)
- **Triage Rules:** Rule 1: `spec:draft` → ChatPRD. Rule 2: `auto:implement` → Codex.
- **Labels:** 38 workspace-level labels (type, spec, exec, ctx, research, template, origin, auto)
- **Full reference:** [`linear-agent-config.md`](skills/clinearhub-workflow/references/linear-agent-config.md)

### Configuration Surfaces

See [CONNECTORS.md](CONNECTORS.md) for the full 4-surface configuration guide:
- **Surface A:** ClinearHub Plugin (OAuth Connectors in [`.mcp.json`](.mcp.json))
- **Surface B:** Linear Agents & Integrations (Settings UI, documented in [`linear-agent-config.md`](skills/clinearhub-workflow/references/linear-agent-config.md))
- **Surface C:** GitHub Repo Config (Copilot, CI, Dependabot, auto-merge)
- **Surface D:** Claude Code Repo Config (`CLAUDE.md`, skills, plugins)

### Key References

| Reference | What | Link |
|-----------|------|------|
| Pipeline Architecture | Canonical 10-phase spec-to-ship pipeline | [Linear Document](https://linear.app/claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f) |
| CONNECTORS.md | 4-surface configuration guide | [CONNECTORS.md](CONNECTORS.md) |
| Agent Guidance | Text for Linear Settings > Team > Agents | [`linear-agent-config.md`](skills/clinearhub-workflow/references/linear-agent-config.md) |
| Cowork Instructions | Text for Claude Desktop > Settings > Instructions | [`cowork-instructions.md`](skills/clinearhub-workflow/references/cowork-instructions.md) |
| Triage Rules | Triage protocol, Sentry routing, Phase 8 automation | [`triage-rules.md`](skills/clinearhub-workflow/references/triage-rules.md) |
| Label Taxonomy | All 38 workspace labels with rules | [`label-taxonomy.md`](skills/clinearhub-workflow/references/label-taxonomy.md) |
| Execution Modes | quick/tdd/pair/checkpoint/swarm/spike | [`execution-modes.md`](skills/clinearhub-workflow/references/execution-modes.md) |
| ChatPRD Personas | Working Backwards, Five Whys, Pre-Mortem, Layman Clarity | [`chatprd-personas.md`](skills/spec-enrichment/references/chatprd-personas.md) |
| PR/FAQ Templates | 4 spec templates (feature, infra, research, quick) | [`prfaq-templates.md`](skills/spec-enrichment/references/prfaq-templates.md) |
| Closure Protocol | Evidence requirements for issue closure | [`closure-protocol.md`](skills/issue-lifecycle/references/closure-protocol.md) |
| Sentry Pipeline | Sentry↔GitHub↔Linear error pipeline | [`sentry-github-pipeline.md`](skills/incident-response/references/sentry-github-pipeline.md) |
| PostHog Queries | HogQL patterns, funnel templates | [`posthog-queries.md`](skills/data-analytics/references/posthog-queries.md) |
| Vercel Checks | Deploy verification patterns | [`vercel-checks.md`](skills/deployment-verification/references/vercel-checks.md) |
| Railway Checks | Railway deployment verification | [`railway-checks.md`](skills/deployment-verification/references/railway-checks.md) |
| Plan Format | Plan document template and conventions | [`plan-format.md`](skills/plan-persistence/references/plan-format.md) |
| Promotion Protocol | Plan promotion to Linear Documents | [`promotion-protocol.md`](skills/plan-persistence/references/promotion-protocol.md) |
| Multi-Surface Review | Cross-surface plan review chain (Cowork → Code → IDE) | [`multi-surface-review.md`](skills/plan-persistence/references/multi-surface-review.md) |
| Initiative Patterns | Initiative + Milestone management templates | [`initiative-patterns.md`](skills/roadmap-management/references/initiative-patterns.md) |
| Docs Sync Manifest | Source-target documentation sync | [`docs-sync.yml`](docs-sync.yml) |

## Stack Skills

ClinearHub handles PM methodology. Stack-specific coding skills (React, Next.js, Supabase, shadcn, etc.) are installed separately at the repo level in `.claude/skills/` via `npx skills add`. See the root `CLAUDE.md` for the full inventory.

## Relationship to CCC

ClinearHub replaces CCC for Cowork/PM usage. CCC remains as a maintenance-mode Claude Code plugin for complex dev work (hooks, git ops, parallel dispatch, TDD enforcement). ClinearHub is the Cowork plugin for PM work.

| Concern | ClinearHub (Cowork) | CCC (Code) |
|---------|-----------------|------------|
| Spec writing | /write-spec | /ccc:write-prfaq |
| Triage | /triage | /ccc:hygiene |
| Decomposition | /decompose | /ccc:decompose |
| Status updates | /stakeholder-update | /ccc:status-update |
| Implementation | Linear agent dispatch | /ccc:go, /ccc:start |
| Code review | Copilot auto-review | /ccc:review, /ccc:pr-dispatch |
| Adversarial review | Linear Agent Teams | /ccc:review |
