---
title: Improvement Queue
record_type: queue
status: canonical
canonical_path: agents/queues/improvement-queue.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-20
---

# Improvement Queue

Pending skill proposals and agent refinement proposals. Proposals are appended by agents at task close and reviewed by a human before promotion to a `SKILL.md` file.

---

## Skill Proposal Entry Format

Skill proposals are pre-structured in SKILL.md format (see [`agents/skills/_formats.md`](../skills/_formats.md)) to minimize transformation work for SkillBuildingAgent.

```
## [YYYY-MM-DD] type: skill-proposal
proposed_by: agent-name
task_context: one-line summary of the task that surfaced this
status: pending | applied | rejected

### Proposal

name: kebab-case-name
description: |
  One-sentence purpose. Include domain, capabilities, and trigger phrases.
version: 1.0.0
platforms: [omit if platform-agnostic]
required_environment_variables: [omit if none]

#### When to Use
[trigger conditions; when NOT to use]

#### Inputs
| Name | Type | Required | Description |
|------|------|----------|-------------|

#### Procedure
1.
2.

#### Pitfalls
[known failure modes]

#### Verification
[how to confirm correctness]

#### Outputs
[what the skill produces]

#### Examples
[concrete worked examples]

durability_rationale: why this qualifies (invocable by ≥2 agents or ≥2 pipeline families)
```

---

## Agent Refinement Entry Format

```
## [YYYY-MM-DD] type: agent-refinement
proposed_by: agent-name
task_context: one-line summary of the task that surfaced this
status: pending | applied | rejected

### Proposal

target_agent: agents/roster/agent-name.md
target_section: ## Section Name
proposed_change: |
  [Exact text to add, replace, or remove. Quote the existing text if replacing.]
gap_resolved: |
  [The specific gap, ambiguity, or missing guardrail that caused friction in this task.]
```

---

## When to Append

**Skill proposal** — append at subtask or task close if:
- A reusable procedure was executed that has no matching entry in `agents/skills/_index.md`
- The procedure is likely to be invocable in at least two agents or two pipeline families

**Agent refinement** — append at subtask or task close if:
- A gap, ambiguity, or missing guardrail in your own spec materially complicated the task
- You can identify the specific section and proposed change

Do not append entries for routine execution. Only propose when there is a genuine gap or reusable procedure.

---

## Pending

_(none)_

---

## Applied

_(none)_

---

## Rejected

_(none)_
