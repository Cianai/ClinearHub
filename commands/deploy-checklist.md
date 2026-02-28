---
description: Pre-deploy verification checklist for Vercel and Railway deployments, covering CI, env vars, Supabase sync, zero-touch agent chain, and rollback readiness
argument-hint: "[<app-name: alteri|soilworx|all>] [--target vercel|railway] [--post for post-deploy validation]"
---

# Deploy Checklist

Pre-deploy and post-deploy verification for Vercel and Railway deployments in the Claudian monorepo zero-touch loop.

## Step 1: Determine Scope

If app name is provided, scope to that app. Otherwise check all apps.

If `--target` is provided, check only that deployment platform. Otherwise check both Vercel and Railway.

If `--post` flag is present, skip to Step 5 (post-deploy validation).

## Step 2: Check CI Status

Query GitHub for the latest CI run on the target branch:
- Lint: passing?
- Typecheck: passing?
- Build: passing?

```
Check GitHub Actions CI workflow status for the branch/PR.
If any check is failing → STOP. Fix CI before deploying.
```

## Step 3: Check Deployment Status

### Vercel
Query Vercel for deployment state:
- Preview deployment exists for the PR?
- Preview URL accessible?
- Vercel GitHub App deployment check status?

For production (post-merge):
- Production deployment state: Building / Ready / Error?
- If Error: pull build logs and diagnose

### Railway
Query Railway for deployment state:
- `railway status --json` — current service health
- `railway logs --build --lines 50` — recent build logs
- Service responding on domain?

For production (post-merge):
- Production environment deployment state
- If failed: `railway logs --build --lines 100` for diagnosis

## Step 4: Verify Environment Variables

### Supabase↔Vercel Sync
- Marketplace integration connected?
- Last sync time (check Vercel dashboard or API)?
- `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY` present?

### Other Required Vars
- Sentry DSN set for target environment?
- PostHog key set?
- App-specific keys (Google Maps for SoilWorx, AI providers for Alteri)?

### Vercel↔Git Integration
- Vercel GitHub App installed on repo?
- Preview URLs appearing on PRs?
- Deployment status checks visible on commits?

## Step 5: Baseline Sentry Errors (Pre-Deploy)

If not `--post` mode, capture current error state:
- Current error rate for the app
- Number of unresolved issues
- Any recent regressions

This baseline is used for post-deploy comparison.

## Step 6: Post-Deploy Monitor (--post or after merge)

### Sentry Error Rate
- Compare error rate to pre-deploy baseline
- Check for new error fingerprints
- Watch for regressions (previously resolved issues reopening)
- Flag if error rate increases >10%

### PostHog Funnel Verification
- Key funnels completing at expected rates?
- New feature (if applicable) showing expected events?
- Session replay available for new deployment users?

### Response Times
- P95 response times within acceptable range (<3s)?
- No timeout spikes?

## Step 7: Output GO/NO-GO Report

```markdown
## Deploy Verification Report — [App] — [Date]

### Pre-Deploy
| Check | Status | Notes |
|-------|--------|-------|
| CI (lint) | ✅ Pass | — |
| CI (typecheck) | ✅ Pass | — |
| CI (build) | ✅ Pass | — |
| Vercel preview | ✅ Ready | [preview URL] |
| Railway status | ✅ Running | [service domain] |
| Vercel↔Git integration | ✅ Active | Deploy checks + PR comments |
| Supabase env sync | ✅ Synced | Last sync: [time] |
| Sentry DSN | ✅ Set | — |
| PostHog key | ✅ Set | — |

### Post-Deploy (if --post)
| Metric | Before | After | Status |
|--------|--------|-------|--------|
| Error rate | N/hr | N/hr | ✅ Stable |
| New errors | — | N | ⚠️ / ✅ |
| Regressions | — | N | ✅ None |
| Funnel: [name] | X% | Y% | ✅ Normal |
| P95 response | Xms | Yms | ✅ Normal |

### Verdict: **GO** / **NO-GO**

[If NO-GO: specific blockers and recommended action (rollback / hotfix / disable feature flag)]
```
