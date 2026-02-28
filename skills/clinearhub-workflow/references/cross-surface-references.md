# Cross-Surface Reference Discipline

Canonical conventions for how ClinearHub formats links, adapts language, and processes attachments across all surfaces (GitHub, Linear, Cowork, Code sessions). Every agent and command in the plugin follows these rules.

## Repo Constants

```
REPO_URL    = https://github.com/Cianai/ClinearHub
PLUGIN_PATH = packages/clinear-plugin
BLOB_BASE   = https://github.com/Cianai/ClinearHub/blob/main
```

Use these when constructing URLs. Never hardcode the full GitHub path inline — compose from constants.

## GitHub File References

When mentioning plugin files in **Linear issues, comments, or plan documents**, always link to the GitHub source:

```markdown
[filename](https://github.com/Cianai/ClinearHub/blob/main/<path>)
```

**Examples:**

| Context | Format |
|---------|--------|
| Linear issue description | `[cowork-instructions.md](https://github.com/Cianai/ClinearHub/blob/main/packages/clinear-plugin/skills/clinearhub-workflow/references/cowork-instructions.md)` |
| Linear comment | `See [cross-surface-references.md](https://github.com/Cianai/ClinearHub/blob/main/packages/clinear-plugin/skills/clinearhub-workflow/references/cross-surface-references.md) for formatting rules.` |
| Plan document (Linear) | `[plan-format.md](https://github.com/Cianai/ClinearHub/blob/main/packages/clinear-plugin/skills/plan-persistence/references/plan-format.md)` |
| Code session output | `packages/clinear-plugin/skills/clinearhub-workflow/references/cowork-instructions.md` (local path, clickable in terminal) |

**Rule:** Plain text file names (e.g., `cowork-instructions.md` without a link) are never acceptable in Linear-facing content. Always hyperlink.

## Linear References

All CIA-XXX issue mentions must be clickable. Format depends on the target surface:

| Surface | Format | Example |
|---------|--------|---------|
| GitHub docs (README, specs, workflows) | `[CIA-XXX](linear://claudian/issue/CIA-XXX)` | Opens Linear desktop app |
| Linear issues/comments | `CIA-XXX` | Auto-links natively in Linear UI |
| Session output (Code/Cowork) | `[CIA-XXX: Title](https://linear.app/claudian/issue/CIA-XXX)` | Full title for human context |
| Plan documents (Linear) | `[CIA-XXX: Title](https://linear.app/claudian/issue/CIA-XXX)` | Full title + web URL |

**Linear Documents:**

| Surface | Format |
|---------|--------|
| GitHub docs | `[Doc Title](linear://claudian/document/<slug>)` |
| Linear issues/comments | `[Doc Title](https://linear.app/claudian/document/<slug>)` |
| Session output | `[Doc Title](https://linear.app/claudian/document/<slug>)` |

## Issue Content Quality

Absorbed from global CLAUDE.md rules `[DOCUMENTATION LINK]` and `[INLINE LINKS]`.

### References Section (Required)

Every issue description must include a `## References` section with hyperlinked resources:

```markdown
## References

- [Plan: CIA-XXX — summary](https://linear.app/claudian/document/...)
- [cowork-instructions.md](https://github.com/Cianai/ClinearHub/blob/main/packages/clinear-plugin/skills/clinearhub-workflow/references/cowork-instructions.md)
- [Pipeline Architecture](linear://claudian/document/pipeline-architecture-spec-to-ship-37416e6d306f)
```

Exceptions: Simple `type:chore` issues with self-contained scope (e.g., "Bump version to X") may omit References.

### Inline Link Discipline

- Every CIA-XXX mention in session output, plans, and comments must be a clickable markdown link
- Session exit summary tables use linked titles: `[Issue title](linear-url)`
- Never use plain text issue IDs — always `[CIA-XXX: Title](url)` or `[CIA-XXX](url)`

## Operational Discipline

Absorbed from global CLAUDE.md rules `[DISPATCH CONTEXT]`, `[VERIFY-AFTER-MUTATE]`, and `[REVISION TRAIL]`.

### Dispatch Context

Before dispatching any issue to an external agent (Factory, Cursor, Copilot coding, cto.new, Amp, Codex):

1. Attach the plan file as a Linear attachment via `create_attachment`
2. Include target repo, branch strategy, and acceptance criteria in the issue description
3. An issue without a plan attachment MUST NOT be delegated

