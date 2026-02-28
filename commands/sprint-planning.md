---
description: Cycle review, velocity analysis, next sprint composition
argument-hint: "[--review | --plan | --both]"
---

# Sprint Planning

Review the current Linear cycle and plan the next one. Covers velocity analysis, completion rates, carry-forward items, and next sprint composition.

## Modes

| Flag | Behavior |
|------|----------|
| `--review` | Review current/last cycle only |
| `--plan` | Plan next cycle only |
| `--both` (default) | Review then plan |

## Step 1: Review Current Cycle

Fetch the current (or most recent completed) cycle:
```
list_cycles(team: "Claudian", limit: 2)
```

For the target cycle, gather:
- Total issues planned vs completed
- Points planned vs completed (velocity)
- Issues carried forward (still In Progress or Todo at cycle end)
- Issues added mid-cycle
- Issues canceled

### Velocity Report

```markdown
## Cycle Review — [Cycle Name/Date Range]

**Velocity:** N pts completed / N pts planned (XX%)
**Completion:** N issues done / N planned (XX%)
**Carried Forward:** N issues (N pts)
**Added Mid-Cycle:** N issues

### Completed
| Issue | Type | Estimate | Notes |
|-------|------|----------|-------|
| CIA-XXX: [Title] | feature | 3pt | — |

### Carried Forward
| Issue | Type | Estimate | Reason |
|-------|------|----------|--------|
| CIA-YYY: [Title] | feature | 5pt | Blocked by [reason] |

### Canceled
| Issue | Reason |
|-------|--------|
| CIA-ZZZ: [Title] | Superseded by CIA-AAA |
```

## Step 1.5: Retrospective (before planning)

Before planning the next cycle, briefly retrospect on the current one:

```markdown
### Retro — [Cycle Name]

**What went well:**
- [1-2 items]

**What didn't go well:**
- [1-2 items]

**What to change:**
- [1 actionable change for next cycle]
```

Keep it concise — this is a prompt for the user, not a formal post-mortem.

## Step 2: Plan Next Cycle

### Capacity Calculation

Based on recent velocity (average of last 3 cycles if available):
- **Target capacity**: Average velocity × 70-80% (NOT 100% — leave buffer)
- **WIP limit**: Maximum 5 issues In Progress simultaneously
- **Mix**: Aim for balance — research/spec + implementation + infra/cleanup

**The 70-80% rule:** Plan for 70-80% of average velocity. Items beyond 80% are **stretch items** — they can be cut without failing the sprint. This prevents overcommitment and leaves room for unplanned work.

### Capacity Table (if GCal connected)

Build a capacity table showing actual available time:

```markdown
| Team Member | Available Days | Meeting Hours | Net Capacity |
|-------------|---------------|---------------|-------------|
| Cian | 5 | 8h | ~60% |
| Claude (agents) | 5 | 0h | 100% |
```

Fetch meeting load from Google Calendar:
```
list_events(timeMin: "<cycle_start>", timeMax: "<cycle_end>")
```

If GCal not connected, skip the table and use velocity-based planning only.

### Issue Selection

Pull candidates from:
1. **Carry-forward** — Unfinished items from current cycle (highest priority)
2. **Unblocked Todo** — Issues in Todo with no blocking dependencies
3. **High-priority Backlog** — Urgent or High priority backlog items
4. **Spike prerequisites** — Any spikes that must complete before dependent implementation

```
list_issues(team: "Claudian", state: "Todo", limit: 20)
```

Filter and rank by:
1. Priority (Urgent > High > Medium > Low)
2. Blocking impact (issues that unblock the most downstream work)
3. SLA proximity (approaching breach)
4. Balance across projects

### Sprint Goal

Require a one-sentence sprint goal before presenting the sprint composition:

> "Complete this sprint in one sentence."

The goal anchors all prioritization decisions. If an item doesn't serve the goal, it's a stretch item or should wait.

### Proposed Sprint

```markdown
## Next Cycle — [Start Date] to [End Date]

**Goal:** <one sentence describing what this sprint achieves>
**Target:** N pts (based on N-cycle average velocity × 80%)
**Issues:** N items

### Committed (within 80% line)
| Issue | Type | Estimate | Mode | Priority |
|-------|------|----------|------|----------|
| CIA-XXX: [Title] | feature | 3pt | tdd | High |
| CIA-YYY: [Title] | bug | 1pt | quick | Urgent |

**Committed total:** N pts / N target (XX%)

### Stretch (beyond 80% — can be cut)
| Issue | Type | Estimate | Mode | Priority |
|-------|------|----------|------|----------|
| CIA-ZZZ: [Title] | chore | 2pt | quick | Medium |

**Including stretch:** N pts / N target (XX%)

### Balance Check
- Features: N pts (N%) [target: 70%]
- Tech Health: N pts (N%) [target: 20%]
- Buffer: N pts (N%) [target: 10%]
```

**Warning flags:**
- Total > 100% of velocity → overcommitted, must cut
- Features > 80% → tech debt risk, flag to user
- No stretch items → planning too conservatively
- 0 pts tech health → fragility increasing

Present the proposed sprint for user approval. Adjust based on feedback.

**Note:** `list_cycles` is read-only — cycles must be created in the Linear UI. This command works with existing cycles.

## Step 3: Apply

After user approves the sprint composition:
1. Assign selected issues to the next cycle in Linear
2. Ensure all issues have `type:*` labels and estimates
3. Report any issues that still need spec work before implementation
