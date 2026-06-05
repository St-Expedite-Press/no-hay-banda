---
title: Agent System Index
record_type: agent-index
status: canonical
canonical_path: agents/_index.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-06-05
---

# Agent System Index

Canonical routing surface for the New Showbiz agent system.

## Entry Points

- [Orchestrator](orchestrator.md) — Tier 1 pipeline agent; classifies tasks, constructs pipelines, validates outputs
- [Agent Roster](roster/_index.md) — full specialist and subagent directory with tier assignments
- [Tier Architecture](../../10-hermes/tier-architecture.md) — three-tier execution model (Tier 0/1/2)

## Tier Architecture Summary

| Tier | Count | Role | Spawn Authority |
|------|-------|------|-----------------|
| 0 | 1 | Session Director (SOUL.md) | Routes to Tier 1 and Tier 2 |
| 1 | 7 | Pipeline Agents | Can spawn Tier 2 subagents |
| 2 | 21 | Subagents / leaf nodes | Cannot delegate further |

**Config:** `delegation.max_spawn_depth: 2`

## Shared Contract

All agents in this system must follow [`_shared-contract.md`](_shared-contract.md):

1. Read their own spec file in full before proceeding
2. Use minimum context — pass only task-specific state to workers
3. Respect the prompt placement contract in `docs/10-hermes/profile-and-prompt-strategy.md`
4. Preserve source evidence for all factual and score-based claims
5. Return structured outputs: `status`, `claims`, `artifacts`, `blockers`
6. Anti-fabrication: report tool failures honestly; never substitute invented data
7. Closing Loops: propose skills for reusable procedures; propose spec updates for gaps

## Pipeline Families

| Pipeline | Agents involved | Tier flow |
|---|---|---|
| Simple fast path | Session Director → any Tier 2 agent | 0 → 2 |
| Content creation | ContentAgent → validate → draft → report | 0 → 1 → 2 |
| Publish with receipt | PublishAgent → validate → publish → report | 0 → 1 → 2 |
| Metrics snapshot | MetricsAgent → analysis → report | 0 → 1 → 2 |
| Data capture | FetchAgent → validate → fetch → transform → report | 0 → 1 → 2 |
| Project coordination | ProjectManager → [specialist agents] → report | 0 → 1 → 2 |
| Engagement triage | Session Director → engagement-agent → escalation-agent | 0 → 2 → 2 |
| Factual dispute | engagement-agent → escalation-agent → movie-research-agent → human | 2 → 2 → 2 |
| Ambiguous task | Session Director → orchestrator → [planned pipeline] | 0 → 1 → 2 |

## Shared Status Vocabulary

| Status | Meaning |
|--------|---------|
| `COMPLETE` | Task finished successfully |
| `BLOCKED` | Cannot proceed; dependency missing or tool failed |
| `PARTIAL` | Task partially done; remaining work documented |
| `INSUFFICIENT` | Input was insufficient to complete the task |
| `NO_BASELINE` | No prior state to compare against |
| `CLEAR` | No action needed; info-only response |
| `HOLD` | Escalation triggered; held for human review |

## Tool Routing

- New Showbiz source data: `newshowbiz_read` toolset
- X reads: `mcp-x-mcp-read` toolset (Barresider) or `mcp-twitter-mcp` (experimental)
- X writes: `mcp-x-mcp-write` toolset — disabled until Phase 3
- Browser QA: `playwright` MCP (global) or `mcp-twitter-mcp` fallback
- Escalation records: `newshowbiz_escalation` toolset

*Last updated: 2026-06-05 — restructured for three-tier execution model; added tier table, updated pipeline families.*
