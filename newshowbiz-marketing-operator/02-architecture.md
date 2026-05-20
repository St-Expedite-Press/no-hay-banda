# New Showbiz Marketing Operator Architecture

## Architecture Thesis

The system is a domain-specific marketing operator running on Hermes Agent. Hermes supplies the agent runtime, tool registry, cron, memory, sessions, profiles, plugins, MCP, gateway, and safety primitives. New Showbiz supplies the product data, social-channel integrations, governance rules, persistence layer, attribution model, and public brand contract.

The architecture must keep those layers separate. If Hermes is treated as the business database, attribution system, or native social publisher, the product will become hard to audit and unsafe to scale.

## High-Level System

```text
Source Inputs
  - newshow.biz movie pages
  - browse/search/filter state
  - scores and category breakdowns
  - strengths, improvement notes, and category-detail explanations
  - watch-provider links
  - user ratings, reviews, and watchlist actions
  - product and donation messaging
  - bug and invalid-analysis reports
  - social trend signals
  - inbound replies, comments, mentions, DMs
  - platform and site analytics

        |
        v

Hermes Runtime Profile: newshowbiz
  - AIAgent run loop
  - SOUL.md brand identity
  - AGENTS.md project rules
  - skills and prompt overlays
  - cron jobs
  - toolsets
  - plugin and MCP tool loading
  - session search and memory

        |
        v

Domain Control Plane
  - TaskRouter
  - PersonaRegistry
  - Policy Engine
  - ContentJob store
  - EngagementJob store
  - EscalationRecord store
  - PerformanceSnapshot store

        |
        v

Channel Integration Layer
  - X read tools
  - X write tools
  - X MCP wrappers
  - general Playwright browser fallback
  - Instagram read tools
  - Instagram write tools
  - media upload tools
  - analytics tools
  - site and donation analytics tools
  - catalog/search/account activation tools

        |
        v

Public Channels and Business Outcomes
  - posts
  - comments and replies
  - DMs
  - traffic
  - signups
  - donations
  - trust
```

## Hermes Product Findings That Matter

### AIAgent

Hermes centers on `AIAgent` in `run_agent.py`. It handles prompt construction, provider selection, tool execution, iteration budgets, fallback, session persistence, memory flushing, and callbacks. This is the correct execution unit for planning, drafting, policy review, reporting, and controlled channel actions.

### Prompt Assembly

Hermes assembles prompt context from stable layers: `SOUL.md`, optional system message, memory snapshots, user profile snapshots, skills, project context files, timestamp, session ID, and platform hint. For New Showbiz:

- `SOUL.md` should define public brand voice and standing product posture.
- `AGENTS.md` should define repository, operator, and risk rules.
- skills should carry reusable workflows.
- ephemeral prompt overlays should be used for task-specific campaign or incident context.

Do not hardcode the entire operator into one monolithic system prompt.

### Profiles

Hermes profiles isolate config, memory, sessions, secrets, and gateway process state. New Showbiz should run in a dedicated profile so campaign memory and channel secrets do not bleed into unrelated work.

### Tool Registry and Toolsets

Hermes exposes tools through a registry and filters them through toolsets. Tool availability can depend on checks. This matters because New Showbiz should not give every cron job every capability.

Recommended toolset classes:

- `newshowbiz_read`: movie catalog, score data, site pages, trend reads
- `newshowbiz_metrics_read`: platform analytics, site analytics, donation analytics
- `newshowbiz_publish_x`: `X` publish and reply writes
- `newshowbiz_publish_instagram`: Instagram publish and comment writes
- `newshowbiz_escalation`: create and update escalation records
- `newshowbiz_reporting`: read metrics and write reports

### Plugins and MCP

Hermes supports native plugins and MCP servers. Use the choice deliberately:

- use a Hermes plugin when the integration is tightly coupled to this operator and should register tools, hooks, commands, or bundled skills
- use MCP when the channel or data capability already exists outside Hermes or should remain separately deployable
- use filtering so write tools are not exposed to workflows that only need read access

X MCP decision:

- prefer `Barresider/x-mcp` for X-specific Playwright tools such as search, profile scraping, timeline scraping, trending topics, posting, threads, replies, and media upload
- keep `microsoft/playwright-mcp` available as the general browser-control fallback for page-state inspection, session diagnosis, and custom workflow development
- use `kitadmin01/social_mcp` as an implementation reference for persistent sessions, login checks, retry behavior, scheduling, and broader marketing-agent scaffolding
- treat `miles0sage` as experimental until stronger maintenance and adoption evidence exists
- expose all third-party MCP actions through New Showbiz wrapper toolsets, not directly through broad Hermes jobs

