# Hermes Instance — EC2 i-05451add3165b57ff

Canonical technical reference for the fully customized Hermes Agent deployment powering the New Showbiz marketing operator. Documents the live state as of 2026-06-05. Not an overview. Everything here is precise and current.

---

## 1. Installation

| Property | Value |
|---|---|
| Instance | `i-05451add3165b57ff` |
| Version | `v0.15.1 (2026.5.29)` |
| Python | `3.11.15` |
| Installation root | `/usr/local/lib/hermes-agent` |
| User config root | `/home/ec2-user/.hermes` |
| Total size | ~684 MB |
| Update cadence | Manual — run `hermes update`; do not auto-update |

Updates are manual because config format changes between versions (current config version: v25). Always review the changelog before applying an update.

---

## 2. Global Configuration (`~/.hermes/config.yaml`)

Global config applies to every session regardless of profile. Profile configs (`~/.hermes/profiles/newshowbiz/config.yaml`) layer on top and override where specified.

### Core settings

| Setting | Value | Notes |
|---|---|---|
| Primary model | `deepseek/deepseek-v4-pro` | Via OpenRouter |
| Delegation model | `deepseek/deepseek-v4-flash` | Subagent calls only |
| Fallback model | `anthropic/claude-sonnet-4` | Via OpenRouter; activates on DeepSeek failure |
| Provider | OpenRouter | Auth: `OPENROUTER_API_KEY` |
| Max spawn depth | `2` | Tier 0 → Tier 1 → Tier 2 |
| Max concurrent children | `3` | Parallel subagents per session |
| Max agent turns | `90` | |
| Prefill messages | `~/.hermes/prefill_messages.json` | Full delegation cycle example (see §5.3) |
| Memory | Enabled | 2200 character limit |
| Compression | Enabled | Threshold 0.5, target ratio 0.2 |
| Prompt cache TTL | 5 minutes | |
| Terminal backend | `local` | |
| Redact secrets | `true` | |
| Tirith | Enabled | Policy enforcement layer |

### Global MCP servers

Available in all sessions regardless of profile.

| Server | Command | Status |
|---|---|---|
| `playwright` | `npx @playwright/mcp` | Enabled — browser automation fallback |
| `github` | `npx @modelcontextprotocol/server-github` | Enabled — GitHub integration |

---

## 3. Anti-Fabrication Configuration

DeepSeek V4 Flash has a documented failure mode: when a tool call fails, it may substitute plausible-looking fabricated output rather than reporting the blocker. This is not a general hallucination problem — it is specifically triggered by tool/API failures where the model fills the gap rather than stopping.

This deployment addresses the failure mode at every layer of the prompt stack:

| Layer | Mechanism |
|---|---|
| `~/.hermes/SOUL.md` | `Anti-fabrication (critical): You are running on DeepSeek...` — operational rule in the global persona |
| `~/.hermes/personas/_shared-contract.md` | Section 4: named DeepSeek failure mode; explicit BLOCKED rules |
| All 28 agent persona files | Per-agent guardrail: `If a tool call, file read, or API call fails, report the blocker...` |
| `~/.hermes/prefill_messages.json` | Few-shot priming demonstrating correct BLOCKED reporting behavior |

The correct behavior when a tool fails: return `BLOCKED` with the error message, the step that failed, and what is needed to unblock. Never infer, estimate, or substitute.

---

## 4. Global Persona System

### SOUL.md — Session Director

**File:** `~/.hermes/SOUL.md`

Loads as the first stable prompt block in every session. Defines the Session Director — Tier 0 of the three-tier agent architecture. Content includes:

- Tier architecture table (Tier 0/1/2, roles, spawn authority)
- Quick routing reference: task_type → agent
- 7-step workflow (receive → classify → route → monitor → consolidate → gate → deliver)
- Authorized pipelines
- Operational rules including anti-fabrication

### `~/.hermes/personas/` directory

30 files total: 28 agent specs + 2 contract documents.

#### Contract documents

| File | Purpose |
|---|---|
| `_shared-contract.md` | 10-section governing contract for all agents: tier declaration, minimum context, anti-fabrication, output format, closing loops |
| `_routing.md` | Canonical task-to-agent routing registry: 27 task types, 7 Tier 1 agents, 21 Tier 2 agents |

