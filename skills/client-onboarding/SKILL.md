---
name: client-onboarding
description: |
  Client onboarding methodology: "Build for, then with, you own it" — a 12-week
  3-phase engagement model for technology consultancy clients. Use when discussing
  client onboarding, workspace provisioning handoff, training plans, champion
  development, support arrangements, handoff checklists, or any question about
  transitioning a client from managed delivery to independent operation. Triggers
  for /onboard-client, /training-plan, /handoff-checklist, /support-plan, or
  questions about client enablement, adoption metrics, or post-delivery support.
---

# Client Onboarding

"Build for, then with, you own it" — a structured 12-week methodology for onboarding technology consultancy clients. Designed for engagements where the consultancy provisions and configures a workspace (monday.com, custom tools, integrations), then transitions ownership to the client team through hands-on training and graduated support.

> **Claudian default:** This skill is configured for Cognito AI Consultancy (3-person team, AI strategy/implementation/integration services for construction, manufacturing, and professional services). Marketplace users should adapt company name, service catalog, phase durations, and support tiers to their own consultancy.

## Methodology Overview

```
Week 1-4               Week 5-8               Week 9-12
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│  PHASE 1    │       │  PHASE 2    │       │  PHASE 3    │
│  Build For  │──────►│  Build With │──────►│ You Own It  │
│             │       │             │       │             │
│ Cognito     │       │ Joint       │       │ Client      │
│ provisions  │       │ workshops   │       │ operates    │
│ workspace   │       │ + training  │       │ independently│
│             │       │             │       │             │
│ Client:     │       │ Client:     │       │ Client:     │
│ read-only   │       │ hands-on    │       │ full owner  │
│ access      │       │ with guide  │       │ + support   │
└─────────────┘       └─────────────┘       └─────────────┘
      │                     │                     │
  Deliverable:          Deliverable:          Deliverable:
  Configured            Trained team          Independent
  workspace +           + champion            operation +
  documentation         users                 support SLA
```

**Core principle:** The client never depends on the consultancy long-term. Every engagement ends with the client owning and operating their own system. Support is available but not required.

## Phase 1: Build For (Weeks 1-4)

Cognito provisions the complete workspace, builds custom tools, and configures integrations. The client receives read-only access to observe progress and provide feedback, but does not operate the system yet.

### Week-by-Week

| Week | Focus | Activities | Client Involvement |
|------|-------|------------|-------------------|
| 1 | Discovery + setup | Stakeholder interviews, requirements capture, workspace architecture, account provisioning | Interviews, access credentials |
| 2 | Core build | Board creation, column configuration, data migration, sample data population | Read-only review of boards |
| 3 | Integrations | Automation recipes, email/calendar integrations, third-party connections, dashboard setup | Provide API credentials, review flows |
| 4 | Polish + document | Testing, edge case handling, documentation writing (PDF + video walkthroughs), admin guide | Review documentation drafts |

### Phase 1 Deliverables

- Fully configured monday.com workspace (all boards, columns, groups, automations)
- Sample data populated to demonstrate workflows
- Integration connections tested and documented
- Admin guide (PDF) covering workspace structure and configuration decisions
- Process documentation for each workflow (step-by-step with screenshots)
- Video walkthroughs for key workflows (3-5 minutes each)
- Architecture decision record — why each tool/integration was chosen

### Phase 1 Status Updates

Weekly status updates to the client via `/stakeholder-update`. Include:
- Completed this week (with screenshots)
- Planned for next week
- Decisions needed from client
- Blockers or risks

Track progress in monday.com Client Projects board. Log status updates as Activities on the Account.

## Phase 2: Build With (Weeks 5-8)

Hands-on training for the client team. Cognito facilitates role-specific workshops, develops internal champions, and hands off process documentation. The client begins operating the system with Cognito guidance.

### Workshop Schedule

