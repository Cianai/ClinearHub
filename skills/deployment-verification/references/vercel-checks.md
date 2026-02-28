# Vercel Deployment Checks Reference

Configuration and verification reference for Vercel deployments in the Claudian monorepo.

## Vercel Deployment States

| State | Meaning | Action |
|-------|---------|--------|
| **Building** | Build in progress | Wait — check build logs if taking >5 min |
| **Ready** | Deployment successful, live at URL | Verify functionality |
| **Error** | Build or runtime error | Check build logs, fix, redeploy |
| **Queued** | Waiting for build capacity | Normal during high-traffic periods |
| **Canceled** | Build canceled (by user or new push) | No action needed if superseded |

## Vercel↔Git Integration

**Docs:** https://vercel.com/docs/git

### Auto-Deploy Behavior

| Git Event | Vercel Action | Deployment Type |
|-----------|--------------|-----------------|
| Push to feature branch | Deploy preview | Preview (unique URL per commit) |
| Push to PR branch | Deploy preview + comment on PR | Preview |
| Merge to `main` | Deploy production | Production |
| Force push | Cancel previous + deploy new | Depends on branch |

### GitHub App Features

**App:** https://github.com/apps/vercel

The Vercel GitHub App provides:

1. **Deployment status checks**: Added as a GitHub commit status check. Shows "Vercel — Deployment has completed" (or building/error).
2. **PR comments**: Bot posts a comment with:
   - Preview URL for the deployment
   - Build duration and status
   - Updated on each push to the PR branch
3. **Auto-cancel**: If a new commit is pushed before the previous build finishes, the previous build is automatically canceled.

### Configuration (per project)

In Vercel Dashboard > Project Settings > Git:
- **Production Branch**: `main`
- **Root Directory**: `apps/alteri` or `apps/soilworx` (monorepo filter)
- **Ignored Build Step**: Can configure to skip builds for changes outside the app directory

## Supabase↔Vercel Marketplace Integration

**Marketplace:** https://vercel.com/marketplace/supabase
**Setup:** https://supabase.com/partners/integrations/vercel

### Auto-Synced Environment Variables

The Marketplace integration auto-syncs these variables from Supabase to Vercel:

| Variable | Scope | Notes |
|----------|-------|-------|
| `NEXT_PUBLIC_SUPABASE_URL` | Public (client) | Supabase project URL |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Public (client) | Anon/public key for client-side |
| `SUPABASE_SERVICE_ROLE_KEY` | Server only | Service role key for server-side operations |
| `SUPABASE_URL` | Server only | Same as public URL (for server SDK) |

### Branch Environments

- Supabase preview branches can be linked to Vercel preview deployments
- Each preview gets its own isolated Supabase instance
- Useful for testing migrations without affecting production

### Verification

To verify the integration is working:
1. Check Vercel Dashboard > Project > Settings > Environment Variables — Supabase vars should show "(Managed by Supabase)" or similar
2. Check Supabase Dashboard > Project > Settings > Integrations — Vercel should show as connected
3. Deploy a preview and verify the app connects to the correct Supabase instance

## Environment Variable Checklist (Per App)

### Alteri (`apps/alteri`)

| Variable | Source | Scope |
|----------|--------|-------|
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase Marketplace (auto) | Public |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase Marketplace (auto) | Public |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase Marketplace (auto) | Server |
| `SENTRY_DSN` | Manual (Sentry project DSN) | Server |
| `NEXT_PUBLIC_SENTRY_DSN` | Manual (same DSN) | Public |
| `SENTRY_AUTH_TOKEN` | Manual (org auth token) | Server |
| `NEXT_PUBLIC_POSTHOG_KEY` | Manual (PostHog project API key) | Public |
| `NEXT_PUBLIC_POSTHOG_HOST` | Manual (`https://us.i.posthog.com`) | Public |
| AI provider keys | Manual (per provider) | Server |

### SoilWorx (`apps/soilworx`)

Same pattern as Alteri. Google Maps API key is additionally required:

| Variable | Source | Scope |
|----------|--------|-------|
| `NEXT_PUBLIC_GOOGLE_MAPS_KEY` | Manual | Public |

## Preview Deployment Testing Protocol

When a preview deployment is created for a PR:

### Automated (via zero-touch loop)
1. Vercel builds and deploys preview — bot posts URL on PR
2. Copilot auto-review runs — posts code review comment
3. CI checks run — lint, typecheck, build

### Manual Verification (when needed)
1. Visit the preview URL from the Vercel PR comment
2. Test the specific feature/fix from the PR description
3. Verify no console errors in browser DevTools
4. Check Sentry for any errors from the preview environment
5. If UI changes: compare against design spec or screenshot

## Production Deployment Monitoring

### First 15-Minute Watch Window

After a production deployment:

1. **Minute 0-1**: Verify deployment state is "Ready" in Vercel
2. **Minute 1-5**: Check Sentry for new errors with the latest release tag
3. **Minute 5-10**: Check PostHog for funnel completion rates
4. **Minute 10-15**: Verify response times are within normal range

### Build Log Interpretation

Common build issues in the Claudian monorepo:

| Pattern | Cause | Fix |
|---------|-------|-----|
| `Module not found: @claudian/*` | Turborepo didn't build dependency | Check `turbo.json` `dependsOn`, rebuild |
| `Type error: Property X does not exist` | TypeScript error not caught locally | Run `pnpm typecheck` locally, fix |
| `ENOMEM` | Build ran out of memory | Increase Vercel build memory or optimize imports |
| `ERR_PNPM_OUTDATED_LOCKFILE` | `pnpm-lock.yaml` out of sync | Run `pnpm install` and commit lockfile |
| `Supabase connection error` | Env vars not synced | Check Marketplace integration status |
