# Pattern Taxonomy

24 AI writing patterns organized into 6 categories. Adapted from blader/humanizer (MIT, 7.7k stars).

Core insight: LLMs use statistical algorithms to guess what comes next. The result tends toward the most statistically likely phrasing that applies to the widest variety of cases. Every pattern below is a symptom of this tendency.

---

## Category 1: Content Patterns (1-6)

These patterns inflate or distort what the text actually says.

### Pattern 1: Inflated Significance

The text assigns outsized importance to ordinary things. Everything is "groundbreaking", "revolutionary", or "transformative" when it is merely useful, interesting, or new.

**Detection:** Look for superlatives and significance markers that the evidence doesn't support.

**Examples:**
| AI version | Fix |
|------------|-----|
| "This groundbreaking approach revolutionizes how teams collaborate" | "This approach changes how teams collaborate" |
| "A transformative shift in the industry" | "A shift in the industry" (or cut entirely if no evidence given) |
| "This represents a significant milestone" | "This is a milestone" or just describe what happened |

**Fix strategy:** Downgrade or remove the adjective. Let the facts carry the weight. If the achievement really is significant, the specifics will show it without the label.

### Pattern 2: Notability Name-Dropping

The text references famous people, institutions, or companies to borrow credibility when the connection is tangential or unnecessary.

**Detection:** Ask "Would the sentence lose meaning without this name?" If not, it is name-dropping.

**Examples:**
| AI version | Fix |
|------------|-----|
| "Much like how Elon Musk disrupted the automotive industry..." | Cut the analogy. State your point directly. |
| "Following in the footsteps of MIT researchers..." | "Recent research shows..." (cite the actual paper if relevant) |

**Fix strategy:** Remove the name unless it is the actual subject of the sentence. Cite sources properly rather than invoking authority by association.

### Pattern 3: Superficial "-ing" Analyses

The text uses present participles to gesture at analysis without delivering any. "Leveraging AI to transform outcomes" sounds analytical but says nothing concrete.

**Detection:** Look for "-ing" verb phrases that describe a process without specifying what actually happens.

**Examples:**
| AI version | Fix |
|------------|-----|
| "Leveraging machine learning to optimize performance" | "The model reduced inference time by 30%" |
| "Driving innovation through collaborative partnerships" | State what the partnership produced |
| "Enabling seamless integration across platforms" | "The API works with Slack, GitHub, and Linear" |

**Fix strategy:** Replace the gerund phrase with a concrete statement of what happened, what was built, or what changed. If you can't be specific, the sentence probably has no content.

### Pattern 4: Promotional Language

The text reads like marketing copy. Adjectives like "vibrant", "stunning", "cutting-edge", "world-class", and "best-in-class" signal promotion, not description.

**Detection:** Highlight every adjective. Ask which ones a skeptical reader would accept without evidence.

**Examples:**
| AI version | Fix |
|------------|-----|
| "A vibrant ecosystem of developers" | "An active developer community" or "~2,000 active contributors" |
| "Stunning performance improvements" | "3x faster cold starts" |
| "Our cutting-edge solution" | "Our solution" |
| "A seamless, intuitive experience" | Describe the specific UX improvement |

**Fix strategy:** Replace promotional adjectives with measurable specifics. If no specifics exist, use plain language ("good", "fast", "useful") or cut the adjective entirely.

### Pattern 5: Vague Attributions

"Experts argue", "researchers have found", "many believe", "studies show" -- without citing who, what study, or which experts.

**Detection:** Every claim of external authority must have a specific source. If it doesn't, flag it.

**Examples:**
| AI version | Fix |
|------------|-----|
| "Experts argue that this approach is superior" | "Smith et al. (2024) found that..." or cut the attribution and state the claim directly |
| "Research suggests that..." | Cite the research or write "We believe that..." |
| "Industry leaders have noted..." | Name the leader and the context, or remove |

**Fix strategy:** Either cite the source properly or own the claim. "We think X" is more honest than "Experts agree X" with no citation.

### Pattern 6: Formulaic "Challenges and Future Prospects" Sections

AI text almost always ends with a section acknowledging "challenges" and expressing optimism about "future prospects" or "the road ahead". This structure is so formulaic it flags the text immediately.

**Detection:** Does the text end with a paragraph about challenges followed by a hopeful conclusion? Is this structure imposed rather than earned by the content?

