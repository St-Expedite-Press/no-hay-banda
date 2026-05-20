# New Showbiz Marketing Operator

This documentation defines a Hermes-backed marketing operator for `newshow.biz`. The operator plans, publishes, engages, measures, and escalates across `X` and `Instagram` while preserving one public brand voice and hard business-risk boundaries.

The project should not be read as a generic social bot. It is a governed growth system for a structured movie-discovery product. Hermes provides the runtime substrate. New Showbiz supplies the domain model, channel integrations, brand rules, measurement logic, and human accountability.

## Research Basis

This rewrite was produced from four evidence surfaces:

- Composer agent doctrine: editorial pressure, clear institutional voice, and avoidance of generic marketing mush.
- ResearchPage doctrine: source provenance, retrieval discipline, and refusal to overclaim before the corpus exists.
- Orchestrator/Data-Agent doctrine: route through the minimum needed context, keep specialist boundaries explicit, and treat control surfaces as source of truth.
- Hermes product and codebase review: local upstream source, live Hermes docs inspected with Playwright, and GitHub metadata for `NousResearch/hermes-agent`.
- X MCP option review: GitHub verification of `Barresider/x-mcp`, `microsoft/playwright-mcp`, `kitadmin01/social_mcp`, and Hermes issue `#10959`, plus PulseMCP review of the `miles0sage` listing.
- Live New Showbiz product review: homepage, movie browse, movie detail, donate, about, contact, and sign-up surfaces inspected with Playwright.

The key Hermes finding is simple: Hermes is a strong autonomous-agent runtime, not a finished social-marketing product. It gives us agent execution, prompt assembly, skills, memory, session search, cron, plugins, MCP, gateway surfaces, approvals, profiles, and container backends. It does not natively give us safe `X` or `Instagram` publishing, inbox handling, campaign persistence, or attribution to `newshow.biz`.

The key X integration finding is also simple: use `Barresider/x-mcp` first for X-specific Playwright automation, retain `microsoft/playwright-mcp` as the general browser-control fallback, treat `kitadmin01/social_mcp` as a scaffold reference, and keep the `miles0sage` PulseMCP listing experimental. Browser automation is necessary because X can block simple automated requests, but it is brittle and must be wrapped behind policy, approval, receipts, rate limits, and account-safety telemetry.

## Product Thesis

New Showbiz has structured source material: a searchable catalog of more than 110,000 titles, score ranges, category filters, movie pages, watch-provider links, user ratings/reviews, watchlist actions, AI-generated inclusivity profiles, and an independent-project support narrative. That structure can be repeatedly translated into platform-native content:

- discovery recommendations
- score explainers
- comparisons
- where-to-watch and browse prompts
- rating, review, and watchlist activation posts
- reactive movie-discourse posts
- product-education posts
- donation and support narratives
- routine support and discovery replies

The operator exists to make that translation fast, measurable, and governed.

## Runtime Thesis

Hermes should be used as the operator control plane:

- `AIAgent` runs the reasoning and tool-calling loop.
- `SOUL.md` carries the stable public brand identity.
- `AGENTS.md` carries project rules and builder/operator instructions.
- skills carry reusable workflows such as campaign planning, policy review, reporting, and incident review.
- cron triggers recurring planning, publishing, monitoring, and reporting work.
- plugins or MCP servers expose business tools to Hermes.
- profiles isolate the New Showbiz runtime, memory, sessions, config, and secrets from other Hermes work.
- CLI, gateway, and API server surfaces provide human oversight.
- approvals, allowlists, website controls, and container backends provide operational safety.

Hermes should not become the database of record for the business. Content jobs, engagement jobs, escalations, metrics, channel receipts, and attribution should be persisted in New Showbiz-controlled storage.

## Documentation Set

- `01-product-spec.md`: Product definition, Hermes fit, scope, autonomy model, domain contracts, and acceptance criteria.
- `02-architecture.md`: Runtime architecture, Hermes-to-domain mapping, data flow, persistence, profiles, tool surfaces, and deployment posture.
- `03-personas-and-behavior-modes.md`: Internal persona contracts, behavior modes, routing rules, and `TROLL` constraints.
- `04-channel-operations.md`: `X` and `Instagram` operating model, content programs, cadence, formatting, DM/reply handling, and integration contracts.
- `05-risk-guardrails-and-escalation.md`: Risk classes, escalation triggers, policy boundaries, Hermes runtime controls, and incident handling.
- `06-metrics-and-reporting.md`: KPI model, attribution, reporting cadence, experiment design, and data contracts.
- `07-x-mcp-options-and-discussions.md`: X/Twitter MCP option ranking, configs, case-specific use, wrappers, and account-safety requirements.
- `whitepaper.md`: Strategic argument for a governed Hermes-backed operator.
- `phased-checklist.md`: Implementation phases, exit criteria, dependencies, human decisions, and Hermes-specific deliverables.

## Recommended Reading Order

1. `01-product-spec.md`
2. `02-architecture.md`
3. `05-risk-guardrails-and-escalation.md`
4. `03-personas-and-behavior-modes.md`
5. `04-channel-operations.md`
6. `06-metrics-and-reporting.md`
7. `07-x-mcp-options-and-discussions.md`
8. `whitepaper.md`
9. `phased-checklist.md`

## Non-Negotiable Boundaries

- One public identity: `New Showbiz`.
- Two v1 public channels: `X` and `Instagram`.
- Hermes is the runtime, not the social-channel transport.
- `X` and `Instagram` writes require explicit custom plugin, MCP, or service-adapter tools.
- `Barresider/x-mcp` is the preferred X-specific candidate, but only behind New Showbiz wrapper toolsets.
- `microsoft/playwright-mcp` is the preferred general browser fallback, not a policy bypass for publishing.
- Read-only analytics tools must be separated from write-capable publish/reply tools.
- Money, legal, partnership, creator-complaint, and high-risk identity-conflict cases escalate.
- `TROLL` mode is `X`-only, fact-bound, policy-bound, and suspendable.
- Metrics must optimize qualified traffic, signups, donations, and trust rather than raw engagement alone.
- Donation messaging must preserve the live site's constraints: independent project, not tax-deductible charitable donations, crypto irreversible/non-refundable, and no financial advice.
