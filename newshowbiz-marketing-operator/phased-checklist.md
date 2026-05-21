# Phased Checklist

## Phase 0: Documentation, Brand Rules, and Runtime Decision

*Last reviewed: 2026-05-20. Items marked ✅ are complete at the documentation level.*

### Deliverables

- [x] ✅ Approve one-sentence product promise. — *"Watch more of what matters to you."* (AGENTS.md)
- [x] ✅ Approve public voice constraints. — Kakusu Protocol, em dash ban, 2-hashtag cap, film-critic register (AGENTS.md Brand and Voice Rules)
- [x] ✅ Approve banned claims. — No fabricated facts, no invented social proof, no fake certainty about AI analysis (AGENTS.md)
- [x] ✅ Approve donation language. — Independent project, not tax-deductible, crypto irreversible and non-refundable, no financial advice (AGENTS.md)
- [x] ✅ Approve crypto-support language and non-tax-deductible contribution language. — Same as above.
- [x] ✅ Approve `TROLL` mode boundary. — X only, fact-bound, policy-bound, incident-reviewed, suspendable; permanently blocked channels defined (AGENTS.md)
- [ ] Approve persona contracts. — Seven personas defined in `03-personas-and-behavior-modes.md`; formal PersonaRegistry mapping personas to agents not yet written.
- [x] ✅ Approve risk classes and escalation triggers. — 12 classes defined and consistent across all docs (AGENTS.md, CLARITY.md, agent specs)
- [x] ✅ Approve Hermes as runtime substrate. — Phase 3+ runtime; three-layer architecture documented in OVERVIEW.md and AGENTS.md
- [x] ✅ Approve that `X` and Instagram require custom tools. — Five named New Showbiz toolsets defined; no third-party MCP exposed directly (AGENTS.md)
- [x] ✅ Approve `Barresider/x-mcp` as the first X-specific MCP candidate. — Phase 3+ scope; confirmed in AGENTS.md and CLARITY.md
- [x] ✅ Approve `microsoft/playwright-mcp` as the general browser fallback. — QA and browser inspection only; not an unsupervised publishing fallback (AGENTS.md)
- [x] ✅ Approve that `kitadmin01/social_mcp` is reference material, not the default runtime. — Tier 3 reference for session/retry design (AGENTS.md)
- [x] ✅ Approve that `miles0sage` remains experimental. — Tier 4; do not rely on (AGENTS.md)

### Exit Criteria

- [x] ✅ Two builders can distinguish Hermes-native capabilities from New Showbiz custom work. — Explicit three-layer boundary in AGENTS.md and OVERVIEW.md §4
- [x] ✅ Two builders can distinguish X MCP adapters from New Showbiz policy, wrapper, and persistence layers. — Toolset wrapper model and MCP ranking documented in AGENTS.md
- [x] ✅ Brand rules are specific enough to produce consistent copy. — Kakusu Protocol + formatting rules + banned terms in AGENTS.md
- [x] ✅ Money, legal, partnership, and creator-complaint escalation rules are unambiguous. — 12 risk classes with definitions in AGENTS.md
- [x] ✅ `TROLL` mode is channel-restricted, fact-bound, and suspendable. — Full TROLL policy in AGENTS.md with permanent block list

### Risks to Watch

- [ ] Brand voice remains too vague. — *Mitigated: Kakusu Protocol and film-critic register are specific. Monitor first drafts.*
- [ ] Hidden disagreement on how sharp `X` should be. — *Mitigated: TROLL mode boundary is explicit. Open: no examples of TROLL content yet.*
- [ ] Donation language is emotionally manipulative or legally sloppy. — *Mitigated: constraints are specific and conservative.*
- [ ] Hermes is treated as a complete social stack rather than a runtime. — *Mitigated: Layer boundary is the most-emphasized constraint in AGENTS.md.*
- [ ] X MCP tools are mistaken for permission to automate engagement. — *Mitigated: Phase 1 is draft-only; Barresider is Phase 3+ scope explicitly.*

### Human Decisions Required

- [x] ✅ Final public tone. — Locked in AGENTS.md Brand and Voice Rules.
- [x] ✅ Final donation language. — Locked in AGENTS.md Risk Rules.
- [x] ✅ Final `TROLL` policy. — Locked in AGENTS.md TROLL Mode section.
- [ ] Human owner for escalations. — Not yet named. Required before Phase 4 (autonomous publishing).

## Phase 1: Hermes Profile and Manual-Review Drafting

### Deliverables