**Examples:**
| AI version | Fix |
|------------|-----|
| "While challenges remain, the future looks promising..." | End with your actual conclusion. What should the reader do next? |
| "Despite these obstacles, the potential for growth is immense" | State the specific next step or open question |
| "As we look to the future, we can expect..." | Cut. End on your last substantive point. |

**Fix strategy:** End when the content ends. If there are real challenges, discuss them where they are relevant, not in a designated "challenges" section. If there are real next steps, state them concretely.

---

## Category 2: Language/Grammar Patterns (7-12)

These patterns involve specific word choices and grammatical constructions that AI overuses.

### Pattern 7: AI Vocabulary Overuse

Certain words appear in AI text at 10-100x the rate of human writing. Their presence, especially in clusters, is a strong AI signal.

**Detection:** Scan for these words and phrases:

| High-frequency AI words | Human alternatives |
|------------------------|-------------------|
| enduring | lasting, persistent |
| pivotal | important, key |
| landscape | field, area, space |
| interplay | interaction, relationship |
| testament | proof, evidence, sign |
| multifaceted | complex (or describe the specific facets) |
| nuanced | detailed, subtle (or describe the nuance) |
| tapestry | (cut entirely -- almost never needed) |
| delve | explore, examine, look at |
| realm | area, field, domain |
| foster | encourage, support, build |
| leverage | use |
| utilize | use |
| facilitate | help, enable, let |
| comprehensive | thorough, full, complete |
| robust | strong, solid, reliable |

**Fix strategy:** Replace with the simpler alternative. One "landscape" in a long document is fine. Three in a page is a pattern.

### Pattern 8: Copula Avoidance

AI text avoids the verb "is" in favor of circumlocutions: "serves as", "acts as", "functions as", "represents", "stands as". This makes simple statements unnecessarily complex.

**Detection:** Search for "serves as", "acts as", "functions as", "represents a", "stands as".

**Examples:**
| AI version | Fix |
|------------|-----|
| "This serves as the foundation for..." | "This is the foundation for..." |
| "The dashboard acts as a central hub" | "The dashboard is the central hub" |
| "TypeScript functions as a superset of JavaScript" | "TypeScript is a superset of JavaScript" |
| "This represents a major improvement" | "This is a major improvement" |

**Fix strategy:** Replace with "is" (or "are", "was", etc.). If "is" sounds too blunt, the sentence probably needs restructuring, not a fancier verb.

### Pattern 9: Negative Parallelisms

"Not only X, but also Y" and "Not just X, but Y" are dramatically overrepresented in AI text. Humans use these constructions occasionally; AI uses them constantly.

**Detection:** Search for "not only...but also", "not just...but", "not merely...but".

**Examples:**
| AI version | Fix |
|------------|-----|
| "Not only does it improve speed, but it also reduces costs" | "It improves speed and reduces costs" |
| "Not just a tool, but a platform" | "It is a platform" (or just "a platform") |

**Fix strategy:** Rewrite as a simple conjunction ("X and Y") or two sentences.

### Pattern 10: Rule-of-Three Overuse

AI defaults to three-item lists, three examples, three adjectives, three bullet points. This is the most statistically "safe" list length, and AI gravitates toward it.

**Detection:** Count list items across the document. If nearly every list has exactly three items, it is a pattern.

**Examples:**
| AI version | Fix |
|------------|-----|
| "Speed, reliability, and scalability" | Use the actual number of relevant qualities. Sometimes it is two. Sometimes five. |
| Three bullet points per section, every section | Vary list lengths. Some sections need one point. Others need seven. |
| "Easy to use, easy to maintain, and easy to extend" | "Easy to use and maintain" (if "extend" is filler) |

**Fix strategy:** Let the content dictate the list length. Two items is fine. Four is fine. The problem is uniformity, not the number three itself.

### Pattern 11: Synonym Cycling

Within a paragraph, AI avoids repeating a word by cycling through synonyms: "the platform... the tool... the solution... the system." Human writers either repeat the word (which is fine) or restructure the sentence.

**Detection:** Look for 3+ synonyms for the same concept within a short passage.

**Examples:**
| AI version | Fix |
|------------|-----|
| "The platform handles X. The tool also manages Y. The solution provides Z." | "The platform handles X, manages Y, and provides Z." |
| "developers... engineers... practitioners... professionals" (all meaning the same people) | Pick one term and stick with it |