| Week | Audience | Topics | Duration | Format |
|------|----------|--------|----------|--------|
| 5 | All users | Platform basics, navigation, views, mobile app, personal settings | 2 hours | Live workshop + recording |
| 6 | Managers + users | Board operations, item management, updates, file attachments, search | 2 hours | Live workshop + recording |
| 7 | Managers + admins | Automations, integrations, dashboards, reporting, notifications | 2 hours | Live workshop + recording |
| 8 | Admins only | Workspace management, user permissions, troubleshooting, billing, support escalation | 1.5 hours | Live workshop + recording |

### Champion Development

Identify 1-2 internal power users ("champions") by Week 6. Champions receive:

- Extended 1:1 training sessions (30 min each, Weeks 6-8)
- Admin-level access and configuration knowledge
- Direct communication channel with Cognito for questions
- Responsibility for internal first-line support after handoff
- "Champion playbook" document covering common questions and troubleshooting

**Champion Selection Criteria:**
- Comfortable with technology (not necessarily technical)
- Respected by peers (influence drives adoption)
- Enthusiastic about the new system (intrinsic motivation)
- Available for additional training time
- Ideally one manager-level and one field-level user

### Phase 2 Deliverables

- All team members trained on role-appropriate functionality
- 1-2 champion users identified, trained, and equipped
- Workshop recordings available for future onboarding of new staff
- Process documentation handed off (client has their own copies)
- Quick-reference cards for each role (1-page, laminated-ready PDF)
- Champion playbook document

### Phase 2 Tracking

Log each workshop as an Activity in monday.com. Track attendance. Note questions and areas where the team struggled — these inform Phase 3 check-in focus areas.

## Phase 3: You Own It (Weeks 9-12)

The client operates independently. Cognito provides support desk access and conducts check-ins that gradually reduce in frequency. The phase ends with a success metrics review and transition to ongoing support.

### Check-in Cadence

| Week | Frequency | Format | Focus |
|------|-----------|--------|-------|
| 9 | 2x/week | 30-min call | Active monitoring, answer questions, fix issues |
| 10 | 1x/week | 30-min call | Address adoption gaps, reinforce training |
| 11 | 1x/week | 30-min call | Review metrics, adjust workflows if needed |
| 12 | 1x (final) | 60-min review | Success metrics review, support plan handoff |

### Success Metrics

Define these at kickoff (Phase 1, Week 1) and measure at Phase 3 close:

| Metric | How to Measure | Target | Warning |
|--------|---------------|--------|---------|
| User adoption rate | Active users / provisioned users (last 7 days) | > 80% | < 60% |
| Task completion rate | Items moved to Done / items created (last 30 days) | > 70% | < 50% |
| Support ticket volume | Tickets submitted to Cognito (weekly) | Decreasing trend | Flat or increasing |
| Champion resolution rate | Issues resolved by champion / total internal issues | > 50% | < 25% |
| Time to first action | Average time from item creation to first update | < 4 hours | > 24 hours |
| Process compliance | Items following defined workflow / total items | > 75% | < 50% |

### Phase 3 Deliverables

- Client operating independently for minimum 2 weeks
- Success metrics reviewed and documented
- Support plan agreed and signed (Standard, Premium, or Enterprise)
- Escalation path documented and tested
- Final report: engagement summary, metrics achieved, recommendations

### Escalation Protocol

If the client struggles during Phase 3:

1. **Adoption < 60%:** Schedule additional champion 1:1s. Identify specific blockers per user.
2. **Support tickets increasing:** Extend Phase 2 workshops for specific topics. Create targeted quick-reference guides.
3. **Champion unavailable/ineffective:** Identify alternative champion. Offer dedicated 2-week champion bootcamp.
4. **Fundamental process mismatch:** Pause Phase 3. Return to Phase 1 for workflow redesign. No additional charge for first redesign; subsequent redesigns scoped as change orders.

## Actions

### /onboard-client — Start Client Onboarding

