# Label Taxonomy

38 workspace-level labels organized by category. Every issue must have exactly one `type:*` label.

## Type Labels (Required — Exactly One Per Issue)

| Label | When to Use | Verb Heuristic |
|-------|------------|----------------|
| `type:feature` | New functionality or enhancement | Build, Implement, Add, Create, Ship |
| `type:bug` | Something broken that needs fixing | Fix, Resolve, Repair |
| `type:chore` | Maintenance, config, cleanup | Configure, Migrate, Set up, Wire up, Audit |
| `type:spike` | Research or investigation (output = knowledge, not code) | Evaluate, Survey, Investigate, Spike |

## Spec Lifecycle Labels (Mutually Exclusive)

Applied in order as a spec progresses. Replace, don't stack.

| Label | State | Transition |
|-------|-------|-----------|
| `spec:draft` | Authoring / ChatPRD enrichment | Applied on issue creation or when spec needs work |
| `spec:ready` | Human approved spec | Human moves from draft after reviewing ChatPRD enrichment |
| `spec:review` | Under adversarial review | Reviewer begins (Linear Agent Teams) |
| `spec:implementing` | Code is being written | Codex or human starts implementation |
| `spec:complete` | Shipped and verified | All ACs met, PR merged, deploy verified |

## Execution Mode Labels (Mutually Exclusive)

Determine ceremony level and implementation approach. Applied during triage or planning.

| Label | Scope | Estimate | Agent Routing |
|-------|-------|----------|---------------|
| `exec:quick` | Small, obvious changes | 1-2pt | Direct implementation, minimal ceremony |
| `exec:tdd` | Testable acceptance criteria | 3pt | Red-green-refactor cycle |
| `exec:pair` | Uncertain scope, needs human-in-the-loop | 5pt | Human + agent collaboration |
| `exec:checkpoint` | High-risk, milestone-gated | 8pt | Pause for human review at each gate |
| `exec:swarm` | 5+ independent parallel tasks | 5-8pt | Multi-agent fan-out |

## Execution Context Labels (Mutually Exclusive)

Track who/where is working on the issue. Replace on context transitions.

| Label | Surface | Stale Threshold |
|-------|---------|----------------|
| `ctx:interactive` | Human-present: Cowork, Claude Code, Cursor, Desktop | 2 hours |
| `ctx:autonomous` | Background agent: Codex, Factory, Copilot coding | 30 minutes |
| `ctx:review` | Automated review: Copilot auto-review, Vercel preview | 1 hour |
| `ctx:human` | Manual work without AI assistance | 48 hours |

Rules: Apply only to Todo, In Progress, In Review. Remove on Done/Canceled.

## Auto-Dispatch Labels

| Label | Action |
|-------|--------|
| `auto:implement` | Triggers Codex dispatch via Linear triage rule |

## Research Readiness Labels (Alteri Only)

| Label | Requirement |
|-------|-------------|
| `research:needs-grounding` | Idea exists, no literature support |
| `research:literature-mapped` | 3+ papers cited |
| `research:methodology-validated` | Instruments + statistics documented |
| `research:expert-reviewed` | Human domain expert has reviewed (always requires human) |

## Template Labels

| Label | PR/FAQ Template |
|-------|----------------|
| `template:prfaq-feature` | Customer-facing product feature |
| `template:prfaq-infra` | Internal infrastructure change |
| `template:prfaq-research` | Research-backed feature |
| `template:prfaq-quick` | Small scope change |

## Origin Labels (Mutually Exclusive)

Track where the issue originated. Apply once at creation.

| Label | Source |
|-------|--------|
| `source:voice` | Voice memo |
| `source:cowork` | Cowork session |
| `source:code-session` | Claude Code session |
| `source:direct` | Direct input |
| `source:vercel-comments` | Vercel deploy preview comments |

## Standalone Labels

| Label | Purpose |
|-------|---------|
| `urgent` | SLA-critical, needs immediate attention |
| `dependencies` | Has external dependency tracking |
| `design` | Requires design work. Triggers human-gated design step in pipeline Phase 3: design must be created (Figma/Magic Patterns/v0), approved by human, and linked to issue before `auto:implement` is applied. Codex implements with Figma MCP design context when available. |
| `app:soilworx` | Routes to SoilWorx app context |
| `app:alteri` | Routes to Alteri app context |
| `app:shared` | Shared/platform-level work |
