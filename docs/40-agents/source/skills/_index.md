---
title: Skill Registry
record_type: skill-index
status: canonical
canonical_path: agents/skills/_index.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-20
---

# Skill Registry

Reusable procedures distilled from live agent work. All skills are stored in the **Hermes/agentskills.io SKILL.md format** (default) and can be exported to any supported framework format on demand.

Any agent may invoke a registered skill by routing through [ExecuteAgent](../roster/execute-agent.md) or citing the skill file path directly.

## Format Reference

See [`agents/skills/_formats.md`](_formats.md) for:
- Full annotated SKILL.md template (default format)
- Hermes `<tools>` XML inference-time format
- Conversion tables and templates for: OpenAI, Anthropic, LangChain, CrewAI, AutoGen, MCP
- Decompose procedure (SKILL.md → any target format)
- Reform procedure (any framework definition → SKILL.md)

To convert a skill: route to [SkillBuildingAgent](../roster/skill-builder.md) with the skill name and target framework.

## Registry

| Name | Description | Status | Added | Proposed By |
|------|-------------|--------|-------|-------------|
| [vault-query-routing](vault-query-routing.md) | Route vault queries through the index hierarchy (MASTER_INDEX → section → ledger) before opening content files | validated | 2026-05-20 | orchestrator |
| [session-log-write](session-log-write.md) | Write or append to the session log for the current date; handles task-close, pre-op-snapshot, failure, and escalation entry types | validated | 2026-05-20 | orchestrator |
| [ledger-update](ledger-update.md) | Add or update an entry in any of the 7 canonical vault ledgers; requires pre-op snapshot and drift-check | validated | 2026-05-20 | ingest-agent |
| [record-create](record-create.md) | Create a new canonical record file from template with schema validation; always followed by ledger-update and drift-check | validated | 2026-05-20 | ingest-agent |
| [drift-check](drift-check.md) | Verify ledger entries, _index.md listings, and canonical_path resolution after any write that changes file structure | validated | 2026-05-20 | lint-agent |

## How Skills Enter the Registry

1. An agent appends a `skill-proposal` (pre-structured in SKILL.md format) to `agents/queues/improvement-queue.md`.
2. [SkillBuildingAgent](../roster/skill-builder.md) validates: skill must be invocable by at least two agents or two pipeline families.
3. If valid: SkillBuildingAgent writes `agents/skills/<name>.md` and registers it here with `status: draft`.
4. The skill is immediately available to all agents via ExecuteAgent.

## Skill Lifecycle

| Status | Meaning |
|--------|---------|
| `draft` | Constructed but not yet confirmed by a second invocation |
| `validated` | Successfully invoked in at least two distinct tasks |
| `stable` | No changes required across three or more task cycles |

Skills may be promoted by SkillBuildingAgent when evidence from the improvement queue confirms usage. Do not promote manually without invocation evidence.
