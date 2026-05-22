# Metrics and Reporting

## Measurement Thesis

The operator exists to create business outcomes for `newshow.biz`. Social reach matters only when it compounds into qualified product usage, signups, donations, or durable trust.

The reporting system must avoid vanity optimization. A post that creates fewer impressions but better movie-page sessions may be more valuable than a high-reach argument that produces no useful traffic and raises incident risk.

## Hermes Role

Hermes should schedule collection, call analytics tools, summarize outcomes, and recommend next actions. Hermes should not be the metrics system of record.

Source-of-truth inputs should include:

- `X` receipts and analytics
- X MCP account-safety and browser-automation telemetry
- Instagram receipts and analytics
- `newshow.biz` traffic analytics
- signup analytics
- account activation analytics, including watchlist, rating, and review actions
- donation analytics
- content and engagement job stores
- escalation and incident records
- Hermes run metadata for traceability

## North-Star Metric

### Qualified Social Traffic to Product Surfaces

Definition:

Sessions from social sources that land on `/movies`, movie detail pages, donation pages, or approved product surfaces and meet a minimum quality threshold.

Suggested qualification events:

- second page view
- meaningful dwell time
- return visit
- signup
- rating/review/watchlist action
- search or representation-filter usage
- where-to-watch click
- donation-page visit
- donation conversion

## KPI Groups

### Traffic KPIs

- link clicks by post
- landing sessions by platform
- qualified session rate
- page depth
- return visits
- top traffic-driving titles
- traffic by content program
- traffic by CTA pattern
- where-to-watch clicks from movie pages
- browse-filter sessions from social

### Signup KPIs

- signup conversion rate by platform
- signup conversion rate by content program
- signup conversion rate by CTA
- signup conversion rate by landing page
- delayed signup after prior social touch where available
- post-signup activation rate: watchlist, rating, or review action
- Google sign-up versus email sign-up mix where privacy policy permits tracking

### Donation KPIs

- donation-page visits from social
- donation conversion rate by campaign
- donation conversion rate by support messaging type
- average donation where available
- assisted donation after prior social engagement where available
- Buy Me a Coffee conversions where available
- crypto support events where voluntarily disclosed or internally trackable

### Engagement KPIs

- impressions
- likes
- replies/comments
- reposts/shares
- saves
- profile visits
- follower growth
- DM starts
- reply quality
- comment quality

### Trust KPIs

Trust is harder to measure directly, but the operator should track proxies:

- saves on explanatory content
- positive replies or comments
- support-question resolution rate
- repeat engagement from known users
- low correction rate on score explanations
- invalid-analysis report rate
- resolved correction rate
- donation-message tolerance

### Risk KPIs

- escalations per week
- blocked outputs per week
- incidents per content program
- `TROLL`-mode incidents
- creator complaints
- moderation flags
- correction events
- invalid-analysis reports
- high-risk replies avoided
- policy false positives and false negatives
- X auth, CAPTCHA, Cloudflare or `403`, selector-drift, and account-warning events
- X write failures by tool and failure class
- X manual approval latency for browser-automation writes

## Per-Channel Metrics

### X

Primary:

- qualified clicks
- impressions
- engagement rate
- reply quality
- quote-post velocity
- follower growth

Risk overlays:

- backlash ratio
- harassment volume
- `TROLL` incident rate
- quote-post sentiment
- browser-automation failure rate
- account-health warning count
- write receipt success rate
- duplicate-prevention and idempotency exceptions

### Instagram

Primary:

- saves
- shares
- profile actions
- link-in-bio or profile-driven traffic
- comment quality
- follower growth

Risk overlays:

- complaint rate
- comment disputes
- creator complaints
- misinformation corrections

## Attribution Model

The operator must distinguish direct, assisted, and correlated outcomes.

### Direct Attribution

Use when a platform post or link can be connected to a site session, signup, or donation.

Fields:

- source platform
- source post ID
- campaign
- content program
- CTA
- target URL
- session outcome

### Assisted Attribution

Use when a user engaged with social content before a later signup or donation but the final conversion was not directly click-attributed.

