---
name: humanizer
description: |
  Post-processing skill for removing AI writing patterns from generated content.
  Use when polishing research digests, stakeholder updates, documentation, or any
  AI-generated text that needs to read naturally.
  Triggers: "humanize", "polish writing", "remove AI patterns", "make it sound natural".
  Source: blader/humanizer (MIT).
---

# Humanizer

LLMs use statistical algorithms to guess what comes next. The result tends toward the most statistically likely phrasing that applies to the widest variety of cases. This produces text that is grammatically flawless but stylistically uniform -- and recognizably machine-written. The humanizer skill identifies and removes these patterns.

## When to Use

| Trigger | Example |
|---------|---------|
| Explicit request | "Humanize this", "Polish the writing", "Remove AI patterns" |
| Research digests | Weekly briefs, literature summaries, paper annotations |
| Stakeholder updates | Sprint summaries, status reports, `/stakeholder-update` output |
| Documentation | READMEs, architecture docs, Linear document descriptions |
| Any generated prose | PR descriptions, issue descriptions, email drafts |

Do NOT apply to code, structured data, CLI output, or technical specifications where precision matters more than voice.

## Process

The humanizer runs as a five-step pipeline. Never skip directly to a final rewrite -- the audit step catches patterns the initial rewrite misses.

```
1. Read  -->  2. Identify  -->  3. Rewrite  -->  4. Self-Audit  -->  5. Revise
```

### Step 1: Read

Read the source text completely. Note the intended audience and purpose. Identify the author's actual point -- not the filler surrounding it.

### Step 2: Identify

Scan for all 24 patterns across the six categories. Mark every instance. See [references/pattern-taxonomy.md](references/pattern-taxonomy.md) for the full taxonomy.

Quick-reference checklist:

- **Content**: Inflated significance? Name-dropping? Promotional adjectives? Vague attributions?
- **Language**: AI vocabulary ("pivotal", "landscape", "testament")? Copula avoidance ("serves as" instead of "is")? "Not only...but also"? Rule-of-three lists? Synonym cycling?
- **Style**: Excessive em dashes? Boldface overload? Inline-header lists? Emojis?
- **Communication**: Chatbot artifacts ("I hope this helps!")? Knowledge-cutoff disclaimers? Sycophantic openings?
- **Filler**: "In order to" instead of "to"? Excessive hedging? Generic positive conclusions?

### Step 3: Rewrite

Rewrite the text with all identified patterns removed. Follow these principles:

**Prefer simple words.** "Use" not "utilize". "Help" not "facilitate". "Show" not "demonstrate".

**Prefer "is" over circumlocution.** If something IS something, say so. Don't write "serves as", "acts as a", "functions as", or "represents".

| AI pattern | Human rewrite |
|------------|---------------|
| "This serves as a foundation for..." | "This is the foundation for..." |
| "The platform facilitates seamless collaboration" | "The platform lets teams work together" |
| "It is worth noting that the results demonstrate" | "The results show" |
| "In the rapidly evolving landscape of AI" | Cut entirely, or: "In AI," |
| "This is a testament to the team's dedication" | "The team built this well" |
| "Not only does X improve Y, but it also enhances Z" | "X improves Y and Z" |
| "Challenges, opportunities, and future prospects" | State the specific challenge or opportunity |

**Cut filler ruthlessly.** If removing a phrase doesn't change the meaning, remove it.

| Filler | Replacement |
|--------|-------------|
| "In order to" | "To" |
| "It is important to note that" | Cut entirely |
| "At the end of the day" | Cut entirely |
| "When it comes to" | Cut, or use the noun directly |
| "A wide range of" | "Many" or "several" |
| "In today's world" | Cut entirely |
| "Moving forward" | Cut entirely |
| "As we can see" | Cut entirely |

**Vary sentence structure.** AI text defaults to Subject-Verb-Object monotony. Mix in fragments, inversions, and varying sentence lengths. Short sentences have punch. Use them.

**Be specific.** Replace generalities with concrete details. "Several key stakeholders" becomes "the design lead and two engineers" (if you know who). "Significant improvements" becomes "40% faster" (if you have the number). If you don't have specifics, say less rather than fabricating vague authority.

### Step 4: Self-Audit

After the rewrite, ask: **"What still makes this obviously AI-generated?"**

Answer honestly with a bullet-pointed list. Common remaining tells:

- Every paragraph is the same length
- The text follows a predictable structure (intro, three body paragraphs, conclusion)
- Transitions are too smooth -- real writing is sometimes abrupt
- No sentence fragments or informal phrasing
- Everything sounds optimistic (real writing includes doubt, tension, trade-offs)
- Lists always have three items (the AI rule-of-three)
- No first-person voice where it would be natural

### Step 5: Revise

Fix every issue identified in the audit. This second pass typically catches 3-5 additional patterns that survived the first rewrite.

## Output Format

When invoked as a standalone skill, produce three sections:

```markdown
## Draft Rewrite

<Full rewritten text>

## Audit

- <Pattern 1 still present and where>
- <Pattern 2 still present and where>
- <Pattern 3 still present and where>
- ...

## Final Version

<Revised text with audit findings addressed>
```

When applied inline (e.g., polishing a stakeholder update as part of `/stakeholder-update`), skip the three-section format and return only the final polished text.

## Calibration

The goal is natural, not sloppy. The output should read like competent professional writing -- the kind a senior engineer, researcher, or PM would produce in a focused hour. Not literary prose, not casual chat, not corporate jargon. Clear, direct, specific.

Some patterns are worse offenders than others:

| Severity | Patterns | Action |
|----------|----------|--------|
| **Always fix** | Chatbot artifacts, sycophantic tone, AI vocabulary, filler phrases, "serves as" copula avoidance | Remove on sight |
| **Usually fix** | Em dash overuse, rule-of-three, synonym cycling, promotional language, generic conclusions | Fix unless the context warrants it |
| **Context-dependent** | Boldface, lists, hedging, sentence-length uniformity | Fix in prose; acceptable in structured docs |

## Integration Points

The humanizer applies as a post-processing step on output from other skills:

| Skill | When to Apply |
|-------|---------------|
| `/stakeholder-update` | Always -- stakeholder-facing prose must read naturally |
| `/weekly-brief` | Always -- same reason |
| `/standup` | Selectively -- standup notes can be terse |
| Plan documents | Summary and Decisions sections only (not Tasks or Verification) |
| Issue descriptions | When the description is prose-heavy (specs, research findings) |
| PR descriptions | Summary section; skip technical details |

## Pattern Taxonomy

> See [references/pattern-taxonomy.md](references/pattern-taxonomy.md) for the full 24-pattern taxonomy with examples, detection heuristics, and fix strategies for each pattern.

## Cross-Skill References

- **clinearhub-workflow** -- humanizer applies during Step 5 (human review) polishing
- **plan-persistence** -- humanizer covers Summary and Decisions sections of promoted plans
- **wrap-up** -- session summaries and closing comments benefit from humanizer pass
