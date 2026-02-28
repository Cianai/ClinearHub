---
name: deployment-verification
description: |
  Deployment verification for the Claudian monorepo zero-touch loop (Vercel + Railway). Use when discussing deploy checklists, pre-deploy verification, post-deploy validation, rollback decisions, deployment status, preview URL testing, production health checks, or any question about deployment readiness. Also triggers for build failures, deployment logs, environment variable verification, domain configuration, Supabase env sync, Railway service management, or the Vercel/Railway GitHub integrations. Complements the incident-response skill for post-deploy error triage.
---

# Deployment Verification

Structured pre/post-deploy verification for the Claudian monorepo zero-touch loop. Covers the full deploy lifecycle from CI green through production health confirmation across both Vercel and Railway deployment targets.

## Deployment Topology

### Vercel (Frontend / SSR Apps)

Vercel project-per-app model with monorepo root directory filters:

| App | Vercel Project | Port (dev) | Root Directory |
|-----|---------------|------------|----------------|
| Alteri | claudian-alteri | 3001 | `apps/alteri` |
| SoilWorx | claudian-soilworx | 3002 | `apps/soilworx` |

### Railway (Backend / API Services)

Railway service-per-app model with shared repo context and watch patterns:

| App | Railway Service | Root Directory | Watch Pattern |
|-----|----------------|----------------|---------------|
| Alteri | alteri | `apps/alteri` | `["apps/alteri/**", "packages/**"]` |
| SoilWorx | soilworx | `apps/soilworx` | `["apps/soilworx/**", "packages/**"]` |

Railway uses the shared monorepo approach (full repo context, scoped via build/start commands) since apps share `@claudian/*` packages. Watch patterns prevent unnecessary redeployments.

See `references/railway-checks.md` for Railway-specific verification patterns.

### Vercel↔Git Integration

Vercel connects to GitHub via the [Vercel GitHub App](https://github.com/apps/vercel):

- **Auto-deploy on push**: Every push to a branch triggers a preview deployment
- **Preview per PR**: Each PR gets a unique preview URL, posted as a PR comment by the Vercel bot
- **Production on merge to main**: Merging to `main` triggers production deployment
- **Deployment status checks**: Vercel adds deployment status as a GitHub check on each commit

Docs: https://vercel.com/docs/git

### Supabase↔Vercel Integration

Connected via [Vercel Marketplace](https://vercel.com/marketplace/supabase):

- **Auto-syncs env vars**: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` are auto-synced from Supabase project to Vercel project environment variables
- **Branch environments**: Supabase preview branches can map to Vercel preview deployments
- **Setup**: https://supabase.com/partners/integrations/vercel

**Important:** Never manually set Supabase env vars in Vercel if the Marketplace integration is connected — they'll be overwritten on next sync.

## Pre-Deploy Checklist

Before any production deployment:

### 1. CI Green
- `pnpm lint` passes (no ESLint errors)
- `pnpm typecheck` passes (no TypeScript errors)
- `pnpm build` succeeds (Turborepo builds all packages + apps)
- GitHub Actions CI workflow (`ci.yml`) shows green check

### 2. PR Approved
- PR has at least one approval (Copilot auto-review counts)
- No unresolved review comments
- PR body includes `Closes CIA-XXX` for auto-close

### 3. Environment Variables Verified
- Supabase vars: auto-synced via Marketplace integration (verify last sync in Vercel dashboard)
- Sentry DSN: set per environment (preview + production)
- PostHog key: `NEXT_PUBLIC_POSTHOG_KEY` + `NEXT_PUBLIC_POSTHOG_HOST`
- AI provider keys: set per app requirements

### 4. Feature Flags Set
- Any new feature flags configured in PostHog
- Rollback flags ready for critical features

## Zero-Touch Agent Chain

The full automated pipeline from code push to production:

```
Developer pushes → GitHub
  → Vercel GitHub App creates preview deployment
  → Railway detects push → preview deployment (per environment)
  → Copilot auto-review adds code review comment
  → GitHub Actions CI runs (lint, typecheck, build)
  → All checks pass → PR eligible for auto-merge
  → Auto-merge triggers → squash merge to main
  → Vercel detects main branch push → production deploy
  → Railway main environment → production deploy
  → Linear auto-closes issue (via "Closes CIA-XXX" in PR body)
```

### Check Points

| Stage | Tool | What to Verify |
|-------|------|---------------|
| PR created | GitHub | Branch name matches `CIA-XXX-slug` pattern |
| Preview deploy | Vercel | Preview URL works, no build errors |
| Code review | GitHub | Copilot review posted, no blocking issues |
| CI | GitHub Actions | All jobs green |
| Auto-merge | GitHub | Merge queue processed, squash commit on main |
| Production deploy | Vercel | Deployment status: Ready |
| Issue closure | Linear | Issue moved to Done, `ctx:review` removed |

## Post-Deploy Validation

After production deployment, monitor for 15 minutes:

### Sentry Error Check
- Compare error rate before and after deploy
- Watch for new error fingerprints not present pre-deploy
- Check for regressions (previously resolved issues reopening)
- Target: error rate should not increase by >10%

### PostHog Funnel Check
- Verify key funnels are not disrupted:
  - Alteri: landing → sign up → first research session → scenario completion
  - SoilWorx: landing → search → results → contact
- Check session replay for new deployment's first users
- Verify feature flags are evaluating correctly

### Health Metrics
- Response times (P95 < 3s for all routes)
- Server-side render success rate
- API endpoint availability

## Rollback Decision Tree

```
Error rate spike detected post-deploy?
├── Yes → Is the error rate >3x baseline?
│   ├── Yes → ROLLBACK immediately (Vercel instant rollback)
│   └── No → Is a hotfix obvious from stack trace?
│       ├── Yes → HOTFIX (branch, fix, emergency PR, skip queue)
│       └── No → ROLLBACK + investigate
└── No → Monitor for full 15-min window
    └── All clear → Deploy verified ✓
```

### Vercel Rollback
- Vercel supports instant rollback to previous deployment via Dashboard
- No code revert needed — rollback is a deployment-level operation
- After rollback: create a `type:bug` issue with RCA (see incident-response skill)

### Railway Rollback
- Railway supports instant rollback via `railway rollback` CLI or Dashboard
- Rollback redeploys the previous deployment without a new build
- Use `railway logs --lines 50 --since 15m` to diagnose issues before rollback decision
- After rollback: create a `type:bug` issue with RCA (see incident-response skill)

### Feature Flag Disable
- If the issue is isolated to a new feature behind a flag:
  - Disable the flag in PostHog
  - No rollback needed
  - Fix forward with a proper PR

## Cross-Skill References

- **incident-response** — Post-deploy error triage, severity classification, RCA protocol
- **clinearhub-workflow** — Overall pipeline flow, Step 6 (verification → deploy)
- **data-analytics** — PostHog funnel checks for post-deploy validation
