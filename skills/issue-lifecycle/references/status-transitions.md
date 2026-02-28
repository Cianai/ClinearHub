# Status Transitions

Complete reference for valid status transitions, who triggers them, and what conditions must be met.

## Status Flow

```
Triage → Todo → In Progress → In Review → Done
  ↓        ↓        ↓            ↓
Backlog    ↓    (back to Todo)  (back to In Progress)
           ↓
      Canceled (from any state, human only)
```

## Transition Details

### Triage → Todo
- **Who:** Agent or human during triage sweep
- **Conditions:** `type:*` label applied, project assigned, estimate set
- **Actions:** Apply execution mode label if determined

### Triage → Backlog
- **Who:** Agent or human
- **Conditions:** Not urgent, no immediate plan to work on
- **Actions:** Estimate optional for backlog items

### Todo → In Progress
- **Who:** Agent or human when work begins
- **Conditions:** None (anyone can start work)
- **Actions:** Apply `ctx:*` label IMMEDIATELY (don't batch). If interactive session: `ctx:interactive`. If agent dispatch: `ctx:autonomous`.

### In Progress → In Review
- **Who:** Agent (typically Codex after PR opened)
- **Conditions:** PR opened or review requested
- **Actions:** Apply `ctx:review`. PR body must include `Closes CIA-XXX`.

### In Review → Done
- **Who:** Agent (after PR merge) or human
- **Conditions:** PR merged, deploy verified, closing comment with evidence posted
- **Actions:** Remove `ctx:*` label. Post closing comment. Never mark Done if PR is only opened (not merged).

### In Review → In Progress
- **Who:** Agent or human
- **Conditions:** Review requested changes
- **Actions:** Update `ctx:*` to reflect who's fixing (interactive vs autonomous)

### Any → Canceled
- **Who:** Human only (agents never cancel)
- **Conditions:** Issue no longer needed
- **Actions:** Remove all `ctx:*` labels. Post brief reason for cancellation.
- **Spelling:** "Canceled" (American English, single L). "Cancelled" fails silently in the API.

## Spec Label Transitions

These run in parallel with status transitions:

| Spec Label | Status Usually | Gate |
|-----------|---------------|------|
| `spec:draft` | Triage or Todo | — |
| `spec:ready` | Todo | Gate 1: Human approves spec |
| `spec:review` | Todo or In Progress | — |
| `spec:implementing` | In Progress | Gate 2: Review passes |
| `spec:complete` | Done | Gate 3: PR merged + verified |

## Context Label Transitions

When the execution surface changes, replace the `ctx:*` label (don't stack):

| Old Context | New Context | When |
|------------|------------|------|
| `ctx:autonomous` | `ctx:interactive` | Agent fails, human picks up |
| `ctx:interactive` | `ctx:review` | PR opened for review |
| `ctx:review` | `ctx:interactive` | Review requests changes, human fixes |
| `ctx:interactive` | `ctx:autonomous` | Human dispatches to background agent |

Always post a comment documenting context transitions for the audit trail.

## Anti-Patterns

- **Skipping Triage**: Creating issues directly in Todo without triage labels
- **Batching status updates**: Waiting to mark In Progress until work is "really" started
- **Done without evidence**: Marking Done without a closing comment
- **Done without merge**: Marking Done when PR is open but not merged
- **Stale In Progress**: Leaving issues In Progress beyond stale thresholds (2hr interactive, 30min autonomous)
