# Phased Checklist

## Phase 0: Documentation, Brand Rules, and Runtime Decision

*Last reviewed: 2026-05-20. Items marked âœ… are complete at the documentation level.*

### Deliverables

- [x] âœ… Approve one-sentence product promise. â€” *"Watch more of what matters to you."* (docs/10-hermes/AGENTS.md)
- [x] âœ… Approve public voice constraints. â€” Kakusu Protocol, em dash ban, 2-hashtag cap, film-critic register (docs/10-hermes/AGENTS.md Brand and Voice Rules)
- [x] âœ… Approve banned claims. â€” No fabricated facts, no invented social proof, no fake certainty about AI analysis (docs/10-hermes/AGENTS.md)
- [x] âœ… Approve donation language. â€” Independent project, not tax-deductible, crypto irreversible and non-refundable, no financial advice (docs/10-hermes/AGENTS.md)
- [x] âœ… Approve crypto-support language and non-tax-deductible contribution language. â€” Same as above.
- [x] âœ… Approve `TROLL` mode boundary. â€” X only, fact-bound, policy-bound, incident-reviewed, suspendable; permanently blocked channels defined (docs/10-hermes/AGENTS.md)
- [ ] Approve persona contracts. â€” Seven personas defined in `03-personas-and-behavior-modes.md`; formal PersonaRegistry mapping personas to agents not yet written.
- [x] âœ… Approve risk classes and escalation triggers. â€” 12 classes defined and consistent across all docs (docs/10-hermes/AGENTS.md, retired clarity map, agent specs)
- [x] âœ… Approve Hermes as runtime substrate. â€” Phase 3+ runtime; three-layer architecture documented in retired overview and docs/10-hermes/AGENTS.md
- [x] âœ… Approve that `X` and Instagram require custom tools. â€” Five named New Showbiz toolsets defined; no third-party MCP exposed directly (docs/10-hermes/AGENTS.md)
- [x] âœ… Approve `Barresider/x-mcp` as the first X-specific MCP candidate. â€” Phase 3+ scope; confirmed in docs/10-hermes/AGENTS.md and retired clarity map
- [x] âœ… Approve `microsoft/playwright-mcp` as the general browser fallback. â€” QA and browser inspection only; not an unsupervised publishing fallback (docs/10-hermes/AGENTS.md)
- [x] âœ… Approve that `kitadmin01/social_mcp` is reference material, not the default runtime. â€” Tier 3 reference for session/retry design (docs/10-hermes/AGENTS.md)
- [x] âœ… Approve that `miles0sage` remains experimental. â€” Tier 4; do not rely on (docs/10-hermes/AGENTS.md)

### Exit Criteria

- [x] âœ… Two builders can distinguish Hermes-native capabilities from New Showbiz custom work. â€” Explicit three-layer boundary in docs/10-hermes/AGENTS.md and retired overview Â§4
- [x] âœ… Two builders can distinguish X MCP adapters from New Showbiz policy, wrapper, and persistence layers. â€” Toolset wrapper model and MCP ranking documented in docs/10-hermes/AGENTS.md
- [x] âœ… Brand rules are specific enough to produce consistent copy. â€” Kakusu Protocol + formatting rules + banned terms in docs/10-hermes/AGENTS.md
- [x] âœ… Money, legal, partnership, and creator-complaint escalation rules are unambiguous. â€” 12 risk classes with definitions in docs/10-hermes/AGENTS.md
- [x] âœ… `TROLL` mode is channel-restricted, fact-bound, and suspendable. â€” Full TROLL policy in docs/10-hermes/AGENTS.md with permanent block list

### Risks to Watch

- [ ] Brand voice remains too vague. â€” *Mitigated: Kakusu Protocol and film-critic register are specific. Monitor first drafts.*
- [ ] Hidden disagreement on how sharp `X` should be. â€” *Mitigated: TROLL mode boundary is explicit. Open: no examples of TROLL content yet.*
- [ ] Donation language is emotionally manipulative or legally sloppy. â€” *Mitigated: constraints are specific and conservative.*
- [ ] Hermes is treated as a complete social stack rather than a runtime. â€” *Mitigated: Layer boundary is the most-emphasized constraint in docs/10-hermes/AGENTS.md.*
- [ ] X MCP tools are mistaken for permission to automate engagement. â€” *Mitigated: Phase 1 is draft-only; Barresider is Phase 3+ scope explicitly.*

### Human Decisions Required

- [x] âœ… Final public tone. â€” Locked in docs/10-hermes/AGENTS.md Brand and Voice Rules.
- [x] âœ… Final donation language. â€” Locked in docs/10-hermes/AGENTS.md Risk Rules.
- [x] âœ… Final `TROLL` policy. â€” Locked in docs/10-hermes/AGENTS.md TROLL Mode section.
- [ ] Human owner for escalations. â€” Not yet named. Required before Phase 4 (autonomous publishing).

## Phase 1: Hermes Profile and Manual-Review Drafting

### Deliverables

- [x] âœ… Create dedicated Hermes profile for `newshow.biz`. â€” *docs/10-hermes/hermes-config.example.yaml complete with plugin activation block, gateway config, and personalities. `future implementation package metadata` registers vault and gateway plugins as entry-points. Install: `pip install -e ".[telegram,anthropic]"` then `hermes plugins enable newshowbiz-vault && hermes plugins enable newshowbiz-gateway`. Profile copy: `mkdir -p ~/.hermes/profiles/new-showbiz && cp docs/10-hermes/hermes-config.example.yaml ~/.hermes/profiles/new-showbiz/config.yaml && cp docs/10-hermes/SOUL.md ~/.hermes/profiles/new-showbiz/docs/10-hermes/SOUL.md`. Updated 2026-05-21.*
- [x] âœ… Write profile-scoped `docs/10-hermes/SOUL.md`. â€” *Written 2026-05-20. At `New_Show_Bot/docs/10-hermes/SOUL.md` and `no-hay-banda/docs/docs/10-hermes/SOUL.md`.*
- [x] âœ… Write project `docs/10-hermes/AGENTS.md`. â€” *Complete with three-module architecture, Agent Activation Protocol, Task-to-Agent Routing Table, persona overlay registration, and full brand/escalation rules. Reformatted 2026-05-21.*
- [x] âœ… Define initial skills for content drafting, X publishing, and escalation. â€” *`content-draft-from-movie-data`, `x-publish-with-receipt`, `escalation-record-create` written 2026-05-21. Campaign planning and reporting skills remain.*
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

