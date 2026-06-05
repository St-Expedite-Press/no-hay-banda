# Routing Registry — Agent Dispatch Map

*Single source of truth for task-to-agent routing. Read by SOUL.md and Orchestrator to determine which agent or pipeline handles a given task type.*

---

## Tier Architecture

| Tier | Role | Spawn Authority |
|------|------|-----------------|
| **0** | SOUL.md (Session Director) | Routes to Tier 1 and Tier 2 |
| **1** | Pipeline Agents | Can spawn Tier 2 subagents |
| **2** | Subagents (leaf nodes) | Cannot delegate further |

---

## Pipeline Patterns

| Pattern | Description |
|---------|-------------|
| `simple` | Single agent handles the task end-to-end |
| `A → B → C` | Multi-step; output of A feeds B, output of B feeds C |

---

## Shared Status Vocabulary

All agents MUST return one of these status codes (see `_shared-contract.md` for full definitions):

| Status | Meaning |
|--------|---------|
| `COMPLETE` | Task finished successfully |
| `BLOCKED` | Cannot proceed; dependency missing or tool failed |
| `PARTIAL` | Task partially done; remaining work documented |
| `INSUFFICIENT` | Input was insufficient |
| `NO_BASELINE` | No prior state to compare against |
| `CLEAR` | No action needed; info-only response |
| `HOLD` | Escalation triggered; held for human review |

---

## Routing Table

| task_type | agent | tier | pipeline |
|-----------|-------|------|----------|
| `clarify` / `disambiguate` | interrogator | 2 | simple |
| `research` / `fact-check` / `broad` / `query` / `lookup` | researcher | 2 | simple |
| `film_research` / `structured_research` / `evidence` | movie-research-agent | 2 | simple |
| `write` / `creative` / `general_writing` / `essay` / `criticism` | writer | 2 | simple |
| `edit` / `proofread` / `review_writing` | editor | 2 | simple |
| `analyze` / `compute` / `compare` | analysis-agent | 2 | simple |
| `diff` / `changes` / `compare_versions` | lint-agent | 2 | simple |
| `validate` / `check` | validate-agent | 2 | simple |
| `fetch` / `capture` | fetch-agent | 1 | validate → fetch → transform → report |
| `transform` / `normalize` | transform-agent | 2 | simple |
| `lint` / `health_check` / `audit` | lint-agent | 2 | simple |
| `execute` / `run_procedure` | execute-agent | 2 | simple |
| `generate_content` / `social_post` | content-agent | 1 | validate → content → publish → report |
| `publish` / `post` | publish-agent | 1 | validate → publish → report |
| `metrics` / `performance` / `analytics` | metrics-agent | 1 | metrics → analysis → report |
| `escalate` / `flag` / `risk` | escalation-agent | 2 | simple |
| `inbox` / `engagement` / `mentions` | engagement-agent | 2 | simple |
| `plan` / `project` / `coordinate` | project-manager | 1 | plan → [specialist agents] → report |
| `report` / `format_output` | report-agent | 2 | simple |
| *ambiguous / multi-domain* | orchestrator | 1 | classify → pipeline → execute |

---

## Task Resolution Algorithm

```
1. Normalize task_type to lowercase
2. Try exact match against canonical task_type
3. If no match, try alias match (slash-separated alternatives)
4. If no match, fall back to researcher for broad/general tasks
5. If researcher also cannot handle, delegate to orchestrator for classification
6. If orchestrator returns INSUFFICIENT, return to user for clarification
```

---

## Tier 1 Agent Authorized Subagents

Each Tier 1 agent may only spawn the subagents listed here:

| Tier 1 Agent | Authorized Tier 2 Subagents |
|---|---|
| **orchestrator** | All Tier 2 agents |
| **content-agent** | validate-agent, movie-research-agent, writer, editor, report-agent, escalation-agent |
| **publish-agent** | validate-agent, report-agent, escalation-agent |
| **metrics-agent** | analysis-agent, report-agent |
| **fetch-agent** | validate-agent, transform-agent, report-agent |
| **project-manager** | All Tier 2 agents |

---

## Agent Roster Summary

| Category | Count |
|----------|-------|
| Tier 0 (Session Director) | 1 |
| Tier 1 (Pipeline Agents) | 6 |
| Tier 2 (Subagents) | 13 |
| **Total** | **20** |

**Tier 1:** orchestrator, content-agent, publish-agent, metrics-agent, fetch-agent, project-manager

**Tier 2:** analysis-agent, editor, engagement-agent, escalation-agent, execute-agent, interrogator, lint-agent, movie-research-agent, report-agent, researcher, transform-agent, validate-agent, writer

---

*Last updated: 2026-06-05*
