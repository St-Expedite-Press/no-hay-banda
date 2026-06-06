# New Showbiz Marketing Operator Product Spec

## Product Summary

`New Showbiz Marketing Operator` is a high-autonomy marketing system for `newshow.biz`. It plans, drafts, publishes, replies, escalates, and reports on `X`.

The operator converts a structured movie-analysis product into repeatable growth activity. Its job is not to simulate a personality. Its job is to drive qualified traffic, signups, donations, and trust by translating product evidence into social-native communication.

The live public promise is `Watch more of what matters to you`. The operator should preserve that promise: help audiences browse, rate, and discover films that align with their values through AI-generated inclusivity profiles.

## What New Showbiz Already Has

The product is unusually suitable for agentic marketing because it has durable content objects:

- movie titles and metadata
- more than 110,000 browsable movie results
- search and filter surfaces
- MPAA ratings, runtime, release year, posters, and synopsis fields
- where-to-watch links for rent/buy availability when present
- score structures
- category breakdowns
- category detail explanations
- score labels such as limited, fair, and good
- written analysis
- strengths and areas for improvement
- similar-movie discovery affordances
- user ratings and optional reviews
- watchlist actions
- product-use explanations
- contact paths for bugs and invalid diversity analysis
- an independent project/support narrative

The operator should treat each movie page and product concept as a source object. It may generate many platform artifacts from those source objects, but it must preserve the evidence chain behind claims, comparisons, and score explanations.

## Implementation Base: Hermes Agent

The operator should be built on `NousResearch/hermes-agent`.

Hermes should provide:

- primary `AIAgent` reasoning and tool-calling loop
- prompt assembly through `docs/10-hermes/SOUL.md`, `docs/10-hermes/AGENTS.md`, skills, memory, and context files
- session storage and session search
- cron-based autonomous execution
- tool registry and toolsets
- plugin loading
- MCP server loading and per-server tool filtering
- optional delegation for bounded research, drafting, analysis, and verification subtasks
- profile isolation for config, memory, sessions, secrets, and gateway process state
- CLI, TUI, gateway, and API-facing oversight surfaces
- approvals, command blocklists, allowlists, container execution, and other security controls

New Showbiz must provide:

- `X` publishing, reply, DM, browser-session, account-safety, and analytics integrations
- content, engagement, escalation, and metric persistence
- campaign and experiment taxonomy
- attribution joins between social events and `newshow.biz`
- reviewer workflow and incident ownership
- policy rules specific to representation, money, partnerships, legal exposure, and brand risk

Recommended X integration posture:

- use `Barresider/x-mcp` as the first X-specific MCP candidate because it exposes Playwright-backed X tools for search, scraping, posting, threads, replies, media upload, trending topics, and engagement actions
- use `microsoft/playwright-mcp` as the canonical general browser automation fallback and verification layer
- treat `kitadmin01/social_mcp` as a reference for session handling, retries, scheduling, and broad social-bot architecture rather than a drop-in dependency
- treat the `miles0sage` PulseMCP listing as experimental until direct repo review and adoption signals improve
- wrap any third-party MCP server behind New Showbiz toolsets so unsupported write or engagement actions cannot leak into ordinary cron jobs

## Product Goal

Build a governed autonomous marketing operator that can:

- create useful platform-native content from New Showbiz source material
- publish at a consistent cadence without manual drafting bottlenecks
- respond to routine audience interactions without escalating everything
- preserve hard escalation boundaries around high-risk matters
- measure which content creates qualified product usage
- learn from performance and risk outcomes

## Primary Business Outcomes

### Traffic

Drive qualified visits to `/movies`, movie detail pages, donation pages, and other product surfaces. Traffic is qualified when the visitor does more than bounce: additional page view, meaningful dwell time, signup, return visit, donation action, or other defined engagement threshold.

### Signups

Convert social interest into accounts for ratings, reviews, watchlists, repeat visits, and future product activation.

### Donations

Convert trust and product affinity into support for an independent project. Donation language must be approved and non-manipulative.

### Trust

Make New Showbiz feel useful, specific, and credible. Trust is not a vanity outcome; it supports traffic, signups, and donations.

## Non-Goals

- paid advertising in v1
- newsletter or CRM automation in v1
- autonomous sponsorship or partnership negotiation
- autonomous legal response
- long-form editorial publishing
- public activity on channels beyond `X`
- fully unsupervised handling of major controversy
- synthetic testimonials, fake urgency, fake scarcity, or fabricated metrics
- financial or tax guidance about crypto support

## v1 Scope

### In Scope

