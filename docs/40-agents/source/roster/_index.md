---
title: Agent Roster Index
record_type: agent-index
status: canonical
canonical_path: agents/roster/_index.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-23
part_of:
  - agent-system
---

# Agent Roster Index

Directory of specialist agents dispatched by the orchestrator. Annealed for the New Showbiz marketing operator on 2026-05-20.

## Intake

- [Interrogator](interrogator.md) — task clarification and brief production

## New Showbiz Marketing

Core marketing operator pipeline agents.

- [ContentAgent](content-agent.md) — generate policy-checked social content from movie and product data
- [PublishAgent](publish-agent.md) — route approved ContentJobs through toolsets; return durable receipts
- [EngagementAgent](engagement-agent.md) — read channel inbox; classify mentions and replies; trigger escalation
- [EscalationAgent](escalation-agent.md) — hold flagged items; write EscalationRecords; route to human review
- [MetricsAgent](metrics-agent.md) — collect PerformanceSnapshots; attribution joins; content-angle feedback

## Acquisition and Processing

General-purpose agents adapted for New Showbiz data and content flows.

- [ValidateAgent](validate-agent.md) — content policy, brand rules, and ToS preflight
- [FetchAgent](fetch-agent.md) — fetch product data from newshow.biz; channel reads via approved toolsets
- [TransformAgent](transform-agent.md) — normalize product data into content briefs; format for channel targets
- [AnalysisAgent](analysis-agent.md) — metrics analysis, attribution scoring, and performance computation
- [MovieResearchAgent](movie-research-agent.md) — research film context, cast, reception, and representational claims before content creation

## Operations

- [LintAgent](lint-agent.md) — audit ContentJob receipts, EscalationRecords, and routing drift
- [PythonStandardsAgent](python-standards-agent.md) — define and review Python coding standards, tooling policy, typing expectations, testing practices, and maintainability guidance with evidence-scored recommendations
- [QueryAgent](query-agent.md) — answer questions about content history, prior posts, and deduplication
- [DiffAgent](diff-agent.md) — compare metrics periods; detect engagement anomalies
- [DistillAgent](distill-agent.md) — evaluate completed tasks for reusable procedure candidates
- [ExecuteAgent](execute-agent.md) — run known procedures from the live skill registry; preferred executor for simple known procedures
- [ReportAgent](report-agent.md) — format and deliver output while preserving blockers

## System Improvement

- [SkillBuildingAgent](skill-builder.md) — construct skills from proposals; apply agent refinements; convert between framework formats (Hermes, OpenAI, Anthropic, LangChain, CrewAI, AutoGen, MCP)

## Specialist

- [ComposerAgent](composer.md) — literary and editorial voice work; primary brand voice for marketing copy requiring the Composer register
- [ComposerTranslatorAgent](composer-translator.md) — Golden Age Castilian into Composer register

## Archived (vault-oriented; not active for New Showbiz)

These agents were built for the Sandbatch Vault Knowledge OS. They are preserved in `archive/` for reference and framework portability but are not part of the active New Showbiz operator roster.

- `archive/ingest-agent.md` — vault source and record formalization
- `archive/concept-agent.md` — vault concept promotion
- `archive/librarian-agent.md` — vault organizational completeness
- `archive/historian.md` — structural historical analysis
- `archive/research-page.md` — archival retrieval (superseded by MovieResearchAgent)

Last updated: 2026-05-23 — Added Simple Task Fast Path support and PythonStandardsAgent; roster examples remain preserved across active and archived specs.
