# Execution Modes

Reference for selecting the right execution mode. ClinearHub documents these for triage and estimation; actual execution happens in Claude Code (CCC plugin) or via agent dispatch.

## Decision Heuristic

```
Is this exploration/investigation (output = knowledge, not code)?
|
+-- YES --> exec:spike
|
+-- NO --> Is the scope well-defined with clear acceptance criteria?
           |
           +-- YES --> Are there 5+ independent tasks?
           |           |
           |           +-- YES --> exec:swarm
           |           |
           |           +-- NO --> Is it testable (can you write a failing test)?
           |                      |
           |                      +-- YES --> exec:tdd
           |                      |
           |                      +-- NO --> exec:quick
           |
           +-- NO --> Is it high-risk (security, data, breaking changes)?
                      |
                      +-- YES --> exec:checkpoint
                      |
                      +-- NO --> exec:pair
```

When in doubt, prefer `exec:pair` — it keeps a human in the loop while scope crystallizes.

## Estimate-to-Mode Mapping

| Estimate | Recommended Mode | Rationale |
|----------|-----------------|-----------|
| 1pt | `exec:quick` | Trivial, obvious implementation |
| 2pt | `exec:quick` | Small but slightly more involved |
| 3pt | `exec:tdd` | Moderate scope, testable ACs |
| 5pt | `exec:tdd` or `exec:pair` | Significant scope, may need human input |
| 8pt | `exec:pair` or `exec:checkpoint` | Large scope, consider decomposing |
| 13pt | `exec:checkpoint` | Must decompose into smaller issues first |

## Mode Details

### quick (1-2pt)
Small, well-understood changes. No explicit test-first step. Fix a typo, update config, adjust a string.
Guard rail: If it takes longer than 30 min, upgrade to tdd.

### tdd (3pt)
Strict red-green-refactor. Write failing test first, implement minimum to pass, refactor.
Guard rail: If you can't express the requirement as a test, drop to pair.

### pair (5pt)
Human-in-the-loop. Agent proposes, human validates. Use Plan Mode for shared understanding.
Guard rail: Define exit criteria up front. If scope clarifies, upgrade to tdd.

### checkpoint (8pt)
Milestone-gated. Hard stops at each checkpoint for human review. No "I'll just finish this."
Use for: database migrations, auth changes, payment integration, breaking API changes.

### swarm (5-8pt)
5+ independent parallel tasks. Fan out to subagents, collect results, reconcile.
Guard rail: Tasks must be truly independent. If they have dependencies, sequence them instead.

### spike (research)
Time-boxed exploration. Output is knowledge (document, analysis, recommendation), not code.
Every spike ends with a concrete recommendation. If more time needed, create a follow-up spike.

## Retry Budget

Every implementation gets 2 attempts with different approaches. After 2 failures: stop, escalate to human with evidence of both approaches.