Fields:

- prior social touch
- later conversion event
- time window
- confidence level

### Correlated Lift

Use when exact attribution is unavailable but aggregate movement aligns with campaign timing.

Rules:

- label as correlated, not direct
- avoid overclaiming
- compare against baseline where available

## Reporting Outputs

### Daily Operator Report

Audience:

- operator
- reviewer

Must include:

- posts published
- posts scheduled
- top and bottom performers
- unresolved escalations
- incidents or risk signals
- notable replies, comments, or DMs
- next-day opportunities
- any tool or integration failures
- X MCP health: login state, block/CAPTCHA signals, selector failures, rate-limit or account warnings, and failed receipts

### Weekly Growth Report

Audience:

- growth owner
- product owner

Must include:

- content program performance
- platform comparison
- traffic, signup, and donation summary
- experiment results
- risk-cost summary
- recommended scale, stop, revise, or investigate actions

### Monthly Strategy Report

Audience:

- strategic owner
- stakeholder

Must include:

- overall growth trend
- conversion quality
- source-object clusters that drove outcomes
- platform efficiency
- incident summary
- governance findings
- roadmap recommendations

## Experiment Design

Every experiment should define:

- hypothesis
- channel
- content program
- audience segment
- primary KPI
- secondary KPI
- risk guardrail
- sample logic
- stop rule
- scale rule

Experiment dimensions:

- hook style
- CTA wording
- score explanation depth
- comparison framing
- tone intensity on `X`
- donation messaging angle
- product-education density
- carousel structure
- posting window

## PerformanceSnapshot Contract

Required fields:

- `snapshot_id`
- `platform`
- `content_or_engagement_id`
- `time_window`
- `campaign_type`
- `content_program`
- `objective`
- `traffic_metrics`
- `signup_metrics`
- `donation_metrics`
- `activation_metrics`
- `where_to_watch_metrics`
- `engagement_metrics`
- `risk_notes`
- `experiment_tags`
- `source_run_id`
- `source_cron_job_id`
- `channel_receipt_id`
- `mcp_adapter_name`
- `browser_automation_status`
- `account_safety_notes`
- `interpretation_notes`

## ContentJob Reporting Cuts

Analyze by:

- platform
- campaign type
- content program
- source movie
- source movie cluster
- objective
- hook family
- CTA pattern
- risk level
- behavior mode
- publish window
- persona route
- policy disposition

Questions to answer:

- Which source objects produce qualified traffic?
- Which hooks produce signups rather than noise?
- Which CTAs produce donations without fatiguing the audience?
- Which CTAs produce account activation after signup?
- Which titles produce watchlist, rating, review, or where-to-watch actions?
- Which content programs create risk without business value?
- Which persona routes produce stronger outcomes?

## EngagementJob Reporting Cuts

Analyze by:

- platform
- intent class
- sentiment
- risk level
- response posture
- assigned persona
- action taken
- originating content program
- escalation trigger

Questions to answer:

- Which content programs generate support load?
- Which response postures de-escalate best?
- Which intents should be automated or escalated?
- Where is the bot overreplying?
- Which inbound reports identify genuinely invalid or weak AI analysis?
- Which inbound themes should inform product copy?

## Decision Rules

- Scale formats that create qualified traffic, even if they are not the loudest.
- Scale formats that convert signups, even if raw reach is modest.
- Use donation messaging sparingly unless it proves efficient.
- Reduce tactics whose risk cost exceeds business value.
- Treat `TROLL` reach as suspect until conversion and risk-adjusted value are proven.
- Prefer evergreen compounding formats when reactive performance is noisy.
- Treat X browser-automation reliability as a launch gate, not an implementation detail.

## v1 Success Criteria

v1 succeeds when:

- the operator publishes consistently without manual drafting bottlenecks
- social posts generate measurable qualified traffic
- signups can be attributed to social content or campaigns
- donation messaging shows early lift without trust damage
- routine engagement is handled autonomously
- escalations are captured reliably
- reports recommend concrete next actions
- risk incidents remain within accepted limits