### Verify After Mutate

After any batch of Linear mutations (3+ issues updated):

1. Immediately verify by reading back affected issues
2. Parallelize verification via subagent if >3 issues
3. Retry once on failure, then flag user

### Revision Trail

Before rewriting a Linear issue description:

1. Post a comment: `**Description revision [N]**: [summary]. Reason: [context]. Removed: [key content].`
2. Then perform the update
3. Never silently overwrite descriptions — the comment trail is the audit log

## Surface-Aware Language

Generalized from `/stakeholder-update`'s audience adaptation. Every command and session output should match the target surface's language conventions:

| Surface | Audience | Tone | Link Style | Jargon |
|---------|----------|------|------------|--------|
| **GitHub** (README, PR body, specs) | Developers, public | Technical, concise | `linear://` for Linear refs, relative for repo files | Use freely |
| **Linear** (issues, comments, plans) | PM, agents, stakeholders | Process-focused, structured | GitHub URLs for source files, web URLs for Linear | Define on first use |
| **Cowork / session output** | Human PM | Conversational, explanatory | Full URLs, clickable everything | Define parenthetically |
| **Stakeholder comms** | Exec / customer / board | Strategic, outcome-focused | Minimal links, inline context | Avoid entirely |

**Key principle:** The same information is presented differently depending on who reads it. Technical content stays intact — only the framing adapts.

### Per-Audience Templates (from /stakeholder-update)

| Audience | Frame | Metrics | Next Steps |
|----------|-------|---------|------------|
| Executive | Strategic impact, timeline, blockers | Velocity, completion %, burn rate | Decisions needed, risks |
| Team | Detailed progress, technical wins | Issues closed, PR stats, test coverage | Upcoming work, dependencies |
| Customer | Benefit-focused, what's new for them | Feature availability, reliability | Release dates, feedback channels |
| Board | Market context, strategic direction | Quarter progress, milestone completion | Strategic pivots, resource needs |

## Multimedia Attachment Processing

### MarkItDown MCP

Convert multimedia attachments to markdown for inline context during session start and plan review.

**Tool:** `convert_to_markdown(uri)` — supports `file:`, `http:`, `https:`, `data:` URIs

**Use cases:**

| Attachment Type | What MarkItDown Does | Pipeline Step |
|----------------|---------------------|---------------|
| PDF | Full text extraction | Session Start Protocol (Step 5) |
| Screenshot / image | OCR via LLM (requires `OPENAI_API_KEY`) | Session Start Protocol (Step 5) |
| Office docs (DOCX, XLSX, PPTX) | Structured text extraction | Session Start Protocol (Step 5) |
| YouTube URL | Transcript extraction | Issue context discovery |
| HTML page | Clean markdown conversion | Research, /update |

**Integration with Session Start Protocol:**

```
5. get_attachment(issueId) — human-added files
   5a. For PDF/image/Office/video attachments → convert_to_markdown(attachment_url)
   5b. Include converted content in Known State under "Attached Resources"
```

Linear supports [native video embed](https://linear.app/docs/editor) — YouTube URLs attached to issues can be transcribed via MarkItDown for agent consumption.

**Surface availability:**

| Surface | Transport | How |
|---------|-----------|-----|
| Claude Code | stdio | `~/.mcp.json` → `uvx markitdown-mcp` (per-session enabled, Doppler wraps `OPENAI_API_KEY`) |
| Cowork | HTTP | Run `markitdown-mcp --http --host 127.0.0.1 --port 3001` locally, then bridge via Desktop Commander relay or tunnel. Not yet automated — requires local server running. |
| Antigravity | stdio | Add to `~/.gemini/antigravity/mcp_config.json` (same uvx command) |

**Configuration:** MarkItDown MCP is a per-session enabled server in `~/.mcp.json`. Enable when sessions involve multimedia attachments. For Cowork access, run the HTTP server locally first: `uvx markitdown-mcp --http --host 127.0.0.1 --port 3001`.

## Cross-Skill References

- **plan-persistence** — Plan Format Hyperlink Rules (specific to plan documents)
- **issue-lifecycle** — Issue Content Quality section (references this file)
- **clinearhub-workflow** — Cross-Surface References section (references this file)
- **stakeholder-update** — Language Adaptation table (detailed audience templates)
