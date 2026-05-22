---
title: Agent System Index
record_type: agent-index
status: canonical
canonical_path: agents/_index.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-18
---

# Agent System Index

Canonical routing surface for the live agent system outside `infernalis/`.

## Entry Points

- [Orchestrator](orchestrator.md) - central router for vault, research, ingest, maintenance, and composition tasks
- [Agent Roster](roster/_index.md) - specialist and subagent directory

## Shared Contract

All agents in this system must:

1. Obey the root session loop in [`legacy Claude context file`](../legacy Claude context file).
2. Route through [`infernalis/_Index/MASTER_INDEX.md`](../infernalis/_Index/MASTER_INDEX.md) before broad vault reading.
3. Use the minimum relevant section index, ledger, queue, report, summary, or local `_index.md` before opening content notes.
4. Respect authored writing as human-owned unless the user explicitly asks for revision.
5. Update changed control surfaces in the same pass when they materially drift.
6. Prefer canonical records, ledgers, and indexes over ad hoc narrative notes when establishing machine truth.
7. At subtask or task close: if a reusable procedure was executed that has no entry in `agents/skills/_index.md`, append a `skill-proposal` to `agents/queues/improvement-queue.md`.
8. At subtask or task close: if a gap or ambiguity in your own spec materially complicated the task, append a targeted `agent-refinement` proposal to `agents/queues/improvement-queue.md`.

## Pipeline Families

- Vault query: `Interrogator -> Orchestrator -> QueryAgent -> ReportAgent`
- Source ingest: `Interrogator -> Orchestrator -> ValidateAgent -> FetchAgent -> TransformAgent -> IngestAgent -> ReportAgent`
- Structural maintenance: `Interrogator -> Orchestrator -> QueryAgent / LintAgent / DiffAgent / ConceptAgent -> ReportAgent`
- Historical research: `Interrogator -> Orchestrator -> ResearchPageAgent -> HistorianAgent -> ReportAgent`
- Generative composition: `Interrogator -> Orchestrator -> ComposerAgent -> ReportAgent`
- Translation: `Interrogator -> Orchestrator -> ComposerTranslatorAgent -> ReportAgent`
- Reusable workflow execution: `Interrogator -> Orchestrator -> ExecuteAgent -> ReportAgent`
- Self-improvement: `Any Agent -> improvement-queue -> Orchestrator -> SkillBuildingAgent -> ReportAgent`

## Shared Status Vocabulary

- `CLEAR` - safe to proceed
- `BLOCKED` - do not continue without user input or policy change
- `PARTIAL` - usable but incomplete
- `INSUFFICIENT` - evidence does not support a claim yet
- `NO BASELINE` - comparison requested without a prior state
- `COMPLETE` - taskable handoff returned with no blocker

## Tool Routing

- Vault-local reading and editing: local file tools first
- Lightweight inspection and automation: shell second
- External verification or acquisition: web or connector tools only when needed
- Drive or other remote systems: treat as external sources, then ingest into canonical vault surfaces if the task calls for permanence

Last updated: 2026-05-20 - added self-improvement loops to shared contract and pipeline families; added SkillBuildingAgent.