- [ ] Create dedicated Hermes profile for `newshow.biz`. — *hermes-config.yaml written; human install step remains (`mkdir ~/.hermes/profiles/new-showbiz`, copy files).*
- [x] ✅ Write profile-scoped `SOUL.md`. — *Written 2026-05-20. At `New_Show_Bot/SOUL.md` and `no-hay-banda/docs/SOUL.md`.*
- [x] ✅ Write project `AGENTS.md`. — *Complete with Agent Activation Protocol, Task-to-Agent Routing Table, persona overlay registration, and full brand/escalation rules.*
- [ ] Define initial skills for campaign planning, draft review, policy review, and reporting.
- [ ] Define `PersonaRegistry`.
- [ ] Define `TaskRouter`.
- [ ] Define `ContentJob`, `EngagementJob`, `EscalationRecord`, and `PerformanceSnapshot` schemas.
- [ ] Add `ChannelIntegration` fields for MCP adapter, fallback tool, session path, and account-safety signals.
- [ ] Add activation fields for watchlist, rating, review, search/filter, and where-to-watch actions.
- [ ] Build template library for `X`.
- [ ] Build template library for Instagram.
- [ ] Build manual-review workflow.
- [ ] Produce one week of human-reviewed draft content.

### Exit Criteria

- [ ] Operator can generate platform-specific drafts from source objects.
- [ ] Reviewers can approve, reject, or revise drafts efficiently.
- [ ] Every draft has objective, source refs, CTA, and risk classification.
- [ ] Reports can summarize drafts and review decisions.

### Risks to Watch

- [ ] Generic content volume hides weak positioning.
- [ ] Reviews become unstructured comments instead of decisions.
- [ ] Source evidence is missing from score claims.
- [ ] Persona system creates inconsistency instead of leverage.

### Dependencies

- [ ] Access to source content from `newshow.biz`.
- [ ] Hermes installed and configured.
- [ ] Human reviewer availability.

### Human Decisions Required

- [ ] Initial campaign priorities.
- [ ] Initial cadence.
- [ ] Initial CTA preferences.
- [ ] Manual review SLA.

## Phase 2: Read-Only Integrations and Reporting

### Deliverables

- [ ] Implement source-data read tools for `newshow.biz`.
- [ ] Implement catalog/search/filter URL helper tools.
- [ ] Implement movie-detail source extraction for scores, category details, strengths, improvement notes, watch providers, and AI analysis.
- [ ] Implement platform analytics read tools for `X`.
- [ ] Implement platform analytics read tools for Instagram.
- [ ] Implement site traffic analytics read tools.
- [ ] Implement account activation analytics for signups, watchlists, ratings, and reviews where privacy policy permits.
- [ ] Implement signup and donation analytics read tools.
- [ ] Create read-only Hermes toolsets.
- [ ] Create `newshowbiz_x_read`.
- [ ] Create `newshowbiz_x_draft_context`.
- [ ] Create `newshowbiz_x_account_safety`.
- [ ] Canary `Barresider/x-mcp` read-only search, trend, profile, and timeline workflows.
- [ ] Canary `microsoft/playwright-mcp` browser QA on New Showbiz pages and X page-state inspection.
- [ ] Create daily report cron job.
- [ ] Create weekly report cron job.
- [ ] Store `PerformanceSnapshot` records.

### Exit Criteria

- [ ] Reports use real data rather than invented summaries.
- [ ] Analytics tools are read-only.
- [ ] Cron reports run in fresh sessions without hidden state assumptions.
- [ ] Reports distinguish direct, assisted, and correlated attribution.
- [ ] Reports include X MCP health and browser-automation failure classes.

### Risks to Watch

- [ ] Metrics are too noisy to guide action.
- [ ] Tool responses lack enough identifiers for attribution.
- [ ] Hermes session memory is mistaken for durable metrics state.

### Dependencies

- [ ] Analytics access.
- [ ] Durable metrics store.
- [ ] Approved KPI definitions.

### Human Decisions Required

- [ ] Minimum threshold for qualified traffic.
- [ ] Reporting recipients.
- [ ] Attribution confidence labels.

## Phase 3: Write-Capable Channel Integrations

### Deliverables

- [ ] Implement `X` publish tool.
- [ ] Implement `newshowbiz_x_publish_reviewed` wrapper around the selected X adapter.
- [ ] Implement `X` schedule tool if separate.
- [ ] Implement `X` reply tool.
- [ ] Implement Instagram publish tool.
- [ ] Implement Instagram media upload/attach tool.
- [ ] Implement Instagram comment reply tool.
- [ ] Add receipts for every write.
- [ ] Add idempotency strategy where available.
- [ ] Create write-capable toolsets separated by channel.
- [ ] Add policy checks before all public writes.
- [ ] Keep manual approval for first production window.
- [ ] Keep like, retweet, bookmark, and mass engagement tools disabled or manual-only.
- [ ] Confirm retries cannot duplicate X posts or replies.

### Exit Criteria

- [ ] Public writes return durable receipts.
- [ ] Failed writes return structured errors and retry guidance.
- [ ] X failures classify auth, login wall, CAPTCHA, Cloudflare or `403`, selector drift, rate limit, network, account warning, or unknown.
- [ ] Read-only workflows do not receive write tools.
- [ ] Reviewers can trace final copy to job, source refs, policy decision, and platform receipt.