**Fix strategy:** Repeat the word, use a pronoun ("it"), or restructure to avoid the need for a reference. Synonym cycling reads as evasive.

### Pattern 12: False Ranges

"From X to Y" constructions that imply a range but actually just list two things. Often the "range" is meaningless because X and Y are not endpoints of anything.

**Detection:** Search for "from X to Y" and ask: is this actually a range, or two examples?

**Examples:**
| AI version | Fix |
|------------|-----|
| "From healthcare to education to finance" | "In healthcare, education, and finance" |
| "Ranging from simple tasks to complex workflows" | "For both simple tasks and complex workflows" |

**Fix strategy:** Rewrite as a list or conjunction. Only use "from X to Y" for actual ranges (temperatures, dates, numerical values).

---

## Category 3: Style Patterns (13-18)

These patterns involve formatting and typographic choices.

### Pattern 13: Em Dash Overuse

AI text uses em dashes (--) at 3-5x the human rate. One or two per document is fine. One per paragraph is a pattern.

**Detection:** Count em dashes across the document. More than one per 300 words is likely overuse.

**Fix strategy:** Replace with commas, parentheses, periods, or restructured sentences. Reserve em dashes for genuine asides that need emphasis.

### Pattern 14: Boldface Overuse

AI text bolds far more than necessary, especially in prose paragraphs. Bold should highlight key terms on first use or critical warnings, not emphasize every other phrase.

**Detection:** If more than 10% of words in a prose section are bold, it is overuse.

**Fix strategy:** Remove bold from all but the most essential terms. In structured docs (tables, reference material), bold is more acceptable.

### Pattern 15: Inline-Header Vertical Lists

AI loves this structure: a bold word or phrase followed by a colon, then an explanation, repeated vertically. Real writing mixes lists with prose paragraphs.

**Detection:** Three or more consecutive "**Header:** explanation" lines in a row.

**Example:**
```
**Speed:** The system processes requests in under 100ms.
**Reliability:** Uptime exceeds 99.9%.
**Scalability:** Handles up to 10k concurrent users.
```

**Fix strategy:** Convert to a table, a paragraph, or a genuine bullet list. Mix formats within a document.

### Pattern 16: Title-Case Headings

AI defaults to Title Case for All Headings Like This. Most modern style guides prefer sentence case (capitalize only the first word and proper nouns).

**Detection:** Check heading capitalization style. If every word is capitalized, it is title case.

**Fix strategy:** Use sentence case: "Pattern taxonomy" not "Pattern Taxonomy". Exception: proper nouns and product names.

### Pattern 17: Emoji Usage

Emojis in professional/technical writing flag AI generation immediately. Human technical writers almost never use them.

**Detection:** Any emoji in prose, headings, or list items.

**Fix strategy:** Remove. No exceptions in technical or professional writing.

### Pattern 18: Curly Quotation Marks

AI sometimes inserts typographic "curly" quotes instead of straight quotes. In code-adjacent contexts, this causes bugs and reads as AI-generated.

**Detection:** Search for Unicode characters U+201C, U+201D, U+2018, U+2019.

**Fix strategy:** Replace with straight quotes. In markdown and code, always use ASCII quotes.

---

## Category 4: Communication Patterns (19-21)

These patterns come from the chatbot training context leaking into written output.

### Pattern 19: Chatbot Artifacts

Phrases that belong in a chat response, not in a document: "I hope this helps!", "Feel free to ask if you have questions", "Let me know if you need anything else", "Here's what I found".

**Detection:** Would this phrase appear in a document that a human wrote and saved to disk? If not, it is a chatbot artifact.

**Fix strategy:** Remove entirely. Documents don't talk to readers.

### Pattern 20: Knowledge-Cutoff Disclaimers

"As of my last update", "I don't have access to real-time data", "My training data goes up to..." -- these are model-identity leaks.

**Detection:** Any reference to training data, knowledge cutoffs, or the model's capabilities.

**Fix strategy:** Remove. If the information might be outdated, add a date: "As of March 2026" rather than "As of my last update."

### Pattern 21: Sycophantic Tone

"Great question!", "That's an excellent point!", "Absolutely!", "You're right to ask about this." This pattern comes from RLHF training rewarding agreeableness.

**Detection:** Does the text praise the reader or agree enthusiastically before delivering content?

