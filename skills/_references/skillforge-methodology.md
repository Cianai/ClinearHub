# SkillForge Methodology — Design-Time Reference

> Source: [tripleyak/SkillForge](https://github.com/tripleyak/SkillForge) v5.1 (531+ stars)
> Purpose: Apply these patterns when **creating or adapting** ClinearHub plugin skills and external skill wrappers.
> This is a design-time methodology — CI-time validation uses Promptfoo evals + agnix static checks.

## When to Use This Reference

- Creating a new ClinearHub plugin skill
- Substantially modifying an existing skill (>30% of content)
- Adapting an external skill for internal use
- Evaluating whether an upstream skill change is safe to adopt

## 1. Skill Triage (Phase 0)

Before creating anything new, classify the request:

| Match % | Action | Example |
|---------|--------|---------|
| ≥80% | **USE_EXISTING** — reuse existing skill | "Add deployment checks" → `deployment-verification` already covers this |
| 50-79% | **IMPROVE_EXISTING** — enhance current skill | "Add Railway-specific deploy steps" → extend `deployment-verification` |
| <50% | **CREATE_NEW** — build from scratch | "Add customer feedback pipeline" → no existing skill covers this |
| Multiple | **COMPOSE** — combine existing skills | "Sprint planning with deploy verification" → compose `task-management` + `deployment-verification` |

## 2. Thinking Lenses (Phase 1 — Deep Analysis)

Apply 2-3 most relevant lenses before writing any skill content. All 11 for major skills, rapid scan for patches.

| # | Lens | Question to Ask |
|---|------|-----------------|
| 1 | **First Principles** | What is the fundamental purpose? Strip away conventions. |
| 2 | **Inversion** | What would make this skill fail? What are the anti-patterns? |
| 3 | **Second-Order Effects** | What happens 3-4 levels downstream of this skill's actions? |
| 4 | **Pre-Mortem** | Assume this skill failed in production. Why? |
| 5 | **Systems Thinking** | How does this skill interact with other skills and the pipeline? |
| 6 | **Devil's Advocate** | What's the strongest argument against this skill's approach? |
| 7 | **Constraint Analysis** | Which constraints are real vs. assumed? |
| 8 | **Pareto Analysis** | Which 20% of this skill delivers 80% of the value? |
| 9 | **Root Cause Analysis** | Five whys — is this skill solving the root cause or a symptom? |
| 10 | **Comparative Analysis** | What alternatives exist? Score against weighted criteria. |
| 11 | **Opportunity Cost** | What are we NOT doing by investing in this skill? |

## 3. Regression Questioning Protocol

Seven question categories to exhaust before finalizing a skill:

1. **Missing Elements** — What's not covered? What edge cases are unhandled?
2. **Expert Simulation** — How would a domain expert, UX designer, security engineer, and maintenance engineer each critique this?
3. **Failure Analysis** — Likelihood x Impact for each failure mode
4. **Temporal Projection** — Will this skill still work in 6 months? 1 year? 2 years? 5 years?
5. **Completeness Verification** — Have all thinking lenses been applied?
6. **Meta-Questioning** — What hidden assumptions are baked in?
7. **Automation Analysis** — What should be autonomous vs. human-gated?

**Termination**: Three consecutive rounds with zero new insights AND temporal evolution score ≥7/10.

## 4. Evolution Scoring (Timelessness Gate)

Score each skill 1-10 before merging. **Threshold: ≥7 for approval.**

| Score | Category | Traits |
|-------|----------|--------|
| 1-4 | **Ephemeral** | Version-coupled, trend-dependent → REJECT |
| 5-6 | **Moderate** | Some hardcoding, missing extension points → REVISE |
| 7-8 | **Solid** | Principle-based, documented extensions, abstracted deps → APPROVE |
| 9-10 | **Timeless** | Composable, principle-driven, designed for evolution → EXEMPLAR |

**Scoring dimensions:**
- **Temporal viability** (30%) — projected usefulness at 6mo/1yr/2yr/5yr
- **Dependency abstraction** (25%) — hardcoded versions vs. principle-based patterns
- **Extension points** (20%) — documented mechanisms for future adaptation (≥2 required)
- **Eval stability** (25%) — expected variance in eval scores over time

## 5. Degrees of Freedom Framework

Match instruction specificity to operation fragility:

| Freedom Level | When to Use | Example |
|---------------|-------------|---------|
| **High** | Analytical/decision phases (multiple valid approaches) | "Assess severity based on error rate, user impact, and blast radius" |
| **Medium** | Structured but adaptable (templates with parameters) | "Create a Linear issue with labels from the taxonomy, priority based on SLA rules" |
| **Low** | Execution/validation (exact commands, consistency-critical) | "Run `pnpm --filter @claudian/evals eval` with `EVAL_SUITE=skill-regression`" |

**Anti-pattern**: Low freedom in analytical phases (forces brittle behavior) or high freedom in execution phases (causes inconsistency).

## 6. Multi-Agent Synthesis Panel

For high-impact skills (ClinearHub core skills, cross-cutting concerns), evaluate from three perspectives:

| Agent | Focus | Pass Criteria |
|-------|-------|---------------|
| **Design** | Technical soundness, architecture, internal consistency | Weighted avg ≥7.0, zero critical issues |
| **Audience** | Usability, trigger phrases, discoverability, examples | Weighted avg ≥7.0, zero critical issues |
| **Evolution** | Future-proofing, timelessness, extension points, dependency abstraction | Evolution score ≥7/10 |

**Approval**: All three must approve. 2+ major issues → rejection. After 5 rounds without approval → escalate.

In our pipeline, this maps to the `quality-scorer.ts` dimensions (Phase 3.2).

## 7. Iteration vs. Redesign

| Condition | Action |
|-----------|--------|
| <50% of content needs rewriting | **Iterate** — targeted fixes, test with same scenarios |
| ≥50% of content needs rewriting | **Redesign** — start fresh with Phase 0 triage |
| Eval score drops >15% | **Investigate** — check if upstream change or skill rot |
| Evolution score <5 | **Redesign mandatory** — skill has become ephemeral |

## Quick Reference: Applying This to ClinearHub Skills

```
1. Triage → Is there an existing skill? (Section 2)
2. Analyze → Apply 2-3 thinking lenses (Section 2)
3. Question → Run regression questioning until convergence (Section 3)
4. Score → Evolution score ≥7? (Section 4)
5. Check → Degrees of freedom appropriate? (Section 5)
6. Review → Multi-agent panel for core skills (Section 6)
7. Validate → CI evals pass (Promptfoo + agnix)
```