#### Tier 1 — Pipeline agents (7)

| Agent | File | Purpose |
|---|---|---|
| `orchestrator` | `orchestrator.md` | Classifies ambiguous tasks; routes across multiple domains |
| `content-agent` | `content-agent.md` | Film research → draft → publish pipeline coordinator |
| `publish-agent` | `publish-agent.md` | Validated publish actions with receipts |
| `metrics-agent` | `metrics-agent.md` | Data collection → analysis → report pipeline |
| `fetch-agent` | `fetch-agent.md` | Source fetch → transform → report pipeline |
| `distill-agent` | `distill-agent.md` | Skill extraction and improvement loop |
| `project-manager` | `project-manager.md` | Multi-domain project decomposition; routes to all Tier 2 |

#### Tier 2 — Leaf subagents (21)

**Intake:**

| Agent | File | Purpose |
|---|---|---|
| `interrogator` | `interrogator.md` | Task clarification and structured brief production |

**Research and evidence:**

| Agent | File | Purpose |
|---|---|---|
| `researcher` | `researcher.md` | Multi-source web research, fact-checking, literature review |
| `movie-research-agent` | `movie-research-agent.md` | Film evidence: production context, scores, representational claims |

**Content and voice:**

| Agent | File | Purpose |
|---|---|---|
| `compose` | `composer.md` | Literary writing, criticism, essays (C. Composer voice) |
| `writer` | `writer.md` | General prose, documentation, marketing copy, scripts |
| `composer-translator` | `composer-translator.md` | Golden Age Castilian translation in Composer register |
| `editor` | `editor.md` | Editing, proofreading, tone calibration, quality gating |

**Design:**

| Agent | File | Purpose |
|---|---|---|
| `designer` | `designer.md` | Visual design, diagrams, HTML/CSS/SVG, layout |

**Analysis and data:**

| Agent | File | Purpose |
|---|---|---|
| `analysis-agent` | `analysis-agent.md` | Computation over normalized data, rankings, summaries |
| `query-agent` | `query-agent.md` | Evidence-based vault lookups |
| `diff-agent` | `diff-agent.md` | Snapshot comparison, change detection |
| `validate-agent` | `validate-agent.md` | Pre-fetch access checks, schema gating |
| `transform-agent` | `transform-agent.md` | Normalization of captured material |

**Operations:**

| Agent | File | Purpose |
|---|---|---|
| `lint-agent` | `lint-agent.md` | Vault/record health checks, structural repair |
| `python-standards-agent` | `python-standards-agent.md` | Python code standards audit |
| `execute-agent` | `execute-agent.md` | Run known procedures from the live skill registry |

**Content operations:**

| Agent | File | Purpose |
|---|---|---|
| `engagement-agent` | `engagement-agent.md` | Inbox triage, mention classification, escalation routing |
| `escalation-agent` | `escalation-agent.md` | Risk incident logging, human routing, HOLD status |

**System improvement:**

| Agent | File | Purpose |
|---|---|---|
| `skill-builder` | `skill-builder.md` | Construct skill files from distilled proposals |
| `report-agent` | `report-agent.md` | Format and package specialist output for delivery |

**Knowledge management:**

| Agent | File | Purpose |
|---|---|---|
| `librarian` | `librarian.md` | Obsidian vault organization, MOCs, PKM |

---

## 5. Custom Modifications ("The Hacks")

This section documents everything that differs from a stock Hermes installation. Stock Hermes is a general-purpose agent shell. Everything here is purpose-built for the New Showbiz marketing operator.

### 5.1 Three-tier agent architecture

**Stock Hermes** uses a flat persona system — a single persona file per session, no delegation hierarchy.

**This deployment** defines a custom three-tier spawn authority model enforced at both the prompt and runtime levels:

| Tier | Identity | Spawn authority |
|---|---|---|
| **0** | Session Director (`SOUL.md`) | Routes to Tier 1 and Tier 2 directly |
| **1** | Pipeline agents (7) | Can spawn Tier 2 via `delegate_task`; cannot spawn other Tier 1 |
| **2** | Leaf subagents (21) | Cannot delegate further |

