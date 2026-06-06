# no-hay-banda

**New Showbiz marketing operator** — a multi-agent content pipeline that researches films, drafts X posts, routes them through human approval, and publishes with a durable receipt.

**Status:** Phase 1 operational. Telegram gateway live. Two pre-Phase-3 blockers: X auth credentials need rotation, and newshow.biz login credentials required so the agent can pull scores directly. Anti-fabrication enforcement confirmed working in production (2026-06-05): a fabricated score was caught at the review layer when the source page was inaccessible.

---

## ELI5: What is this?

**New Showbiz** is a movie-discovery website. It scores over 110,000 films across five dimensions of representation — gender, race/ethnicity, LGBTQ+, disability, and religion/culture. The scores are AI-generated structured literary and cinematic analysis. If you care whether a film actually has disabled characters with meaningful roles — not just background faces — New Showbiz has a number for that, with the specific scenes that justify it.

**This repo is the marketing operator.** It's an AI system that:

1. Reads the New Showbiz catalog and identifies films worth posting about
2. Drafts posts about those films for X (Twitter) in a consistent film-critic voice
3. Sends each draft to a human operator for approval over Telegram
4. Posts it **only** when the human says yes
5. Stores a receipt proving exactly what was sent, when, and what source data backed it

**Simpler version:** Imagine a film critic who never sleeps, knows the full 110,000-title catalog, will never make up a fact, and cannot publish a single word without your explicit approval. That's this system.

**Why not just hire someone to tweet?** A human social media manager for a 110,000-title catalog would need documented processes for: which films to surface each week, how to write about representation without triggering culture-war framing, which posts are legally or reputationally risky, how to verify that every claim has a source, and how to maintain one consistent public voice across hundreds of posts per year. This system *is* that documented process — made repeatable, auditable, and suspendable at any time from a Telegram message.

---

## The Technical Argument

### Why a multi-agent pipeline instead of one big prompt?

Content production at catalog scale has a **division-of-cognitive-labor problem**. Research, drafting, policy review, publishing, and reporting require different context windows, different tool access, and different failure behaviors. Combining them into one monolithic agent produces a system that:

- Has no seams where human review can interrupt
- Cannot escalate individual steps without aborting the whole run
- Cannot be upgraded incrementally (change the policy without touching the writer)
- Fails silently when one step produces bad output that the next step compounds

A pipeline with discrete agents and a shared output contract solves all four. Each agent has a defined input, a defined output schema, and an explicit failure mode. A blocked step produces `status: BLOCKED` with a named blocker — not a plausible-sounding fabricated result that corrupts everything downstream.

### Why Hermes as the runtime?

Hermes Agent provides the infrastructure that makes agent pipelines production-safe without building it from scratch: profile isolation (secrets don't bleed between projects), session persistence (memory survives across runs), a cron scheduler that attaches skills, an approval gateway (Telegram), and a tool registry with toolset filtering. These are load-bearing features for a system that manages live social-account credentials and posts to a public audience. A custom framework would need to rebuild all of them, and get them wrong once to cause a real incident.

### Why flat-file JSON before a database?

The ContentJob store is plain JSON files in a directory. This is intentional for Phase 1. Flat files are: readable without tooling, diffable in git, trivially portable, and impossible to lose to a migration bug. When the system is producing 50+ jobs per week and needs querying, the upgrade path to SQLite or Postgres is a one-sprint migration. The domain record schemas are already defined and stable. The cost of premature database setup — auth, connections, migrations, backup — is not worth paying before the content pipeline has proved it works.

### Why the Kakusu Protocol exists

New Showbiz's scores are interpretive AI analysis, not certified empirical metrics. Every post about representation inherently touches identity-adjacent cultural territory. Without a framing constraint, an AI writing about these scores will default to one of two failure modes: advocacy language (which alienates audiences who don't share the political frame) or disclaimers so hedged the post says nothing useful. The Kakusu Protocol resolves both: frame it as cinematic analysis, the way a film critic discusses narrative architecture — not as politics. This preserves factual rigor while staying durable across cultural moments.

---

## System Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                          SOURCE INPUTS                             │
│   newshow.biz movie pages · X trends · inbound mentions            │
│   platform analytics · user ratings · watch-provider links         │
└──────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│                    HERMES RUNTIME  (substrate)                     │
│                                                                    │
│  Agent execution loop   ·  Prompt assembly (SOUL + AGENTS + skills)│
│  Cron scheduler         ·  Session memory & search                 │
│  MCP tool registry      ·  Profile isolation                       │
│  Gateway (Telegram)     ·  Approval workflows                      │
└──────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│                DOMAIN CONTROL PLANE  (New Showbiz)                 │
│                                                                    │
│  TaskRouter    ·  PersonaRegistry    ·  Policy Engine              │
│  ContentJob store · EngagementJob store                            │
│  EscalationRecord store · PerformanceSnapshot store                │
└──────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│                  CHANNEL INTEGRATION LAYER                         │
│                                                                    │
│  x-mcp-read   (Barresider/x-mcp, patched, authenticated reads)    │
│  x-mcp-write  (same binary, write tools, disabled until Phase 3)  │
│  playwright   (browser fallback, inspection only)                  │
│  twitter-mcp  (stateless scrape, no auth, experimental)           │
└──────────────────────────────┬─────────────────────────────────────┘
                               │
                               ▼
