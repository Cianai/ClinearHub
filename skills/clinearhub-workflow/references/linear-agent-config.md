# Linear Agent & Integration Configuration

Reproducible configuration for Linear Team Settings. These are UI-only settings — this file is the version-controlled reference.

## Coding Tools

**Location:** Settings > Preferences > Coding tools

### Enabled Tools

| Tool | Status | Notes |
|------|--------|-------|
| Codex | Enabled | Primary implementation agent via `auto:implement` triage rule |
| Cursor | Enabled | IDE-based implementation for interactive sessions |
| Cto.new | Enabled | Background agent execution for well-specified tasks |
| GitHub Copilot | Enabled | Code review (via ruleset) + coding agent (via issue assignment) |
| v0 | Enabled | UI component generation |
| Claude Code | **Disabled** | Claude subscription reserved for Cowork/Desktop sessions |

### Automations

- "On open in coding tool, move issue to started status" — **ON**
- "On git branch copy, move to started status" — OFF (agents create branches programmatically)
- "On move to started status, assign to yourself" — OFF (custom assignment logic)

### Prompt Template (v0 Only)

Settings > Preferences > Prompt template. **This template is used by v0 only.** Other agents receive instructions via their own channels:

| Agent | Instructions Source |
|-------|-------------------|
| v0 | This prompt template (below) |
| Codex | `auto:implement` triage rule + issue ACs + agent guidance |
| ChatPRD | `spec:draft` triage rule + @mention + assignment |
| Cursor | Assignment + `.cursorrules` repo file |
| Copilot | `copilot-auto-review` ruleset + `.github/copilot-instructions.md` |
| Sentry | Auto-create from errors + @mention + agent guidance |

```
Implement Linear issue {{issue.identifier}}.

Instructions:
- The acceptance criteria in the description are your definition of done. Do not exceed scope.
- Read all issue comments — they contain spec clarifications, review feedback, and context.
- Branch: {{issue.identifier}}-<short-slug> (lowercase, kebab-case)
- Every PR body MUST include "Closes {{issue.identifier}}" for auto-close
- Ask before implementing anything underspecified. Do not guess.
- Run tests before pushing. Write tests for new behavior if none exist.
- Post a completion summary comment on the issue when done.

{{context}}
```

## Agent Additional Guidance

**Location:** Settings > Team > Agents

All 9 agents receive this guidance text. Configure in Linear Team Settings > Agents tab.
Copy the text between the ``` fences below into the "Additional guidance" field.

```
Team: Claudian (CIA)
Repo: Cianai/Claudian-Clinear (Turborepo monorepo)
Apps: alteri (port 3001), soilworx (port 3002)
Stack: Next.js 16, React 19, TypeScript 5.x, Tailwind v4, pnpm 9

## Pipeline (your role)

ClinearHub is a spec-to-ship pipeline. Each agent has a specific phase:

- ChatPRD: Phase 1 (ideation) + Phase 2 (spec enrichment with 4 personas: Working Backwards, Five Whys, Pre-Mortem, Layman Clarity) + Phase 8 (business validation after all sub-issues close). When enriching a spec, create child sub-issues with the auto:implement label.
- Codex: Phase 4 (implementation). Triggered by auto:implement label. Read the acceptance criteria carefully. Create one branch + one PR per sub-issue.
- Cursor: Phase 2 (technical enrichment for 3pt+ features). Review architecture impact, dependency analysis, technical feasibility. Post findings as comment.
- GitHub Copilot: Phase 5 (code review). Auto-triggered on PR via copilot-auto-review ruleset.
- Sentry Agent: Ongoing (error analysis, root cause). When assigned a Sentry-created issue, analyze the stack trace, identify the root cause, and suggest a fix.
- Factory / Cto.new: Phase 4 (background implementation). Same rules as Codex.

Full pipeline reference: linear://claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f

## Labels (apply to every issue)

- Type (required, exactly one): type:feature, type:bug, type:chore, type:spike
- Execution: exec:quick (1-2pt), exec:tdd (3pt), exec:pair (5pt), exec:checkpoint (8pt)
- Context: ctx:autonomous (for agent work), ctx:review (for PR/deploy stages)

## Conventions

- Branch: CIA-XXX-short-slug (lowercase, kebab-case)
- PR body: MUST include "Closes CIA-XXX" for auto-close on merge
- Commit trailer: Co-Authored-By: <agent-name>
- Do not exceed the scope defined in acceptance criteria
- Read all issue comments before starting — they contain spec clarifications and review feedback
- Post a completion summary comment on the issue when done
- Run tests before pushing. Write tests for new behavior if none exist.

## Completion Protocol

- Before marking Done: tick all [x] acceptance criteria checkboxes in the issue description
- Post a completion comment with: what was implemented, PR link, any deviations from spec
- If an AC cannot be met: post a comment explaining why, do NOT tick the checkbox

## Zero-touch loop

Push → PR → Copilot auto-review → CI (lint+typecheck+build) → Auto-merge → Linear close → Vercel/Railway deploy
```

## Triage Rules

**Location:** Settings > Team > Triage

| Rule | Trigger | Agent | Action |
|------|---------|-------|--------|
| 1 | Issue receives `spec:draft` label | ChatPRD | Enriches spec with personas (Working Backwards, Five Whys, Pre-Mortem, Layman Clarity). Creates sub-issues with `auto:implement` label. |
| 2 | Issue receives `auto:implement` label | Codex | Opens coding tool, implements the issue, creates PR with `Closes CIA-XXX`. |

## Native Integrations

**Location:** Settings > Integrations

### GitHub Integration

- **Repo:** `cianos95-dev/Claudian-Clinear`
- **PR status transitions:** Configure per event:
  - On push → move to In Progress
  - On merge to main → move to Done (via `Closes CIA-XXX` magic words)
  - On review requested → no change (Copilot auto-reviews)
- **Synced comments:** ON — PR comments sync bidirectionally with Linear issue comments
- **Branch format:** `CIA-XXX-slug`

### Figma Integration

- **Purpose:** Bidirectional design↔issue linking
- **Capabilities:** Create issues from Figma selections, link designs to existing issues, embedded design previews in Linear, update issue properties from Figma
- **Setup:** Install Figma plugin for Linear, connect workspace
- **Docs:** https://linear.app/docs/figma

### Sentry Integration

- **Purpose:** Auto-create Linear issues from production errors
- **Setup:** Connect Sentry org to Linear workspace
- **Issue format:** Sentry auto-creates issues with error details, stack traces, affected users
- **Team routing:** Route to Claudian team

### PostHog Integration

- **Purpose:** Create Linear issues from PostHog, bidirectional links
- **Setup:** Install via https://linear.app/integrations/posthog
- **Limitation:** Does not work with private teams
- **Docs:** https://posthog.com/docs/cdp/destinations/linear

### Vercel Integration

- **Purpose:** Link deployments to Linear issues, deployment status
- **Setup:** Install via https://vercel.com/integrations/linear
- **Preview links:** Linear auto-detects Vercel preview URLs on PR attachments

### Sentry↔GitHub Integration (cross-surface)

- **Purpose:** Suspect commits, stack trace→source linking, PR comments surfacing issues, resolve-via-commit, AI code review via Seer
- **Setup:** Configure in Sentry Settings > Integrations > GitHub
- **Config needed:** Code mappings (map stack trace paths to repo paths), enable PR comments (open + merged), enable suspect commits
- **Docs:** https://docs.sentry.io/organization/integrations/source-code-mgmt/github/
