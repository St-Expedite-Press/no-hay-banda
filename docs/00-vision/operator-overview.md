# New Showbiz Marketing Operator — Overview and Assessment

*Assessment date: 2026-06-05. This document reflects the live deployed system.*

---

## What This Is

New Showbiz is a structured movie-discovery product at [newshow.biz](https://newshow.biz). The catalog contains more than 110,000 titles, each with AI-generated inclusivity profiles scored across five dimensions: LGBTQ+ representation, Gender representation, Racial and Ethnic representation, Disability representation, and Religious and Cultural representation. The site surfaces these scores through browse filters, movie detail pages, and user-facing category ratings. Its live promise: "Watch more of what matters to you."

The marketing operator is an autonomous agent system — built on a customized Hermes Agent v0.15.1 deployment — that turns that structured catalog data into governed social content for X and Instagram. The system researches films, drafts posts in a controlled brand voice, routes them through human review, and (in Phase 3) publishes with receipts. It is not a schedule-and-blast tool. It is a governed production system with explicit human gates at every write boundary.

---

## System State as of 2026-06-05

The operator is deployed and operational on EC2 (i-05451add3165b57ff). Oneshot mode is confirmed working. The content pipeline has been exercised: DeepSeek V4 Pro was handed film data, read the template library, and produced on-brand drafts that passed Kakusu Protocol constraints. Two bootstrapped ContentJob JSON files sit in the review queue awaiting human decisions. What remains to complete Phase 1 is X authentication, followed by a production content run with fresh research.

| Layer | State |
|---|---|
| Hermes runtime | **Live** — v0.15.1, DeepSeek V4 Pro/Flash via OpenRouter |
| Oneshot mode (`hermes -p newshowbiz --yolo -z`) | **Confirmed working** — profile config bug found and fixed |
| Three-tier agent system | **Live** — 20 agents (Tier 0/1/2), consolidated from 29; all tier declarations in place |
| Anti-fabrication enforcement | **Live** — present at SOUL, contract, and every agent file |
| Content pipeline | **Confirmed working** — templates read, drafts produced, ContentJob store populated |
| First content run (DeepSeek output) | **Complete** — discovery post (255 chars) and 3-post thread on Racial & Ethnic (9.6 score) |
| Human review workflow | **Live** — procedure doc + review-decision-record skill; 2 drafts pending review |
| X read tools (twitter-mcp) | **Partially live** — public profile lookup confirmed; search requires auth |
| X read tools (x-mcp-read) | **Built, auth pending** — Barresider local fork patched and compiled; login not yet called |
| X write tools | **Configured, disabled** — Phase 3 gate enforced at config level |
| Autonomous publishing | **Not started** — Phase 3 prerequisite |
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

**The content pipeline works.** This is no longer a theoretical claim. DeepSeek V4 Pro, operating through the newshowbiz profile in oneshot mode, read the template library without prompting, applied the correct structural constraints, enforced Kakusu Protocol character limits and term prohibitions, and produced drafts that are on-brand. The discovery post came in at 255 characters. The thread-breakdown on Racial and Ethnic representation ran three posts against a 9.6 score. The model verified character counts before returning. It did not use loaded advocacy language. It framed scores as analytical observations: "The multiverse is not a metaphor for diversity; it is built from it." That is the film-critic register working as designed.

**The model block bug is a good example of why the hacked-instance framing matters.** Interactive mode worked for weeks. Oneshot mode silently failed. The root cause was non-obvious and required reading the Hermes source to understand how profile configs are loaded in `-z` mode versus interactive mode. This is not a Hermes bug — it is a consequence of running a customized deployment where interactive and oneshot modes have different config resolution paths. Anyone operating this system should treat the profile config as fully independent of the global config and verify that both modes work after any config change.

**The Kakusu Protocol creative decision is validated.** The concern going in was whether an LLM instructed to avoid advocacy framing would produce flat, hedged copy as a result. It did not. DeepSeek reached naturally for film-structural analysis — cinematic architecture, directorial choices, narrative function — when the templates prohibited the loaded terms. This is not a constraint working around quality; it is a constraint producing quality. The protocol exists for brand safety reasons, but it turns out to be editorially correct as well.

**The remaining gap is not "does the system work" — it is "does the output survive human review at production volume."** Two bootstrapped drafts are in the queue. They were produced from film data handed directly to the agent, not from the agent doing its own research. A full production cycle means the agent finds the film, pulls the score data, applies the template, and produces a draft that earns a human approval — not because the human is being lenient, but because the content is actually ready to post. That cycle has not run yet. When it runs three to five times in sequence, and the reviewer is making real approve/reject decisions rather than bootstrapping examples, that is when Phase 1 is genuinely complete.

**The operator has no audience yet.** The X account (`@new_show_biz`) exists and has some following. Growing a relevant audience for a representation-scored movie catalog requires a consistent content strategy over weeks and months. The operator is ready to execute that strategy. The decisions about which films to lead with, what cadence to run, and what CTA to emphasize are human decisions that have not yet been made.

**Phase 3 (autonomous publish) is the real gate.** Everything before Phase 3 is governed by a human with final say on every post. Phase 3 introduces the policy engine and receipt store that allow the system to publish without asking. That is where the risk/reward calculus changes and where the Telegram oversight gate becomes mandatory.

---

## Next Actions (Phase 1 Completion)

1. **X authentication** — invoke the `login` tool in interactive mode (`hermes -p newshowbiz`), verify `x-auth/twitter.json` is written, confirm x-mcp-read search works
2. **Production content run** — agent researches 3–5 films independently (not from data handed to it), produces drafts using the template library, all drafts go through real human review decisions
3. **Human decisions** — campaign priorities, post cadence (X vs Instagram split), CTA preference (browse / signup / donate), review SLA
4. **Build 7-day queue** — 14–21 approved posts across X and Instagram
5. **Phase 1 exit report** — `report-agent` over store/ → commit to `docs/50-rollout/phase-1-exit-report.md`

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
