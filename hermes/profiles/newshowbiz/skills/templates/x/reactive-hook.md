# Template: Reactive Hook

**Objective:** Connect a trending film discourse moment to newshow.biz's analysis. Drive clicks to the relevant movie page or browse filter.

**Character limit:** 280

**Required inputs:**
- A specific, verifiable discourse signal (trending topic, news item, award, or cultural moment) — source ref required
- A film or category from newshow.biz that is directly relevant
- The newshow.biz URL (movie page or browse filter)

**Skeleton:**

```
[Brief acknowledgment of the discourse moment — 1 clause, factual, no hot take]. [newshow.biz's angle on it — 1 sentence, grounded in a specific score or category observation.]

[newshow.biz URL]

#[discourse hashtag if appropriate] #[optional second]
```

**Anti-fabrication rule:** The discourse signal MUST be a real, verifiable event. Do not invent trending topics or news items. If the source ref is unavailable or unverifiable, return BLOCKED and do not generate this post.

**Prohibitions:**
- No punching down at any group in the rubric
- No editorial opinion on the discourse itself — stay analytical
- No em dash
- The newshow.biz angle must be grounded in actual product data, not manufactured relevance
