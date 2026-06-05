# Agent Execution Tier Architecture

*Implemented 2026-06-05. Replaces the previous flat single-tier roster.*

---

## Overview

The New Showbiz agent system uses a three-tier execution model that maps directly to Hermes's `max_spawn_depth` config. Tier determines spawn authority — which agents can call `delegate_task` and which cannot.

```
┌─────────────────────────────────────────────────────────────┐
│  TIER 0 — Session Director (SOUL.md)                        │
│  User-facing. Routes to Tier 1 or Tier 2 directly.         │
│  Tracks task board. Relays results to user.                 │
├─────────────────────────────────────────────────────────────┤
│  TIER 1 — Pipeline Agents (7)                               │
│  Manage multi-step workflows. CAN spawn Tier 2 subagents.   │
│  Return consolidated results to Tier 0.                     │
├─────────────────────────────────────────────────────────────┤
│  TIER 2 — Subagents / Leaf Nodes (21)                       │
│  Atomic executors. CANNOT delegate further.                 │
│  Return structured output to whoever called them.           │
└─────────────────────────────────────────────────────────────┘
```

**Config:** `delegation.max_spawn_depth: 2` in `~/.hermes/config.yaml`

---

## Tier 0 — Session Director

**File:** `~/.hermes/SOUL.md`

The user-facing orchestrator. Receives all requests, routes to the appropriate tier, maintains the task board, verifies artifact claims, and relays results. Never performs specialist work directly.

---

## Tier 1 — Pipeline Agents

These 7 agents manage multi-step workflows and are authorized to spawn Tier 2 subagents via `delegate_task`.

| Agent | Pipeline | Authorized Tier 2 Subagents |
|---|---|---|
| **Orchestrator** | classify → plan → route | All Tier 2 |
| **ContentAgent** | validate → draft → report | validate-agent, writer, compose, movie-research-agent, report-agent, escalation-agent |
| **PublishAgent** | validate → publish → report | validate-agent, report-agent, escalation-agent |
| **MetricsAgent** | collect → analysis → report | analysis-agent, query-agent, report-agent |
| **FetchAgent** | validate → fetch → transform → report | validate-agent, transform-agent, report-agent |
| **DistillAgent** | evaluate → skill-builder → report | skill-builder, report-agent |
| **ProjectManager** | plan → dispatch → consolidate | All Tier 2 |

---

## Tier 2 — Subagents

These 21 agents are atomic leaf-node executors. They do not call `delegate_task`.

| Agent | Domain |
|---|---|
| interrogator | Intake / clarification |
| researcher | Web research |
| movie-research-agent | Film evidence |
| compose | Literary voice (C. Composer) |
| writer | General prose |
| composer-translator | Translation |
| designer | Visual / diagrams |
| editor | Editing / proofreading |
| analysis-agent | Data computation |
| query-agent | Vault lookups |
| diff-agent | Snapshot comparison |
| validate-agent | Access / schema gating |
| transform-agent | Normalization |
| lint-agent | Structural health |
| python-standards-agent | Code standards |
| execute-agent | Known procedure execution |
| engagement-agent | Inbox triage |
| escalation-agent | Risk incident handling |
| skill-builder | Skill construction |
| report-agent | Output formatting |
| librarian | Vault / PKM |

---

## Routing Decision

SOUL.md routes using this priority:

1. **Single atomic task** → delegate directly to the correct Tier 2 agent
2. **Multi-step pipeline** → delegate to the appropriate Tier 1 pipeline agent
3. **Ambiguous or cross-domain** → delegate to **Orchestrator** for classification

The canonical routing table is in [`_routing.md`](_routing.md) (see `docs/40-agents/source/`).

---

## Shared Contract

All agents at all tiers are governed by [`_shared-contract.md`](_shared-contract.md). Key rules:

- Every response must include `status`, `claims`, `artifacts`, `blockers`
- Tier 2 agents CANNOT call `delegate_task`
- Tier 1 agents must validate every Tier 2 output before returning it upstream
- Anti-fabrication: if a tool call fails, report the blocker — never substitute invented data

---

## Why This Structure

**Before (flat):** SOUL.md routed directly to all 21 agents. Multi-step pipelines (content → validate → publish → receipt) had to be orchestrated manually by SOUL.md turn by turn, with no intermediate coordinator to validate stages.

**After (tiered):** Tier 1 pipeline agents own their workflow end-to-end. SOUL.md dispatches once and gets back a consolidated, validated result. Intermediate failures surface within the pipeline agent, not as raw errors to the user.

**Cost tradeoff:** Tier 1 agents use the subagent model (`deepseek/deepseek-v4-flash`), so multi-step pipelines spawn multiple V4 Flash calls. For complex pipelines this is acceptable — V4 Flash is fast and cheap. For simple single-step tasks, route directly to Tier 2 to avoid the Tier 1 coordination overhead.
