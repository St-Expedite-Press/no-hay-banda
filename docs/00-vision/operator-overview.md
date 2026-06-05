# New Showbiz Marketing Operator — Overview and Assessment

*Assessment date: 2026-06-05. This document reflects the live deployed system.*

---

## What This Is

New Showbiz is a structured movie-discovery product at [newshow.biz](https://newshow.biz). The catalog contains more than 110,000 titles, each with AI-generated inclusivity profiles scored across five dimensions: LGBTQ+ representation, Gender representation, Racial and Ethnic representation, Disability representation, and Religious and Cultural representation. The site surfaces these scores through browse filters, movie detail pages, and user-facing category ratings. Its live promise: "Watch more of what matters to you."

The marketing operator is an autonomous agent system — built on a customized Hermes Agent v0.15.1 deployment — that turns that structured catalog data into governed social content for X and Instagram. The system researches films, drafts posts in a controlled brand voice, routes them through human review, and (in Phase 3) publishes with receipts. It is not a schedule-and-blast tool. It is a governed production system with explicit human gates at every write boundary.

---

## System State as of 2026-06-05

The operator is deployed and operational on EC2 (i-05451add3165b57ff). The Telegram gateway (`buchenwald_bettybot`) is live — the operator can be controlled from a mobile device without SSH access. A full pipeline run was triggered via Telegram, producing a draft for *Daughters of the Dust* (1991, Julie Dash) that was on-brand in voice and structure. The draft was rejected because the agent fabricated the film's Racial & Ethnic Diversity score (reported `94/100`; actual score is `9.8/10`) when the source page was inaccessible without auth. This is the anti-fabrication failure mode documented in the system design — confirmed in production for the first time.

Two blockers remain before a verified production run can complete: newshow.biz movie pages are auth-gated server-side (no public API; Playwright without credentials hits a 307 redirect), and the X account `stex_press` is rate-limited on login (one manual browser login from a non-EC2 IP would clear it).

| Layer | State |
|---|---|
| Hermes runtime | **Live** — v0.15.1, DeepSeek V4 Pro/Flash via OpenRouter |
| Oneshot mode | **Confirmed working** — profile config self-contained (model block fix applied) |
| Telegram gateway | **Live** — `buchenwald_bettybot`; operator controllable via Telegram from mobile |
| Three-tier agent system | **Live** — 20 agents (consolidated from 29); all tier declarations in place |
| Anti-fabrication enforcement | **Live — failed once in production** — Daughters of the Dust, 2026-06-05: score fabricated when source was inaccessible |
| Content pipeline | **Confirmed working** — templates read, Kakusu Protocol enforced, drafts produced |
| newshow.biz score scraping | **Blocked** — movie pages return 307 redirect without auth; no public API; agent cannot pull scores independently |
| Human review workflow | **Live** — review-decision-record skill; 2 bootstrapped drafts in queue (pending replacement) |
| Monitoring | **Live** — run-pipeline.sh failure logger; systemd weekly log-rotation timer |
| Phase 3 gate infrastructure | **Built** — telegram-notify + telegram-await-approval skills; 6-gate activation checklist |
| X read tools (x-mcp-read) | **Built, auth pending** — Barresider fork compiled; `stex_press` rate-limited on login |
| X read tools (twitter-mcp) | **Partially live** — public profile lookup confirmed; search requires auth |
| X write tools | **Configured, disabled** — Phase 3 gate; 6 binary conditions must pass before enabling |
| Autonomous publishing | **Not started** — Phase 3 prerequisite |
| Approved content queue | **0 posts** — production run blocked on two resolved prerequisites |
| Instagram | **Not started** — Phase 5 |

---

## Product Thesis

New Showbiz has more structured source material than most social accounts ever get. A catalog with 110,000+ titles, machine-generated scores across five dimensions, watch-provider links, and a filter-browse interface is already a content engine — it just needs a translation layer. That layer is this operator.

The translation opportunities are concrete:

- **Discovery** — "This 1974 Brazilian film scores 94% on Gender representation and is streaming on MUBI. Here's why it's worth your time."
- **Score explainers** — "What does an 87% LGBTQ+ score actually mean for a film? Here's how we read it."
- **Comparisons** — "Two Oscar nominees. Different scores on Racial representation. Here's what the data shows."
- **Browse prompts** — "Looking for horror films with high Disability representation? We've got 340 of them."
- **Reactive** — When a film is trending on X, surface its New Showbiz scores with a link.
- **Support narrative** — "We're an independent project. No VC. No algorithm. [donate link]"

The operator exists to make this translation fast, consistent, and safe to scale.

---

## Runtime Thesis

A standard Hermes installation provides agent execution, prompt assembly, skills, memory, session persistence, cron, MCP integration, gateway surfaces, and profiles. This deployment uses all of those — and adds seven specific customizations that make it appropriate for a governed marketing operator rather than a general-purpose agent tool:

1. **Three-tier spawn authority** — prevents rogue delegation chains and keeps the system's decision graph legible
2. **DeepSeek model split** — Pro for orchestration (high reasoning), Flash for leaf tasks (fast and cheap), with Anthropic fallback
3. **Anti-fabrication enforcement at every layer** — addresses a documented DeepSeek failure mode
4. **Barresider local fork** — makes X browser-automation patches durable across cache clears and system restarts
5. **ContentJob flat-file store** — content persistence outside Hermes sessions; human-readable; no database required for Phase 1
6. **Template library** — platform-specific structural constraints baked into every draft before it reaches review
7. **Kakusu Protocol** — brand guardrail ensuring representation analysis is framed as cinematic analysis, not advocacy

The result is a system where a human supervisor can follow every decision: what template was chosen, what source refs justify each claim, what risk class was assigned, and what the reviewer decided to do with it. That transparency is what makes autonomous publishing safe enough to work toward.

---

## The "Hacked Hermes" Framing

The system is intentionally described as a "hacked Hermes instance." This framing is accurate and useful. Stock Hermes is a powerful general-purpose autonomous agent runtime. It does not natively provide:

- Safe X or Instagram publishing
- Campaign persistence or content storage
- Brand-specific tone enforcement at the model level
- Anti-fabrication enforcement for DeepSeek-family models
- A multi-tier agent authority hierarchy

All of these have been grafted onto the Hermes base. The patches to Barresider's login.ts, the persona files with tier declarations, the custom skills, the ContentJob store, the template library — these are not Hermes features. They are the additions that make this a marketing operator rather than a blank agent session.

This framing also has a practical implication: **Hermes updates require care**. A `hermes update` could change the config schema (already happened: v24 → v25), alter how personas are loaded, or break assumptions baked into the SOUL.md system. Updates should be tested in isolation before applying to the live operator session.

One instance of this already occurred. Hermes in interactive mode reads the global config and therefore picked up the model definition from there. Oneshot mode (`-z`) reads only the profile config. Because `~/.hermes/profiles/newshowbiz/config.yaml` had no `model` block, oneshot silently returned empty responses. The fix was adding `model.default: deepseek/deepseek-v4-pro` and `delegation.model: deepseek/deepseek-v4-flash` directly to the profile config. The lesson is broader than this one bug: **profile configs must be self-contained**. Any operator running `hermes -p <profile> -z` should audit their profile config independently of the global config, because the two are not merged in oneshot mode.

---

## What New Showbiz Is Actually Selling

Understanding the product informs what the operator can say and what it cannot.

The platform is a movie-discovery tool with an explicit values lens. Users find films that match their representation priorities. The scores are AI-generated, not editorial, and they cover five specific dimensions. The product charges nothing. It asks for optional donations ("independent project, not tax-deductible charitable donations, crypto irreversible/non-refundable"). It has a sign-up flow for a watchlist and notification features.

This means the operator's content is always in the service of one goal: get someone to click through to a film page or browse filter on newshow.biz. The secondary goals (signups, donations, brand trust) follow from that primary action. A post that generates 1,000 likes but zero site clicks is a failure. A post that generates 12 clicks and 2 watchlist adds from the right audience is a success.

The Kakusu Protocol exists because the product's representation scores can easily be framed in politically loaded ways that would alienate part of the audience. The operator's job is to present the same analytical data in a film-critic register — "this film handles X with unusual sophistication" rather than "this film advances DEI goals." The analysis is the same. The framing is not.

---

## Strategic Boundaries

These are not preferences. They are constraints baked into the system at the agent, skill, and config levels.

| Boundary | Implementation |
|---|---|
| One public identity: New Showbiz | SOUL.md, Kakusu Protocol, all templates |
| No engagement automation | `like`, `retweet`, `bookmark` excluded from all MCP configs |
| No autonomous publish before Phase 3 | `x-mcp-write` disabled at config level |
| Every draft has source refs | Skill verification step; drafts without refs are incomplete |
| Risk class on every draft | Required ContentJob field; medium/high triggers escalation-agent |
| Money/legal/partnership cases escalate | escalation-agent, escalation-record-write skill |
| TROLL mode is X-only and fact-bound | Personality gate; can be suspended; requires prior incident review |
| Metrics optimize qualified traffic, not raw engagement | growth-analyst persona; PerformanceSnapshot schema |
| Donation messaging matches live site constraints | Template prohibitions; product-explainer guardrails |
| No fabrication under tool failure | Anti-fabrication enforcement stack (4 layers) |

---

## Assessment: Where the Project Stands

**The Telegram gateway is the most significant development since the last assessment.** The operator can now be controlled from a mobile device via Telegram message. A full pipeline — research, draft, template selection, Kakusu Protocol enforcement — was triggered from Telegram and ran without SSH access to the EC2 instance. This is not a Phase 3 capability. This is the system working as designed at Phase 1. It changes the operational picture: the human operator does not need to be at a terminal to run the content cycle.

**The anti-fabrication stack was tested in production and failed.** The Daughters of the Dust run produced a draft claiming `94/100 for Racial & Ethnic representation`. The actual score on newshow.biz is `9.8/10`. The format was wrong (the site uses X.X/10, not XX/100), the number was wrong (98/100 if converted, not 94), and the agent had no way to verify because the movie page returned a 307 redirect without credentials. The draft was caught in human review and rejected. The failure mode is exactly the one documented in the anti-fabrication stack: inaccessible tool → plausible-looking fabricated output rather than BLOCKED status. The stack detected it at the review layer, not at the generation layer. That is the right place to catch it for now, but it is not where we want to catch it permanently.

**The newshow.biz auth gap is the critical Phase 1 blocker.** The agent cannot do independent film research without credentials to access movie pages. Every workaround explored has a hard wall: the 307 redirect is server-side, there is no public API, and Playwright without a session cookie hits the same redirect. The fix is newshow.biz login credentials in the profile `.env`. Until those exist, every production run requires a human to look up scores and hand them to the agent — which is not what this system is built for.

**The X auth block is a temporary annoyance, not a structural problem.** `stex_press` hit a login rate limit on EC2 IP ranges. One manual browser login from a non-EC2 IP clears the rate limit window. After that, the Playwright login tool saves a session cookie to `x-auth/twitter.json` and the system does not need to re-login on every post.

**The Kakusu Protocol creative decision remains validated.** The Daughters of the Dust draft — fabricated score aside — used the film-critic register correctly. "Julie Dash's 1991 debut refuses the familiar documentary gaze — the Gullah Geechee women carry their own archive." That is the voice the protocol is designed to produce. The content problem is not the framing; it is the data sourcing.

**Phase 3 infrastructure is built.** The Telegram gate skills (`telegram-notify`, `telegram-await-approval`), the activation checklist with 6 binary gates, the credential rotation doc, the failure logging wrapper, and the weekly log-rotation timer are all in place. Phase 3 is not blocked on infrastructure. It is blocked on Phase 1 being complete, which requires the approved content queue to exist, which requires the newshow.biz auth gap to close.

---

## Next Actions (Phase 1 Completion)

1. **newshow.biz credentials** — add login email and password to `~/.hermes/profiles/newshowbiz/.env` as `NEWSHOWBIZ_EMAIL` and `NEWSHOWBIZ_PASSWORD`; update `movie-research-agent` to use Playwright for authenticated score scraping
2. **X authentication** — log into `stex_press` in a real browser from any non-EC2 IP to clear the rate limit; then invoke the `login` tool in `hermes -p newshowbiz` to save the session cookie
3. **Production content run** — agent researches 3–5 films independently via Playwright-authenticated newshow.biz pages, drafts using the template library, all drafts go through real human review via Telegram
4. **Human decisions** — campaign priorities (which films/categories to lead with), post cadence, CTA preference (browse / signup / donate)
5. **Build 7-day approved queue** — 14–21 approved posts with verified source refs
6. **Phase 1 exit report** — `report-agent` over `store/` → commit to `docs/50-rollout/phase-1-exit-report.md`

---

## Non-Negotiable Boundaries (Restatement)

- One public identity: `New Showbiz`
- Hermes is the runtime, not the social-channel transport
- X and Instagram writes require explicit tool wrappers behind the ContentJob store and policy engine
- Engagement tools (`like_post`, `retweet_post`, `bookmark_post`) are excluded from all MCP configs — permanently
- Write tools (`tweet`, `thread`) require Phase 3 gate to pass — no exceptions
- TROLL mode is X-only, fact-bound, and suspendable
- Metrics optimize qualified traffic, signups, donations, and trust — not raw engagement
- Donation messaging follows the live site constraints exactly
- No fabricated plot points, identities, quotes, scores, or reception data in any draft
