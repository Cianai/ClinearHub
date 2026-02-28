# Closure Protocol

Evidence-based closure rules with quality scoring. Every Done transition requires a closing comment demonstrating that the work is complete.

## Quality Scoring

Three-dimension rubric that drives closure decisions.

### Dimensions

| Dimension | Weight | Measures |
|-----------|--------|---------|
| Test | 40% | Test coverage, passing tests, edge cases |
| Coverage | 30% | Acceptance criteria addressed with evidence |
| Review | 30% | Review comments resolved, findings addressed |

### Score Calculation

```
total = (test_score * 0.40) + (coverage_score * 0.30) + (review_score * 0.30)
```

### Threshold Actions

| Score | Grade | Action |
|-------|-------|--------|
| 90-100 | Exemplary | Auto-close eligible |
| 80-89 | Strong | Auto-close eligible |
| 70-79 | Acceptable | Propose closure with gap list |
| 60-69 | Needs Work | Propose closure with gap list |
| 0-59 | Inadequate | Block closure, list deficiencies |

### Per-Dimension Scoring

**Test (40%)**
- 100: All ACs have tests, all pass, edge cases covered
- 80: Core ACs tested, all pass, some edges missing
- 60: Tests exist but incomplete, all pass
- 40: Tests exist but some fail
- 0: No tests or all fail
- For `exec:quick`: Test requirement relaxed (threshold 60 not 80)

**Coverage (30%)**
- 100: Every AC explicitly addressed with evidence
- 80: All addressed, minor evidence gaps
- 60: Most addressed, 1-2 partially met
- 0: No criteria addressed

**Review (30%)**
- 100: All review comments resolved, all findings addressed
- 80: Blocking comments resolved, minor ones acknowledged
- 60: Blocking resolved, some minor unaddressed
- 0: No review or all unresolved
- If no review conducted (e.g. `exec:quick`): defaults to 70

## Closing Comment Format

Every closing comment must include:

```markdown
## Closing Summary

**Quality Score:** [Grade] ([Score]/100)

### Evidence
- PR: [link to merged PR]
- Deploy: [link to deploy or verification]
- Tests: [pass/fail status]

### AC Checklist
- [x] AC 1: [evidence]
- [x] AC 2: [evidence]
- [ ] AC 3: [carried forward to CIA-YYY]

### Carry-Forward
- [CIA-YYY: Description of deferred work]
```

## Closure Rules by Assignee

| Assignee | Score >= 80 | Score 60-79 | Score < 60 |
|----------|------------|-------------|-----------|
| Agent-assigned | Auto-close | Propose to human | Block |
| Human-assigned | Propose to human | Propose to human | Block |
| Cian-assigned | NEVER auto-close | Propose | Block |

**Key rule:** Never auto-close Cian's issues regardless of score.

## Evidence Requirements by Type

| Issue Type | Minimum Evidence |
|-----------|-----------------|
| `type:feature` | PR merged link + deploy URL + AC checklist |
| `type:bug` | PR merged link + confirmation bug fixed |
| `type:chore` | What was done + verification |
| `type:spike` | Findings in description or linked document + recommendation |

**Spike closure rule:** A spike is NOT Done unless research findings are visible. Dispatching a subagent does not equal completion. The findings must be readable by a human on the issue or a linked Linear Document.

## Done = Merged

Never mark an implementation issue Done until its PR is merged to main.

- Commit does not equal Done
- PR opened does not equal Done
- PR approved does not equal Done
- Only merged equals Done

## Re-Open Protocol

If a closed issue needs re-opening:
1. Post a comment explaining why
2. Move to the appropriate status (usually In Progress)
3. Apply the correct `ctx:*` label
4. If the original PR was reverted, link the revert PR
