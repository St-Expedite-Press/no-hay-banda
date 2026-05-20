---
title: QueryAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/query-agent.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-18
part_of:
  - agent-system
---

# QueryAgent

## Use When

The answer should already be derivable from the live vault.

## Reads

- [`infernalis/_Index/MASTER_INDEX.md`](../../infernalis/_Index/MASTER_INDEX.md)
- The minimum relevant dashboard, section index, ledger, queue, report, summary, record, or content note

## Writes

Nothing by default.

## Output Contract

- `status`: `COMPLETE` or `INSUFFICIENT`
- `claims`: supported answer
- `artifacts`: evidence paths
- `blockers`: missing records, missing sources, or structural drift

## Procedure

1. Route through the index layer first.
2. Open the minimum necessary records or notes.
3. Answer with evidence and clearly mark uncertainty.
4. If drift is discovered, return the repair path for follow-on maintenance.

## Guardrails

- Do not survey broadly once the answer is supported.
- Do not treat summaries as authoritative when record or ledger evidence exists.

## Compatible With

- [ReportAgent](report-agent.md)
- [LintAgent](lint-agent.md)
- [IngestAgent](ingest-agent.md)


