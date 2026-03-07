---
name: design-workflow
description: |
  Frontend design workflow, design chain, Mobbin workflow, v0 prototyping, Claude Preview verification, design skills, UI/UX quality assurance, website builds, client website delivery, design direction, aesthetic choices, design QA, accessibility audits, anti-slop validation, responsive design, mobile app design, or any question about how to build polished frontend interfaces for Cognito clients, Alteri, SoilWorx, or any Claudian app.
---

# Design Workflow

The end-to-end process for building production-grade frontend interfaces. Combines the 4-stage design chain with the Mobbin/v0/Claude Preview parallel workflow. Applies to all Claudian apps, client websites, and mobile apps.

## Design Chain (4 Stages)

Every frontend build follows this sequence. See `.claude/rules/design-chain.md` for the auto-loaded rules.

### Stage 1: Design Direction

Before writing any code, commit to an aesthetic direction:

1. User provides Mobbin screenshots, v0 prototypes, or verbal direction
2. For client projects: scrape the client's existing website for brand alignment (Firecrawl)
3. Consult `ui-ux-pro-max` for palette/typography/style options
4. Apply `frontend-design` (impeccable-enhanced) for creative boldness
5. State the chosen direction explicitly before coding

### Stage 2: Build

Production code using the Claudian stack:
- Next.js 16 + React 19 + Tailwind v4
- `@claudian/ui` (Radix + shadcn) for components
- `frontend-design` + impeccable anti-patterns guide the aesthetic
- `preview_screenshot` after each major section

### Stage 3: QA Chain

Run all four in sequence:
1. `/baseline-ui` — anti-slop (animation durations, typography scale, layout patterns)
2. `/fixing-accessibility` — ARIA, keyboard, focus, contrast
3. `/fixing-motion-performance` — animation safety, transform performance
4. `/fixing-metadata` — titles, meta, OG, social cards

### Stage 4: Polish

Targeted refinement with impeccable commands:
- `/polish` — alignment, spacing, consistency
- `/audit` — comprehensive design audit
- `/distill` — simplify overdesigned areas
- `/bolder` / `/quieter` — adjust intensity
- `/critique` — UX effectiveness evaluation

## Mobbin/v0/Claude Preview Workflow

See `.claude/rules/design-workflow.md` for the auto-loaded rules.

### Parallel Tracks

**User track**: Mobbin (inspiration) -> v0.dev (rapid prototype) -> compare -> feedback
**Agent track**: Read references -> design chain -> section checkpoints -> QA chain

### Checkpoints

After each major section (hero, nav, content, footer):
1. Agent takes `preview_screenshot`
2. User compares with their v0 prototype
3. Feedback applied before next section

## Client Website Delivery Process

For Cognito client engagements (Tarco, Datum, CapCon, JF Flynn, future clients):

### Pre-Build Research
1. Firecrawl scrape client's current website — extract brand colors, messaging, services
2. Firecrawl scrape 2-3 industry competitors — identify digital presence gaps
3. Review client profile in monday.com CRM (Account notes, contact preferences)

### Design Direction
1. User (Cian/Patrick) provides Mobbin inspiration for client's industry
2. Brand colors extracted from client's existing site inform palette
3. Client's industry informs aesthetic: construction = professional/solid, engineering = precision/clean

### Build
1. Follow the 4-stage design chain
2. Use client brand colors as CSS variables
3. Mobile-first (construction professionals are on-site)
4. Include client's actual services, projects, team info from research

### Client Review
1. Deploy to Vercel preview URL
2. Share with client via email (Patrick's relationship)
3. Iterate based on client feedback (max 2 rounds included in pricing)

## Installed Design Skills

| Skill | Source | Purpose |
|-------|--------|---------|
| `frontend-design` | Anthropic (plugin) + pbakaus/impeccable | Core creative guidance + anti-patterns |
| `baseline-ui` | ibelick/ui-skills | Anti-slop UI baseline validation |
| `fixing-accessibility` | ibelick/ui-skills | ARIA, keyboard, focus, contrast |
| `fixing-metadata` | ibelick/ui-skills | Titles, meta, OG, social cards |
| `fixing-motion-performance` | ibelick/ui-skills | Animation safety + performance |
| `ui-ux-pro-max` | nextlevelbuilder | 50 styles, 21 palettes, 50 font pairings, 9 stacks |
| `web-design-guidelines` | vercel-labs | Web Interface Guidelines compliance |
| `shadcn-ui` | community | shadcn/ui component patterns |
| Impeccable commands (18) | pbakaus | `/polish`, `/audit`, `/distill`, `/bolder`, `/quieter`, etc. |

### Impeccable Command Reference

| Command | When to Use |
|---------|-------------|
| `/polish` | Final quality pass before shipping |
| `/audit` | Comprehensive interface quality audit |
| `/distill` | Simplify overdesigned areas |
| `/bolder` | Amplify boring/safe designs |
| `/quieter` | Tone down aggressive designs |
| `/colorize` | Add color to monochromatic areas |
| `/animate` | Add purposeful motion/micro-interactions |
| `/adapt` | Cross-platform/responsive adaptation |
| `/clarify` | Improve UX copy and microcopy |
| `/critique` | UX effectiveness evaluation |
| `/delight` | Add moments of joy and personality |
| `/extract` | Extract reusable components/tokens |
| `/harden` | Error handling, i18n, edge cases |
| `/normalize` | Match design system consistency |
| `/onboard` | Improve first-time user experience |
| `/optimize` | Performance (loading, rendering, bundle) |
| `/teach-impeccable` | One-time project design context setup |

## GAW (Autonomous Agents)

When `auto:implement` agents build frontend:
- Follow design chain stages 2-4 automatically (no user for Stage 1)
- Rely on existing design tokens and patterns
- MUST run QA chain (Stage 3) before creating PR
- `/baseline-ui` + `/fixing-accessibility` are the quality gate

## Cross-Platform

For mobile apps (React Native, Flutter, SwiftUI):
- Same design chain applies
- `ui-ux-pro-max` has stack-specific guidance for all 9 frameworks
- `/adapt` handles responsive/cross-platform adaptation
- Touch targets: minimum 44x44px
- Platform-specific patterns (iOS HIG, Material Design)