**Fix strategy:** Remove. Start with the content.

---

## Category 5: Filler and Hedging (22-24)

These patterns add words without adding meaning.

### Pattern 22: Filler Phrases

Words and phrases that can be removed without changing the meaning of the sentence.

**Detection:** Read each sentence and ask: does every phrase carry meaning?

**High-frequency fillers:**

| Remove | Replace with |
|--------|-------------|
| "In order to" | "To" |
| "It is important to note that" | (cut) |
| "It is worth mentioning that" | (cut) |
| "At the end of the day" | (cut) |
| "When it comes to" | (cut, or use the noun) |
| "A wide range of" | "Many" or "several" |
| "In today's world" | (cut) |
| "As a matter of fact" | (cut) |
| "The fact that" | (cut; restructure sentence) |
| "Due to the fact that" | "Because" |
| "In the context of" | "In" or "for" |
| "With regard to" | "About" or "on" |
| "Moving forward" | (cut) |
| "As we can see" | (cut) |
| "Basically" | (cut) |
| "Essentially" | (cut, or it means you should simplify the sentence) |

**Fix strategy:** Delete. The sentence will be shorter and stronger.

### Pattern 23: Excessive Hedging

AI text hedges constantly: "arguably", "potentially", "it could be said that", "there is a possibility that", "to some extent". One hedge per paragraph is reasonable. Three is a pattern.

**Detection:** Count hedging words per paragraph. More than one per 100 words is likely excessive.

**Common hedges:**
- "Arguably"
- "Potentially"
- "It could be said that"
- "To some extent"
- "In many ways"
- "It is possible that"
- "May or may not"
- "Somewhat"
- "Relatively"
- "It seems that"

**Fix strategy:** Commit to the claim or cut it. "This is arguably the best approach" becomes "This is the best approach" (if you believe it) or "This approach has trade-offs" (if you don't).

### Pattern 24: Generic Positive Conclusions

AI text almost always ends positively: "exciting times ahead", "the potential is enormous", "together we can achieve great things". Real conclusions state what happens next or what the reader should do.

**Detection:** Does the final paragraph add information, or just express optimism?

**Examples:**
| AI version | Fix |
|------------|-----|
| "The future of AI is bright and full of possibilities" | State the specific next step |
| "We look forward to continuing this journey" | Describe what will happen next quarter |
| "With continued effort, the possibilities are endless" | End on your last substantive point |

**Fix strategy:** End when the content ends. The last sentence should be the most useful one, not the most optimistic one.

---

## Quick Scan Checklist

Use this during Step 2 (Identify) for rapid detection:

- [ ] Any superlatives without evidence? (Pattern 1)
- [ ] Famous names used for borrowed credibility? (Pattern 2)
- [ ] "-ing" phrases replacing concrete descriptions? (Pattern 3)
- [ ] Marketing adjectives: vibrant, stunning, seamless, cutting-edge? (Pattern 4)
- [ ] "Experts say" / "research shows" without citations? (Pattern 5)
- [ ] Challenges-and-prospects ending? (Pattern 6)
- [ ] Cluster of: pivotal, landscape, testament, delve, foster, leverage, utilize? (Pattern 7)
- [ ] "Serves as" / "acts as" / "functions as" instead of "is"? (Pattern 8)
- [ ] "Not only...but also" constructions? (Pattern 9)
- [ ] Every list has exactly three items? (Pattern 10)
- [ ] Multiple synonyms for the same concept in one paragraph? (Pattern 11)
- [ ] "From X to Y" that is not a real range? (Pattern 12)
- [ ] More than one em dash per 300 words? (Pattern 13)
- [ ] Heavy boldface in prose? (Pattern 14)
- [ ] Repeated "**Header:** explanation" format? (Pattern 15)
- [ ] Title Case On Every Heading? (Pattern 16)
- [ ] Any emojis? (Pattern 17)
- [ ] Curly quotes? (Pattern 18)
- [ ] "I hope this helps" or "Let me know"? (Pattern 19)
- [ ] References to training data or knowledge cutoffs? (Pattern 20)
- [ ] "Great question!" or "Absolutely!"? (Pattern 21)
- [ ] Filler phrases: "in order to", "it is worth noting"? (Pattern 22)
- [ ] More than one hedge per 100 words? (Pattern 23)
- [ ] Optimistic conclusion without substance? (Pattern 24)
