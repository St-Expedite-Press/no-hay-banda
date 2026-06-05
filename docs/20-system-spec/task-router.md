# TaskRouter

## Purpose

TaskRouter is the callable specification of `_routing.md`. It defines the input contract, resolution algorithm, and fallback behavior for routing any incoming task to the correct Tier 1 or Tier 2 agent pipeline. Where `_routing.md` is the registry of agent-to-task mappings, TaskRouter is the executable interface that the Session Director (Tier 0) and orchestrator invoke to resolve a task_type to a concrete agent and pipeline pattern. It is stateless: each call takes an input object and returns a routing decision.

## Input Contract

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `task_type` | string | yes | The canonical task identifier. May be a known task_type, an alias, or a free-form label to be classified. |
| `context` | object | no | Task description and any available metadata (e.g., source text, objective, platform). Used for disambiguation when task_type is ambiguous. |
| `source_record_id` | string | no | ID of a ContentJob or EngagementJob that spawned this task. Included when the routing call originates from a running pipeline rather than a direct user request. |

## Resolution Algorithm

1. **Normalize.** Convert task_type to lowercase. Strip leading and trailing whitespace.
2. **Exact match.** Look up the normalized task_type in the canonical routing table. If found, return the matched agent, tier, and pipeline. Set confidence to `high`.
3. **Alias match.** If no exact match, check slash-separated alternatives in the routing table (e.g., `research / fact-check / broad`). If an alias matches, return the associated agent, tier, and pipeline. Set confidence to `medium`.
4. **Researcher fallback.** If no alias match, route to `researcher` for broad or general tasks. Set confidence to `medium` and set `fallback_used` to `true`.
5. **Orchestrator classification.** If the researcher cannot handle the task (returns `INSUFFICIENT` or `BLOCKED`), delegate to `orchestrator` for DAG construction and classification across the full agent roster. Set confidence to `medium` and `fallback_used` to `true`.
6. **Return to user.** If the orchestrator also returns `INSUFFICIENT`, halt routing and return a `BLOCKED` status to the caller. See Escalation section below.

## Output Contract

| Field | Description |
|-------|-------------|
| `agent` | Resolved agent name (e.g., `content-agent`, `escalation-agent`, `researcher`). |
| `tier` | Agent tier: `1` (pipeline agent, may spawn subagents) or `2` (leaf subagent, no further delegation). |
| `pipeline` | Execution pattern: `simple` for single-agent tasks, or an explicit pipeline string such as `validate → content → publish → report`. |
| `confidence` | `high` if the task_type matched exactly; `medium` if resolved via alias, researcher fallback, or orchestrator classification. |
| `fallback_used` | `true` if resolution required researcher fallback or orchestrator classification; `false` on an exact or alias match. |

## Fast Path

For single-hop, low-risk tasks, the Session Director may skip DAG construction and route directly to the resolved agent. The fast path applies when all of the following conditions are met:

- The task_type produced an exact match (confidence is `high`).
- The resolved agent is Tier 2 (no subagent spawning required).
- The pipeline pattern is `simple`.
- No `source_record_id` is present (task is not part of a running ContentJob or EngagementJob pipeline).
- The task context contains no risk flags and no escalation indicators.

When the fast path is taken, the Session Director passes the task directly to the Tier 2 agent and does not construct a full pipeline DAG. The output contract is otherwise identical.

## Escalation

If resolution fails after all fallbacks — meaning the orchestrator returns `INSUFFICIENT` — the task is returned to the user with a `BLOCKED` status and a clarification request. The clarification request must identify what additional context would allow routing to succeed (e.g., a more specific task_type, a source record reference, or disambiguation between two candidate pipelines). No agent action is taken and no ContentJob or EngagementJob record is written for the failed routing attempt.
