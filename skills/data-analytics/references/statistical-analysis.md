# Statistical Analysis Reference

Statistical methodology for A/B tests and product experiments in PostHog. PostHog uses Bayesian statistics by default.

## Bayesian vs Frequentist

| Aspect | PostHog (Bayesian) | Traditional (Frequentist) |
|--------|-------------------|--------------------------|
| **Result** | "95% probability variant B is better" | "p < 0.05, reject null hypothesis" |
| **Sample size** | No fixed requirement — results improve over time | Must calculate upfront, wait for target |
| **Early peeking** | Safe — results are always valid | Inflates false positive rate |
| **Multiple variants** | Native support | Requires correction (Bonferroni) |
| **Interpretation** | Intuitive probability statements | Conditional probability (often misunderstood) |

## PostHog Experiment Setup

### Before Running

1. **Define success metric**: One primary metric (e.g., funnel completion rate), optional secondary metrics
2. **Estimate minimum sample**: PostHog provides a sample size calculator. Rule of thumb:
   - Small effect (5% lift): ~1,600 per variant
   - Medium effect (10% lift): ~400 per variant
   - Large effect (20% lift): ~100 per variant
3. **Set experiment duration**: Minimum 1 week to account for day-of-week effects

### During Experiment

- Safe to check results at any time (Bayesian eliminates the peeking problem)
- Watch for Sample Ratio Mismatch (SRM): if variant sizes differ by >1%, investigate
- Monitor for negative guardrail metrics (e.g., error rate increase)

### Decision Framework

| Probability (variant > control) | Decision |
|--------------------------------|----------|
| >95% | **Ship variant** — strong evidence of improvement |
| 90-95% | **Consider shipping** — good evidence, monitor post-launch |
| 75-90% | **Continue experiment** — signal but not conclusive |
| 50-75% | **Continue experiment** — no meaningful signal yet |
| <50% | **Consider stopping** — variant may be worse |
| <5% | **Stop and revert** — strong evidence variant is worse |

## Credible Intervals

PostHog reports 95% credible intervals for metric differences:

- **Credible interval**: "We are 95% confident the true effect is between X% and Y%"
- Unlike confidence intervals, this is the actual probability statement most people think they're making
- If the credible interval excludes 0, the result is "significant" in the traditional sense

### Interpreting Intervals

| Interval | Interpretation |
|----------|---------------|
| [+2%, +8%] | Strong positive effect (doesn't cross 0) |
| [-1%, +5%] | Likely positive but uncertain (crosses 0) |
| [-3%, +3%] | No meaningful effect detected |
| [-8%, -2%] | Strong negative effect |

## Minimum Detectable Effect (MDE)

The smallest effect size your experiment can reliably detect given your sample size.

### Formula (approximate)

```
MDE ≈ 2.5 × sqrt(p × (1-p) / n)

Where:
  p = baseline conversion rate
  n = sample size per variant
```

### Example Calculations

| Baseline Rate | Sample per Variant | MDE |
|--------------|-------------------|-----|
| 10% | 100 | ~7.5% absolute (75% relative) |
| 10% | 500 | ~3.4% absolute (34% relative) |
| 10% | 1,000 | ~2.4% absolute (24% relative) |
| 50% | 100 | ~12.5% absolute (25% relative) |
| 50% | 500 | ~5.6% absolute (11% relative) |

**For Claudian apps**: With early-stage traffic (<100 DAU), only large effects (>20% relative) are detectable. Focus on qualitative feedback + large directional changes rather than fine-grained A/B tests.

## Segmentation Analysis

When full A/B tests aren't practical (low traffic), use cohort segmentation:

### Cohort Comparison Pattern

```
1. Define cohorts: users exposed to feature vs not (via feature flag)
2. Compare key metrics between cohorts over same time period
3. Check for confounding factors (early adopters, power users)
4. Report directional findings with sample size caveat
```

### Statistical Caveats for Small Samples

- **Don't over-interpret**: With <100 users per group, random variation is large
- **Look for large effects**: Only trust >30% relative differences
- **Use multiple metrics**: Consistent direction across 3+ metrics is more convincing than one significant result
- **Time effects**: Compare same time periods to avoid seasonal confounds
- **Novelty effect**: First-week metrics may not represent long-term behavior

## PostHog Statistical Features

| Feature | What It Does |
|---------|-------------|
| **Experiment results** | Bayesian analysis with posterior probabilities |
| **Funnel significance** | Automatic significance testing on funnel steps |
| **Correlation analysis** | Find properties correlated with conversion |
| **Lifecycle analysis** | New, returning, resurrecting, dormant user segments |
| **Stickiness** | How many days per week do users perform an action |
