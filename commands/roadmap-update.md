---
description: View, update, and manage strategic roadmap via Linear Initiatives and Milestones
argument-hint: "<--view | --add | --reprioritize | --create>"
---

# Roadmap Update

Manage the strategic roadmap using Linear Initiatives (strategic themes) and Milestones (time-bound targets).

## Mode: --view (default)

Display the current Now/Next/Later roadmap.

### Step 1: Fetch Initiatives

```
list_initiatives()
```

### Step 2: Fetch Milestones

```
list_milestones()
```

### Step 3: Fetch Recent Status Updates

For each "Now" initiative:
```
get_status_updates(initiativeId: "<id>")
```

### Step 4: Compose View

```markdown
## Roadmap — <date>

### Now (this quarter)

#### <Initiative 1>
- **Health:** 🟢 On Track
- **Milestones:**
  - <Milestone 1> — <target date> (on track)
  - <Milestone 2> — <target date> (at risk)
- **Projects:** <project list>
- **Last update:** <date> — <1-sentence summary>

### Next (next quarter)

#### <Initiative 2>
- **Scope:** <1-sentence description>
- **Projects:** <project list>
- **Dependencies:** <any blockers>

### Later (future)

- <Initiative 3> — <1-sentence description>
- <Initiative 4> — <1-sentence description>

### Capacity Check
- Current cycle: <N>/<M> pts planned (<X>% of velocity)
- Feature/Tech/Buffer split: <X>/<Y>/<Z>%
```

## Mode: --add

Add a new initiative or milestone to the roadmap.

### Step 1: Gather Details

Ask the user:
1. What is the initiative about? (objective, key results)
2. Which horizon? (Now / Next / Later)
3. Which projects are involved?
4. Target date for first milestone? (if Now)

### Step 2: Trade-Off Analysis

**Required before adding to "Now" or "Next":**

```
list_initiatives()
```

Present the current roadmap and ask:
- "What gets removed or delayed to make room for this?"
- "What's the RICE score compared to existing initiatives?"

If adding to "Now" and already 2 initiatives there, one must move to "Next".

### Step 3: Create Initiative

```
save_initiative(
  name: "<initiative name>",
  description: "<formatted description per template>"
)
```

### Step 4: Create Milestone (if Now horizon)

```
save_milestone(
  name: "<initiative abbreviation>: <deliverable>",
  targetDate: "<YYYY-MM-DD>",
  description: "<what this milestone represents>"
)
```

### Step 5: Post Status Update

```
save_status_update(
  type: "initiative",
  id: "<initiative_id>",
  health: "onTrack",
  body: "Initiative created. <objective summary>"
)
```

## Mode: --reprioritize

Reorder initiatives across Now/Next/Later horizons.

### Step 1: Display Current State

```
list_initiatives()
```

Show current horizon assignments.

### Step 2: Propose Changes

Present options:
- Move initiative X from Next → Now (requires: what leaves Now?)
- Move initiative Y from Now → Next (why? what changed?)
- Archive initiative Z to Later (what evidence supports deprioritization?)

### Step 3: Execute Changes

Update initiative descriptions with new horizon labels. Update milestone target dates if horizons shift.

### Step 4: Post Status Updates

For each changed initiative:
```
save_status_update(
  type: "initiative",
  id: "<initiative_id>",
  health: "<appropriate health>",
  body: "Reprioritized: moved from <old horizon> to <new horizon>. Reason: <rationale>"
)
```

## Mode: --create

Shorthand for creating a single milestone within an existing initiative.

### Step 1: Select Initiative

```
list_initiatives()
```

### Step 2: Create Milestone

```
save_milestone(
  name: "<initiative>: <deliverable>",
  targetDate: "<YYYY-MM-DD>",
  description: "<milestone description>"
)
```

## Connector Tier

| Connector | Tier | Access |
|-----------|------|--------|
| Linear | Core | R/W (initiatives, milestones, status updates, projects) |