### Cron

Hermes cron jobs run in fresh sessions and can attach skills. This is good for repeatable automation, but bad for hidden state assumptions. Every cron prompt must be self-contained or fetch durable state from New Showbiz storage.

Cron should trigger:

- daily source scan
- weekly campaign plan
- publish-window checks
- engagement inbox classification
- metrics collection
- daily and weekly reporting
- escalation reminder sweep

Cron should not be the only record of what happened.

### Gateway and API Surfaces

Hermes gateway connects to many messaging platforms and supports authorization, pairing, approvals, slash commands, delivery, and cron output. For New Showbiz, the gateway should be an internal oversight channel, not the public `X` or `Instagram` transport.

Use it for:

- escalation notifications
- human approval or denial
- incident freeze commands
- report delivery
- ad hoc operator commands

Use custom channel integrations for actual public `X` and `Instagram` actions.

### Security Controls

Hermes includes dangerous-command approvals, hardline blocklists, container backends, authorization, MCP environment filtering, context-file scanning, URL protection, and credential handling. Production write-capable workflows should use containerized or remote execution and narrow toolsets.

## Deployment Model

Recommended v1 deployment:

- one dedicated Hermes profile named `newshowbiz`
- containerized terminal backend for production runs
- profile-scoped secrets in Hermes config or environment, with least privilege
- New Showbiz domain store for jobs, receipts, metrics, and escalations
- plugin or MCP tool layer for `X`, `Instagram`, site analytics, and donation analytics
- internal oversight channel through Hermes gateway or a custom API dashboard
- scheduled work through Hermes cron
- explicit allowlists for oversight users

## Subsystems

### Runtime Layer

Responsibilities:

- run agent sessions
- load prompts, memory, skills, and context files
- expose available tools
- enforce toolset boundaries
- schedule cron jobs
- preserve session logs for operator traceability
- deliver internal notifications

Implementation base:

- Hermes `AIAgent`
- Hermes profile
- Hermes cron
- Hermes tools, toolsets, plugins, MCP
- Hermes gateway or API server

### Domain Control Plane

Responsibilities:

- create and update `ContentJob`
- create and update `EngagementJob`
- create and update `EscalationRecord`
- create and update `PerformanceSnapshot`
- route tasks through personas and policy
- own durable state
- expose safe APIs to Hermes tools

This layer should remain independent enough that another runtime could act on it later.

### Source Data Layer

Responsibilities:

- expose movie catalog data
- expose movie detail pages
- expose browse, search, filter, and pagination metadata
- expose score breakdowns
- expose score labels and category detail text
- expose analysis text
- expose strengths and areas for improvement
- expose watch-provider links
- expose user rating, review, and watchlist state
- expose site URLs and canonical identifiers
- expose approved product and donation language
- expose contact and invalid-analysis reporting paths

The operator must preserve source references for all factual and score-based claims.

### Policy Engine

Responsibilities:

- classify risk
- enforce channel restrictions
- enforce persona and behavior-mode restrictions
- block unsupported claims
- require evidence where needed
- route high-risk cases to escalation
- suspend or constrain `TROLL` mode after incident thresholds

Policy must run before public sends.

### Content Engine

Responsibilities:

- turn source objects into draft variants
- choose platform format
- assign CTA
- score variants
- generate media briefs when needed
- preserve evidence refs

### Engagement Engine

Responsibilities:

- ingest inbound items
- classify intent, sentiment, urgency, and risk
- choose response posture
- generate reply drafts
- decide send, ignore, clarify, redirect, or escalate
- store final disposition

### Publishing Layer

Responsibilities:

- schedule posts
- publish posts
- upload media
- send replies and comments
- handle idempotency
- return receipts
- retry transient failures
- block unsafe writes

This layer is custom. Hermes should call it through tools.

X implementation note:

`Barresider/x-mcp` can be the underlying adapter for X-specific actions, but the New Showbiz publishing layer still owns policy checks, idempotency, receipt normalization, approval state, media review, and account-safety gating. `microsoft/playwright-mcp` may support verification and diagnostics, but should not become a hidden unsupervised publisher.

### Analytics Layer

Responsibilities:

- collect post metrics
- collect engagement metrics
- join site traffic
- join signup and donation data
- compare experiments
- produce reports
- identify formats to scale, stop, or revise

### Oversight Layer

Responsibilities:

