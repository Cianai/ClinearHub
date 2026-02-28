---
description: Draft a spec using Working Backwards PR/FAQ, push to Linear with spec:draft
argument-hint: "<feature idea, problem statement, or CIA-XXX issue ID>"
---

# Write Spec

Draft a PR/FAQ specification using the Working Backwards method, then create or update a Linear issue with `spec:draft` label to trigger ChatPRD enrichment.

## Step 1: Duplicate Check

Before anything else, search Linear for existing issues covering the same scope:

```
list_issues(project: "<project>", query: "<2-3 distinctive terms>", limit: 10)
```

If matches found, present them to the user. Ask whether to proceed with a new issue, merge into existing, or adjust scope.

## Step 2: Determine Template

Ask the user to clarify the scope:

| Customer-facing? | Research-backed? | Infrastructure? | Small scope? | Template |
|:-:|:-:|:-:|:-:|----------|
| Yes | No | No | No | `prfaq-feature` |
| Any | Yes | No | No | `prfaq-research` |
| No | No | Yes | No | `prfaq-infra` |
| Any | Any | Any | Yes | `prfaq-quick` |

If the input is a CIA-XXX issue ID, fetch it from Linear first to pre-populate context.

When in doubt, default to `prfaq-feature`.

Read the template from @${CLAUDE_PLUGIN_ROOT}/skills/spec-enrichment/references/prfaq-templates.md

## Step 3: Interactive Drafting

Follow the spec-enrichment skill's interactive drafting sequence:

1. **Problem Discovery** — Who, what's frustrating, workarounds, what if we do nothing?
2. **Press Release** — One-sentence announcement, key benefit, user quote
3. **FAQ Generation** — 10-15 candidates, user selects 6-12, draft answers
4. **Stress Testing** — 3 failure stories, inversion analysis, mitigations
5. **Acceptance Criteria** — Derived from FAQ + inversion + pre-mortem
6. **Non-Goals** — At least 3, each citing why excluded
7. **Scale Declaration** — Personal, Team, Organization, or Platform

Present the draft after each phase for feedback. Do not skip phases or batch questions.

## Step 4: Frontmatter and Metadata

Add spec frontmatter:
```yaml
---
linear: CIA-XXX
exec: <mode based on complexity>
status: draft
created: <now ISO 8601>
---
```

Select execution mode using the decision heuristic from clinearhub-workflow.

## Step 5: Create Linear Issue

Create or update the Linear issue:

1. Set title (verb-first: "Build X", "Implement Y")
2. Set description to the complete spec
3. Apply labels: `type:*` (required), `spec:draft`, `template:prfaq-*`
4. Apply estimate based on execution mode
5. Assign to the correct project

The `spec:draft` label triggers ChatPRD enrichment via Linear triage rules. ChatPRD will:
- Apply 4 business strategy personas
- Refine acceptance criteria
- Create child sub-issues with `auto:implement` label

## Step 6: Next Steps

```
Spec created: CIA-XXX with spec:draft label.
ChatPRD will enrich the spec automatically.

Next: Review the enriched spec when ChatPRD finishes.
Then: Move to spec:ready to approve, or return to spec:draft with feedback.
```
