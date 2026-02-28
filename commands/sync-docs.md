---
description: Check and sync plugin reference files with their external targets (Linear UI, Claude Desktop)
argument-hint: "[--check-only]"
---

# Sync Docs

Check which plugin reference files have changed since their last sync to external targets (Linear UI settings, Claude Desktop instructions). Helps keep documentation in sync across GitHub repo and UI-configured surfaces.

## Step 1: Read Manifest

Read `docs-sync.yml` from the plugin root. Parse the mappings list.

## Step 2: Check Each Mapping

For each mapping in the manifest:

1. Read the source file
2. Extract the section content (between ``` fences matching the section name)
3. Check `last_synced` date against file's last modified date (via `git log -1 --format=%aI -- <path>`)
4. If `last_synced` is null or older than last modified → mark as **STALE**

## Step 3: Report

Output a sync status table:

```markdown
## Documentation Sync Status

| Source File | Target | Status | Last Synced | Last Modified |
|-------------|--------|--------|-------------|--------------|
| linear-agent-config.md (Agent Guidance) | Linear > Team > Agents | STALE | never | 2026-02-27 |
| linear-agent-config.md (Prompt Template) | Linear > Preferences | STALE | never | 2026-02-27 |
| cowork-instructions.md (Global) | Desktop > Instructions | OK | 2026-02-27 | 2026-02-27 |
```

If `--check-only`, stop here.

## Step 4: Sync Guidance

For each STALE mapping, output:

1. The target location (where to paste)
2. The extracted content to paste (between ``` fences)
3. Ask user to confirm they've synced it

## Step 5: Update Manifest

After user confirms sync for each stale mapping:

1. Update `last_synced` to today's date in `docs-sync.yml`
2. Commit the updated manifest

## Notes

- This command does NOT auto-apply changes to Linear or Desktop — those are UI-only settings
- It tracks staleness and provides the content to paste, reducing the risk of drift
- CI can run `--check-only` to warn on PRs that modify reference files without syncing
