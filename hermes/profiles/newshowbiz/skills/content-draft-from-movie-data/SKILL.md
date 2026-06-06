---
name: content-draft-from-movie-data
description: "Turn a New Showbiz movie page or research memo into X-ready draft variants"
version: 1.0.0
author: New Showbiz
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [newshowbiz, content, drafting, x, kakusu, film-critic]
---

# Skill: Content Draft From Movie Data

## When to Use

Use when turning a New Showbiz movie page, movie data object, or research memo into
X-ready draft variants.

## Inputs

| Input | Required | Notes |
|---|---:|---|
| `movie_data` | yes | Title, scores, category details, synopsis, watch links |
| `platform` | yes | `x` |
| `objective` | yes | discovery, explain, activate, respond, support |
| `source_refs` | yes | Evidence for any factual or score-based claim |

## Procedure

1. Confirm the source refs support every factual claim.
2. Select a template from `~/.hermes/profiles/newshowbiz/skills/templates/` using the selection logic in `templates/_index.md`. Match on objective + content type. If no template matches, default to `x/original-discovery.md` and note the gap.
3. Draft variants in New Showbiz voice (film critic register, not system summary), following the selected template's skeleton and prohibitions.
4. Enforce Kakusu Protocol — frame representation analysis as cinematic analysis, not advocacy.
5. Apply platform constraints per the selected template (character ceiling, hashtag ceiling, em dash prohibition are all stated per template).
6. Call `content-job-write` for each completed draft variant to persist it in the store.
7. Return draft text, source refs, template used, and validation notes.

## Pitfalls

- Do not invent plot points, identities, quotes, or reception data.
- Do not advertise the scoring methodology or framework name.
- Do not use loaded labels: woke, DEI, political activism, subversive, progressive.
- Do not lead with emoji.
- Do not fabricate social proof, urgency, or endorsements.

## Verification

Every draft must include:
- Source refs for all factual or score-based claims
- Platform constraint check (character count, hashtag count, em dash scan)
- Risk classification (low / medium / high / blocked)

A draft without source refs is not complete. Do not present it as ready for review.