Runtime enforcement: `max_spawn_depth: 2` in the global delegation config. If a Tier 2 agent attempts `delegate_task`, the runtime rejects it before the call executes.

Prompt enforcement: every agent file declares its tier at the top:

```
**Tier: 1** — You CAN spawn Tier 2 subagents via delegate_task. You CANNOT spawn other Tier 1 agents.
```

### 5.2 Anti-fabrication enforcement at every layer

**Stock Hermes** has no model-family-specific fabrication guidance.

**This deployment** adds explicit DeepSeek V4 Flash fabrication guards at four layers (see §3 for full detail). The critical rule in every agent file:

```
If a tool call, file read, or API call fails, report the blocker with the exact error.
Do NOT infer, estimate, or substitute plausible-looking output.
Return status: BLOCKED.
```

### 5.3 Prefill messages

**Stock Hermes** has no prefill configuration.

**This deployment** sets `prefill_messages_file: '/home/ec2-user/.hermes/prefill_messages.json'` in the global config. This file is loaded in every session as few-shot priming before any user message.

Content: a complete Tier 0 → Tier 1 → Tier 2 delegation cycle for a film research + X content task. Demonstrates:
- SOUL.md routing a `generate_content` task to `content-agent`
- `content-agent` spawning `movie-research-agent` and `writer`
- A tool failure returning `BLOCKED` (not fabricated output)
- Final `COMPLETE` with receipt

### 5.4 DeepSeek model split

**Stock Hermes** uses one model for all calls in a session.

**This deployment** routes by call type:

| Call type | Model | Rationale |
|---|---|---|
| Orchestrator / main session | `deepseek/deepseek-v4-pro` | Higher capability for routing and reasoning |
| Delegated subagent calls | `deepseek/deepseek-v4-flash` | Lower cost, faster turnaround for atomic tasks |
| Fallback (DeepSeek unavailable) | `anthropic/claude-sonnet-4` | Via OpenRouter; automatic on provider failure |

### 5.5 Barresider/x-mcp local fork

**Stock Hermes** would use `npx @barresider/x-mcp` — re-downloading the unpatched package on each gateway start.

**This deployment** maintains a patched local fork at `~/.hermes/mcp/x-mcp/`. The profile config points directly to the local build:

```yaml
x-mcp-read:
  command: node
  args:
    - /home/ec2-user/.hermes/mcp/x-mcp/dist/mcp.js
```

This means npx never runs for x-mcp. The patches are durable in the TypeScript source.

**5 patches applied to `src/behaviors/login.ts`:**

| Bug | Fix |
|---|---|
| Login URL | `twitter.com/i/flow/login` → `x.com/i/flow/login` with `domcontentloaded` + 4s wait |
| Username selector | `autocomplete="username"` XPath → `input[name="username_or_email"]` |
| Next/Continue button | `//span[text()='Next']` → `span:text("Next"), span:text("Continue")` first match |
| Auth dir creation | No mkdir → `fs.mkdirSync(authDir, { recursive: true })` before first write |
| stdio pollution | `console.log` → `console.error` (stdout is the MCP JSON-RPC channel) |

Fork version: `1.0.1 (patched)`. Patch documentation: `~/.hermes/mcp/x-mcp/PATCHES.md`.

To rebuild after source edits:

```bash
cd ~/.hermes/mcp/x-mcp
# edit src/behaviors/login.ts
npm run build
hermes gateway restart
```

### 5.6 Domain control plane (Phase 1 flat-file store)

**Stock Hermes** has no content persistence beyond session memory.

**This deployment** adds a structured flat-file store at `~/.hermes/profiles/newshowbiz/store/`:

| Path | Purpose |
|---|---|
| `store/jobs/` | ContentJob JSON files (one per content item) |
| `store/escalations/` | EscalationRecord JSON files |
| `store/review-queue/` | Drafts pending human review |
| `store/approved/` | Approved ContentJobs, ready for publish |
| `store/rejected/` | Rejected ContentJobs with reason |
| `store/review-log.jsonl` | Audit trail — one JSON line per review decision |

Three write skills implement the store protocol:

| Skill | Purpose |
|---|---|
| `content-job-write` | Persist a ContentJob to `store/jobs/` |
| `escalation-record-write` | Write an EscalationRecord when a risk trigger fires |
| `review-decision-record` | Record human approve/reject/revise; move file to appropriate directory; append to review-log |

### 5.7 Content template library

**Stock Hermes** has no platform-specific content templates.

**This deployment** adds a template library at `~/.hermes/profiles/newshowbiz/skills/templates/`:

**X templates (5):**

| Template | File | Purpose |
|---|---|---|
| `original-discovery` | `x/original-discovery.md` | Introduce a film audiences haven't seen |
| `thread-breakdown` | `x/thread-breakdown.md` | Multi-tweet analysis thread |
| `comparison-post` | `x/comparison-post.md` | Side-by-side film or theme comparison |
| `reactive-hook` | `x/reactive-hook.md` | Respond to a trending topic with film angle |
| `utility-post` | `x/utility-post.md` | Actionable list or resource post |

**Instagram templates (3):**

| Template | File | Purpose |
|---|---|---|
| `caption-standard` | `instagram/caption-standard.md` | Standard single-image caption |
| `carousel-intro` | `instagram/carousel-intro.md` | Opening slide copy for carousels |
| `caption-utility` | `instagram/caption-utility.md` | List/resource captions |

All templates include Kakusu Protocol compliance requirements and platform-specific constraints (280-char for X, hashtag discipline for Instagram). The `content-draft-from-movie-data` skill was updated to select a template before drafting — template choice is part of the output spec.

---

## 6. The `newshowbiz` Profile

Profiles in Hermes isolate config, memory, sessions, secrets, and gateway state. The `newshowbiz` profile is the full runtime for the New Showbiz marketing operator. Nothing in this profile bleeds into global sessions.

**Launch command:**

```bash
hermes -p newshowbiz
```

**Profile root:** `~/.hermes/profiles/newshowbiz/`

### Profile directory structure

| Path | Purpose |
|---|---|
| `config.yaml` | Profile MCP servers, toolsets, personalities |
| `SOUL.md` | Marketing operator identity (New Showbiz brand, Kakusu Protocol, escalation triggers) |
| `docs/10-hermes/AGENTS.md` | Project rules for agents operating in this profile |
| `docs/10-hermes/SOUL.md` | Profile-scoped SOUL.md source (canonical copy lives here) |
| `.env` | Credentials: `TWITTER_USERNAME`, `TWITTER_PASSWORD`, `X_AUTH_DIR`, `OPENROUTER_API_KEY` |
| `x-auth/` | Barresider session storage (`twitter.json` after successful login) |
| `store/` | Phase 1 ContentJob flat-file store root |
| `store/jobs/` | ContentJob JSON files |
| `store/escalations/` | EscalationRecord JSON files |
| `store/review-queue/` | Drafts pending human review |
| `store/approved/` | Approved ContentJobs |
| `store/rejected/` | Rejected ContentJobs |
| `store/review-log.jsonl` | Audit trail (one JSON line per decision) |
| `skills/` | Global bundled skills + 6 custom New Showbiz skills + template library |
| `sessions/` | Conversation session history (16 sessions) |
| `memories/` | Agent memory store (currently empty) |
| `cron/` | Scheduled job state |
| `logs/` | Session and MCP logs |

### Profile MCP servers

| Server | Command | Status | Tools |
|---|---|---|---|
| `x-mcp-read` | `node /home/ec2-user/.hermes/mcp/x-mcp/dist/mcp.js` | Enabled | 8 read tools: `login`, `search_twitter`, `get_twitter_profile`, `get_tweet`, `get_user_tweets`, `get_thread`, `scrape_twitter_page`, `get_trending` |
| `x-mcp-write` | `node /home/ec2-user/.hermes/mcp/x-mcp/dist/mcp.js` | **Disabled (Phase 3)** | `tweet`, `thread`, `reply_to_post`, `quote_tweet` — enable only after Phase 3 pipeline is complete |
| `twitter-mcp` | `venv/bin/python3 server.py` | Enabled | Public profile lookup only — write tools excluded at Hermes filter level |
| `social-mcp` | — | **Disabled** | Reference only — `engage_twitter` permanently excluded |

