# Linear Manual Configuration Guide

> Settings that cannot be configured via API and must be set in the Linear UI. This document is the source of truth for manual configuration steps.

## Triage Intelligence Settings

**Location:** Claudian team → Settings → Triage Intelligence

### Auto-Apply Configuration

| Suggestion | Mode | Rationale |
|------------|------|-----------|
| Team | Auto-apply | Routes to CIA/ALT/SWX based on issue content |
| Project | Auto-apply | Maps to Claudian Platform/ClinearHub/Alteri/Cognito |
| Labels | Auto-apply | Applies Type, Exec, Spec, Context labels |
| Assignee | Show | Suggests but doesn't auto-assign (human confirms) |
| Duplicates | Show | Flags potential duplicates for human review |
| Related Issues | Show | Shows related context |

Set **"Include suggestions from"** to **"This team and its sub-teams"** on the Claudian parent team.

### Additional Guidance — Workspace Level

Paste into the Additional Guidance text box on the Claudian team:

```
Solo developer workspace with AI coding agents. Teams: Claudian (CIA) = shared infrastructure and ClinearHub methodology. Alteri (ALT) = AI alignment research platform. SoilWorx (SWX) = distributor finder app.

Routing: Alteri/conversations/research/XState/state machines/voice intake → ALT. SoilWorx/distributors/Google Maps/XLSX import → SWX. Shared packages/ClinearHub/plugin/monorepo/CI/CD/Turborepo/UI components/design system → CIA.

Projects: Implementation/code → Claudian Platform. PM methodology/workflow/plugin → ClinearHub. Alteri product/UX/research → Alteri. Business ops/consultancy → Cognito.

Labels: type:feature (new), type:bug (defects), type:chore (maintenance), type:spike (research). exec:quick (1-2pt), exec:tdd (3pt), exec:pair (5pt). spec:draft (needs enrichment), spec:ready (ready for implementation). ctx:autonomous (agent alone), ctx:interactive (human+agent). auto:implement triggers agent dispatch.
```

### Additional Guidance — ALT Sub-Team Override

```
Alteri issues always belong to the Alteri project. Research-related issues should get research:needs-grounding label. Voice/conversation features involve XState state machines.
```

### Additional Guidance — SWX Sub-Team Override

```
SoilWorx issues always belong to Claudian Platform project for implementation. Simple CRUD app with Google Maps and XLSX import.
```

## Triage Rules

**Location:** Claudian team → Settings → Triage → Rules

| # | Trigger | Actions |
|---|---------|---------|
| 1 | Label = `type:bug` AND Priority = Urgent | Set status: Todo, Add label: `exec:quick`, Assign: GitHub Copilot |
| 2 | Label = `type:bug` AND Priority = High | Set status: Todo, Add label: `exec:quick` |

Rules fire after TI completes. Inherited by ALT and SWX sub-teams.

## SLA Configuration

**Location:** Settings → Workspace → SLAs

Current rules:

| Rule | Filter | Duration |
|------|--------|----------|
| 1 | Priority = Urgent | 24 hours |
| 2 | Priority = High | 1 week |
| 3 | Label = `urgent` | 24 hours |
| 4 | Label = `type:bug` + Priority = Urgent | 12 hours |

Business days: Mon-Fri.

## Sub-Team Agent Membership

**Location:** Each sub-team → Settings → Members → Add a member

**Critical**: Agent membership is NOT inherited from the parent team. Agents must be added to each sub-team individually. Without this, TI can only suggest human assignees and automated dispatch stalls.

Required members on ALT and SWX (matching CIA parent):
- ChatPRD, Claude, Codex, cto.new, Cursor, Factory, GitHub Copilot, Sentry

**Status**: ✅ All agents added to ALT and SWX on 2026-03-03.

## Verification Checklist

After applying the above settings, verify with these tests:

1. Create test issue "Fix Alteri conversation XState bug" → TI should auto-route to ALT + type:bug
2. Create test issue "Add distributor map filter SoilWorx" → TI should auto-route to SWX + type:feature
3. Apply "Auto: Quick" template → verify all metadata populates correctly with `spec:ready` label
4. Apply "Quick Capture" template → verify description template appears with What/Why/Notes headers
5. Create `type:bug` + Urgent issue → triage rule should auto-assign to Copilot

## Known TI Gaps (from 2026-03-03 verification)

- **SWX project routing**: TI assigned a SWX implementation issue to Cognito project instead of Claudian Platform. Additional Guidance may need stronger wording to distinguish implementation (→ Claudian Platform) from product decisions (→ Cognito).
- **Assignee suggestions**: With agents now on sub-teams, re-test to verify TI suggests agents appropriately based on exec label patterns.
