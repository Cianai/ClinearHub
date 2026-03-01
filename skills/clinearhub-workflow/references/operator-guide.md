# Operator Guide

A step-by-step guide for the human operator (PM, technical lead, or founder) using ClinearHub to build products. Everything here happens in the **Claude Desktop Code UI** or **Cowork** — no terminal required.

> **Surface note:** This guide follows the [Cross-Surface Reference Discipline](cross-surface-references.md). It uses GitHub structure with Cowork-style conversational tone — technical content stays intact, jargon is defined on first use.

## 1. Session Lifecycle

### Starting a Code Session

**When:** Any task that changes code in your project — building features, fixing bugs, implementing specs from Linear.

**Where:** Claude Desktop > **Code** tab > select your project folder (the root of your repository).

**How:** Click **+ New session** in the sidebar. Each session automatically gets its own isolated copy of your code via Git worktrees (a safe sandbox where your changes won't affect other sessions or the main codebase). You can run multiple sessions in parallel — each gets its own branch.

**Tip:** For PM-only work (triage, planning, status updates, stakeholder comms), use a **Cowork** session instead — it's designed for conversation, not code changes.

### Working with Claude

Once you're in a session, Claude reads your project files, makes changes, and runs commands on your behalf. A few things to know:

- **Interrupt anytime**: Click stop or type your correction mid-task. Claude adjusts immediately.
- **Point at files**: Type `@filename` in the prompt to direct Claude to specific files.
- **Attach context**: Use the **+** button next to the prompt box for file attachments, skills (`/commands`), and connectors (external tools like Linear, GitHub, Figma).
- **Use ClinearHub commands**: Type `/` to see available commands like `/triage`, `/write-spec`, `/stakeholder-update`, etc.

### Reviewing Claude's Changes

**When:** Claude has made code changes — you'll see diff stats (like `+12 -1`) in the session toolbar.

**How:**

1. Click the diff indicator to open the **diff viewer** (shows a file list on the left, changes on the right).
2. Click any line to leave a comment with feedback or corrections.
3. Press **Cmd+Enter** (Mac) or **Ctrl+Enter** (Windows) to submit all comments at once.
4. Claude reads your comments and revises.

**Self-review:** Before creating a PR, click **Review code** in the diff toolbar (top-right corner). Claude evaluates its own changes and leaves comments directly in the diff — focusing on compile errors, logic bugs, and security issues. This is how the v1.0.5 JSON escaping bug was caught before it reached production.

### Previewing Your App

**When:** Claude has built or modified a web app and you want to see it running.

**How:** Claude usually starts the dev server automatically after editing project files. You can also ask "preview the app" at any time. An embedded browser opens where you can interact with the running app directly.

**Auto-verify** (on by default): Claude takes screenshots, inspects the page, clicks elements, fills forms, and fixes issues it finds — all automatically after every edit.

**Use for:** Reviewing work done by Linear agents (like Codex or Copilot coding). Open the agent's PR branch in a Desktop Code session and preview the app locally to verify it works as expected.

### Creating a Pull Request

**When:** You're satisfied with the changes after reviewing diffs and/or previewing the app.

**How:** Ask Claude to create a PR, or it may offer to create one. Claude creates it with `Closes CIA-XXX` in the body — this automatically closes the Linear issue when the PR merges.

**After PR creation:** A **CI status bar** appears in the session toolbar with two toggles:

| Toggle | What it does |
|--------|-------------|
| **Auto-fix** | Claude reads CI failure output and attempts to fix automatically |
| **Auto-merge** | Claude squash-merges the PR once all checks pass |

**Tip:** Enable both toggles for the full **zero-touch loop** — Claude handles Copilot code review feedback, CI failures, and merging without further intervention from you.

### Ending a Session

- **Code sessions:** The session is "done" once the PR is merged (or auto-merged). Archive it from the sidebar.
- **PM sessions:** Run `/plan --finalize` if plans were created during the session. Review the session exit summary table to confirm all Linear issues reflect the correct state.

## 2. Release Workflow

### Publishing a New Plugin Version

**When:** Significant changes have been merged to main and you want to publish a new version.

**How:** Start a new Desktop Code session in the project. Ask Claude:

> "Bump the plugin version and create a release tag."

Claude will update the version in `plugin.json`, commit, push, create a tag, and push the tag — which triggers the automated release pipeline.

**What happens automatically:**

1. The `release-plugin.yml` workflow (in `.github/workflows` of the private repo) builds the plugin zip, creates a GitHub Release on the private repo, and syncs the version to the [Clinear project](linear://claudian/project/47383cdf-ad21-46c4-817c-ad5e7faa0c83) in Linear.
2. The `publish-public.yml` workflow (in `.github/workflows` of the private repo) copies plugin files to the [public ClinearHub repo](https://github.com/Cianai/ClinearHub) and creates a matching release there.

**Verify:** The CI status bar in your session shows the workflows running. Or ask Claude: "Check if the release succeeded."

### If the Release Pipeline Fails

Ask Claude: "Check the release workflow status and show me the error." Claude can read the workflow logs and identify the failure. If a non-critical step failed (like the Linear version sync), the `continue-on-error` flag means the release still published. For actual build failures, fix the issue in a new session, merge the fix via PR, then ask Claude to re-tag.

## 3. Monitoring PRs and CI

After creating a PR from a Desktop Code session, a **CI status bar** appears automatically.

| Feature | What it does |
|---------|-------------|
| **Status indicator** | Shows whether checks are passing, failing, or pending |
| **Auto-fix toggle** | Claude reads CI failure output and fixes automatically |
| **Auto-merge toggle** | Claude squash-merges once all checks pass |

**The full zero-touch loop:**

```
PR created → Copilot reviews code → CI runs (lint, typecheck, build)
  → Auto-fix if CI fails → Auto-merge when green
    → Linear issue auto-closes via "Closes CIA-XXX"
```

You don't need to monitor this manually — Claude sends a desktop notification when CI finishes.

## 4. Plugin Installation & Updates

### First Install (Claude Code Desktop)

Open a Code session in your project folder. Ask Claude:

> "Install the ClinearHub plugin from the current directory (or from `packages/clinear-plugin` if you're working in the Claudian monorepo)."

### First Install (Cowork / Desktop Chat)

1. Download `clinearhub-plugin.zip` from the [latest release](https://github.com/Cianai/ClinearHub/releases/latest).
2. Open Claude Desktop > **Settings** > **Plugins**.
3. Drag the zip into the upload area.
4. Restart your Cowork session to pick up the plugin.

### Updating After a Release

- **Cowork/Desktop:** Download the new zip from [releases](https://github.com/Cianai/ClinearHub/releases), re-upload in Settings > Plugins, and restart your session.
- **Code:** Ask Claude to re-add the plugin from the local path.

## 5. Configuration Sync

### What Syncs Automatically

These happen on every PR merge or tag push — no action needed:

| What | How |
|------|-----|
| Plugin files → public repo | `publish-public.yml` copies on release |
| Linear project version | `release-plugin.yml` updates on tag push |
| Issue status after merge | `post-merge-reconciliation.yml` runs 3-tier cascade |
| Copilot code review | [`copilot-auto-review`](https://docs.github.com/en/copilot/using-github-copilot/code-review/using-copilot-code-review) ruleset auto-requests on push |

### What Requires Manual Sync

These Linear settings have no API — they must be pasted manually from the plugin's reference files. Run `/sync-docs` in a session to check what's stale and get the exact content to paste.

| Setting | Source file | Paste into |
|---------|-----------|------------|
| Agent Guidance | [`linear-agent-config.md`](linear-agent-config.md) | Linear > Team Settings > Agents |
| Prompt Template | [`linear-agent-config.md`](linear-agent-config.md) | Linear > Preferences > Coding Tools |
| Cowork Instructions | [`cowork-instructions.md`](cowork-instructions.md) | Desktop > Settings > Cowork > Instructions |
| Triage Rules | [`triage-rules.md`](triage-rules.md) | Linear > Team Settings > Triage |

**Why can't these be automated?** Linear's GraphQL API currently has no mutations for team settings, agent guidance, triage rules, or coding tools preferences. The types exist in the schema (`AiPromptRules`, `GuidanceRuleWebhookPayload`) but create/update operations aren't exposed yet. If Linear adds API support, ClinearHub will automate these.

## 6. First-Time Setup (Onboarding)

Follow these steps to set up ClinearHub from scratch for a new project.

### Step 1: Get the Code

Open a Desktop Code session and ask Claude to clone the repo. Or if you already have it locally, select the project folder when starting a new session.

### Step 2: Set Up Secrets (Doppler)

ClinearHub uses [Doppler](https://www.doppler.com/) to manage API keys and secrets. A template is included in the repo for one-click setup.

1. Click the **Import to Doppler** button in the [README](../../../README.md) (or import `doppler-template.yaml` from the plugin directory).
2. This creates a `claude-tools` project with a `dev` config containing all required **runtime/API-provider** secret placeholders (for local development and app runtime).
3. Fill in the API key values for those placeholders in the [Doppler dashboard](https://dashboard.doppler.com/). These cover app/runtime access to external providers; GitHub Actions / workflow secrets (like `PUBLIC_REPO_TOKEN`, `LINEAR_PROJECT_ID`, and other `LINEAR_*` IDs used by automation workflows) are configured separately as GitHub repository secrets in [Step 3](#step-3-github-repo-secrets).

The minimum required keys (Tier 1):

| Secret | Where to get it |
|--------|----------------|
| `LINEAR_API_KEY` | [Linear](https://linear.app/) > Settings > API > Personal API keys |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | [GitHub](https://github.com/) > Settings > Developer settings > Fine-grained PATs |
| `PERPLEXITY_API_KEY` | [Perplexity](https://perplexity.ai/) > API settings |
| `OPENAI_API_KEY` | [OpenAI](https://platform.openai.com/) > API keys |

Additional tiers (CI/CD, project-specific, research, AI providers) are optional — see [`doppler-template.yaml`](../../../doppler-template.yaml) for the full list with descriptions.

### Step 3: GitHub Repo Secrets

Ask Claude in a Desktop Code session:

> "Set up the GitHub secrets for CI workflows using the values from Doppler."

ClinearHubBot handles this via the GitHub API — you don't need to visit the GitHub Settings UI.

### Step 4: Install the Plugin

Ask Claude:

> "Install the ClinearHub plugin."

### Step 5: Configure Linear

Run `/sync-docs` in your session. Follow the prompts to paste content into Linear Settings fields (Agent Guidance, Triage Rules, Prompt Template — see [Section 5](#5-configuration-sync) for the full list).

### Step 6: Connect Desktop Services

Open Claude Desktop > **Settings** > **Connectors** and connect:

- **Required:** Linear, GitHub, Sentry
- **Recommended:** Figma, PostHog, Vercel, Google Calendar, Gmail

These use OAuth — click "Connect" for each service and authorize access.

## 7. What's Automated vs. Manual

| Action | Automated? | How |
|--------|-----------|-----|
| Issue status transitions on merge | Yes | `post-merge-reconciliation.yml` |
| Plugin release + publish to public repo | Yes | Tag push → release → publish chain |
| Linear project version sync | Yes | Release workflow sync step |
| Code review on PRs | Yes | Copilot auto-review ruleset |
| CI (lint, typecheck, build) | Yes | `ci.yml` on push/PR |
| PR auto-merge | Yes | Desktop auto-merge toggle |
| CI failure auto-fix | Yes | Desktop auto-fix toggle |
| Agent guidance text | **Manual** | No Linear API — paste from `/sync-docs` |
| Triage rules | **Manual** | No Linear API — configure in Linear UI |
| Prompt template | **Manual** | No Linear API — paste from `/sync-docs` |
| Desktop connectors | **Manual** | OAuth flow — user clicks "Connect" |
| Doppler secret values | **Manual** | Third-party API keys — user must obtain from each service |

## Cross-Skill References

- [Cross-Surface References](cross-surface-references.md) — link formatting, surface-aware language
- [CONNECTORS.md](../../../CONNECTORS.md) — 4-surface configuration model
- [Triage Rules](triage-rules.md) — how label-based triage dispatches to agents
- [Pipeline Architecture](linear://claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f) — canonical 10-phase spec-to-ship pipeline