┌────────────────────────────────────────────────────────────────────┐
│                  PUBLIC CHANNEL + BUSINESS OUTCOMES                │
│      X posts · replies · qualified traffic · signups · donations   │
└────────────────────────────────────────────────────────────────────┘
```

**The critical design rule:** Hermes owns execution; New Showbiz owns state. Every durable record lives in the flat-file store, not inside a Hermes session. The system can be restarted, upgraded, or replaced without losing content history or audit trail.

---

## The Product: New Showbiz

**Site:** newshow.biz
**Catalog:** 110,000+ films
**Scores:** AI-generated across five representation dimensions

| Dimension | What it measures |
|-----------|-----------------|
| Gender | Representation and narrative roles by gender |
| Race / Ethnicity | Representation and narrative centrality by race/ethnicity |
| LGBTQ+ | LGBTQ+ characters, themes, and narrative roles |
| Disability | Disabled characters with substantive roles |
| Religion / Culture | Religious and cultural representation in context |

Each film gets an overall score and per-dimension scores. Score pages include explanations, strengths, areas for improvement, and watch-provider links. Users can rate, review, build watchlists, and filter by category.

**What the product actually sells:** Not the scores. Not the methodology. The ability to find a film that matches what matters to you before movie night. Every post this system creates has one job: get someone to click through to a film page or browse filter on newshow.biz.

> "A post that generates 1,000 likes but zero site clicks is a failure. A post that generates 12 clicks and 2 watchlist adds from the right audience is a success."

---

## The Agent System

### Three-Tier Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│  TIER 0  —  Session Director (SOUL.md)                      │
│  Single entry point for every session.                      │
│  Routes to Tier 1. Never executes specialist work.          │
└──────────────────────┬──────────────────────────────────────┘
                       │  can spawn ↓
         ┌─────────────┼──────────────────────┐
         ▼             ▼                      ▼
   ┌──────────┐  ┌────────────┐      ┌───────────────────┐
   │ Content  │  │Orchestrator│  ... │  Other Tier 1     │
   │  Agent   │  │            │      │  Pipeline Agents  │
   └──────────┘  └────────────┘      └───────────────────┘

  TIER 1  —  6 Pipeline Agents
  Manage multi-step workflows. Can spawn Tier 2 only.
  Each has an explicit authorized-spawn table.

                       │  can spawn ↓
   ┌──────┬────────────┼──────────┬─────────┬──────────┐
   ▼      ▼            ▼          ▼         ▼          ▼
 Movie  Validate  Engagement  Escalation  Writer   Report
Resrch   Agent     Agent       Agent      Editor   Agent

  TIER 2  —  13 Leaf Agents (subagents)
  Atomic execution. Cannot delegate. Pure specialists.
```

**Why three tiers?** Delegation depth is the main attack surface in multi-agent systems. An unconstrained agent can spawn subagents that spawn further agents, creating invisible chains where accountability is lost and costs spiral. `max_spawn_depth: 2` in config, combined with tier declarations in every persona file and spawn authorization tables in every Tier 1 agent, makes the delegation graph auditable. A rogue chain cannot form.

### Full Agent Roster

| Tier | Agent | Role | Key Constraint |
|------|-------|------|----------------|
| 0 | Session Director (SOUL) | Route all requests; hold brand identity | Never executes specialist work |
| 1 | Orchestrator | Decompose tasks into DAGs; assign agents; validate outputs | Deterministic spine only; does not write content |
| 1 | ContentAgent | Generate X posts from movie data; run validate→draft→publish→report | Never fabricate scores; never self-approve |
| 1 | PublishAgent | Send approved ContentJobs to X; capture receipt | Requires APPROVED status; never retries without new signal |
| 1 | MetricsAgent | Generate PerformanceSnapshots; analyze attribution | Spawns AnalysisAgent + ReportAgent only |
| 1 | FetchAgent | Pull newshow.biz data into vault | Idempotency mandatory; always precedes TransformAgent |
| 1 | ProjectManager | Coordinate multi-specialist work | May spawn any Tier 2 agent |
| 2 | MovieResearchAgent | Research film: cast, production, scores, themes | Returns research memo (not draft copy); flags unverifiable claims |
| 2 | ValidateAgent | Pre-publish policy check; risk classification | Routes risky items to EscalationAgent; never auto-resolves |
| 2 | Writer | Generative composition on demand | — |
| 2 | Editor | Proofread and review writing | — |
| 2 | AnalysisAgent | Data analysis; pattern detection | — |
| 2 | LintAgent | Format and constraint checking | — |
| 2 | EngagementAgent | Triage mentions, replies, engagement signals | May route to EscalationAgent or MovieResearchAgent |
| 2 | EscalationAgent | Log risk; hold item; preserve evidence | Never auto-resolves; status always HOLD until human acts |
| 2 | ExecuteAgent | Run shell/tool operations | — |
| 2 | Interrogator | Clarify ambiguous task specifications | — |
| 2 | Researcher | Query vault/store for prior work | — |
| 2 | ReportAgent | Compose final user-facing summaries | Every pipeline terminates here |
| 2 | TransformAgent | Normalize source material into briefs | — |

