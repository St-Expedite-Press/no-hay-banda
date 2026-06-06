# Content Template Library

Templates for the New Showbiz content pipeline. Used by `content-draft-from-movie-data` skill and `content-agent` persona.

All templates enforce: Kakusu Protocol, no em dash, 2-hashtag ceiling (X), source refs required for all score claims, anti-fabrication rules.

## X Templates

| Template | File | Use When |
|---|---|---|
| Original Discovery | `x/original-discovery.md` | Introducing one film; drive clicks to movie page |
| Thread Breakdown | `x/thread-breakdown.md` | Deep-diving one category dimension across 3 posts |
| Comparison Post | `x/comparison-post.md` | Two films, one shared dimension |
| Reactive Hook | `x/reactive-hook.md` | Responding to current film discourse with product angle |
| Utility Post | `x/utility-post.md` | Promoting browse/filter feature; drive catalog traffic |

## Template Selection Logic

1. If the task is a single film introduction -> `original-discovery.md`
2. If the task is a multi-post deep dive -> `thread-breakdown.md`
3. If the task compares two films -> `comparison-post.md`
4. If a specific discourse moment is the hook -> `reactive-hook.md`
5. If the task promotes a browse filter or feature -> `utility-post.md`

When no template matches exactly, default to `original-discovery.md` and note the gap in the output.
