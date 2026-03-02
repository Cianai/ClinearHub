# Label Taxonomy

Workspace-level labels organized by group. Every issue must have exactly one `type:*` label. Groups enforce **single-select** — only one label from each group may be applied to an issue.

## Type Labels (Group: Type — Single Select, Required)

| Label | When to Use | Verb Heuristic | Description |
|-------|------------|----------------|-------------|
| `type:feature` | New functionality or enhancement | Build, Implement, Add, Create, Ship | New capability or feature implementation |
| `type:bug` | Something broken that needs fixing | Fix, Resolve, Repair | Defect fix or bug resolution |
| `type:chore` | Maintenance, config, cleanup | Configure, Migrate, Set up, Wire up, Audit | Maintenance, configuration, or infrastructure work |
| `type:spike` | Research or investigation (output = knowledge, not code) | Evaluate, Survey, Investigate, Spike | Time-boxed exploration or evaluation |

## Spec Lifecycle Labels (Group: Spec — Single Select)

Applied in order as a spec progresses. Replace, don't stack.

| Label | State | Transition | Description |
|-------|-------|-----------|-------------|
| `spec:draft` | Authoring / ChatPRD enrichment | Applied on issue creation or when spec needs work | Spec in progress (triggers ChatPRD enrichment) |
| `spec:ready` | Human approved spec | Human moves from draft after reviewing ChatPRD enrichment | Spec complete, ready for decomposition |
| `spec:review` | Under adversarial review | Reviewer begins (Linear Agent Teams) | Under adversarial review by agent team |
| `spec:implementing` | Code is being written | Codex or human starts implementation | Active implementation in progress |
| `spec:complete` | Shipped and verified | All ACs met, PR merged, deploy verified | All acceptance criteria met, shipped |

## Execution Mode Labels (Group: Exec — Single Select)

Determine ceremony level and implementation approach. Applied during triage or planning.

| Label | Scope | Estimate | Agent Routing | Description |
|-------|-------|----------|---------------|-------------|
| `exec:quick` | Small, obvious changes | 1-2pt | Direct implementation, minimal ceremony | Direct implementation for small well-understood changes (1-2pt) |
| `exec:tdd` | Testable acceptance criteria | 3pt | Red-green-refactor cycle | Test-driven development with red-green-refactor cycle (3pt) |
| `exec:pair` | Uncertain scope, needs human-in-the-loop | 5pt | Human + agent collaboration | Human-agent pairing for uncertain scope (5pt) |
| `exec:checkpoint` | High-risk, milestone-gated | 8pt | Pause for human review at each gate | Milestone-gated with human review checkpoints (8pt) |
| `exec:swarm` | 5+ independent parallel tasks | 5-8pt | Multi-agent fan-out | Multi-agent parallel fan-out (5-8pt) |

## Execution Context Labels (Group: Context — Single Select)

Track who/where is working on the issue. Replace on context transitions.

| Label | Surface | Stale Threshold | Description |
|-------|---------|----------------|-------------|
| `ctx:interactive` | Human-present: Cowork, Claude Code, Cursor, Desktop | 2 hours | Human-present session: Claude Code, Cursor, Cowork, Desktop Chat |
| `ctx:autonomous` | Background agent: Codex, Factory, Copilot coding | 30 minutes | Unattended agent: Codex, Factory, Cto.new, Copilot coding |
| `ctx:review` | Automated review: Copilot auto-review, Vercel preview | 1 hour | Automated review: Copilot code review, Vercel preview |
| `ctx:human` | Manual work without AI assistance | 48 hours | Manual work without AI assistance |

Rules: Apply only to Todo, In Progress, In Review. Remove on Done/Canceled.

## Dispatch Labels (Group: Dispatch — Single Select)

| Label | Action | Description |
|-------|--------|-------------|
| `auto:implement` | Triggers Codex dispatch via Linear triage rule | Trigger auto-implementation via Codex triage rule |

## Research Readiness Labels (Group: Research — Single Select, ALT Primarily)

| Label | Requirement | Description |
|-------|-------------|-------------|
| `research:needs-grounding` | Idea exists, no literature support | Research idea without literature support |
| `research:literature-mapped` | 3+ papers cited | Literature review complete (3+ papers) |
| `research:methodology-validated` | Instruments + statistics documented | Methodology and instruments documented |
| `research:expert-reviewed` | Human domain expert has reviewed (always requires human) | Domain expert has validated (human gate) |

## Template Labels (Group: Template — Single Select)

| Label | PR/FAQ Template | Description |
|-------|----------------|-------------|
| `template:prfaq-feature` | Customer-facing product feature | PR/FAQ template for customer-facing features |
| `template:prfaq-infra` | Internal infrastructure change | PR/FAQ template for infrastructure changes |
| `template:prfaq-research` | Research-backed feature | PR/FAQ template for research-backed features |
| `template:prfaq-quick` | Small scope change | PR/FAQ template for small scope changes |

## Origin Labels (Group: Source — Single Select)

Track where the issue originated. Apply once at creation.

| Label | Source | Description |
|-------|--------|-------------|
| `source:voice` | Voice memo | Issue originated from voice memo |
| `source:cowork` | Cowork session | Issue originated from Cowork session |
| `source:code-session` | Claude Code session | Issue originated from Claude Code session |
| `source:direct` | Direct input | Issue created directly in Linear |
| `source:vercel-comments` | Vercel deploy preview comments | Issue originated from Vercel preview comment |

## Standalone Labels (No Group — Freely Combinable)

| Label | Purpose | Description |
|-------|---------|-------------|
| `urgent` | SLA-critical, needs immediate attention | SLA trigger — 24hr deadline when combined with Urgent priority |
| `dependencies` | Has external dependency tracking | Issue has external dependencies to track |
| `design` | Requires design work. Triggers human-gated design step in pipeline Phase 3: design must be created (Figma/Magic Patterns/v0), approved by human, and linked to issue before `auto:implement` is applied. Codex implements with Figma MCP design context when available. | Human-gated design step required before implementation |

## Archived Labels

| Label | Reason | Date |
|-------|--------|------|
| `app:alteri` | Replaced by ALT sub-team routing | Mar 2026 |
| `app:soilworx` | Replaced by SWX sub-team routing | Mar 2026 |
| `app:shared` | Replaced by CIA parent team routing | Mar 2026 |
| `sniff:implement` | Sniff agent experiment abandoned (CIA-756/D-017) — native Linear agents preferred | Mar 2026 |
| `sniff:review` | Sniff agent experiment abandoned (CIA-756/D-017) — native Linear agents preferred | Mar 2026 |
