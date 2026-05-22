# docs/10-hermes/AGENTS.md - New Showbiz Documentation Package Contract

This file is the documentation-package version of the New Showbiz operator contract. In a future Hermes runtime profile, copy or adapt it as the profile `docs/10-hermes/AGENTS.md` context file.

## Workspace Scope

This repository is a specification package. It documents how to build the New Showbiz marketing operator, but it does not contain runnable channel adapters, Python packages, Docker services, or a Hermes upstream checkout.

Canonical package areas:

- `docs/00-vision/` - product thesis, operator overview, and whitepaper.
- `docs/10-hermes/` - Hermes prompt architecture, `docs/10-hermes/SOUL.md`, profile setup, and context strategy.
- `docs/20-system-spec/` - architecture, domain contracts, channel operations, risk, metrics, and tool boundaries.
- `docs/30-operations/` - environment setup, tech stack, deployment runbook, and secrets policy.
- `docs/40-agents/` - subagent execution plan and preserved source agent/skill specs.
- `docs/50-rollout/` - phased checklist, acceptance criteria, and risk register.
- `docs/60-models/` - model cards and runtime selection notes.
- `docs/diagrams/` - Mermaid diagram index and authoring rules.

## Product Thesis

New Showbiz is a structured movie-discovery product whose live promise is:

> Watch more of what matters to you.

The product has a browsable and searchable movie catalog, movie detail pages, AI-generated inclusivity profiles, representation dimensions, overall and category scores, detail explanations, strengths, areas for improvement, watch-provider links, account flows, contact paths, and support surfaces.

Do not describe the project as a generic social bot. It is a governed marketing operator for a structured movie-discovery and inclusivity-profile product.

## Runtime Boundary

Hermes Agent is the runtime substrate, not the business product.

Hermes provides agent execution, prompt assembly, sessions, cron, tool registry, memory, skills, plugins, MCP, gateway, profile isolation, approvals, and execution controls.

New Showbiz must provide X and Instagram integrations, channel inbox reads, media upload and scheduling behavior, content and engagement persistence, escalation and incident records, metrics and attribution joins, and policy rules for high-risk cases.

Never imply that Hermes natively solves X or Instagram publishing for this project. Public channel actions require explicit custom plugins, MCP wrappers, or service-adapter tools.

## Documentation Authority

Read and preserve the operator docs in this order:

1. `docs/10-hermes/HERMES_PROMPT_ARCHITECTURE.md`
2. `docs/00-vision/operator-overview.md`
3. `docs/20-system-spec/product-spec.md`
4. `docs/20-system-spec/architecture.md`
5. `docs/20-system-spec/implementation-spec.md`
6. `docs/20-system-spec/domain-contracts.md`
7. `docs/20-system-spec/risk-guardrails-and-escalation.md`
8. `docs/20-system-spec/personas-and-behavior-modes.md`
9. `docs/20-system-spec/channel-operations.md`
10. `docs/20-system-spec/metrics-and-reporting.md`
11. `docs/20-system-spec/x-mcp-options-and-discussions.md`
12. `docs/50-rollout/phased-checklist.md`

When docs conflict, prefer the more specific operational document over the more general strategic document.

## Brand and Voice Rules

- Public brand is always `New Showbiz`.
- Write like a film critic who has watched the work, not like a system summarizing a document.
- Keep copy objective, brief, concrete, accessible, movie-literate, and confident without overclaiming.
- Use the Kakusu Protocol: frame representation analysis as professional cinematic analysis, not advocacy.
- Avoid loaded labels such as `subversive`, `political activism`, `woke`, `progressive`, and `DEI`.
- Do not fabricate plot points, characters, relationships, identities, quotes, social proof, or urgency.
- Do not imply scores are official, endorsed, or empirically definitive.
- Maximum two topical hashtags per post unless source notes document a specific exception.

## Risk Rules

Escalate or block:

- money terms beyond approved donation information
- tax, refund, investment, or wallet-choice advice around crypto support
- partnership, sponsorship, affiliate, or collaboration terms
- legal threats or legal claims
- creator complaints
- invalid diversity analysis reports requiring review
- factual disputes requiring validation
- identity-sensitive conflict involving protected or vulnerable groups
- platform-policy warnings
- high-visibility backlash
- unsupported claims
- any `TROLL` output crossing risk thresholds

Donation/support language is constrained: New Showbiz is independent; contributions are not tax-deductible charitable donations; crypto transactions are irreversible and non-refundable; do not provide tax, investment, or financial advice.

## Tool Routing

- Local documentation edits: file tools first.
- Lightweight inspection: shell second.
- External verification: web or connector tools only when current facts matter.
- X and Instagram writes: dedicated reviewed toolset wrappers only.
- Telegram: oversight and approval only, never a public publishing path.

## Data and Persistence

Hermes sessions are trace material, not business truth. Durable business records must live outside Hermes core:

- `ContentJob`
- `EngagementJob`
- `EscalationRecord`
- `PerformanceSnapshot`
- channel receipts
- incident records
- source evidence references
- account activation metrics
- donation and support metrics

Cron prompts must be self-contained or fetch durable state.

## Editing Rules

- Keep Markdown operational and implementation-ready.
- Preserve one H1 per Markdown file.
- Keep `.env` local and secret-bearing.
- Use `.env.example` and redacted env docs for setup guidance.
- Do not reintroduce runnable scaffolding into this documentation package unless the user explicitly asks to convert it back into an implementation repo.

