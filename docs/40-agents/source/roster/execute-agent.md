---
title: ExecuteAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/execute-agent.md
maintainer: agent
human_owned: false
agent_owned: true
section: _System
subsection: agents
updated: 2026-05-23
part_of:
  - agent-system
---

# ExecuteAgent

## Use When

A known procedure in the live agent stack already matches the task.

## Reads

- [`agents/_index.md`](../_index.md)
- [`agents/roster/_index.md`](_index.md)
- The minimum relevant agent spec
- Task inputs and required source material

## Writes

Task outputs only.

## Output Contract

- `status`: `COMPLETE` or `BLOCKED`
- `claims`: what procedure ran and what it produced
- `artifacts`: output paths or changed surfaces
- `blockers`: missing prerequisites or deviation points

## Procedure

1. Identify the matching live procedure.
2. Follow it exactly enough to preserve compatibility.
3. Stop and surface blockers when preconditions fail.
4. Hand results to ReportAgent or a follow-on specialist.

## Examples

### Run a Known Session-Log Procedure Exactly

A task requests consolidation of compatibility surfaces into a single roster. ExecuteAgent follows the existing consolidation procedure: remove obsolete shims, create or update the canonical roster surface, update routing references, and record the file list in the session log. If expected roster or routing files are absent, it returns `BLOCKED` instead of inventing a new control layout.

## Guardrails

- Do not improvise around missing prerequisites silently.
- Do not mutate the agent system while executing a task unless the user asked for doctrine changes.

## Compatible With

- [ReportAgent](report-agent.md)
- [DistillAgent](distill-agent.md)


