---
title: LintAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/lint-agent.md
maintainer: agent
human_owned: false
agent_owned: true
section: _System
subsection: agents
updated: 2026-05-18
part_of:
  - agent-system
---

# LintAgent

## Use When

The user requests a vault health check or a task reveals structural drift.

## Reads

- Index surfaces
- Ledgers
- Canonical records
- Relevant local `_index.md` files

## Writes

- Structural repairs when safe
- Session log or durable report when findings should persist

## Output Contract

- `status`: `COMPLETE`
- `claims`: drift, missing entries, broken links, and repair summary
- `artifacts`: repaired paths and any report paths
- `blockers`: issues needing human judgment

## Procedure

1. Check for drift across records, ledgers, indexes, queues, and local `_index.md` files.
2. Repair straightforward structural issues.
3. Flag substantive content contradictions without silently rewriting them.
4. Route repeated concept gaps to ConceptAgent.

## Guardrails

- Do not rewrite authored content as a lint action.
- Do not leave control surfaces inconsistent if you touched them.

## Compatible With

- [ConceptAgent](concept-agent.md)
- [ReportAgent](report-agent.md)


