# Multi-Surface Plan Review

How plans flow between surfaces for creation, review, and editing.

## The Multi-Hop Review Chain

```
Cowork (create plan) → promote to Linear Document via /plan --promote
        ↓
    User stays in Cowork (session continues)
        ↓
    Meanwhile, user opens Code tab in Desktop (same machine, same repo folder)
        ↓
    Code reads plan from Linear: /plan --review CIA-XXX
    Code applies output style: /output-style pm-review (for non-technical explanation)
        ↓
    From Code, user clicks "Continue in" → VS Code or Cursor
        ↓
    In IDE: plan is a Linear Document — user edits via Linear UI sidebar
    OR: user copies plan to a local .md file and edits line-by-line
        ↓
    User returns to Cowork, which has been running in parallel the whole time
    Any edits made to the Linear Document are immediately visible via /plan --review
```

**Key insight:** Linear Documents are the shared state bus. All surfaces read/write the same Linear API. No custom sync needed.

## Surface Capabilities for Plan Review

### Cowork (Primary — plan creation)

- Creates plans from conversation context
- Promotes to Linear via `/plan --promote`
- Reviews plans via `/plan --review`
- No filesystem, no shell, no CLI
- Internal sub-agents are system-managed (black box) — not user-directed

### Claude Code (Secondary — interactive review)

- Reads plans from Linear via `/plan --review`
- Output styles (`/output-style pm-review`) for non-technical explanation
- Full filesystem access for local plan files
- User-directed subagents via Task tool
- "Continue in" → VS Code/Cursor transfers session to IDE

### VS Code / Cursor (Tertiary — line-by-line editing)

VS Code 1.109+ (Jan 2026) added significant AI agent features:

| Feature | Status | Relevance to Plan Review |
|---------|--------|-------------------------|
| **Claude Agent Support** | Preview | Reads CLAUDE.md, `.claude/rules`, `.claude/agents`, `.claude/skills`, `.claude/settings.json` — ClinearHub skills available |
| **`/plan` slash command** | Available | 4-phase workflow: Discovery → Alignment → Design → Refinement |
| **Skills as Slash Commands** | Available | Agent Skills appear in `/` menu — ClinearHub `/plan --review` invocable |
| **Plan mode diffs** | Stable | Proposed changes shown as inline diffs for approve/reject/modify |
| **Checkpoints / Rewind** | Stable | Hover any message → Fork conversation, Rewind code, or both |
| **Resume remote sessions** | Stable | Past Conversations → Remote tab → resume web sessions in IDE |
| **Subagents** | Available | Parallel execution with dedicated context windows |
| **Agent Hooks** | Preview | Same hook format as Claude Code — hooks are portable |
| **Session Type Picker** | Available | Switch between Local, Background, Cloud agent environments |
| **Copilot Memory** | Preview | Store/recall context across sessions — complements Linear pre-flight |
| **Message Steering** | Experimental | Send follow-up while requests run — queue, steer, or stop+send |
| **MCP Apps** | Available | Rich interactive UI in chat |
| **@-mention files** | Stable | `@plan.md#5-10` references specific plan sections with line ranges |

**Critical:** VS Code reads Claude's full configuration chain. When a user does "Continue in" → VS Code, ClinearHub skills and repo-scoped skills are available. The `/plan` command from ClinearHub works in VS Code's Claude agent.

VS Code's native `/plan` (4-phase) coexists with ClinearHub's `/plan --review` — they are different tools. ClinearHub's is a skill slash command; VS Code's is the built-in plan mode.

## The Complete Interactive Review Flow

```
Cowork: create plan → /plan --promote CIA-XXX (saves to Linear Document)
  ↓
User opens Code tab in Desktop (same repo folder)
  ↓
Code: /plan --review CIA-XXX → displays plan with status
Code: /output-style pm-review → Claude explains plan in non-technical language
Code: user discusses plan interactively, Claude proposes updates
  ↓
User clicks "Continue in" → VS Code or Cursor
  ↓
IDE (VS Code 1.109+):
  - Claude agent loads CLAUDE.md + .claude/skills (ClinearHub skills available)
  - ClinearHub /plan --review invocable via skills slash menu
  - Plan file opens as VS Code tab — user edits line-by-line
  - @plan.md#5-10 to discuss specific plan sections with Claude
  - /plan mode (VS Code native): 4-phase Discovery → Alignment → Design → Refinement
  - Checkpoints: fork conversation to explore plan alternatives, rewind if wrong direction
  - Subagents: parallel research without main context overflow
  - Message steering: queue follow-up questions while Claude processes current one
  - Changes saved → /plan --promote updates Linear Document
  ↓
Meanwhile, Cowork is still running on same Linear issues
  - User returns to Cowork: reads updated plan via /plan --review
  - Any Linear Document edits from IDE are immediately visible
  - No conflict: both surfaces use Linear API, last-write-wins
```

## Simultaneous Session Compatibility

| Surface A (running) | Surface B (parallel) | How B accesses plans | Conflicts? |
|---------------------|---------------------|---------------------|------------|
| Cowork | Code tab (same Desktop) | `/plan --review` reads Linear Document | No — both use Linear API |
| Cowork | VS Code/Cursor (via "Continue in") | Edit plan file directly + @-mention | File conflicts if same dir — use worktree |
| Cowork | Web session (`claude --remote`) | Reads Linear via MCP | No — isolated cloud VM |
| Cowork | Mobile/browser (`/remote-control`) | View-only into Code session | No — read-only bridge |
| Code | Web session (parallel) | Both read/write Linear | No — last-write-wins |

## When to Use Each Surface

| Surface | Best For | Plan Access |
|---------|----------|-------------|
| **Cowork** | Creating plans, triage, stakeholder comms | `/plan --promote`, `/plan --review` |
| **Code + output styles** | Explaining plans to non-technical reviewers, interactive discussion | `/plan --review` + `/output-style pm-review` |
| **IDE ("Continue in")** | Line-by-line plan editing, @-mention specific sections, exploring alternatives via checkpoints | Edit local `.md` or Linear sidebar |
| **Web/Mobile** | Parallel research, remote review | Read Linear via MCP |

## Platform Constraints

| Constraint | Impact | Workaround |
|------------|--------|------------|
| No Cowork→Code handoff | Can't auto-transfer session context | Linear Documents are the bridge; user manually opens Code tab |
| No "Continue in" from Cowork | Must manually start Code tab | Code tab reads same Linear issue via `/plan --review` |
| Code→IDE "Continue in" works | Session transfers to VS Code/Cursor | VS Code 1.109 loads full Claude config — ClinearHub skills available |
| Plan file names auto-generated | Can't enforce `CIA-XXX-slug.md` naming | Convention: copy to canonical name before promotion |
| Cowork subagents are black box | Can't direct parallelization in Cowork | Accept system-managed; explicit subagents only in Code/IDE |
| No webhook on remote session completion | Can't notify Cowork when Code/Web finishes | Poll via Linear issue status or `/plan --review` |
| Chrome extension ≠ session bridge | Can't open sessions from browser pages | Browser automation tool, not useful for plan review |

## Notes

- The Chrome extension is a browser automation tool, NOT a session bridge — not useful for cross-surface plan review
- Cowork internal sub-agents are system-managed — there is no Task tool, Agent Teams, or explicit subagent control in Cowork
- All plan mutations go through Linear API — architecturally isolated, no conflicts between simultaneous surfaces
