---
description: Post-merge outcome validation — synthesize all AI + agent work for human review
argument-hint: "<CIA-XXX parent spec issue ID> [--quick for summary only]"
---

# Verify

Structured post-merge business validation for Phase 10 of the pipeline. Synthesizes spec, enrichment, implementation, deployment, and monitoring evidence into a single GO/NO-GO report for human review.

Run after all child sub-issues of a parent spec are Done.

## Step 1: Fetch Parent Spec

```
get_issue(id: "$1", includeRelations: true)
list_comments(issueId: "$1", limit: 20)
```

Extract from the parent issue:
- **Original spec** (description) — the acceptance criteria are the evaluation standard
- **ChatPRD enrichment comment** (Phase 2) — enriched problem statement, personas applied
- **ChatPRD validation comment** (Phase 8) — if posted, business alignment assessment
- **Child sub-issues** — from `children` relation

If no issue ID provided, check current context for a recently-closed parent spec.

## Step 2: Fetch Child Implementation Evidence

For each child sub-issue:

```
get_issue(id: "<child-id>", includeRelations: true)
```

Collect per child:
- Status (must be Done)
- PR link (from attachments or `Closes CIA-XXX` reference)
- PR merge status (merged to main?)
- Test evidence (CI passed?)
- Reviewer comments (any unresolved?)
- **Design evidence** (if child has `design` label):
  - Figma link attached to issue?
  - Design was approved before implementation?
  - Implementation matches design intent? (check Figma MCP `get_design_context` if available)

If any child is NOT Done → flag as incomplete, include in report.

## Step 3: Check Deployment Status

Query Vercel (if connector available):
- Production deployment state for main branch: Ready / Building / Error?
- Deployment URL accessible?
- Any build errors in logs?

If Vercel connector unavailable, note as "Manual verification required."

## Step 4: Check Error State

Query Sentry:
- New errors since the most recent child PR merged?
- Any new error fingerprints matching changed files?
- Any previously resolved issues that regressed?
- Error rate trend (stable / increasing / decreasing)?

## Step 5: Check Analytics (if applicable)

Query PostHog (if connector available and feature has tracking):
- Feature flag enabled? Rollout percentage?
- Feature adoption events firing?
- Key funnel completion rates (before/after)?
- Any anomalies in user behavior?

If no analytics configured for this feature, note as "No PostHog tracking configured."

## Step 6: Evaluate Acceptance Criteria

For each acceptance criterion from the parent spec description:

| # | Criterion | Evidence | Verdict |
|---|-----------|----------|---------|
| 1 | [criterion text] | [PR link, test name, deploy URL, or "no evidence"] | PASS / PARTIAL / FAIL |
| 2 | ... | ... | ... |

**Verdict rules:**
- **PASS** — Clear evidence the criterion is met (merged PR, passing test, working feature)
- **PARTIAL** — Implemented but with caveats (missing edge case, no test, works but not optimized)
- **FAIL** — Not implemented, broken, or contradicts the criterion

## Step 7: Output Report

```markdown
## Outcome Verification — [CIA-XXX: Title](url)

**Phase:** 10 (Human Verification)
**Spec author:** [assignee or creator]
**Review date:** [today]

### Spec Summary
[1-2 sentence summary of what was specified]

### Implementation Evidence
| Sub-Issue | Status | PR | CI | Merged |
|-----------|--------|----|----|--------|
| [CIA-YYY](url) | Done | [#N](pr-url) | Pass | Yes |
| [CIA-ZZZ](url) | Done | [#M](pr-url) | Pass | Yes |

### ChatPRD Enrichment (Phase 2)
[Summary of what ChatPRD added — personas applied, key insights, non-goals identified]

### ChatPRD Validation (Phase 8)
[Summary of business alignment assessment, or "Not yet posted — trigger manually"]

### Acceptance Criteria
| # | Criterion | Evidence | Verdict |
|---|-----------|----------|---------|
| 1 | [text] | [evidence] | PASS |
| 2 | [text] | [evidence] | PARTIAL |

### Deployment
| Check | Status | Notes |
|-------|--------|-------|
| Production deploy | [Ready/Error/Unknown] | [url or details] |
| Build errors | [None/Yes] | [details] |

### Monitoring
| Check | Status | Notes |
|-------|--------|-------|
| New Sentry errors | [None/N new] | [details] |
| Regressions | [None/N regressed] | [details] |
| Error rate | [Stable/Increased N%] | [comparison] |

### Analytics (if applicable)
| Metric | Value | Status |
|--------|-------|--------|
| Feature flag | [on/off/N%] | [details] |
| Adoption events | [N events] | [expected?] |
| Funnel completion | [X%] | [baseline comparison] |

### Verdict: **GO** / **NO-GO**

**Score:** [N/M criteria PASS] ([percentage]%)

[If GO:]
- Apply `spec:complete` label to parent issue
- Close parent issue with this report as closing comment

[If NO-GO:]
- Specific blockers listed below
- Follow-up issues created and linked to parent
- Parent remains open until follow-ups resolve

### Follow-Up Issues (if NO-GO)
| Issue | Type | Linked To | Description |
|-------|------|-----------|-------------|
| [CIA-AAA](url) | type:bug | CIA-XXX | [what needs fixing] |
```

## Step 8: Post Report and Act

1. **Post the report** as a comment on the parent spec issue
2. **If GO:**
   - Apply `spec:complete` label to parent issue
   - Suggest closing the parent (do NOT auto-close — human confirms)
3. **If NO-GO:**
   - Create follow-up issues for each FAIL/PARTIAL criterion
   - Link follow-ups to parent issue
   - Follow-ups enter Phase 1 of the pipeline (back to ideation)

## Quick Mode (--quick)

If `--quick` flag: skip Steps 3-5 (deploy, Sentry, PostHog). Output only the acceptance criteria evaluation based on child issue status and PR evidence. Useful for specs where monitoring isn't relevant (chores, internal tooling).
