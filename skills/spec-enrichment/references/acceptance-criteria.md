# Acceptance Criteria Writing Guide

Acceptance criteria are the definition of done. They must be independently verifiable, derived from the spec (not invented separately), and specific enough that any developer can implement them without ambiguity.

## Derivation Sources

ACs are not written in isolation. They are derived from three sources:

1. **FAQ answers** — Each substantive FAQ answer implies a testable behavior. "Q: What happens when the user has no data? A: Show an empty state with a CTA to import." → AC: "Empty state displays import CTA when user has zero records."

2. **Inversion-derived principles** — Each inversion produces a design constraint. "To fail: ship without onboarding" → Principle: "Guide to outcome in 60s" → AC: "First-run onboarding completes in under 60 seconds."

3. **Pre-mortem mitigations** — Each mitigation implies monitoring or testing. "Failure: data loss during migration" → Mitigation: "Dry-run mode" → AC: "Migration supports --dry-run flag that validates without writing."

## Writing Rules

### Be Specific and Verifiable

Bad: "The page should load quickly"
Good: "Page loads in under 2 seconds on 3G connection (measured by Lighthouse)"

Bad: "Error handling should be good"
Good: "API errors display user-friendly message with retry button; 4xx errors show specific guidance; 5xx errors show generic message with support link"

### Use Checkbox Format

```markdown
- [ ] Users can create a new project from the dashboard
- [ ] Project name is required, 3-100 characters
- [ ] Duplicate project names within the same workspace are rejected with clear error
- [ ] New project appears in sidebar within 1 second of creation
```

### One Behavior Per Criterion

Bad: "Users can create, edit, and delete projects"
Good:
- "Users can create a new project with name and description"
- "Users can edit project name and description from settings"
- "Users can delete a project with confirmation dialog"

### Include Edge Cases

Don't just cover the happy path. Include:
- Empty states (no data, first-time user)
- Error states (network failure, invalid input, permission denied)
- Boundary conditions (max length, zero items, concurrent access)
- Negative cases (what should NOT happen)

### Avoid Implementation Details

ACs describe WHAT, not HOW. Leave implementation to the developer.

Bad: "Use a React modal component with z-index 1000"
Good: "Confirmation dialog overlays the page and blocks interaction with content behind it"

## AC Quantity Guidelines

| Spec Type | AC Count | Rationale |
|-----------|----------|-----------|
| prfaq-quick | 2-4 | Minimal scope, obvious implementation |
| prfaq-feature | 6-12 | Full feature coverage including edges |
| prfaq-research | 8-15 | Research validation + feature ACs |
| prfaq-infra | 4-8 | Before/after verification + rollback |

## Linking ACs to Sources

For traceability, annotate ACs with their derivation source:

```markdown
- [ ] Empty state shows import CTA (FAQ #3)
- [ ] First-run completes in <60s (Inversion #1)
- [ ] Migration supports --dry-run (Pre-Mortem #2)
```

This makes it clear why each AC exists and prevents removal during scope negotiation.