### The Shared Contract

Every agent — without exception — must return this output structure:

```
status:    COMPLETE | BLOCKED | PARTIAL | INSUFFICIENT | NO_BASELINE | HOLD
claims:    factual assertions, each with a source citation
artifacts: file paths to anything written or changed
blockers:  specific unmet conditions preventing completion
```

This is not a style convention. It is a machine-readable contract that the Orchestrator validates before passing output upstream. An output reporting `COMPLETE` when blockers exist is rejected and routed to error handling.

### The Orchestrator's 12-Phase Workflow

For complex multi-step tasks, the Orchestrator runs a deterministic 12-phase pipeline:

| Phase | Name | What happens |
|-------|------|-------------|
| 1 | Task Intake | Classify request; assign task_id and chain_id |
| 2 | Authorization Check | Proceed / require confirmation / reject |
| 3 | DAG Construction | Build task dependency graph (or fast path) |
| 4 | Context Retrieval | Load per-subtask context; apply compression |
| 5 | Agent Assignment | Map subtasks to agents with skills |
| 6 | Skill Equipping | Load required skill definitions per agent |
| 7 | Dispatch | Execute subtasks; run idempotency checks; capture pre-op snapshots |
| 8 | Output Validation | Accept or reject each subagent output against shared contract |
| 9 | Result Aggregation | Compose composite results; mark downstream tasks ready |
| 10 | Error Handling | Retry / compensate / escalate / dead-letter |
| 11 | Compensation | Restore pre-op snapshots on failure; mark reverted in log |
| 12 | Finalization | Update session log; propose new skills; update specs |

**Fast path:** Phases 3–6 are skipped for single-hop, dependency-free tasks with no final write. Output validation (Phase 8) and finalization (Phase 12) are never skipped.

---

## The Content Pipeline

```
  newshow.biz detail page
         │
         ▼
  ┌──────────────────┐
  │ MovieResearch    │  Research memo: director, cast, scores,
  │ Agent (Tier 2)   │  category data, confidence level,
  │                  │  platform links. NOT draft copy.
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ ContentAgent     │  Select content angle. Match template.
  │ (Tier 1)         │  Draft in New Showbiz voice.
  │                  │  Attach source_refs. Status: DRAFT.
  └────────┬─────────┘
           │
           ▼
  ┌──────────────────┐
  │ ValidateAgent    │  Risk classification: low/medium/high/blocked
  │ (Tier 2)         │  Check: 280 chars, 2 hashtags, no em dash,
  │                  │  source refs present, no trigger language.
  └────────┬─────────┘
           │
      ┌────┴────┐
    PASS      FAIL
      │          │
      ▼          ▼
  ContentJob   EscalationRecord
  status=draft   status=HOLD
      │
      ▼
  ┌──────────────────────────────┐
  │  telegram-notify             │  Human receives draft on Telegram.
  │  → telegram-await-approval   │  4-hour window to APPROVE or REJECT.
  └────────┬─────────────────────┘
           │
      ┌────┴────────────────────┐
   APPROVE                REJECT / timeout
      │                        │
      ▼                        ▼
  status=APPROVED          store/rejected/
      │                    review-log.jsonl
      ▼
  ┌──────────────────┐
  │ PublishAgent     │  Verify APPROVED. Check account safety.
  │ (Tier 1)         │  Publish via reviewed wrapper.
  │                  │  Store durable receipt.
  └────────┬─────────┘
           │
      ┌────┴────────────────────────────────┐
   SUCCESS                          FAILURE (typed)
      │                                   │
      ▼                                   ▼
  Receipt:                       auth · captcha · cloudflare_403
  post_id, URL, timestamp,       selector_drift · rate_limit ·
  content_hash, idempotency_key  network · account_warning
      │                          → EscalationAgent if severe
      ▼
  MetricsAgent → PerformanceSnapshot
```

---

## Key Design Patterns

### Anti-Fabrication Doctrine

This is the most important safety property in the system. It addresses a documented failure mode of DeepSeek V4 Flash: when a tool call fails or returns no data, the model substitutes plausible-sounding fabricated output rather than reporting the failure.

**The rule, stated in every agent spec and the shared contract:**

> "If a tool call fails or is blocked, report the error in blockers and set status BLOCKED. NEVER substitute plausible-looking fabricated output — invented file contents, fake data, synthesized API responses — for results you could not actually produce. Reporting a blocker honestly is always better than inventing a result."

**Enforcement at multiple layers:**