### Risks to Watch

- [ ] Tool scopes are too broad.
- [ ] Retry logic creates duplicate posts.
- [ ] Media upload failures are handled ad hoc.
- [ ] Public writes bypass policy through convenience paths.

### Dependencies

- [ ] Platform API access.
- [ ] Node.js 18 or newer.
- [ ] X credentials and auth/session storage path.
- [ ] Proxy decision for X browser automation.
- [ ] Secret storage model.
- [ ] Rate-limit handling.
- [ ] Durable job store.

### Human Decisions Required

- [ ] Which actions can be autonomous first.
- [ ] Which platform scopes are acceptable.
- [ ] Whether scheduled posts require review during beta.

## Phase 4: Low-Risk Autonomous Publishing and Routine Engagement

### Deliverables

- [ ] Enable autonomous publishing for low-risk content.
- [ ] Enable autonomous publishing for approved medium-risk content.
- [ ] Enable routine public replies.
- [ ] Enable low-risk DM handling where integration context is sufficient.
- [ ] Enable bug-report and invalid-analysis routing to the contact/review path.
- [ ] Store `EngagementJob` records for inbound handling.
- [ ] Store final actions and policy reasons.
- [ ] Add escalation notifications through Hermes oversight surface.
- [ ] Add pause/freeze commands for campaigns and behavior modes.

### Exit Criteria

- [ ] Operator publishes consistently without manual drafting bottleneck.
- [ ] Routine questions are answered without human intervention.
- [ ] Escalations are captured reliably.
- [ ] Human reviewer can pause risky workflows quickly.

### Risks to Watch

- [ ] Misclassification of inbound engagement.
- [ ] Public replies over-engage adversarial users.
- [ ] DM context is incomplete.
- [ ] Autonomy outruns measurement quality.

### Dependencies

- [ ] Working policy engine.
- [ ] Working escalation store.
- [ ] Working oversight channel.
- [ ] Stable write tools.

### Human Decisions Required

- [ ] Low-risk autonomy threshold.
- [ ] DM boundaries.
- [ ] Escalation SLA.

## Phase 5: Managed Edge, TROLL Mode, and Optimization

### Deliverables

- [ ] Enable `DEBATE` mode on `X`.
- [ ] Enable controlled `TROLL` workflows on `X`.
- [ ] Add incident counters for `TROLL`.
- [ ] Add automatic suspension thresholds.
- [ ] Add experiment comparison logic.
- [ ] Add backlash and creator-complaint incident workflow.
- [ ] Add risk-adjusted reporting.
- [ ] Add post-incident learning loop.

### Exit Criteria

- [ ] `TROLL` mode stays inside policy.
- [ ] Edge tactics are evaluated by qualified traffic and risk cost, not reach alone.
- [ ] Incidents produce durable records and decisions.
- [ ] Similar tactics cannot resume after serious incidents without human approval.

### Risks to Watch

- [ ] Reach masks conversion weakness.
- [ ] Tone instability damages trust.
- [ ] `TROLL` mode is used because it is fun rather than useful.
- [ ] Incident review becomes performative.

### Dependencies

- [ ] Mature reporting.
- [ ] Mature escalation workflow.
- [ ] Stable policy enforcement.
- [ ] Human owner for live controversy.

### Human Decisions Required

- [ ] Maximum `TROLL` frequency.
- [ ] Suspension thresholds.
- [ ] Reauthorization path after incident.

## Phase 6: Scaling and Governance Hardening

### Deliverables

- [ ] Build operational dashboard.
- [ ] Build campaign health dashboard.
- [ ] Build risk dashboard.
- [ ] Expand experiment library.
- [ ] Audit tool scopes and MCP filters.
- [ ] Audit command allowlists and secrets.
- [ ] Review whether to add more Hermes plugins, MCP servers, or profiles.
- [ ] Review whether to expand beyond `X` and Instagram.
- [ ] Formalize governance review cadence.

### Exit Criteria

- [ ] Operator shows repeatable qualified-traffic gains.
- [ ] Signups and donations can be tied to campaigns.
- [ ] Risk incidents remain within accepted limits.
- [ ] Governance scales with output volume.
- [ ] Tool exposure remains least-privilege.

### Risks to Watch

- [ ] Attribution gaps hide weak performance.
- [ ] Governance loosens after early success.
- [ ] Platform style overfits to `X`.
- [ ] Channel expansion happens before current channels are stable.

### Human Decisions Required

- [ ] Whether to expand channels.
- [ ] Whether to keep, narrow, or retire `TROLL`.
- [ ] Whether to add email, outreach, or partnerships later.
- [ ] Budget for dashboards and integration hardening.