- show escalations
- accept approvals and denials
- pause campaigns
- suspend behavior modes
- inspect prior runs
- audit high-risk decisions
- deliver reports

Surfaces may include Hermes CLI, Hermes gateway, Hermes API server, or a custom dashboard.

## Data Flow

### Outbound Content Flow

1. Fetch source material, catalog state, watch-provider data, and trend signals.
2. Create `ContentJob`.
3. Assign objective, platform, and activation target.
4. Route through `TaskRouter`.
5. Load relevant Hermes skills and context.
6. Generate draft variants.
7. Attach evidence refs, target URLs, and relevant product affordances.
8. Score variants.
9. Run policy.
10. Publish, schedule, hold, or escalate.
11. Store final copy and platform receipts.
12. Collect performance snapshots.

### Inbound Engagement Flow

1. Receive inbound payload through channel integration or site contact path.
2. Persist raw payload.
3. Create `EngagementJob`.
4. Classify intent, sentiment, urgency, risk, and reported issue type.
5. Attach thread context and evidence requirements.
6. Route to persona and policy.
7. Send response, ignore, redirect, or escalate.
8. Store final action and policy reason.

### Reporting Flow

1. Collect platform analytics.
2. Join site sessions, signups, and donations.
3. Compare by campaign, objective, source object, hook family, CTA, and risk level.
4. Generate daily or weekly report.
5. Recommend next actions.
6. Store report output and source snapshot references.

## State Ownership

Hermes owns:

- session logs
- runtime memory
- profile config
- cron job definitions
- tool execution trace
- internal gateway conversation context

New Showbiz owns:

- source product records
- catalog search/filter records
- watch-provider references
- user activation events
- content jobs
- engagement jobs
- escalation records
- channel receipts
- metrics snapshots
- attribution joins
- experiment definitions
- incident records
- bug and invalid-analysis reports

## Channel Integration Contracts

Each channel must expose explicit tools. Minimum contracts:

### Read Tools

- fetch mentions
- fetch replies/comments
- fetch DMs where allowed
- fetch post status
- fetch analytics
- fetch account health or rate-limit status when available
- fetch catalog/search landing URLs for CTA construction
- fetch account activation events where privacy policy permits it

### Write Tools

- create post
- schedule post
- update scheduled post where supported
- upload media
- send reply/comment
- send DM where allowed
- delete or hide content only under explicit incident tooling

### X MCP Wrapper Tools

- `newshowbiz_x_read`: X search, profile, timeline, trend, post, and account-status reads
- `newshowbiz_x_draft_context`: read-only context packing for `ContentJob` and `EngagementJob` drafts
- `newshowbiz_x_publish_reviewed`: approved post, thread, reply, quote-post, and media upload actions
- `newshowbiz_x_account_safety`: login, CAPTCHA, Cloudflare, rate-limit, selector, and account-health diagnostics
- `newshowbiz_browser_read`: general Playwright page QA and fallback browser inspection

Do not expose raw like, retweet, bookmark, or mass engagement tools to autonomous v1 workflows.

### Tool Requirements

- every write returns a receipt
- every write accepts idempotency keys when possible
- every write records final text and media identifiers
- every write declares platform constraints
- read-only workflows must not receive write tools
- rate limits and auth failures must return structured errors
- browser automation failures must classify auth, selector drift, CAPTCHA, Cloudflare or `403`, rate limit, network, or unknown failure mode

## Operational Boundaries

Autonomous:

- low-risk posts
- approved medium-risk posts
- routine discovery replies
- basic product support
- approved donation information
- metrics collection
- reporting

Escalated:

- partnership and sponsorship interest
- legal complaints
- creator complaints
- factual disputes needing validation
- high-risk identity conflict
- viral backlash
- any money promise
- blocked `TROLL` output

## Implementation Guidance

Build the system around durable records first. Hermes runs should act on records, not replace them.

Recommended first implementation sequence:

1. Define `ContentJob`, `EngagementJob`, `EscalationRecord`, and `PerformanceSnapshot` schemas.
2. Create a dedicated Hermes profile with `SOUL.md` and `AGENTS.md`.
3. Implement read-only source and analytics tools.
4. Implement reporting skills and cron jobs.
5. Implement draft generation and manual review.
6. Canary `Barresider/x-mcp` read-only X workflows behind New Showbiz wrappers.
7. Add write-capable channel tools with narrow toolsets.
8. Add autonomous publishing only after policy, account-safety telemetry, and receipts are reliable.
9. Add `TROLL` workflows last.