| Layer | Mechanism |
|-------|-----------|
| Global SOUL.md | Standing rule in base system prompt |
| `_shared-contract.md` | Binding output contract requiring claims with source citations |
| Every agent persona file | Individual anti-fabrication clause |
| `prefill_messages.json` | Few-shot priming examples showing correct BLOCKED responses |
| ValidateAgent | Pre-publish check catches fabricated or unsourced claims |
| Orchestrator Phase 8 | Rejects outputs missing source citations |

**This has already mattered in production.** In June 2026, the agent produced a fabricated score when the newshow.biz source page returned a 307 redirect (auth gate). The enforcement at the review layer caught it before it reached the approval queue.

### The Kakusu Protocol

**What it is:** A brand constraint requiring that representation scores be framed as cinematic analysis, not political advocacy.

**Required vocabulary:**
- "the film challenges traditional tropes"
- "the casting refuses a familiar pattern"
- "narrative architecture disrupts conventional expectations"

**Blocked vocabulary:**
- `woke` · `DEI` · `subversive` · `progressive` · `political activism`
- Any language implying the scores are empirically definitive or officially certified

**Why it exists:** New Showbiz's scores are AI-generated interpretive analysis. Framing them in culture-war vocabulary — even favorably — invites discourse that consumes the brand's reputation without producing product engagement. Cinematic framing preserves analytical precision while staying useful to audiences with a wide range of political views. It also protects against a post performing well with one ideological audience and then going viral for the wrong reasons.

**Where it lives:** SOUL.md · `_shared-contract.md` · every agent persona file · every X post template · ValidateAgent policy check.

### The Escalation System

12 risk classes trigger an EscalationRecord. When one fires, the related job is halted and held.

| Risk Class | Meaning |
|-----------|---------|
| `money_terms` | Financial language beyond approved donation copy |
| `tax_investment_advice` | Tax, refund, investment, wallet-choice claims |
| `partnership` | Sponsorship, affiliate, collaboration terms |
| `legal` | Legal threat or legal claim |
| `creator_complaint` | Filmmaker or creator objection to content |
| `invalid_analysis` | Dispute of the AI-generated diversity profile |
| `factual_dispute` | Claim requiring external validation |
| `identity_sensitive` | Protected or vulnerable group conflict |
| `platform_policy` | X platform warning or policy flag |
| `backlash` | High-visibility hostile response |
| `unsupported_claim` | Assertion with no source evidence |
| `troll_threshold` | TROLL mode output exceeding policy bounds |

EscalationAgent never auto-resolves, dismisses, or archives without explicit human instruction. Evidence is preserved until a human acts.

### Tool Boundary Architecture

**ELI5:** Each agent only gets the tools it needs. A research agent can read movie pages. It cannot post to X. A publish agent can post. It cannot read the film database. A mistake in a read-only agent is recoverable. A mistake in a write-capable agent is public.

| Toolset | Includes | Excludes |
|---------|----------|---------|
| `newshowbiz_read` | Movie catalog, scores, pages | All writes |
| `newshowbiz_x_read` | Search, profiles, timeline, trends | All writes |
| `newshowbiz_x_draft_context` | Read-only X context for drafts | All writes |
| `newshowbiz_x_publish_reviewed` | Approved posts, threads, replies | Read without policy pass |
| `newshowbiz_x_account_safety` | Diagnostics only | Public writes |
| `newshowbiz_escalation` | Create/update EscalationRecords | Publish |
| `newshowbiz_metrics_read` | Analytics snapshots | All writes |

**Non-negotiable rules:**
- No agent receives write tools unless its task requires writes
- No write executes without an idempotency key
- No public write executes without a policy result and an approval state
- X writes never fall back to raw Playwright if the reviewed wrapper fails
- Like / retweet / bookmark / follow are manual-only in v1 — excluded from every toolset

---

## Domain Records

All durable business state lives in flat-file JSON outside Hermes sessions.

### ContentJob — the central record

```
id:              2026-06-06T091200-a3f1
kind:            original | reply | quote | thread | report
platform:        x
status:          draft → approved → published | hold | failed | rejected
text:            the draft text
source_refs:     ["https://newshow.biz/films/daughters-of-the-dust"]
risk_level:      low | medium | high | blocked
objective:       discovery | explain | activate | respond | support
cta:             "Find it at newshow.biz/films/daughters-of-the-dust"
approval:        null → { by: "human", at: "2026-06-06T10:02Z" }
idempotency_key: same as id in Phase 1
receipt_ids:     [] → ["rcpt-x-2026-06-06T10:14Z-..."]
```

### EngagementJob — inbound interactions

```
id, platform, raw_payload_ref
classification:  support | discovery | factual-dispute | complaint |
                 spam | partnership | legal | other
sentiment:       positive | neutral | negative | hostile | unknown
urgency:         low | normal | high | critical
risk_flags:      [...escalation class names if triggered]
disposition:     respond | ignore | redirect | escalate | hold
```

### EscalationRecord — held for human review

```
id, source_record_id, risk_class, summary
evidence_refs:       [full payloads, links, screenshots]
status:              open | held | approved | rejected | resolved
human_owner:         null until assigned
recommended_action:  approve | revise | hold | investigate | reject
```