- campaign planning
- source-object selection from `newshow.biz`
- evergreen and reactive content generation
- post scheduling and publishing
- public reply handling
- low-risk DM handling
- score and product-use explanations
- where-to-watch prompts that route users to movie pages
- rating, review, and watchlist activation
- bug and invalid-analysis intake routing
- donation-support messaging using approved language
- escalation intake and routing
- daily and weekly reporting
- experiment tagging and recommendations
- human review through Hermes-native or custom oversight surfaces

### Out of Scope

- Reddit, Bluesky, TikTok, YouTube Shorts, or newsletter operations
- paid acquisition
- creator outreach and negotiation
- partnership CRM
- autonomous media buying
- autonomous product roadmap decisions

## Brand Positioning

### Core Promise

Watch more of what matters to you.

### Positioning Pillars

- inclusive movie discovery
- practical decision support
- transparent AI-assisted analysis
- repeatable score framework
- searchable and filterable catalog utility
- account actions: watchlist, ratings, and reviews
- independent, user-supported product
- usefulness over vague cultural posturing

### Public Voice

The public voice should be:

- clear
- specific
- direct
- movie-literate
- internet-native
- confident without sounding institutional
- willing to have taste without inventing facts

Multiple internal personas may collaborate, but the public identity is always `New Showbiz`.

## Channel Scope

### X

`X` is the speed and attention channel. It supports reactive commentary, discourse-aware posts, quote-post strategy, sharper opinion, and controlled `TROLL` mode.

The default implementation candidate for X-specific browser automation is `Barresider/x-mcp`. Its write tools must not be exposed directly to planning, reporting, or research workflows. `microsoft/playwright-mcp` may inspect X or other pages when the X-specific tool fails, but raw browser publishing is not an approved fallback in v1.

## Autonomy Model

The operator is high-autonomy, not approval-first.

It may autonomously:

- research low-risk content opportunities
- create content plans
- draft and select variants
- publish low-risk and approved medium-risk posts
- answer routine questions
- handle low-risk DMs
- collect metrics
- generate reports
- recommend experiments

It must escalate:

- money terms beyond approved donation information
- partnerships, sponsorships, affiliates, or collaboration terms
- legal threats or legal claims
- creator complaints
- platform-policy warnings
- factual disputes requiring verification
- requests for tax, investment, refund, or financial advice about support options
- identity-sensitive conflict involving protected classes or vulnerable groups
- high-visibility backlash
- any draft whose evidence does not support its claim
- any `TROLL` output that crosses risk thresholds

## Hermes Runtime Model

The recommended Hermes operating shape is:

- one dedicated Hermes profile for `newshow.biz`
- profile-scoped `docs/10-hermes/SOUL.md` for public voice
- project `docs/10-hermes/AGENTS.md` for builder and operator rules
- skills for campaign planning, draft review, policy checks, reporting, and incident review
- cron jobs for planning, publish windows, monitoring, and reports
- custom plugins or MCP servers for `X`, site analytics, and donation analytics
- narrow toolsets per workflow
- containerized terminal backend for production write-capable workflows
- allowlisted oversight channels for approvals and escalations

Cron jobs must be self-contained because Hermes cron runs in fresh sessions. Durable state must live in the New Showbiz data layer, not in assumed conversation history.

## Core Workflows

### Planning

Inputs:

- movie pages
- score data
- analysis text
- watch-provider availability
- user rating/review state
- release calendar
- social trend signals
- historical performance
- campaign goals

Actions:

- select candidate source objects
- classify timeliness as evergreen, seasonal, reactive, campaign-driven, or discourse-driven
- assign objective: traffic, signup, donation, trust
- select platform and content program
- create `ContentJob`
- route to personas and policy

### Drafting

Actions:

- generate platform-specific variants
- attach evidence references
- identify CTA and destination
- score variants by objective fit, brand fit, platform fit, evidence strength, novelty, and risk
- select or hold for review

### Publishing

Actions:

- call explicit custom `X` integration tools
- schedule or publish
- store platform IDs, canonical URLs, timestamps, media receipts, and final copy
- tag the run, cron job, campaign, and experiment

Hermes native messaging gateway is not the public `X` publisher for this product.

For X, a reviewed publishing flow may call `Barresider/x-mcp` through a wrapper such as `newshowbiz_x_publish_reviewed`. The wrapper must confirm policy disposition, approval state, idempotency key, final copy, media approvals, and account-safety status before exposing `tweet`, `thread`, `reply_to_post`, or `quote_tweet`.

### Engagement

Inputs:

- mentions
- replies
- quote-post context
- comments
- DMs
- bug reports and invalid-analysis reports

Actions:

- persist raw payload
- create `EngagementJob`
- classify intent, sentiment, risk, and evidence needs
- select response posture
- answer, clarify, redirect, ignore, rate-limit, or escalate
- store final disposition

### Escalation

Actions:

- create `EscalationRecord`
- include source payload, thread context, risk trigger, draft response, evidence gaps, owner, SLA, and recommended action
- send to oversight surface
- block autonomous response until resolution when required

### Reporting

Actions:

- collect platform metrics
- join traffic, signup, and donation analytics
- compare experiments
- summarize content and engagement results
- recommend scale, stop, revise, or escalate decisions

## Domain Contracts

### PersonaRegistry

Defines internal working roles:

- `persona_id`
- `role`
- `allowed_channels`
- `allowed_task_classes`
- `blocked_task_classes`
- `behavior_modes_available`
- `tone_bounds`
- `required_escalation_conditions`

This is not a native Hermes object. It is domain configuration implemented through routing logic, skills, prompt overlays, and metadata.

### TaskRouter

Defines how work is assigned:

- `task_id`
- `task_type`
- `source_context`
- `objective`
- `risk_level`
- `assigned_personas`
- `required_policy_checks`
- `required_reviewers`
- `toolset_scope`
- `final_disposition`

### ContentJob

Represents an outbound content unit:

- `content_job_id`
- `source_movie_ids`
- `source_urls`
- `source_page_type`
- `source_evidence_refs`
- `watch_provider_refs`
- `campaign_type`
- `content_program`
- `platform`
- `format_type`
- `objective`
- `audience_segment`
- `timeliness_class`
- `primary_hook`
- `supporting_angle`
- `draft_variants`
- `selected_variant`
- `cta`
- `cta_destination`
- `activation_target`
- `asset_requirements`
- `risk_level`
- `policy_disposition`
- `experiment_tags`
- `target_publish_window`
- `scheduled_at`
- `published_at`
- `publish_receipt`
- `final_copy`
- `rationale`

Completion rule: a `ContentJob` is complete only when policy disposition, publish disposition, final copy, receipts, and attribution-ready metadata exist.

### EngagementJob

Represents inbound handling:

- `engagement_job_id`
- `platform`
- `source_object_id`
- `parent_object_id`
- `thread_context`
- `author_identifier`
- `author_segment`
- `message_text`
- `reported_issue_type`
- `intent_class`
- `sentiment`
- `risk_level`
- `sensitivity_flags`
- `response_posture`
- `assigned_persona`
- `evidence_refs`
- `draft_response`
- `action_taken`
- `policy_reason`

Completion rule: an `EngagementJob` is complete only when the final action, policy reason, timestamp, and follow-up requirement are stored.

### EscalationRecord

Represents blocked or high-risk work:

- `escalation_id`
- `source_type`
- `source_id`
- `risk_reason`
- `severity`
- `summary`
- `evidence_gap`
- `blocked_or_draft_response`
- `recommended_next_action`
- `human_owner`
- `status`
- `resolution_notes`

### PerformanceSnapshot

Represents measurement state:

- `snapshot_id`
- `platform`
- `content_or_engagement_id`
- `time_window`
- `traffic_metrics`
- `signup_metrics`
- `donation_metrics`
- `activation_metrics`
- `engagement_metrics`
- `risk_notes`
- `experiment_tags`
- `source_run_id`
- `source_cron_job_id`
- `channel_receipt_id`
- `interpretation_notes`

### ChannelIntegration

Represents the explicit Hermes-facing contract for each business channel:

- `platform_id`
- `read_tool_names`
- `write_tool_names`
- `schedule_tool_names`
- `reply_tool_names`
- `dm_tool_names`
- `analytics_tool_names`
- `supported_media_types`
- `auth_owner`
- `secret_storage_model`
- `rate_limit_notes`
- `policy_constraints`
- `mcp_server_candidate`
- `fallback_tool_candidate`
- `session_storage_path`
- `account_safety_signals`

Each channel integration must distinguish read-only operations from write-capable operations.

For `X`, the default candidate values are `Barresider/x-mcp` for X-specific operations and `microsoft/playwright-mcp` for browser fallback or page-state verification.

## Acceptance Criteria

The product spec is ready for implementation when:

- a builder can distinguish Hermes runtime capabilities from New Showbiz custom work
- `X` scope is explicit
- business outcomes are measurable
- autonomy and escalation boundaries are unambiguous
- domain objects are concrete enough to persist
- no workflow assumes Hermes session history as durable business state
- channel tools are explicit, auditable, and separable by risk
- X MCP options are ranked, wrapped, and constrained by case-specific policy

