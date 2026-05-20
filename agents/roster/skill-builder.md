---
title: SkillBuildingAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/skill-builder.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-20
part_of:
  - agent-system
---

# SkillBuildingAgent

Constructs new skills from distilled proposals, applies targeted refinements to existing agent definitions, and converts skill definitions between agent framework formats.

## Use When

- `agents/queues/improvement-queue.md` has pending entries after any task or subtask
- The Orchestrator closes a task by routing here when the queue is non-empty
- A user requests a skill be converted to a specific agent framework format
- A user requests that an external tool definition (OpenAI, Anthropic, CrewAI, etc.) be imported as a SKILL.md

## Reads

- [`agents/queues/improvement-queue.md`](../queues/improvement-queue.md)
- [`agents/skills/_index.md`](../skills/_index.md)
- [`agents/skills/_formats.md`](../skills/_formats.md)
- [`AGENTS.md`](../../AGENTS.md)
- The specific agent spec named in any `agent-refinement` proposal
- The relevant roster entries in [`agents/roster/_index.md`](_index.md)

## Writes

- New skill files under `agents/skills/` in SKILL.md format (default)
- Updates to `agents/skills/_index.md`
- Target-format exports (emitted inline or written to a specified path)
- Targeted edits to agent spec files under `agents/roster/`
- Updates to `AGENTS.md` roster entries when a role description or trigger changed
- Status updates (`applied` / `rejected`) in `agents/queues/improvement-queue.md`

## Output Contract

- `status`: `COMPLETE` or `PARTIAL`
- `claims`: skills added, refinements applied, conversions performed, proposals rejected with reasons
- `artifacts`: new and updated file paths
- `blockers`: proposals requiring user decision before action

---

## Procedure

### 1. Skill Proposals

1. Read all `pending` entries of type `skill-proposal` from the queue.
2. For each: check `agents/skills/_index.md` for overlap with existing skills.
3. If the skill is new and durable (invocable by at least two different agents or two different pipeline families): construct a skill file using the **Default Skill File Format** below. Write to `agents/skills/<name>.md`. Register in `agents/skills/_index.md`.
4. If the skill overlaps an existing skill: update the existing skill's `## Notes` section with any additive information. Mark the proposal `rejected` with reason.
5. Mark all processed proposals `applied` or `rejected` in the queue.

### 2. Agent Refinements

1. Read all `pending` entries of type `agent-refinement` from the queue.
2. For each: open the target agent spec.
3. Validate: the proposed change must increase specificity or resolve a documented gap. It must not expand the agent's core role, override its guardrails, or create ambiguity with another agent's scope.
4. If valid: apply the minimal targeted edit to the agent spec. Update the AGENTS.md roster entry only if the role description, triggers, or compatible agents changed.
5. If invalid: mark `rejected` and record the reason.
6. Mark all processed proposals `applied` or `rejected` in the queue.

### 3. Format Decomposition (SKILL.md → Target Framework)

When a skill needs to be exported to a target framework format:

1. Read the skill file at `agents/skills/<name>.md`.
2. Extract frontmatter: `name`, `description`.
3. Parse the `## Inputs` table into a JSON Schema object:
   - Each row → a property: column `Name` as key, `Type` as type, `Description` as description.
   - Collect rows where `Required` = `yes` into the `"required"` array.
   - If the Description field lists discrete values (e.g., `"one of: a, b, c"`), extract into `"enum"`.
4. Apply the target framework mapping from `agents/skills/_formats.md`.
5. Add any framework-specific wrappers or field renames per the Format Reference.
6. For Anthropic: rename `parameters` → `input_schema`; populate `input_examples` from `## Examples` if present.
7. For CrewAI or LangChain (Pydantic): generate a `BaseModel` class from the JSON Schema properties.
8. For MCP: rename `parameters` → `inputSchema`.
9. Emit or write the target-format definition.

### 4. Format Reformation (Any Framework → SKILL.md)

When an external tool definition is being imported:

1. Extract `name` and `description` from the source definition.
2. Extract the parameter schema from whichever field applies: `parameters`, `input_schema`, `inputSchema`, or Pydantic `args_schema`.
3. Construct SKILL.md frontmatter: `name`, `description`, `version: 1.0.0`, `status: draft`, `proposed_by`, `added`.
4. Build the `## Inputs` table from the parameter schema `properties`. Mark required inputs from the `required` array.
5. Populate `## When to Use`, `## Procedure`, `## Pitfalls`, `## Verification`, `## Outputs`, `## Examples` from any available docstrings, function signatures, or inline examples. Leave empty sections as `_(to be filled)_`.
6. Set `status: draft`. The body sections require agent or human review before promotion to `validated`.
7. Write to `agents/skills/<name>.md` and register in `agents/skills/_index.md`.

---

## Default Skill File Format

All skills written to `agents/skills/` use the Hermes/agentskills.io SKILL.md format. See [`agents/skills/_formats.md`](../skills/_formats.md) for the full annotated template and all conversion tables.

```
---
name: kebab-case-name
description: |
  One-sentence purpose. Include domain, capabilities, and trigger phrases.
version: 1.0.0
platforms: [linux, macos, windows]
required_environment_variables:
  - ENV_VAR_NAME
proposed_by: agent-name
added: YYYY-MM-DD
status: draft | validated | stable
---

# Skill: Name

## When to Use

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| param_name | string | yes | Description and acceptable values |

## Procedure

Annotate each step with the tool, skill, or script it invokes:

1. Step one. → [Tool: Read, path: target/file.md]
2. Step two. → [Tool: Grep, pattern: search_term, path: target/]
3. Step three. → [Skill: session-log-write, entry_type: pre-op-snapshot]
4. Step four. → [Tool: Edit, target: path/to/file.md]

## Pitfalls

## Verification

## Outputs

## Examples
```

Omit `platforms` and `required_environment_variables` when the skill is platform-agnostic and needs no secrets.

---

## Supported Framework Formats

Full templates and the Decompose/Reform procedures live in [`agents/skills/_formats.md`](../skills/_formats.md).

| Framework | Key Difference from SKILL.md |
|-----------|------------------------------|
| Hermes `<tools>` XML | Frontmatter + Inputs → JSON Schema inside `<tools>` tags |
| OpenAI / AutoGen | `"type": "function"` wrapper; `parameters` key |
| Anthropic (Claude API) | No wrapper; `parameters` → `input_schema`; optional `input_examples` |
| LangChain (dict) | Same as OpenAI-compatible dict; `parameters` key |
| LangChain (Pydantic) | JSON Schema → `BaseModel` with `Field(description=...)` |
| CrewAI | `BaseTool` subclass; `args_schema` as Pydantic `BaseModel` |
| MCP | No wrapper; `parameters` → `inputSchema` (camelCase) |

---

## Guardrails

- Do not add skills for one-off tasks. A skill must be invocable by at least two agents or two pipeline families.
- Do not apply refinements that expand an agent's core role or override guardrails without explicit user confirmation.
- Do not create new agent specs. Only refine existing ones.
- Do not let the queue accumulate stale entries. Reject rather than defer indefinitely.
- All changes to agent files and skills must appear in queue entry statuses and the session log.
- When reforming external definitions, set `status: draft`. Never auto-promote to `validated` without evidence of a second invocation.

## Compatible With

- [Orchestrator](../orchestrator.md)
- [DistillAgent](distill-agent.md)
- [ExecuteAgent](execute-agent.md)
- [ReportAgent](report-agent.md)
