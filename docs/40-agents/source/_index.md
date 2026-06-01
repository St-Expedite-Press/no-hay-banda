---
title: Agent System Index
record_type: agent-index
status: canonical
canonical_path: agents/_index.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-06-01
---

# Agent System Index

Canonical routing surface for the New Showbiz agent system.

## Entry Points

- [Orchestrator](orchestrator.md) — central router for content creation, engagement triage, metrics, and self-improvement tasks
- [Agent Roster](roster/_index.md) — specialist and subagent directory

## Shared Contract

All agents in this system must:

1. Read their own spec file in full before proceeding with any task.
2. Use the minimum context needed — pass only task-specific state to workers.
3. Respect the prompt placement contract in `docs/10-hermes/profile-and-prompt-strategy.md`.
4. Preserve source evidence for all factual and score-based claims.
5. Return structured outputs with status, claims, artifacts, and blockers.
6. Update affected indexes and control surfaces in the same pass as substantive changes.
7. At task close: if a reusable procedure was executed that has no entry in `agents/skills/_index.md`, append a `skill-proposal` to `agents/queues/improvement-queue.md`.
8. At task close: if a gap in your own spec materially complicated the task, append a targeted `agent-refinement` proposal to `agents/queues/improvement-queue.md`.

## Pipeline Families

New Showbiz operator pipelines:

- Simple task fast path: `User / Interrogator -> Orchestrator -> ExecuteAgent / one specialist -> ReportAgent`
- Content creation: `Interrogator -> Orchestrator -> MovieResearchAgent -> ContentAgent -> ValidateAgent -> PublishAgent -> ReportAgent`
- Scheduled publishing: `Cron -> Orchestrator -> ContentAgent -> ValidateAgent -> PublishAgent -> MetricsAgent`
- Engagement triage: `Orchestrator -> EngagementAgent -> EscalationAgent or MetricsAgent`
- Factual dispute: `EngagementAgent -> EscalationAgent -> MovieResearchAgent -> human review -> ReportAgent`
- Metrics reporting: `Orchestrator -> MetricsAgent -> AnalysisAgent -> ReportAgent`
- Python standards review: `Orchestrator -> PythonStandardsAgent -> ReportAgent`
- Generative composition: `Orchestrator -> ComposerAgent -> ReportAgent`
- Self-improvement: `Any Agent -> improvement-queue -> Orchestrator -> SkillBuildingAgent -> ReportAgent`

## Shared Status Vocabulary

- `CLEAR` — safe to proceed
- `BLOCKED` — do not continue without user input or policy change
- `PARTIAL` — usable but incomplete
- `INSUFFICIENT` — evidence does not support a claim yet
- `NO BASELINE` — comparison requested without a prior state
- `COMPLETE` — taskable handoff returned with no blocker

## Tool Routing

- New Showbiz source data: `newshowbiz_read` toolset
- X reads: `mcp-x-mcp-read` toolset (Barresider) or `mcp-twitter-mcp` (experimental)
- X writes: `mcp-x-mcp-write` toolset — disabled until Phase 3
- Browser QA: `playwright` MCP (global) or `mcp-twitter-mcp` fallback
- Escalation records: `newshowbiz_escalation` toolset
- Metrics and reporting: `newshowbiz_metrics_read`, `newshowbiz_reporting` toolsets

Last updated: 2026-06-01 — rewritten for New Showbiz operator; removed stale vault OS references.