### PerformanceSnapshot — the feedback loop

```
id, period_start, period_end, content_job_ids
channel_metrics:  { views, likes, replies, saves, shares, follows }
site_metrics:     { sessions, signups, ratings, reviews, watchlist_adds }
support_metrics:  { donation_page_visits, donations }
recommendations:  continue | revise | stop | investigate
```

---

## Store Directory Layout

```
~/.hermes/profiles/newshowbiz/store/
├── jobs/               ← canonical ContentJob records (one JSON file per job)
├── review-queue/       ← drafts pending human review (copies of jobs/)
├── approved/           ← approved jobs ready to publish
├── rejected/           ← rejected jobs (audit archive)
├── escalations/        ← held jobs requiring human resolution
└── review-log.jsonl    ← append-only log of every review decision
```

**File lifecycle:**

```
created:   store/jobs/{id}.json          (status: draft)
           store/review-queue/{id}.json  (copy)
                    │
             human decision
            ┌───────┴──────────┐
         APPROVE             REJECT
            │                  │
  store/approved/{id}.json   store/rejected/{id}.json
  store/jobs/ updated        store/jobs/ updated
  (status: approved)         (status: rejected)
            │
        published
            │
  store/jobs/ updated        review-log.jsonl appended
  (status: published,        {"id":..., "decision":"approve", "at":...}
   receipt_ids: [...])
```

---

## X Integration

### The MCP Server Stack

```
┌─────────────────────────────────────────────────────────┐
│  Tier 1 — Primary (Barresider/x-mcp, local fork)        │
│  x-mcp-read:  login, scrape_posts, scrape_profile,      │
│               scrape_comments, search_twitter,          │
│               search_viral, scrape_timeline,            │
│               scrape_trending                           │
│  x-mcp-write: tweet, thread, reply_to_post,             │
│               quote_tweet  ← disabled until Phase 3     │
├─────────────────────────────────────────────────────────┤
│  Tier 2 — Browser fallback (microsoft/playwright-mcp)   │
│  Inherited from global config. Inspection only.         │
│  Never used as a hidden publisher.                      │
├─────────────────────────────────────────────────────────┤
│  Tier 3 — Experimental (miles0sage/twitter-mcp)         │
│  Stateless Playwright scrape. No authentication.        │
│  Write and engagement tools excluded.                   │
├─────────────────────────────────────────────────────────┤
│  Tier 4 — Reference / disabled (kitadmin01/social_mcp)  │
│  Requires Google Sheets. Contains mass-engagement       │
│  tools. enabled: false. Implementation reference only.  │
└─────────────────────────────────────────────────────────┘
```

### Why a Local Fork of x-mcp?

The upstream `@barresider/x-mcp` package has five login failures on EC2. They are patched in `hermes/mcp/x-mcp/src/behaviors/login.ts` and compiled to `dist/mcp.js`. The binary is never re-downloaded via `npx` — local build only.

| Patch | Root cause | Fix |
|-------|-----------|-----|
| Login URL | `twitter.com` redirect races React hydration | Use `x.com/i/flow/login` + `domcontentloaded` + 4000ms wait |
| Username selector | X renamed field to `name="username_or_email"` | `page.fill('input[name="username_or_email"]', ...)` |
| Continue button | X alternates between "Next" and "Continue" text | `.locator('span:text("Next"), span:text("Continue")').first()` |
| stdio pollution | `console.log` corrupts JSON-RPC protocol on stdout | All logging moved to `console.error` (stderr only) |
| Auth dir creation | `storageState()` fails if parent directory missing | `fs.mkdirSync(authDir, { recursive: true, mode: 0o700 })` |

Rebuild after editing: `cd ~/.hermes/mcp/x-mcp && npm run build`

---

## Telegram Oversight Gate

Every ContentJob that passes validation reaches a human through Telegram before it can be published. This is structural — not optional, not bypassable by any agent.

```
ContentJob (status=draft, risk=low|medium)
       │
       ▼
telegram-notify
  POST /sendMessage to oversight chat
  Returns message_id
       │
       ▼
telegram-await-approval
  Polls getUpdates every 60s
  Matches reply to message_id
       │
   ┌───┴────────────────────────────┐
   │                                │
"APPROVE"                   "REJECT" or 4h timeout
   │                                │
   ▼                                ▼
status: COMPLETE              status: HOLD
→ Proceed to publish          → store/rejected/
                                → operator notified:
                                  "[job_id] timed out after 4h"
```

**Sample notification:**
```
🎬 PUBLISH REQUEST

Job:      2026-06-06T091200-a3f1
Platform: x
Template: original-discovery
Risk:     low

Draft:
Daughters of the Dust has one of the most unusual
representation profiles in the catalog — 89 in
Gender, 94 in Race. newshow.biz/films/daughters
#FilmCritic #Representation

Sources:
• https://newshow.biz/films/daughters-of-the-dust

Reply APPROVE to publish. Reply REJECT to discard.
No reply within 4h = HOLD.
```

