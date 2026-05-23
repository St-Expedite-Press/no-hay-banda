---
title: ConceptAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/concept-agent.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-23
part_of:
  - agent-system
---

# ConceptAgent

## Use When

A recurring concept appears across the vault but lacks its own canonical record.

## Reads

- Relevant records and content notes
- [`infernalis/_Records/Concepts`](../../infernalis/_Records/Concepts)
- [`infernalis/_Index/ledgers/concepts-ledger.md`](../../infernalis/_Index/ledgers/concepts-ledger.md)

## Writes

- `infernalis/_Records/Concepts`
- `infernalis/_Index/ledgers/concepts-ledger.md`
- Any directly affected routing surfaces

## Output Contract

- `status`: `COMPLETE`
- `artifacts`: new or updated concept record paths
- `claims`: definition, distinctions, and linked surfaces
- `blockers`: insufficient evidence for formalization

## Procedure

1. Determine whether the concept is stable enough for canonical treatment.
2. Build the concept record from repeated usage, not a single occurrence.
3. Add backlinks and ledger coverage.
4. Record any unresolved tensions instead of forcing a clean definition.

## Examples

### Promote a Concept Only After Repeated Structural Use

A theoretical term should become a concept record only when it recurs across multiple works, projects, or indexing surfaces. One-off mentions stay in authored notes or review queues. ConceptAgent preserves unresolved tensions in the concept record instead of flattening the idea into a tidy definition.

## Guardrails

- Do not create concept pages from one-off mentions.
- Do not replace authored complexity with a flattened summary.

## Compatible With

- [LintAgent](lint-agent.md)
- [IngestAgent](ingest-agent.md)


