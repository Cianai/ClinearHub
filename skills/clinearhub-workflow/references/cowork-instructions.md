# Cowork Global Instructions

**Location:** Claude Desktop > Settings > Instructions (global, applies to all Cowork sessions)

Copy the text between the ``` fences below into the instructions field.

```
You are working in a ClinearHub-managed workspace. ClinearHub is a spec-to-ship PM methodology that orchestrates work through Linear, GitHub, and a pipeline of AI agents.

## Workspace

- Team: Claudian (CIA)
- Repo: Cianai/Claudian-Clinear (Turborepo monorepo)
- Apps: Alteri (AI alignment research, port 3001), SoilWorx (distributor finder, port 3002)
- Stack: Next.js 16, React 19, TypeScript 5.x, Tailwind v4, pnpm 9

## How ClinearHub Works

1. Specs start in Cowork (you) or ChatPRD. Use /write-spec to create a Linear issue with spec:draft label.
2. The spec:draft label triggers ChatPRD to enrich the spec with business personas and create implementation sub-issues.
3. Sub-issues get auto:implement label, which triggers Codex to implement them as PRs.
4. PRs go through Copilot auto-review → CI → auto-merge → Vercel deploy → Linear auto-close.
5. After all sub-issues close, use /verify to validate outcomes.

## Available Commands

Use these slash commands to trigger workflows:

- /write-spec — Draft a spec using Working Backwards PR/FAQ, push to Linear with spec:draft
- /triage — Pull Linear Triage inbox, categorize issues, apply labels, route to agents
- /decompose — Break a spec into sub-issues with auto:implement label for Codex dispatch
- /sprint-planning — Cycle review, velocity analysis, next sprint composition
- /stakeholder-update — Multi-source status update from Linear + PostHog + Vercel + Sentry
- /update — Sync and digest from all sources with duplicate detection
- /weekly-brief — Cross-project weekly digest from all sources
- /standup — Daily standup summary from Linear + Sentry + Vercel + PostHog
- /incident — Triage production errors, classify severity, perform RCA
- /critique — Review issue quality before agent dispatch
- /deploy-checklist — Pre/post-deploy verification for Vercel deployments
- /analyze — Analyze product data from PostHog using HogQL, funnels, notebooks
- /verify — Post-merge outcome validation, synthesize all AI + agent work for human review
- /plan — Manage session plans: promote to Linear Documents, list plans, finalize at session end
- /roadmap-update — View, update, and manage strategic roadmap via Linear Initiatives and Milestones
- /sync-status — Mechanical cross-surface status sync to Linear + GitHub

## Conventions

- Linear team: Claudian (CIA). Every issue needs a project assigned.
- Issue naming: Verb-first. "Build X", "Implement Y", "Survey Z".
- Labels: type:* (required), exec:*, ctx:*, spec:*. See label taxonomy in ClinearHub skills.
- Branch naming: CIA-XXX-short-slug (lowercase, kebab-case)
- PR body: Must include "Closes CIA-XXX" for auto-close

## Pipeline Reference

Full architecture: https://linear.app/claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f
```

## Per-Project Instructions

In addition to the global instructions above, each Cowork Desktop Chat Project can have project-specific instructions. Configure in the project settings:

### Alteri Project Instructions

```
Alteri is an AI alignment research platform. Key context:
- Conversation engine uses XState state machines (modules/state-machines/)
- Voice intake pipeline for research memo processing (modules/voice-intake/)
- AI providers via @claudian/ai package (Vercel AI SDK)
- Research participants must NOT be recorded (PostHog session replay disabled)
- Supabase for auth and database
```

### SoilWorx Project Instructions

```
SoilWorx is a distributor finder for Cognito clients. Key context:
- Google Maps integration for distributor search
- XLSX import for distributor data
- Simple CRUD app, less complex than Alteri
- Port 3002
```
