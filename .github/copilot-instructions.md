# Copilot Instructions for ClinearHub

## Repository Summary

ClinearHub (Claude + Linear + GitHub) is a Cowork-first PM methodology plugin for Claudian. It consolidates product management, engineering ops, design, data analytics, customer support, and operations into one opinionated plugin. This is **not** a traditional software project with compiled code — it is a Claude Code plugin consisting of Markdown-based skills, reference documents, configuration files, and a shell validation script.

- **Language:** Markdown, YAML, Bash, JSON
- **License:** Apache-2.0
- **Plugin version:** Defined in `.claude-plugin/plugin.json`

## Project Layout

```
ClinearHub/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata (name, version, description)
├── .mcp.json                # MCP server config (intentionally empty — no bundled connectors)
├── skills/                  # 27 skill directories (core of the plugin)
│   ├── <skill-name>/
│   │   ├── SKILL.md         # Skill definition with YAML frontmatter (name, description) + body
│   │   └── references/      # Optional reference docs loaded by the skill
│   └── ...
├── scripts/
│   └── validate-plugin.sh   # Plugin structural validator (the only build/test script)
├── docs-sync.yml            # Maps plugin reference files to their external sync targets
├── doppler-template.yaml    # Secret management template (Doppler)
├── CONNECTORS.md            # 4-surface configuration guide
├── README.md                # Full project documentation
└── LICENSE                  # Apache-2.0
```

### Skill Directory Convention

Each skill lives in `skills/<skill-name>/` and **must** contain a `SKILL.md` file with:

1. YAML frontmatter between `---` fences containing `name:` and `description:` fields
2. The `name:` field must match the directory name
3. A non-empty Markdown body after the frontmatter

Skills may optionally have a `references/` subdirectory with supporting `.md` files.

There are three skill types:
- **Reference skills** (9): Auto-loaded for context (e.g., `clinearhub-workflow`, `incident-response`)
- **Action skills** (15): User-invoked via `/clinearhub:<name>` (e.g., `write-spec`, `triage`)
- **Query skills** (2): Auto-invocable by model (e.g., `update`, `standup`)

## Validation

The only validation script is `scripts/validate-plugin.sh`. Always run it from the repo root after making changes:

```bash
bash scripts/validate-plugin.sh
```

This script checks:
1. `plugin.json` has required fields (`name`, `version`, `description`) and valid semver version
2. Every skill directory has a `SKILL.md` with required frontmatter (`name`, `description`)
3. Skill frontmatter `name` matches directory name
4. No legacy `commands/` directory files
5. `.mcp.json` is valid JSON with `mcpServers` key
6. All `${CLAUDE_PLUGIN_ROOT}` path references in SKILL.md files resolve to existing files

There is no build step, no compilation, no package manager, and no test suite beyond this validator.

## Key Rules

- **`.mcp.json` must stay empty** (`{"mcpServers": {}}`). Do not add MCP servers — all connectors are configured globally in Claude Desktop to avoid duplicate tool registrations.
- **Do not create a `commands/` directory.** All functionality lives in `skills/`.
- **Verb-first naming** for issues and branches: "Build X", "Implement Y", "Fix Z".
- **One PR per issue.** Each CIA issue gets its own branch and PR.
- When adding a new skill, create `skills/<name>/SKILL.md` with proper frontmatter matching the directory name and a non-empty body. Optionally add a `references/` subdirectory.
- When editing reference files, check `docs-sync.yml` to see if the file maps to an external target that may need syncing.

## Configuration Files

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin identity — bump version here for releases |
| `.mcp.json` | MCP config — intentionally empty, do not add servers |
| `docs-sync.yml` | Source-to-target doc sync manifest for `/sync-docs` command |
| `doppler-template.yaml` | Doppler secret template with 5 tiers of API keys |

## File Naming Conventions

- Skill directories: lowercase with hyphens (e.g., `deploy-checklist`, `sprint-planning`)
- Reference files: lowercase with hyphens, `.md` extension (e.g., `triage-rules.md`)
- Frontmatter `name` field must exactly match the containing directory name