Initialize a new client onboarding engagement following the 3-phase methodology.

1. Ask for: client name, engagement type (workspace build, tool integration, process automation), team size, industry, key contacts (sponsor, champion candidates)
2. Look up client in monday.com:
   - `get_board_items_by_name` on Accounts board for the company
   - `get_board_items_by_name` on Contacts board for key contacts
   - `get_board_items_by_name` on Deals board for the associated deal
3. If Account not found: offer to create via `create_item` on Accounts board
4. Create a Linear project for the engagement:
   - Project name: `[Client Name] Onboarding`
   - Team: CIA (or appropriate sub-team)
   - Create milestone issues for each phase gate:
     - `Complete Phase 1: Build For` (due: Week 4)
     - `Complete Phase 2: Build With` (due: Week 8)
     - `Complete Phase 3: You Own It` (due: Week 12)
5. Create onboarding tracker in monday.com Client Projects board:
   - `create_item` with client name, linked Account, start date, phase status
6. Generate the Phase 1 kickoff checklist:
   - [ ] Stakeholder interviews scheduled
   - [ ] Client credentials and access provisioned
   - [ ] Workspace architecture documented
   - [ ] Success metrics defined with client
   - [ ] Communication cadence agreed (weekly status + ad-hoc Slack/email)
   - [ ] Champion candidates identified (at least 2)
7. Log the kickoff as an Activity on the Account in monday.com
8. Present: onboarding plan summary with timeline, phase gates, and success metrics

### /training-plan — Generate Training Plan

Create a 4-week role-specific training plan for a client's monday.com workspace.

1. Ask for: client name, team size, roles (admin, manager, field user), current tech proficiency (low/medium/high), specific workflows to cover
2. Look up client in monday.com:
   - `get_board_items_by_name` on Accounts board
   - `get_board_items_by_name` on Client Projects board for workspace context
3. Generate training plan:

**Week 1: Platform Foundations**
- Session 1 (all users, 1hr): monday.com navigation, views (Table, Kanban, Timeline, Calendar), mobile app setup, notifications
- Session 2 (all users, 1hr): Personal settings, My Work view, inbox, search, bookmarks
- Homework: Each user creates 3 test items and explores mobile app
- Resources: [monday.com Academy — Getting Started](https://monday.com/helpcenter/getting-started)

**Week 2: Daily Operations**
- Session 1 (all users, 1hr): Creating and managing items, status updates, person assignments, dates, file attachments
- Session 2 (managers, 1hr): Board views for management — timeline planning, workload view, filters, sorting, grouping
- Homework: Each user logs one full day of work in the system
- Resources: [monday.com Academy — Working with Items](https://monday.com/helpcenter/working-with-items)

**Week 3: Power Features**
- Session 1 (managers + admins, 1hr): Automations — when/then recipes, custom automations, integration triggers
- Session 2 (managers + admins, 1hr): Dashboards, reporting widgets, chart types, filtering, sharing dashboards
- Session 3 (all users, 30min): Integrations relevant to their workflow (email, calendar, file storage)
- Homework: Each manager creates one automation and one dashboard widget
- Resources: [monday.com Academy — Automations](https://monday.com/helpcenter/automations)

**Week 4: Administration + Independence**
- Session 1 (admins, 1.5hr): Workspace management, board creation, column types, permissions, user management, billing, security
- Session 2 (admins, 1hr): Troubleshooting common issues, support escalation path, knowledge base access
- Session 3 (champions, 1hr): Champion responsibilities, internal support playbook, FAQ compilation
- Final assessment: Each role completes a practical task demonstrating competency
- Resources: [monday.com Academy — Admin Center](https://monday.com/helpcenter/admin)

4. Adapt plan based on proficiency level:
   - **Low proficiency:** Add 30-min pre-sessions for basic concepts. Extend homework review time. Pair each user with a buddy.
   - **Medium proficiency:** Standard plan as above.
   - **High proficiency:** Compress Weeks 1-2 into a single week. Focus Week 2 on advanced features. Add API/developer topics in Week 4.
5. Present training plan with schedule, materials list, and success criteria per week

### /handoff-checklist — Pre-Handoff Verification

Generate and verify the pre-handoff checklist before transitioning from Phase 2 to Phase 3.

1. Ask for: client name
2. Look up client in monday.com:
   - `get_board_items_by_name` on Accounts board
   - `get_board_items_by_name` on Client Projects board for engagement details
3. Present checklist for verification:

**Workspace Readiness**
- [ ] All boards provisioned and configured (columns, groups, views)
- [ ] Sample data populated to demonstrate workflows
- [ ] Automations configured, tested, and documented
- [ ] Integrations connected and verified (email, calendar, third-party)
- [ ] Dashboards built with relevant widgets and filters
- [ ] User accounts created with correct permissions per role

**Documentation**
- [ ] Admin guide complete (PDF, covers workspace structure and config decisions)
- [ ] Process documentation per workflow (step-by-step with screenshots)
- [ ] Video walkthroughs recorded for key workflows (3-5 min each)
- [ ] Quick-reference cards per role (1-page PDF)
- [ ] Champion playbook complete (common questions, troubleshooting, escalation)

**Training**
- [ ] All workshops delivered (Weeks 5-8 per training plan)
- [ ] Workshop recordings available and shared with client
- [ ] Champion users identified, trained, and confirmed
- [ ] Practical assessment completed for each role
- [ ] Attendance logged for all sessions

**Support Readiness**
- [ ] Support escalation path documented and shared
- [ ] Support plan options presented (Standard / Premium / Enterprise)
- [ ] Champion direct communication channel established
- [ ] Success metrics defined, baseline recorded, measurement method confirmed
- [ ] Final review meeting scheduled (Week 12)

4. For each incomplete item: note the gap and recommend a resolution action
5. If >3 items incomplete: recommend extending Phase 2 by 1-2 weeks before proceeding
6. Log the checklist review as an Activity on the Account in monday.com
7. If all items complete: confirm readiness for Phase 3 transition

### /support-plan — Post-Handoff Support Options

Present and configure the post-handoff support arrangement.

1. Ask for: client name, preferred support level (or ask to present all options)
2. Look up client in monday.com:
   - `get_board_items_by_name` on Accounts board
   - `get_board_items_by_name` on Client Projects board
   - `get_board_items_by_name` on Deals board for contract context
3. Present support tiers:

| Feature | Standard | Premium | Enterprise |
|---------|----------|---------|-----------|
| **Channel** | Email only | Phone + email | Dedicated account manager |
| **Response time** | 48 hours (business) | 4 hours (business) | 1 hour (business) |
| **Check-in** | Monthly (30 min) | Weekly (30 min) | Weekly (1 hr) + on-site quarterly |
| **Review** | Quarterly (remote) | Quarterly (remote) | Quarterly (on-site) |
| **Scope** | Bug fixes, questions | Bug fixes, minor config changes, guidance | Full config changes, new workflow design, training refreshers |
| **Champion support** | Email Q&A | Scheduled 1:1s (bi-weekly) | Dedicated Slack channel + priority 1:1s |
| **New staff onboarding** | Self-serve (recordings + docs) | 1-hr orientation per new user | Full training session per cohort |
| **Pricing** | Included (3 months), then EUR 500/month | EUR 1,500/month | EUR 3,500/month + on-site travel |

4. Recommend tier based on client profile:
   - **Standard:** Tech-comfortable team, strong champion, < 20 users, simple workflows
   - **Premium:** Mixed proficiency team, moderate complexity, 20-100 users, multiple integrations
   - **Enterprise:** Large team, mission-critical workflows, high compliance requirements, multi-site
5. If client selects a tier:
   - Update Account notes in monday.com with support plan details
   - Create a recurring Activity reminder for check-in cadence
   - Document support contact info and escalation path
   - If Stripe connected: create subscription for ongoing support billing
6. Present: support plan summary with contact details, SLA commitments, and first check-in date

## monday.com Training Resources

Direct clients to these official resources to supplement live training:

| Resource | URL | Best For |
|----------|-----|----------|
| monday.com Academy | https://monday.com/helpcenter | All users — structured courses |
| Getting Started Guide | https://monday.com/helpcenter/getting-started | New users — first week |
| Automations Guide | https://monday.com/helpcenter/automations | Managers + admins |
| Integrations Directory | https://monday.com/helpcenter/integrations | Admins — connecting tools |
| API Documentation | https://developer.monday.com/ | Technical users — custom integrations |
| Community Forum | https://community.monday.com/ | Champions — peer support |
| YouTube Channel | https://www.youtube.com/@mondaydotcom | All users — visual learners |

## Connector Dependencies

| Source | Tier | Access | Purpose |
|--------|------|--------|---------|
| monday.com CRM | Core | R/W | Account, Contact, Client Projects, Activities tracking |
| Linear | Core | R/W | Engagement project, milestone issues, deliverable tracking |
| monday.com AI Notetaker | Enhanced | R | Client call transcripts for training feedback |
| Granola | Enhanced | R | Internal meeting notes for engagement planning |
| Gamma | Enhanced | R/W | Training presentation generation |
| Google Drive | Enhanced | R/W | Documentation storage and sharing |
| GCal | Enhanced | R | Workshop scheduling, check-in calendar |
| Stripe | Enhanced | R/W | Support plan subscription billing |

When a connector is not available, note the gap and suggest manual alternatives. Never fail silently.

## Graceful Degradation

| Scenario | Behavior |
|----------|----------|
| monday.com unavailable | Track onboarding in Linear project only. Note missing CRM tracking. |
| Linear unavailable | Use monday.com Client Projects board for milestone tracking. Note missing issue-level tracking. |
| Both unavailable | Present methodology and checklists inline. Note that tracking requires monday.com or Linear. |
| Gamma unavailable | Create training materials as markdown or PDF manually. |
| Stripe unavailable | Note support plan pricing for manual invoicing. |

## Marketplace Configuration

Phase durations, support pricing, training schedules, and success metric targets in this skill reflect defaults for a small consultancy (3-5 people) serving SMB clients (10-200 users). Marketplace users should adapt:

- **Phase durations:** Simple workspaces may compress to 8 weeks total. Enterprise engagements may extend to 16-20 weeks.
- **Support pricing:** Adjust for your market, team size, and cost structure.
- **Training plan:** Adapt session count and duration based on client team size and proficiency.
- **Success metrics:** Adjust targets based on industry benchmarks and client expectations.

Board IDs are resolved at runtime via `get_board_items_by_name` and `get_board_schema`, not hardcoded.

## Cross-Skill References

- **crm-management** — Track onboarding progress in monday.com (Accounts, Contacts, Activities, Client Projects boards). Use `/crm-log` for interaction tracking throughout all phases.
- **business-development** — Client lifecycle feeds into onboarding. Deal "Closed Won" triggers `/onboard-client`. Onboarding success feeds back into QBR and retention.
- **customer-ops** — Post-handoff support tickets (Tier 1 or Tier 2) flow through customer-ops. Champion users are first-line responders before escalation.
- **small-team-finance** — Support plan billing via Stripe. Quotes & Invoices board for engagement invoicing.
- **task-management** — `/stakeholder-update` for weekly Phase 1 status updates to client.
- **content-marketing** — Workshop recordings and documentation can be repurposed as marketing content (with client permission).
- **design-workflow** — If the engagement includes website or UI delivery, the design chain runs within Phase 1.
- **notion-hub** — Engagement documentation can be mirrored to Notion for client-facing read-only access.