**Active toolsets:** `hermes-cli`, `mcp-x-mcp-read`, `mcp-twitter-mcp`

### Profile model configuration

**Critical:** The profile config must define its own `model` block. Hermes oneshot mode (`-z`) reads only the profile's `config.yaml` — it does not merge the global config. Without a local model definition, oneshot silently returns an empty response and exits with code 1.

```yaml
model:
  default: deepseek/deepseek-v4-pro
  provider: openrouter

delegation:
  model: deepseek/deepseek-v4-flash
  provider: openrouter
```

Interactive mode (`hermes -p newshowbiz`) is not affected — it merges global config. Only oneshot mode hits this path. This is a Hermes architectural behavior, not a bug that will be fixed upstream.

### Profile personalities

Personality overlays are prompt conveniences, not public personas. All public output remains the single New Showbiz brand voice. Activate with `/personality <key>` in any `hermes -p newshowbiz` session.

| Key | Role | Phase |
|---|---|---|
| `brand-director` | Message hierarchy, CTA discipline, one-voice enforcement | Phase 1 |
| `audience-researcher` | Demand discovery, trend signals, source selection | Phase 1 |
| `product-explainer` | Catalog structure, score explanation, feature education | Phase 1 |
| `x-editor` | X post generation, 280-char discipline, thread architecture | Phase 1 |
| `instagram-editor` | Instagram caption and carousel copy | Phase 2 |
| `provocateur` | TROLL mode — X only, fact-bound, incident-reviewed | Phase 5 |
| `growth-analyst` | Qualified traffic, signup, donation, trust measurement | Phase 1 |

---

## 7. MCP Server Architecture

EC2 IP ranges return 403 from Cloudflare on direct HTTP requests to x.com. All X interaction must use Playwright browser automation (via x-mcp or the global playwright server). Raw HTTP/API calls to X will fail from this instance.

### All MCP servers on this instance

| Server | Installed At | Version | Status | Auth Required |
|---|---|---|---|---|
| x-mcp (Barresider fork) | `~/.hermes/mcp/x-mcp/` | `1.0.1 (patched)` | Read enabled; write disabled (Phase 3) | Yes — X credentials from profile `.env` |
| twitter-mcp (miles0sage) | `~/.hermes/mcp/twitter-mcp/` | — | Enabled (public lookup only) | No |
| social_mcp (kitadmin01) | `~/.hermes/mcp/social_mcp/` | — | Disabled | Requires Google Sheets |
| playwright (microsoft) | `npx` (global) | — | Enabled | No |
| github (MCP) | `npx` (global) | — | Enabled | GitHub PAT in env |

### x-mcp tool inventory

The `x-mcp-read` server exposes 8 tools. The `x-mcp-write` server exposes 4 tools (all disabled in Phase 1/2).

**Read tools (enabled):**

| Tool | Purpose |
|---|---|
| `login` | Authenticate and save session to `x-auth/twitter.json` |
| `search_twitter` | Search tweets by query |
| `get_twitter_profile` | Get public profile data |
| `get_tweet` | Fetch a single tweet by ID |
| `get_user_tweets` | Get recent tweets for a user |
| `get_thread` | Fetch a full conversation thread |
| `scrape_twitter_page` | Playwright-rendered page scrape |
| `get_trending` | Current trending topics |

**Write tools (disabled — Phase 3):**

| Tool | Purpose |
|---|---|
| `tweet` | Post a new tweet |
| `thread` | Post a multi-tweet thread |
| `reply_to_post` | Reply to an existing tweet |
| `quote_tweet` | Quote-tweet with commentary |

---

## 8. Skills System

The `newshowbiz` profile has access to 109 skills across 31 categories. Most are bundled Hermes hub skills. The 6 custom New Showbiz skills are the operational core of the content pipeline.

### Custom New Showbiz skills

