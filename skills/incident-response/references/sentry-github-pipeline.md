# Sentry↔GitHub Integration Pipeline

Configuration reference for the Sentry↔GitHub integration that connects error tracking to source code.

## Setup Location

Sentry Settings > Integrations > GitHub > Configure

**Docs:** https://docs.sentry.io/organization/integrations/source-code-mgmt/github/

## Code Mappings

Map Sentry stack trace paths to repository source paths so stack frames link to the correct files.

| Stack Trace Root | Source Root | Repo |
|-----------------|------------|------|
| `app/` | `apps/alteri/app/` | cianos95-dev/Claudian-Clinear |
| `components/` | `apps/alteri/components/` | cianos95-dev/Claudian-Clinear |
| `modules/` | `apps/alteri/modules/` | cianos95-dev/Claudian-Clinear |
| `lib/` | `apps/alteri/lib/` | cianos95-dev/Claudian-Clinear |
| `packages/` | `packages/` | cianos95-dev/Claudian-Clinear |

**Note:** These mappings are Alteri-specific. Add SoilWorx mappings when that app has Sentry instrumented.

## Features to Enable

### Suspect Commits
- **What:** When a Sentry error is detected, Sentry identifies recent commits that touched files in the stack trace.
- **Enable:** Sentry Settings > Integrations > GitHub > Code Mappings (must be configured for suspect commits to work)
- **Benefit:** Immediate pointer to the likely cause — no manual git blame needed.

### Stack Trace Linking
- **What:** Each frame in a Sentry stack trace becomes a clickable link to the exact line in GitHub (version-specific URL matching the release).
- **Enable:** Automatic once code mappings are configured.
- **Benefit:** One-click navigation from error to source code.

### PR Comments
- **What:** Sentry posts comments on GitHub PRs surfacing related errors.
- **Merged PR comments:** If errors occur in files changed by a recently merged PR (<2 weeks), Sentry comments on that PR.
- **Open PR comments:** If an open PR touches files with existing Sentry issues, Sentry comments with a warning.
- **Enable:** Sentry Settings > Integrations > GitHub > Enable "PR Comments" for both open and merged PRs.
- **Benefit:** Developers see production impact of their changes without leaving GitHub.

### Resolve via Commit
- **What:** Including `fixes SENTRY-ID` in a commit message automatically resolves the Sentry issue when the commit is deployed.
- **Format:** `fixes PROJ-123` or `Fixes PROJ-123` (case-insensitive)
- **Enable:** Automatic once GitHub integration is connected.
- **Benefit:** Closes the loop without manual Sentry interaction.

### AI Code Review (Seer)
- **What:** Sentry's AI (Seer) analyzes stack traces and suggests root cause + fix in PR comments and issue details.
- **Enable:** Sentry Settings > Seer (may require specific plan tier).
- **Benefit:** Automated first-pass root cause analysis.

## Sentry→Linear Auto-Issue Pipeline

Configure in Sentry: Settings > Integrations > Linear (separate from GitHub integration).

- **Trigger:** New Sentry issue (first occurrence of an error fingerprint)
- **Action:** Creates a Linear issue in the Claudian team
- **Content:** Error type, message, stack trace, affected users count, first/last seen
- **Team routing:** Route to Claudian team

**Important:** This creates issues in Linear Triage. The ClinearHub triage protocol (clinearhub-workflow skill) then classifies severity and routes them.

## Cross-Surface Notes

- **Surface A (ClinearHub Plugin):** Sentry OAuth Connector provides MCP tools for querying issues, events, traces.
- **Surface B (Linear):** Sentry native integration auto-creates issues. Configured in Linear Settings > Integrations > Sentry.
- **Surface C (GitHub):** Sentry↔GitHub integration provides suspect commits, PR comments, stack trace linking. Configured in Sentry Settings > Integrations > GitHub.
- **Surface D (Claude Code):** `sentry-mcp` plugin + 4 repo-scoped Sentry skills (sentry-nextjs-sdk, sentry-react-sdk, sentry-fix-issues, sentry-create-alert).