**Why Telegram, not a web dashboard?** The operator runs a one-person shop. The oversight surface needs to work from a phone at any hour, without opening a browser. Telegram is already running. The bot token and chat ID are the full deployment surface.

---

## Behavior Modes

| Mode | When used | Character |
|------|-----------|-----------|
| **STANDARD** | Default | Clear, measured, direct. Routine posts and product explanation. |
| **UTILITY** | Discovery content | Recommendation-driven. "Best films for X." User-action oriented. |
| **HYPE** | Milestones, launches | Higher energy, no exaggeration. |
| **DEBATE** | Opinionated posts | Challenge-oriented but fully factual. Comparisons, discourse responses. |
| **TROLL** | Authorized edge content | Intentionally provocative within hard limits. X only. Evidence-bound. |

**TROLL mode in detail:** Every claim must trace to product data. EscalationAgent review required before posting. Incident counters track outcomes. Any authorized human can suspend it immediately. Permanent blocks: DMs, support flows, donation messaging, creator complaints, identity-sensitive conflicts. Not deployed because it's entertaining — deployed because attribution numbers justify the risk.

---

## Agent Personalities

Six personality overlays are available via `/personality <name>` in the Hermes CLI. These are prompt extensions — they add a specific operating posture on top of the base agent identity.

| Personality | Role | Hard limit |
|-------------|------|-----------|
| `brand-director` | Final positioning gate; pressure-tests CTA discipline and external consistency | Does not generate content |
| `audience-researcher` | Finds unlocated demand; surfaces high-leverage films from current X conversations | Does not draft copy |
| `product-explainer` | Makes representation scores intelligible to new users without jargon or ideology | No framework advertising |
| `x-editor` | Drafts original/reply/quote/thread posts; enforces all constraints | Cannot post without human approval |
| `provocateur` | TROLL mode; all claims traceable to source data; escalation review required | Blocked from DMs, identity-sensitive targets |
| `growth-analyst` | Measures qualified outcomes (traffic, signups, donations) | Does not fabricate attribution |

---

## X Post Templates

Five templates cover the production content program. All enforce: Kakusu Protocol, no em dash, 2-hashtag ceiling, source refs required.

| Template | Use when | Format |
|----------|---------|--------|
| `original-discovery` | Introducing one film; drive clicks | Score observation → URL → #tag1 #tag2 |
| `thread-breakdown` | Deep-diving one dimension across 3 posts | 3-post thread; each node standalone |
| `comparison-post` | Two films, one shared dimension | Film A vs Film B → both URLs |
| `reactive-hook` | Responding to current film discourse with data | Discourse hook → product angle |
| `utility-post` | Promoting a browse/filter feature | Feature description → catalog URL |

**Original Discovery skeleton:**
```
[Cinematic observation grounded in scores — 1 sentence, no advocacy]
[newshow.biz/films/slug]
#tag1 #tag2
```

**Comparison Post hard rule:** If only one film's source data is available, return `BLOCKED`. Never comparison-post with fabricated data for the second film.

---

## Model Selection

| Task | Model | Reason |
|------|-------|--------|
| Tier 0 routing, Tier 1 orchestration, policy decisions | `deepseek/deepseek-v4-pro` via OpenRouter | Strong instruction-following; reliable tool calls; reasoning depth justifies cost |
| Tier 2 leaf work: research memos, format checks, drafting | `deepseek/deepseek-v4-flash` | Speed and cost for atomic tasks; lower reasoning demand; parallel cron runs |

**Known risk:** DeepSeek V4 Flash substitutes fabricated output on tool failure more readily than V4 Pro. This is mitigated through the anti-fabrication enforcement stack, not by avoiding Flash entirely. The cost/latency trade-off for leaf work is real and justified.

**Benchmarking criteria for any model change:**
1. Instruction-following on Kakusu Protocol constraints
2. Tool-call reliability on multi-step pipelines
3. Anti-fabrication behavior on blocked tool calls
4. Brand-voice stability under persona overlays
5. Refusal behavior on risk-class prompts
6. Cost and latency under cron workloads

---

## Phased Rollout

```
Phase 0 ─── Docs & decisions locked
              Gate: domain contracts, env templates, brand rules complete
                │
Phase 1 ─── Draft-only service
              Gate: drafts produced with source refs; validation results
                    logged; zero public writes
                │
Phase 2 ─── Read-only integrations + reporting
              Gate: X analytics, site traffic; PerformanceSnapshots
                    generated; read tools cannot access write toolsets
                │
Phase 3 ─── Reviewed X publishing          ← current target
              Gate: policy engine blocks all 12 escalation classes;
                    human approval path working; reviewed wrapper returns
                    durable receipts; idempotency tested; account safety
                    diagnostics operational; pause command active;
                    ≥14 approved jobs in store; ≥1 escalation exercised;
                    Telegram approval smoke-tested
                │
Phase 4 ─── Low-risk autonomous publishing
              Gate: pause path operational; daily reports reconcile
                    receipts; routine engagement automated; bounded to
                    low-risk ContentJob kinds only
                │
Phase 5 ─── DEBATE + TROLL modes
              Gate: incident counters implemented; suspension thresholds
                    active; all TROLL output incident-reviewed
                │
Phase 6 ─── Dashboards + governance hardening
              Gate: scale and governance wrappers tested; channel
                    expansion evaluated
```

