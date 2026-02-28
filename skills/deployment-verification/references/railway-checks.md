# Railway Deployment Checks

Railway-specific verification patterns for the Claudian monorepo. Complements `vercel-checks.md`.

## Preflight

Before any Railway operation:

```bash
# Verify CLI installed and authenticated
railway whoami
railway version

# Check linked project context
railway status --json
```

If not linked, resolve context first: `railway link` in the app directory.

## Pre-Deploy Verification

### 1. Service Health

```bash
# Check current service status
railway status --json

# Verify environment configuration
railway variables --json
```

### 2. Watch Patterns (Monorepo)

Verify watch patterns are configured to prevent unnecessary redeployments:

```json
{
  "build": {
    "watchPatterns": ["apps/alteri/**", "packages/**"]
  }
}
```

Apps sharing `@claudian/*` packages must include `packages/**` in watch patterns.

### 3. Environment Variables

Required per environment:

| Variable | Required For | Source |
|----------|-------------|--------|
| `DATABASE_URL` | Supabase connection | Railway service variable or Supabase |
| `NEXT_PUBLIC_SUPABASE_URL` | Supabase client | Supabase project |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | Supabase client | Supabase project |
| `SENTRY_DSN` | Error tracking | Sentry project |
| `NEXT_PUBLIC_POSTHOG_KEY` | Analytics | PostHog project |

### 4. Build Configuration

Railway defaults to Railpack (auto-detect). Verify:

```bash
# Pin Node version if needed
RAILPACK_NODE_VERSION=22

# For monorepo shared approach
# Build command uses pnpm filter
pnpm --filter @claudian/alteri build
```

## Deploy Commands

```bash
# Detached deployment (automation — returns immediately)
railway up --detach -m "CIA-XXX: description"

# Watched deployment (troubleshooting — streams logs)
railway up --ci -m "CIA-XXX: description"

# Target specific service + environment
railway up --service alteri --environment production --detach -m "CIA-XXX: description"
```

## Post-Deploy Verification

### 1. Deployment Status

```bash
# Check deployment state
railway status --json

# View recent build logs (bounded)
railway logs --build --lines 50

# View runtime logs (bounded)
railway logs --lines 50 --since 15m
```

### 2. Health Check

```bash
# Verify service is responding
curl -f https://<service-domain>/api/health
```

### 3. Error Monitoring

Same as Vercel post-deploy:
- Sentry error rate comparison (pre vs post)
- New error fingerprints
- Regression detection
- PostHog funnel verification

## Rollback

```bash
# Instant rollback to previous deployment
railway rollback

# Restart container without rebuild (config changes only)
railway restart

# Remove latest deployment (preserves service)
railway down
```

## Troubleshooting

```bash
# View build logs for failed deployment
railway logs --build --lines 100

# Check runtime logs for errors
railway logs --lines 100 --since 30m

# Verify environment
railway variables --json | jq 'keys'
```

## Railway MCP

Railway MCP server is available per-session in Claude Code (`~/.mcp.json`, enable when needed). Provides programmatic access to:
- Project/service management
- Deployment operations
- Variable management
- Log querying
- Domain configuration
