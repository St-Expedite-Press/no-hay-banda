# Diagram Index

Mermaid is the standard diagram format for this package. Diagrams should live next to the spec text they clarify. This directory is only the index and authoring contract.

## Authoring Rules

- Use Mermaid fenced blocks in Markdown.
- Put diagrams near the requirements they explain.
- Prefer flowcharts for workflows, sequence diagrams for handoffs, and entity diagrams for domain records.
- Every diagram must name real package concepts: Hermes profile, ContentJob, EngagementJob, EscalationRecord, PerformanceSnapshot, Policy Engine, PublishAgent, channel wrapper tools, receipts.
- Do not add decorative diagrams. A diagram must clarify ownership, sequence, risk, or state.

## Required Diagram Set

| Required diagram | Canonical location | Purpose |
|---|---|---|
| Documentation package map | `README.md` | Explain how to read the package |
| Prompt assembly tiers | `docs/10-hermes/profile-and-prompt-strategy.md` | Separate stable, context, volatile, and ephemeral instructions |
| Hermes profile loading | `docs/10-hermes/hermes-profile-setup.md` | Show profile files, env, skills, and gateway config |
| Full operator architecture | `docs/20-system-spec/implementation-spec.md` | Show runtime, domain, tools, channels, and outcomes |
| Domain record relationships | `docs/20-system-spec/domain-contracts.md` | Show ContentJob, EngagementJob, EscalationRecord, PerformanceSnapshot |
| Outbound content flow | `docs/20-system-spec/implementation-spec.md` | Show draft to policy to publish to receipt |
| Inbound engagement flow | `docs/20-system-spec/implementation-spec.md` | Show inbox item to classification to action |
| Metrics attribution flow | `docs/20-system-spec/metrics-and-reporting.md` | Show post metrics joined to site and support outcomes |
| Toolset permission boundary | `docs/20-system-spec/tool-boundaries.md` | Keep read and write capabilities separate |
| Secrets lifecycle | `docs/30-operations/secrets-policy.md` | Show local env, profile env, runtime tools, and redaction |
| Documentation update loop | `docs/40-agents/subagent-execution-plan.md` | Show scope, consistency, evidence, safety, verification, and reporting flow |
| Subagent DAG | `docs/40-agents/subagent-execution-plan.md` | Show implementation delegation order |
| Rollout dependency graph | `docs/50-rollout/acceptance-criteria.md` | Show phase gates and blockers |
