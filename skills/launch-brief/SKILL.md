---
name: launch-brief
description: |
  Generate a pre-launch checklist combining deploy readiness with go-to-market elements. Use when preparing to launch a feature, product, or client website. Triggers for launch planning, release readiness, go-to-market preparation, launch sequence, rollback planning, feature release, product announcement, or any question about whether something is ready to ship. Extends the deployment-verification skill with GTM elements. Cross-references content-marketing for messaging and brand voice.
---

# /launch-brief

Generate a comprehensive launch brief that combines technical deploy readiness with go-to-market preparation. Extends `/deploy-checklist` with GTM elements.

## Usage

```
/launch-brief [feature or product name]
```

## Workflow

1. **Assess feature completeness** from Linear:
   - All issues in the milestone/project marked Done?
   - Any open blockers or dependencies?
   - Acceptance criteria ticked?
2. **Check deploy readiness** from GitHub + Vercel:
   - PRs merged? CI green?
   - Preview URL tested?
   - Sentry: any new errors in preview?
3. **Prepare GTM elements**:
   - Target audience identified
   - Messaging drafted (use brand voice from `content-marketing` skill)
   - Channels selected
   - Success metrics defined
4. **Generate the brief**:

```markdown
## Launch Brief — [Feature/Product] — [Target Date]

### Readiness Checklist

#### Technical
- [ ] All issues Done: [N/M completed]
- [ ] CI green on main
- [ ] Preview URL tested: [url]
- [ ] Sentry: no new errors in preview
- [ ] Database migrations applied (if any)
- [ ] Environment variables set in production

#### Go-to-Market
- [ ] Target audience: [segment]
- [ ] Positioning: [one sentence]
- [ ] Announcement draft: [channel: draft link]
- [ ] Success metrics defined: [metric 1, metric 2]
- [ ] Support prep: FAQ or known limitations documented

### Rollback Plan
- Revert commit: [SHA or PR link]
- Feature flag: [flag name, if applicable]
- Communication: [who to notify if rollback needed]

### Launch Sequence
1. [time] — Deploy to production
2. [time] — Verify in Sentry + PostHog
3. [time] — Publish announcement on [channel]
4. [+1 day] — Check adoption metrics in PostHog
5. [+1 week] — Post-launch review

### Open Questions
- [anything unresolved before launch]
```

## Connector Dependencies

| Source | Tier | Access |
|--------|------|--------|
| Linear | Core | R (issues, milestones) |
| GitHub | Core | R (PRs, CI status) |
| Vercel | Enhanced | R (deploy status, preview URLs) |
| Sentry | Enhanced | R (error check) |
| PostHog | Enhanced | R (adoption metrics post-launch) |