---

## Deployment

### Prerequisites

- EC2 instance (Amazon Linux 2023) — SSH restricted to operator IPs, not `0.0.0.0/0`
- Hermes Agent installed (`~/.hermes/`)
- Node.js for x-mcp build
- Python 3 + venv for twitter-mcp
- OpenRouter account with DeepSeek V4 Pro/Flash access
- Telegram bot created via @BotFather
- X operator account credentials

### Environment Variables

Copy `hermes/profiles/newshowbiz/.env.example` to `~/.hermes/profiles/newshowbiz/.env` and populate:

| Variable | Required | Notes |
|----------|----------|-------|
| `TWITTER_USERNAME` | Yes | X account handle |
| `TWITTER_PASSWORD` | Yes | X account password |
| `TWITTER_EMAIL` | Phase 3 | Required for email 2FA challenges during login |
| `TWITTER_PHONE` | Phase 3 | Required for SMS 2FA challenges during login |
| `X_AUTH_DIR` | Yes | `~/.hermes/profiles/newshowbiz/x-auth` |
| `OPENROUTER_API_KEY` | Yes | From openrouter.ai |
| `INGEST_ENABLED` | Yes | Set `false` to halt all X reads immediately |
| `TELEGRAM_BOT_TOKEN` | Phase 3 | From @BotFather |
| `TELEGRAM_CHAT_ID` | Phase 3 | From `GET /bot{TOKEN}/getUpdates` after messaging the bot |
| `HERMES_PROFILE` | Yes | `newshowbiz` |
| `LOG_LEVEL` | No | `INFO` |
| `LOG_DIR` | No | `~/.hermes/profiles/newshowbiz/logs` |

**Never commit `.env` to git. Never paste values into docs, prompts, or reports.**

### Setup

```bash
REPO=~/no-hay-banda
PROFILE=~/.hermes/profiles/newshowbiz

# Create profile structure
mkdir -p $PROFILE/{bin,docs/10-hermes,skills/templates/x}
mkdir -p $PROFILE/store/{jobs,review-queue,approved,rejected,escalations}
mkdir -p $PROFILE/{x-auth,logs}

# Copy config + env template (then edit .env with real values)
cp $REPO/hermes/profiles/newshowbiz/config.yaml $PROFILE/config.yaml
chmod 600 $PROFILE/config.yaml
cp $REPO/hermes/profiles/newshowbiz/.env.example $PROFILE/.env
chmod 600 $PROFILE/.env

# Copy docs, scripts, skills
cp $REPO/hermes/profiles/newshowbiz/docs/10-hermes/{SOUL.md,AGENTS.md} $PROFILE/docs/10-hermes/
cp $REPO/hermes/profiles/newshowbiz/bin/*.sh $PROFILE/bin/
chmod +x $PROFILE/bin/*.sh
cp -r $REPO/hermes/profiles/newshowbiz/skills/ $PROFILE/skills/

# Build x-mcp (local fork, never use npx)
cd ~/.hermes/mcp/x-mcp && npm install && npm run build

# Initialize review log
touch $PROFILE/store/review-log.jsonl

# Verify
hermes profile list
hermes -p newshowbiz -z "say hello"
```

### Running the Pipeline

```bash
# Convenience wrapper (logs all runs)
~/.hermes/profiles/newshowbiz/bin/run-pipeline.sh "research the top films in gender representation this week and draft original-discovery posts"

# One-shot query
hermes -p newshowbiz -z "what is in the review queue right now?"

# Check approved jobs
hermes -p newshowbiz -z "list all ContentJobs in store/approved/"
```

All runs log to `logs/pipeline-output.log`. Failures log to `logs/pipeline-failures.log` with exit code and prompt.

### Credential Rotation

Rotate when: entering Phase 3, suspected compromise, unexpected X account activity, anomalous billing.

```bash
# Always: generate new credentials BEFORE revoking old ones
# 1. Generate replacement credentials
# 2. hermes --stop
# 3. Update ~/.hermes/profiles/newshowbiz/.env
# 4. Update ~/.hermes/.env  (for GitHub PAT)
# 5. rm -f ~/.hermes/profiles/newshowbiz/x-auth/*  (clear X session)
# 6. hermes -p newshowbiz
# 7. hermes -p newshowbiz -z "say hello"  (verify)
# 8. Revoke old credentials
```

### Log Rotation

Managed by systemd. Timer fires Monday 02:00 UTC.

```bash
sudo cp hermes/systemd/newshowbiz-log-rotate.{service,timer} /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now newshowbiz-log-rotate.timer
```

---

## Metrics & What Success Looks Like

