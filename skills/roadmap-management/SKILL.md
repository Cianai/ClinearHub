---
name: roadmap-management
description: |
  Strategic roadmap management using Linear Initiatives and Milestones. Use when discussing roadmap planning, initiative creation, milestone tracking, Now/Next/Later prioritization, RICE scoring, capacity allocation, trade-off analysis, dependency mapping, status updates on initiatives, or any question about strategic planning and prioritization. Also triggers for questions about what to build next, how to prioritize features, what to remove when adding work, or how initiatives and milestones map to projects and issues.
---

# Roadmap Management

Strategic planning layer that maps to Linear's hierarchy: Initiatives (strategic themes) → Projects (product areas) → Issues (work items). Milestones provide time-bound targets within this hierarchy.

## Linear Hierarchy

```
Initiative (strategic theme, multi-quarter)
  └── Project (product area, ongoing)
        └── Milestone (time-bound target within a project)
              └── Issues (work items)
```

### Mapping

| ClinearHub Concept | Linear Entity | MCP Tools |
|---------------------|---------------|-----------|
| Strategic theme | Initiative | `save_initiative`, `get_initiative`, `list_initiatives` |
| Product area | Project | `save_project`, `get_project`, `list_projects` |
| Time-bound target | Milestone | `save_milestone`, `get_milestone`, `list_milestones` |
| Status report | Status Update | `save_status_update`, `get_status_updates` |

## Now/Next/Later Framework

Organize initiatives by time horizon:

| Horizon | Initiatives | Commitment Level |
|---------|-------------|-----------------|
| **Now** (this quarter) | 1-2 max | High — resources allocated, milestones set |
| **Next** (next quarter) | 2-3 | Medium — scoped, not yet staffed |
| **Later** (future) | Unlimited | Low — ideas, not commitments |

**Rules:**
- Maximum 2 initiatives in "Now"
- Every "Now" initiative has at least one milestone with a target date
- Moving an initiative from "Next" to "Now" requires answering: "What gets removed or delayed?"

## RICE Prioritization

Adapted for Linear Priority + Fibonacci estimates:

| Factor | Linear Mapping | Scale |
|--------|----------------|-------|
| **Reach** | Customer Requests count + initiative scope | 1-10 |
| **Impact** | Linear Priority (Urgent=4, High=3, Medium=2, Low=1) | 1-4 |
| **Confidence** | Research label status + spike completion | 0.5-1.0 |
| **Effort** | Sum of issue Fibonacci estimates | Total pts |

**Score = (Reach × Impact × Confidence) / Effort**

Use for comparing initiatives, not individual issues. Individual issue priority is set by triage.

## Capacity Allocation

Target mix for each cycle:

| Category | Allocation | Example |
|----------|-----------|---------|
| **Features** | 70% | New capabilities, customer requests |
| **Tech health** | 20% | Bugs, performance, dependencies, refactoring |
| **Buffer** | 10% | Unplanned, incidents, support |

**Warning thresholds:**
- Features > 80% → technical debt accumulation risk
- Tech health < 10% → fragility increasing
- Buffer used > 20% → interrupt-driven, investigate root cause

## Trade-Off Discipline

When adding work to the roadmap, always answer:

1. **What gets removed?** — If nothing, the roadmap is overcommitted
2. **What gets delayed?** — Push one "Next" initiative to "Later"
3. **What gets descoped?** — Reduce scope of an existing "Now" initiative

Never add without subtracting. The roadmap is a zero-sum game within a quarter.

## Dependency Mapping

Use Linear's blocking relations to map cross-initiative dependencies:

```
get_initiative(id: "<initiative_id>")
# Check projects under the initiative
list_projects()
# Check milestones for target dates
list_milestones()
```

Flag dependencies that cross initiatives — these are the highest-risk items.

## Status Updates

> See [references/initiative-patterns.md](references/initiative-patterns.md) for status update templates.

Initiative status updates use `save_status_update`:

```
save_status_update(
  type: "initiative",
  id: "<initiative_id>",
  health: "onTrack" | "atRisk" | "offTrack",
  body: "<markdown status update>"
)
```

**Cadence:** Weekly, Monday-aligned (matches cycle start).

**Health signals:**
| Health | Criteria |
|--------|----------|
| **On Track** | Milestone dates holding, no blockers, velocity stable |
| **At Risk** | 1+ milestones may slip, dependency unresolved, velocity declining |
| **Off Track** | Milestones missed, critical blockers, requires intervention |

## Cross-Skill References

- **clinearhub-workflow** — Overall 6-step flow, sprint planning context
- **plan-persistence** — Plans may reference initiative context
- **issue-lifecycle** — How initiative-linked issues move through statuses
