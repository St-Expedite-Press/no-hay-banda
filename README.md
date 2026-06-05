# New Showbiz Marketing Operator

**What this is:** A deployed autonomous marketing operator for [newshow.biz](https://newshow.biz) built on a heavily customized ("hacked") instance of Hermes Agent v0.15.1. The system uses a 20-agent, three-tier architecture to research films from the New Showbiz catalog, generate governed social content, route it through human review, and (in Phase 3) publish to X and Instagram. It is live on EC2 and has produced content. This repository is the documentation package, canonical spec, and operational reference for that system.

**Status:** Phase 1 operational. Telegram gateway live — operator is controllable from mobile. Two blockers remain before production run: X auth (`stex_press` rate-limited) and newshow.biz credentials (movie pages auth-gated; agent cannot pull scores independently). Anti-fabrication failure recorded in production (2026-06-05): agent produced a fabricated score when the source page was inaccessible.

---

## Live System at a Glance

| Property | Value |
|---|---|
| **Instance** | EC2 i-05451add3165b57ff (Amazon Linux 2023) |
| **Hermes version** | v0.15.1 (2026-05-29) |
| **Hermes root** | `~/.hermes/` (684 MB total) |
| **Profile** | `newshowbiz` — `hermes -p newshowbiz` |
| **Orchestrator model** | `deepseek/deepseek-v4-pro` via OpenRouter |
| **Subagent model** | `deepseek/deepseek-v4-flash` via OpenRouter |
| **Fallback model** | `anthropic/claude-sonnet-4` via OpenRouter |
| **Agent tiers** | Tier 0 (1) · Tier 1 (6) · Tier 2 (13) = 20 agents total |
| **Active MCP servers** | x-mcp-read (Barresider fork), twitter-mcp, playwright, github |
| **Telegram gateway** | `buchenwald_bettybot` — operator controllable from mobile via Telegram |
| **Custom skills** | 8 domain skills + 8-template library |
| **Phase 3 gate** | telegram-notify + telegram-await-approval skills built; activation checklist written |
| **Monitoring** | run-pipeline.sh failure logger + systemd weekly log-rotation timer |
| **Content pipeline** | Flat-file ContentJob store (Phase 1) |
| **Sessions recorded** | 16 |
| **Drafts in review queue** | 2 bootstrapped (pending replacement with verified-source drafts) |
| **Approved queue** | 0 — production run blocked pending newshow.biz credentials + X auth |
| **Phase** | Phase 1 (~80% complete — two blockers identified) |
| **Blockers** | (1) newshow.biz auth required for score scraping · (2) X `stex_press` rate-limited on login |

---

## Architecture Overview

```mermaid
flowchart TD
    A[hermes -p newshowbiz] --> B[SOUL.md\nSession Director — Tier 0]
    B --> C[Tier 1 Pipeline Agents\norchestrator · content-agent · publish-agent\nmetrics-agent · fetch-agent · project-manager]
    C --> D[Tier 2 Subagents — 13 leaf nodes\nresearcher · writer · editor · movie-research-agent\nescalation-agent · validate-agent · report-agent · and 6 others]
    D --> E[MCP Tools]
    E --> F[x-mcp-read\nBarresider fork\n~/.hermes/mcp/x-mcp/]
    E --> G[twitter-mcp\nmiles0sage\n~/.hermes/mcp/twitter-mcp/]
    E --> H[playwright\nnpx global]
    D --> I[Skills]
    I --> J[content-draft-from-movie-data\ncontent-job-write\nescalation-record-write\nreview-decision-record\nx-publish-with-receipt\nescalation-record-create]
    D --> K[ContentJob Store\n~/.hermes/profiles/newshowbiz/store/]
```

---

## The Hacked Hermes Instance

This is not a standard Hermes deployment. The following customizations have been made to a stock Hermes v0.15.1 installation. Together they constitute the "hacked instance" that powers this operator.

### 1. Three-Tier Agent Architecture

Stock Hermes has a flat persona system — one SOUL.md, one session, worker agents as needed. This deployment imposes a strict three-tier execution authority model enforced at both the prompt level (each agent file declares its tier) and the runtime level (`max_spawn_depth: 2` in global config):

| Tier | Role | Spawn Authority | Count |
|---|---|---|---|
| **0** | Session Director (SOUL.md) | Routes to Tier 1 and Tier 2 | 1 |
| **1** | Pipeline Agents | Can spawn Tier 2; cannot spawn other Tier 1 | 6 |
| **2** | Leaf Subagents | Cannot delegate further | 13 |

Each agent file opens with a tier declaration so the agent understands its authority limits before receiving any task.

### 2. Anti-Fabrication Enforcement

DeepSeek V4 Flash (the subagent model) has a documented failure mode: it may substitute plausible-sounding fabricated output when a tool call fails, rather than reporting the failure. Addressed at every layer:

- `~/.hermes/SOUL.md` — global operational rule against fabrication
- `~/.hermes/personas/_shared-contract.md` — Section 4: named DeepSeek failure mode, BLOCKED reporting rules
- All 19 agent persona files — explicit anti-fabrication clause
- `~/.hermes/prefill_messages.json` — few-shot priming demonstrating correct BLOCKED response

### 3. DeepSeek Model Split

- Orchestrator/session turns → `deepseek/deepseek-v4-pro`
- Delegated subagent calls → `deepseek/deepseek-v4-flash`
- Any failure → `anthropic/claude-sonnet-4` via OpenRouter fallback

### 4. Barresider Local Fork

Five patches applied to `src/behaviors/login.ts`, rebuilt to `dist/`:

| Bug | Fix |
|---|---|
| Stale login URL | `twitter.com` → `x.com/i/flow/login` with `domcontentloaded` + 4s hydration wait |
| Username selector drift | XPath `autocomplete="username"` → `input[name="username_or_email"]` |
| Next/Continue button | XPath exact text → `span:text("Next"), span:text("Continue")` first match |
| Auth dir not created | Added `fs.mkdirSync(authDir, { recursive: true })` before first write |
| stdio pollution | All `console.log` → `console.error` (stdout is the MCP JSON-RPC channel) |

Profile config uses `node /home/ec2-user/.hermes/mcp/x-mcp/dist/mcp.js` — npx never re-downloads the upstream unpatched package.

### 5. Profile Must Define Its Own Model Block

**Critical operational finding (2026-06-05):** Hermes oneshot mode (`hermes -p newshowbiz -z`) reads only the profile's `config.yaml` — it does not merge the global config. Without a `model` block in the profile config, oneshot silently returns an empty response and exits with code 1 (`hermes -z: no final response was produced`). Interactive mode is not affected because it merges both configs.

Fix applied: the profile config now includes:

```yaml
model:
  default: deepseek/deepseek-v4-pro
  provider: openrouter

delegation:
  model: deepseek/deepseek-v4-flash
  provider: openrouter
```

This is a Hermes architectural behavior, not a fixable bug. Any profile intended for oneshot use must be self-contained.

### 6. ContentJob Flat-File Store

Domain-specific store at `~/.hermes/profiles/newshowbiz/store/` with human-readable file layout, three write skills, and an append-only audit trail. Currently holds 2 bootstrapped draft ContentJobs pending human review.

### 7. Content Template Library

8 platform-specific templates at `~/.hermes/profiles/newshowbiz/skills/templates/` (5 X, 3 Instagram). Confirmed working: DeepSeek V4 Pro reads templates correctly, enforces Kakusu Protocol, respects character limits, and produces on-brand content.

### 8. Kakusu Protocol (Brand Rule)

All content agents operate under a brand constraint: frame representation analysis as cinematic analysis, not advocacy. Prohibited vocabulary across all templates and agent files: "woke," "DEI," "subversive," "progressive," "political activism." Confirmed working in live content run.

---

## Agent System

### Tier 0 — Session Director

**`~/.hermes/SOUL.md`** is loaded as the first stable prompt block in every session. Contains: three-tier architecture table, routing reference by task type, 7-step workflow, authorized pipeline list, anti-fabrication rules.

### Tier 1 — Pipeline Agents (6)

| Agent | Purpose | Authorized Subagents |
|---|---|---|
| `orchestrator` | Classifies ambiguous tasks; routes across domains | All Tier 2 |
| `content-agent` | Film research → draft → publish pipeline | validate, movie-research-agent, writer, editor, report, escalation |
| `publish-agent` | Validated publish with receipts | validate, report, escalation |
| `metrics-agent` | Data collection → analysis → report | analysis, report |
| `fetch-agent` | Source fetch → transform → report | validate, transform, report |
| `project-manager` | Multi-domain project decomposition | All Tier 2 |

### Tier 2 — Leaf Subagents (13)

analysis-agent · editor · engagement-agent · escalation-agent · execute-agent · interrogator · lint-agent · movie-research-agent · report-agent · researcher · transform-agent · validate-agent · writer

### Routing Registry

`~/.hermes/personas/_routing.md` — 20 canonical task types mapped to agents with tier, pipeline pattern, and authorized spawn paths. Callable spec: [docs/20-system-spec/task-router.md](docs/20-system-spec/task-router.md).

---

## MCP Stack

EC2 IP ranges return 403 from Cloudflare on direct HTTP to x.com. All X interaction uses Playwright browser automation.

| Server | Location | Status | Auth | Tools |
|---|---|---|---|---|
| `x-mcp-read` | `~/.hermes/mcp/x-mcp/` (Barresider fork) | **Enabled** | X credentials (pending login) | login, search_twitter, scrape_trending, scrape_timeline, scrape_posts, scrape_profile, scrape_comments (7 read tools) |
| `x-mcp-write` | `~/.hermes/mcp/x-mcp/` (Barresider fork) | **Disabled** (Phase 3 gate) | X credentials | tweet, thread, reply_to_post, quote_tweet |
| `twitter-mcp` | `~/.hermes/mcp/twitter-mcp/` (miles0sage) | **Enabled** | None | twitter_user (public profile only; other tools hit X login walls) |
| `social-mcp` | `~/.hermes/mcp/social_mcp/` (kitadmin01) | **Disabled** (reference) | Google Sheets | Contains engage_twitter mass-like tool — keep disabled |
| `playwright` | npx (global) | **Enabled** | None | Full browser automation fallback |
| `github` | npx (global) | **Enabled** | GitHub PAT | Repo operations |

Engagement tools (`like_post`, `retweet_post`, `bookmark_post`) are excluded from all server configs at the Hermes MCP filter level.

---

## Content Pipeline

```
newshow.biz movie page
        │
        ▼
movie-research-agent
(film data, scores, watch links, source refs)
        │
        ▼
content-draft-from-movie-data skill
  → select template (_index.md)
  → draft in film-critic register
  → enforce Kakusu Protocol
  → platform constraint check
  → risk classification
        │
        ▼
content-job-write skill
  → writes ContentJob JSON to store/jobs/{id}.json
  → copies to store/review-queue/{id}.json
  → agent outputs plain-text review summary
        │
        ▼
Human review (manual-review-procedure.md)
  approve / reject / revise {id}
        │
        ▼
review-decision-record skill
  → records decision
  → moves file (approved/ or rejected/)
  → appends store/review-log.jsonl
        │
        ▼ (Phase 3, x-mcp-write enabled)
x-publish-with-receipt skill
  → validates approved ContentJob
  → calls tweet/thread via x-mcp-write
  → writes durable receipt
```

**ContentJob ID format:** `{ISO-date}T{HHmmss}-{4-char-hex}` (e.g., `2026-06-05T140012-e98f`)

**Risk classification:** low / medium / high / blocked — required on every draft. Medium and above triggers escalation-agent review before moving to review-queue.

---

## Running It

```bash
# Interactive session — full agent system, all MCP servers, personality overlays
hermes -p newshowbiz

# Oneshot — single task, non-interactive, returns only the final response
hermes -p newshowbiz --yolo -z "your task here"

# Example: draft content for a specific film
hermes -p newshowbiz --yolo -z "Read the template at ~/.hermes/profiles/newshowbiz/skills/templates/x/original-discovery.md. Draft one X post for Moonlight (2016). Scores from newshow.biz: Overall 9.1, LGBTQ+ 9.8, Racial/Ethnic 9.5."

# Activate a personality overlay (interactive sessions only)
/personality x-editor
/personality audience-researcher
/personality brand-director
/personality product-explainer
/personality growth-analyst

# Check what's in the review queue
ls ~/.hermes/profiles/newshowbiz/store/review-queue/

# Read the audit log
cat ~/.hermes/profiles/newshowbiz/store/review-log.jsonl

# List skills
hermes -p newshowbiz skills list
```

**Authenticate x-mcp-read (one-time, still pending):**
```bash
hermes -p newshowbiz
# In session: invoke the login tool
# Verify: ls ~/.hermes/profiles/newshowbiz/x-auth/
```

**Rebuild Barresider after source edits:**
```bash
cd ~/.hermes/mcp/x-mcp
# edit src/behaviors/login.ts
npm run build
hermes gateway restart   # if gateway is running
```

---

## Directory Structure

### Documentation repo (`no-hay-banda/`)

```
docs/
  00-vision/
    operator-overview.md              ← Product thesis and live system assessment
    whitepaper.md                     ← Strategic argument for a governed operator
  10-hermes/
    hermes-instance.md                ← Full technical reference for the hacked instance ★
    hermes-profile-setup.md           ← Setup and replication guide (Barresider fork)
    hermes-config.example.yaml        ← Redacted config template
    HERMES_PROMPT_ARCHITECTURE.md     ← How Hermes assembles prompts
    SOUL.md                           ← Profile-scoped SOUL.md source
    AGENTS.md                         ← Profile-scoped AGENTS.md source
    tier-architecture.md              ← Three-tier model documentation
  20-system-spec/
    domain-contracts.md               ← ContentJob, EscalationRecord, PerformanceSnapshot schemas
    persona-registry.md               ← 7 personalities → agents/toolsets/phase gates
    task-router.md                    ← Callable routing spec (wraps _routing.md)
    implementation-spec.md            ← Full build contract
    architecture.md                   ← Runtime and domain architecture
  30-operations/
    env-setup.md                      ← Environment variables (no values)
    manual-review-procedure.md        ← Human review SOP ★
    x-mcp-test-log.md                 ← Per-tool results, patches, incidents
    secrets-policy.md                 ← What never gets committed
  40-agents/source/
    _index.md                         ← Agent source index
    _routing.md                       ← Task-to-agent routing registry
    _shared-contract.md               ← Governing contract for all agents
    roster/                           ← 28 agent spec files
    skills/
      _index.md                       ← Skill registry (6 New Showbiz + vault skills)
      content-draft-from-movie-data.md
      content-job-write.md
      escalation-record-write.md
      review-decision-record.md
      x-publish-with-receipt.md
      escalation-record-create.md
    templates/                        ← Mirror of live template library
      _index.md                       ← Template selection logic
      x/                              ← 5 X templates
      instagram/                      ← 3 Instagram templates
  50-rollout/
    phased-checklist.md               ← Phase gates and exit criteria
    acceptance-criteria.md            ← Phase-specific pass/fail criteria
    risk-register.md                  ← Known risks and mitigations
```

### Live Hermes system (`~/.hermes/`)

```
~/.hermes/
  config.yaml                         ← Global Hermes config (v25 format)
  SOUL.md                             ← Session Director — loaded every session
  prefill_messages.json               ← Delegation cycle priming (4 messages)
  state.db                            ← 15 MB SQLite (Hermes internal state)
  personas/                           ← 21 files (19 agents + 2 contracts)
    _shared-contract.md               ← Governing contract for all agents
    _routing.md                       ← Task-to-agent routing registry
    orchestrator.md / content-agent.md / publish-agent.md   ← Tier 1
    fetch-agent.md / metrics-agent.md / project-manager.md  ← Tier 1
    [13 Tier 2 agent files]
  mcp/
    x-mcp/                            ← Barresider local fork (121 MB, patched)
      src/behaviors/login.ts          ← Patched source (5 fixes)
      dist/behaviors/login.js         ← Compiled output
      PATCHES.md                      ← Patch documentation
    twitter-mcp/                      ← miles0sage fork (207 MB)
      venv/                           ← Python 3.11 virtualenv
      server.py
    social_mcp/                       ← kitadmin01 fork (293 MB, disabled)
  profiles/newshowbiz/
    config.yaml                       ← Profile MCP, toolsets, personalities, model block
    SOUL.md                           ← Marketing operator identity
    .env                              ← TWITTER_USERNAME, TWITTER_PASSWORD, OPENROUTER_API_KEY
    x-auth/                           ← Barresider session (twitter.json after login — PENDING)
    store/
      jobs/                           ← 2 ContentJob JSON files (bootstrapped drafts)
      escalations/                    ← EscalationRecord JSON files (empty)
      review-queue/                   ← 2 drafts pending human review
      approved/                       ← Empty — no decisions made yet
      rejected/                       ← Empty — no decisions made yet
      review-log.jsonl                ← Append-only audit trail (empty)
    skills/
      content-draft-from-movie-data/SKILL.md
      content-job-write/SKILL.md
      escalation-record-write/SKILL.md
      review-decision-record/SKILL.md
      x-publish-with-receipt/SKILL.md
      escalation-record-create/SKILL.md
      templates/
        _index.md                     ← Template selection logic
        x/original-discovery.md · thread-breakdown.md · comparison-post.md
        x/reactive-hook.md · utility-post.md
        instagram/caption-standard.md · carousel-intro.md · caption-utility.md
    sessions/                         ← 16 recorded sessions
    memories/                         ← Agent memory store (empty)
    logs/
      agent.log                       ← Session logs
      mcp-stderr.log                  ← MCP server startup logs
```

---

## Current Status — Phase 1

### What is operational

| Capability | State |
|---|---|
| Hermes runtime | Live — v0.15.1, DeepSeek V4 Pro/Flash |
| Three-tier agent system | Live — 29 agents, tier declarations and contracts in place |
| Anti-fabrication enforcement | Live — present at every layer |
| Profile model configuration | Live — model block in profile config enables oneshot mode |
| Oneshot mode | Live — `hermes -p newshowbiz --yolo -z "..."` confirmed working |
| Content pipeline (template → draft) | **Confirmed working** — DeepSeek reads templates, applies Kakusu Protocol, counts characters |
| `twitter-mcp` public lookups | Live — `twitter_user` confirmed working |
| Barresider local fork | Built — 5 patches applied, compiled, profile wired |
| 7 personality overlays | Live — brand-director, audience-researcher, product-explainer, x-editor, instagram-editor, provocateur, growth-analyst |
| Template library | Live — 5 X templates + 3 Instagram templates |
| ContentJob flat-file store | Live — 2 bootstrapped drafts in review queue |
| Manual review workflow | Live — procedure doc + review-decision-record skill |
| VS Code server cleanup | Live — systemd timer, weekly Sunday midnight |

### What is pending

| Capability | Blocker |
|---|---|
| `x-mcp-read` authenticated search | Login tool call not yet executed — one `hermes -p newshowbiz` session, invoke login tool |
| Production content run | Requires: (1) human decisions on campaign priorities, cadence, CTA; (2) research 3–5 films from live newshow.biz data via movie-research-agent |
| Human review decisions | 2 drafts sitting in review-queue since 2026-06-05 |
| 7-day approved draft queue | Follows production content run |
| Phase 1 exit report | Follows approved queue |

### What is intentionally disabled

| Capability | Reason |
|---|---|
| `x-mcp-write` (tweet/thread) | Phase 3 gate — requires ContentJob store, policy engine, human approval path, receipt store |
| `social-mcp` | Contains mass-engagement tools (`engage_twitter`) — permanently excluded |
| Engagement tools (like/retweet/bookmark) | Filtered at Hermes MCP level across all servers |
| Autonomous publishing | Phase 3 — not before full policy engine and Telegram oversight |
| Instagram writes | Phase 4 — channel contract not yet written |

### Phase map

| Phase | Status | Exit Criteria |
|---|---|---|
| **Phase 0** — Documentation | Complete | Spec package published to GitHub |
| **Phase 1** — Governed draft production | ~90% complete | 7-day approved draft queue, X auth live, review workflow exercised |
| **Phase 2** — Scheduled content | Not started | Cron pipeline, ContentJob → EngagementJob flow |
| **Phase 3** — Supervised publish | Not started | `x-mcp-write` enabled, policy engine, receipt store, Telegram oversight |
| **Phase 4** — Analytics loop | Not started | UTM attribution, PerformanceSnapshot, campaign optimization |
| **Phase 5** — Instagram | Not started | Channel contract, caption pipeline, approval flow |
| **Phase 6** — Full autonomy | Not started | All prior phases stable; Telegram oversight required |

---

## Document Map

| Need | Document |
|---|---|
| Full hacked instance reference | [docs/10-hermes/hermes-instance.md](docs/10-hermes/hermes-instance.md) ★ |
| Setup on a new machine | [docs/10-hermes/hermes-profile-setup.md](docs/10-hermes/hermes-profile-setup.md) |
| How Hermes assembles prompts | [docs/10-hermes/HERMES_PROMPT_ARCHITECTURE.md](docs/10-hermes/HERMES_PROMPT_ARCHITECTURE.md) |
| Product vision and assessment | [docs/00-vision/operator-overview.md](docs/00-vision/operator-overview.md) |
| Domain record schemas | [docs/20-system-spec/domain-contracts.md](docs/20-system-spec/domain-contracts.md) |
| Persona → agent → toolset mapping | [docs/20-system-spec/persona-registry.md](docs/20-system-spec/persona-registry.md) |
| Task routing spec | [docs/20-system-spec/task-router.md](docs/20-system-spec/task-router.md) |
| Human review procedure | [docs/30-operations/manual-review-procedure.md](docs/30-operations/manual-review-procedure.md) |
| X MCP test results and patches | [docs/30-operations/x-mcp-test-log.md](docs/30-operations/x-mcp-test-log.md) |
| Environment variables | [docs/30-operations/env-setup.md](docs/30-operations/env-setup.md) |
| Agent source specs | [docs/40-agents/source/_index.md](docs/40-agents/source/_index.md) |
| Skill registry | [docs/40-agents/source/skills/_index.md](docs/40-agents/source/skills/_index.md) |
| Template library | [docs/40-agents/source/templates/_index.md](docs/40-agents/source/templates/_index.md) |
| Phase gates and exit criteria | [docs/50-rollout/phased-checklist.md](docs/50-rollout/phased-checklist.md) |
| Risk register | [docs/50-rollout/risk-register.md](docs/50-rollout/risk-register.md) |

---

## Security Posture

| Rule | Detail |
|---|---|
| Never commit `.env` | Profile `.env` has X credentials and OPENROUTER_API_KEY |
| Never commit global `config.yaml` | Contains GitHub PAT in plaintext (github MCP server entry) |
| Never commit `x-auth/` | Will contain live X session cookies after login |
| `x-mcp-write` disabled | Will not be enabled before Phase 3 acceptance criteria pass |
| Engagement tools excluded | Filtered at MCP config level — not accessible to any agent |
| GitHub PAT | Stored as `GITHUB_PAT_WRITE` in `~/.hermes/.env`; owned by `CSandbatch` (St-Expedite-Press org) |
| Secrets policy | Full policy: [docs/30-operations/secrets-policy.md](docs/30-operations/secrets-policy.md) |

---

*Hermes v0.15.1 · DeepSeek V4 Pro/Flash via OpenRouter · EC2 i-05451add3165b57ff · Phase 1 operational · 2026-06-05*
