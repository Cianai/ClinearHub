---
name: discovery-digest
description: Summarize recent ecosystem discoveries from the dependency monitor — new plugins, MCPs, skills, and tools found via GitHub Search and RSS feeds. Use when asked about new tools, ecosystem updates, what's been discovered, or what's new in the Claude/MCP ecosystem.
context: fork
---

# Discovery Digest

Summarize recent ecosystem discoveries created by the automated `dependency-monitor` workflow. Presents a triage table of new tools, plugins, MCPs, and skills for evaluation.

## Step 1: Query Linear for Recent Discoveries

Search for issues matching **all** of these criteria:
- Team: Claudian (CIA)
- Labels: `dependencies` AND/OR `type:spike`
- Created in the last 14 days (or `$ARGUMENTS` timeframe if specified)
- Title patterns: "Evaluate *", "deps: *"

Use the Linear MCP `search_issues` or `list_issues` with appropriate filters.

## Step 2: Categorize Results

Group discoveries into:

### Dependency Updates (created by release monitoring)
Issues titled `deps: <repo> major update X → Y`. These are known dependency major version bumps that need attention.

### Ecosystem Discoveries (created by GitHub Search + RSS)
Issues titled `Evaluate <repo> (N stars)`. These are new repos/tools discovered via the daily GitHub Search API scan or RSS feeds.

### Manual Spikes
Any `type:spike` issues created manually by Cian or Claude during sessions.

## Step 3: Cross-Reference Current State

For each discovery, check:
1. Is it already in the monitored repos list (${CLAUDE_PLUGIN_ROOT}/../../.github/monitored-repos.yml) — if so, note "Already tracked"
2. Is it already installed as an MCP in ~/.mcp.json — if so, note "Already installed"
3. Is it already a skill in the plugin skills directory (${CLAUDE_PLUGIN_ROOT}/skills) — if so, note "Already a skill"

## Step 4: Present Digest

```markdown
## Ecosystem Digest — [timeframe]

### Dependency Updates Requiring Action

| Package | Change | Type | Issue | Action Needed |
|---------|--------|------|-------|---------------|
| next.js | 16.1 → 17.0 | major | CIA-XXX | Review changelog, test locally |

### New Ecosystem Discoveries

| Tool | Stars | Source | Discovered | Verdict |
|------|-------|--------|-----------|---------|
| [repo/name](url) | N | GitHub Search | 2026-03-01 | Adopt / Evaluate / Monitor / Skip |

### Already Tracked (no action)

- [tool] — in monitored-repos.yml since [date]

### Recommended Next Steps

1. **Adopt**: [tool] — install command
2. **Add to monitoring**: [tool] — add to monitored-repos.yml T2
3. **Create spike**: [tool] — needs deeper evaluation
```

## Step 5: Offer Actions (with user approval)

For any discovery the user wants to act on:
- **Adopt**: Provide install command and config changes
- **Monitor**: Propose `monitored-repos.yml` addition
- **Triage**: Move the Linear issue to the current cycle
- **Dismiss**: Close the Linear issue with a note

## Notes

- This skill is auto-invocable — Claude will load it when the user asks about ecosystem updates
- Runs in a forked context to avoid polluting the main conversation
- Depends on the `dependency-monitor` GitHub Actions workflow running (daily at 08:00 UTC)
- If no discoveries exist, report "No new discoveries in the last 14 days" and suggest running the workflow manually