| Skill | Type | Purpose | Status |
|---|---|---|---|
| `content-draft-from-movie-data` | Custom | Turn movie page data into platform-ready draft variants; selects template before drafting | validated |
| `content-job-write` | Custom | Persist a ContentJob to the flat-file store (`store/jobs/`) | draft |
| `escalation-record-write` | Custom | Write an EscalationRecord when a risk trigger fires | draft |
| `review-decision-record` | Custom | Record human approve/reject/revise; move file to correct directory; append to `review-log.jsonl` | draft |
| `x-publish-with-receipt` | Custom | Publish an approved ContentJob via the reviewed publish wrapper (Phase 3) | validated |
| `escalation-record-create` | Custom | Create an EscalationRecord from a ContentJob or EngagementJob | validated |
| `templates/x/*` | Custom | 5 X content templates with Kakusu Protocol compliance and platform constraints | active |
| `templates/instagram/*` | Custom | 3 Instagram content templates | active |

### Bundled skill categories (Hermes hub)

Not New Showbiz specific. Available to all agents in this profile:

`apple` · `autonomous-ai-agents` · `creative` · `data-science` · `devops` · `email` · `gaming` · `github` · `media` · `mlops` · `note-taking` · `productivity` · `red-teaming` · `research` · `smart-home` · `social-media` · `software-development`

---

## 9. Session Commands

```bash
# Start a newshowbiz operator session (interactive)
hermes -p newshowbiz

# Run a single task and return only the final response (oneshot mode)
hermes -p newshowbiz --yolo -z "your task here"

# Example: draft content from movie data
hermes -p newshowbiz --yolo -z "Draft an X post for [film] using the template at ~/.hermes/profiles/newshowbiz/skills/templates/x/original-discovery.md"

# Start a standard global session (no profile)
hermes

# Check Hermes version
hermes --version

# List skills available in the newshowbiz profile
hermes -p newshowbiz skills list

# List saved sessions
hermes -p newshowbiz sessions list

# Check review queue state
ls ~/.hermes/profiles/newshowbiz/store/review-queue/

# Read the audit trail
cat ~/.hermes/profiles/newshowbiz/store/review-log.jsonl

# Verify x-auth session exists
ls ~/.hermes/profiles/newshowbiz/x-auth/
```

**Oneshot mode note:** `--yolo` auto-approves all tool calls and shell hooks (required for non-interactive use). Without it, file reads and skill invocations stall waiting for approval. Oneshot requires the profile config to have a `model` block — see Profile model configuration above.

---

## 10. Maintenance

### Rebuild Barresider after source edits

```bash
cd ~/.hermes/mcp/x-mcp
# edit src/behaviors/login.ts or other source files
npm run build
# restart gateway if it is already running
hermes gateway restart
```

Full patch documentation: `~/.hermes/mcp/x-mcp/PATCHES.md`

### Update Hermes

```bash
hermes update
# Review changelog before applying — config format may change between versions
# Current config version: v25
```

Do not auto-update. Config format changes are not always backward compatible. After any update, verify `~/.hermes/config.yaml` loads without errors before running a profile session.

### X authentication (retry after rate limit or new session)

```bash
hermes -p newshowbiz
# In session: invoke the login tool
# Session is saved to ~/.hermes/profiles/newshowbiz/x-auth/twitter.json
# Subsequent sessions load from this file without re-authenticating

# Verify session file exists after login:
ls ~/.hermes/profiles/newshowbiz/x-auth/
```

**Rate limit note:** X may apply temporary login restrictions if login is attempted repeatedly from a new IP in a short window. If login fails, wait several hours and retry once. Do not loop on login. See `docs/30-operations/x-mcp-test-log.md` for the incident record.

### Disk cleanup (VS Code server versions)

VS Code server versions accumulate on EC2 and consume significant disk space.

```bash
# Automated: systemd timer runs every Sunday at midnight
# Manual run:
~/.local/bin/vscode-server-cleanup.sh
```

### Profile boundary rules

| Surface | Rule |
|---|---|
| Secrets | Profile-local `.env` only; never committed |
| X writes | `x-mcp-write` disabled — enable only after Phase 3 pipeline exists |
| Instagram writes | Disabled until channel spec is complete |
| Engagement tools | Excluded from all MCP configs at Hermes filter level; never enable |
| Memory | Trace material, not business truth |
| Cron | Must fetch durable state from store before acting; do not rely on session history |
| Gateway | Internal oversight only; never use as public X or Instagram transport |
