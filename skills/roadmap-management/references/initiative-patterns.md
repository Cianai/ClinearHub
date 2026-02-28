# Initiative & Milestone Patterns

Templates and patterns for managing Linear Initiatives and Milestones via MCP tools.

## Initiative Description Template

```markdown
## <Initiative Name>

**Horizon:** Now / Next / Later
**Owner:** <person>
**Target Quarter:** Q<N> <YYYY>

### Objective
<1-2 sentences: what does success look like?>

### Key Results
1. <Measurable outcome 1>
2. <Measurable outcome 2>
3. <Measurable outcome 3>

### Projects
- <Project 1> — <role in this initiative>
- <Project 2> — <role in this initiative>

### Dependencies
- <Dependency 1> — <status>
- <Dependency 2> — <status>

### RICE Score
Reach: <N>/10 | Impact: <N>/4 | Confidence: <N>/1.0 | Effort: <N> pts
**Score: <calculated>**
```

## Status Update Template

Weekly status updates via `save_status_update`:

```markdown
## Week of <date>

**Health:** 🟢 On Track / 🟡 At Risk / 🔴 Off Track

### Progress
- <What was accomplished this week>
- <Metrics or evidence>

### Milestones
| Milestone | Target | Status | Confidence |
|-----------|--------|--------|------------|
| <name> | <date> | On Track / Slipping | High / Medium / Low |

### Blockers
- <Blocker 1> — <action needed>

### Next Week
- <Key focus for next week>
```

## Milestone Management

### Creating Milestones

```
save_milestone(
  name: "<milestone name>",
  targetDate: "<YYYY-MM-DD>",
  description: "<what this milestone represents>"
)
```

### Milestone Naming Convention

Format: `<Initiative abbreviation>: <deliverable>`

Examples:
- `CLH v1.0: Plugin shipped`
- `Alteri: Voice intake live`
- `Platform: Shared UI library v2`

### Target Date Management

- Set realistic dates based on velocity (pts/cycle)
- Update target dates proactively when velocity changes
- Never silently miss a date — update the milestone and post a status update explaining the slip

## Status Update Cadence

| Update Type | Frequency | Tool | Notes |
|-------------|-----------|------|-------|
| Initiative status | Weekly (Monday) | `save_status_update(type: "initiative")` | Health + progress + blockers |
| Milestone progress | On completion or slip | `save_milestone` | Update description with latest |
| Project description | After significant changes | `save_project` | Keep project description current |

## Limitations

- `save_status_update` supports `type: "initiative"` only — project-level status updates may require the Linear UI or GraphQL
- `list_cycles` is read-only — cycles must be created in the Linear UI
- Initiative → Project linking is managed in Linear UI; MCP can read but not modify the association
