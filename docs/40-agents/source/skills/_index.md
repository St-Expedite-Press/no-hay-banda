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

### New Showbiz domain skills

| Name | Description | Status | Added | Proposed By |
|------|-------------|--------|-------|-------------|
| [content-draft-from-movie-data](content-draft-from-movie-data.md) | Turn a New Showbiz movie page or research memo into channel-ready draft variants for X | validated | 2026-05-21 | orchestrator |
| [content-job-write](content-job-write.md) | Write a ContentJob JSON to the Phase 1 flat-file store; places in jobs/ and review-queue/ | draft | 2026-06-05 | project-manager |
| [escalation-record-write](escalation-record-write.md) | Write an EscalationRecord JSON when a risk trigger fires; outputs HOLD notice | draft | 2026-06-05 | project-manager |
| [review-decision-record](review-decision-record.md) | Record a human approve/reject/revise decision; moves file, updates status, appends review-log.jsonl | draft | 2026-06-05 | project-manager |
| [x-publish-with-receipt](x-publish-with-receipt.md) | Publish an approved ContentJob through newshowbiz_x_publish_reviewed and return a durable receipt | validated | 2026-05-21 | orchestrator |
| [escalation-record-create](escalation-record-create.md) | Create an EscalationRecord when a ContentJob or EngagementJob triggers a risk class that blocks autonomous action | validated | 2026-05-21 | orchestrator |

### Vault infrastructure skills (portable, path-adapted)

These skills were developed for the Sandbatch Vault OS and are portable to any file-based vault structure. Before using them in a New Showbiz deployment, replace the hardcoded `infernalis/` path references with the actual store root (see `docs/20-system-spec/modules/vault.md`).

| Name | Description | Status | Added | Proposed By |
|------|-------------|--------|-------|-------------|
| [vault-query-routing](vault-query-routing.md) | Route vault queries through the index hierarchy before opening content files; prevents broad reads | validated | 2026-05-20 | orchestrator |
| [session-log-write](session-log-write.md) | Write or append to the session log; handles task-close, pre-op-snapshot, failure, and escalation entry types | validated | 2026-05-20 | orchestrator |
| [ledger-update](ledger-update.md) | Add or update an entry in a canonical vault ledger; requires pre-op snapshot and drift-check | validated | 2026-05-20 | ingest-agent |
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