**North star:** Qualified traffic from X to New Showbiz product surfaces.

| Metric | What it tracks |
|--------|---------------|
| Link clicks | Clicks on newshow.biz URLs in posts |
| Landing sessions | Sessions arriving from X |
| Qualified rate | Landing sessions / link clicks (filters bots) |
| Signups | New accounts from X sessions |
| Watchlist adds | Product engagement attributed to X |
| Escalations / week | Risk triggers per window — rising means prompts need tuning |
| Blocked outputs / week | Policy blocks before review — model behavior drift detection |

**Three reporting cadences:** Daily (posts sent, escalations, MCP health), Weekly (program performance by template, attribution analysis), Monthly (overall trend, incident summary, roadmap).

---

## What This System Does Not Do

By design, permanently:

| What | Why |
|------|-----|
| Engagement actions (like, retweet, bookmark) | Excluded from all MCP toolsets |
| Autonomous DMs | No direct messages to users |
| Unsupervised writes in Phase 1 or 2 | Approval gate must be operational first |
| Fabricate sources | A blocked tool call produces `status: BLOCKED`, not invented data |
| Multi-platform publishing | X only; any new channel requires its own reviewed wrapper and phase gate |
| Endorsement or certification claims | Scores are AI analysis, not certified metrics |

---

## Repo Layout

```
no-hay-banda/
├── README.md                           ← this file
├── AUDIT_REPORT.md                     ← full system audit (2026-06-06)
│
├── hermes/
│   ├── README.md                       ← installation & quick-start guide
│   ├── global/
│   │   ├── SOUL.md                     ← base brand identity (every session)
│   │   ├── config.example.yaml         ← global Hermes config template
│   │   ├── .env.example                ← global env vars template
│   │   ├── prefill_messages.json       ← few-shot anti-fabrication priming
│   │   └── personas/                   ← 20 deployed agent persona files
│   │       ├── _shared-contract.md     ← binding output contract (all agents)
│   │       ├── _routing.md             ← TaskRouter routing table
│   │       ├── orchestrator.md
│   │       ├── movie-research-agent.md
│   │       ├── content-agent.md
│   │       ├── publish-agent.md
│   │       └── ...                     ← 16 more
│   ├── mcp/
│   │   └── x-mcp/
│   │       ├── PATCHES.md              ← documented EC2 login patches
│   │       └── src/behaviors/login.ts  ← patched Barresider login
│   ├── profiles/
│   │   └── newshowbiz/
│   │       ├── config.yaml             ← MCP servers, model, personalities
│   │       ├── .env.example            ← env vars template
│   │       ├── bin/
│   │       │   ├── run-pipeline.sh     ← pipeline entry point
│   │       │   └── rotate-logs.sh      ← log compression
│   │       ├── docs/10-hermes/
│   │       │   ├── SOUL.md             ← New Showbiz brand identity
│   │       │   └── AGENTS.md           ← operator contract
│   │       ├── skills/
│   │       │   ├── content-draft-from-movie-data/SKILL.md
│   │       │   ├── content-job-write/SKILL.md
│   │       │   ├── escalation-record-create/SKILL.md
│   │       │   ├── escalation-record-write/SKILL.md
│   │       │   ├── review-decision-record/SKILL.md
│   │       │   ├── telegram-await-approval/SKILL.md
│   │       │   ├── telegram-notify/SKILL.md
│   │       │   ├── x-publish-with-receipt/SKILL.md
│   │       │   └── templates/x/        ← 5 X post templates
│   │       └── store/                  ← runtime state (not in git)
│   └── systemd/
│       ├── newshowbiz-log-rotate.service
│       └── newshowbiz-log-rotate.timer
│
└── docs/
    ├── 00-vision/          ← whitepaper, operator overview
    ├── 10-hermes/          ← Hermes config docs, tier architecture
    ├── 20-system-spec/     ← architecture, domain contracts, implementation spec,
    │                          channel ops, personas, risk guardrails, tool boundaries
    ├── 30-operations/      ← deployment runbook, secrets policy, env setup,
    │                          tech stack, credential rotation, manual review
    ├── 40-agents/          ← full agent roster, orchestrator spec, skill library,
    │                          templates, subagent execution plan
    ├── 50-rollout/         ← phased checklist, acceptance criteria, risk register
    └── 60-models/          ← model selection rationale, model cards
```

---

## Quick Reference

```bash
# Start interactive Hermes session
hermes -p newshowbiz

# Run the pipeline (one-shot with logging)
~/.hermes/profiles/newshowbiz/bin/run-pipeline.sh "PROMPT"

# Check review queue
hermes -p newshowbiz -z "list everything in store/review-queue/"

# Emergency: disable all X reads immediately
# → set INGEST_ENABLED=false in ~/.hermes/profiles/newshowbiz/.env

# Emergency: disable write tool
# → set x-mcp-write: enabled: false in ~/.hermes/profiles/newshowbiz/config.yaml

# Rebuild x-mcp after patch changes
cd ~/.hermes/mcp/x-mcp && npm run build
```
