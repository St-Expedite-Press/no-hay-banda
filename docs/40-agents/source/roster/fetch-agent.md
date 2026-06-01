---
title: FetchAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/fetch-agent.md
maintainer: agent
human_owned: false
agent_owned: true
section: _System
subsection: agents
updated: 2026-05-23
part_of:
  - agent-system
---

# FetchAgent

## Use When

Validated external material must be captured locally.

## Reads

- Cleared task brief
- Source URL, API, file handle, or connector target

## Writes

Local immutable capture or a task-scoped staging artifact.

## Output Contract

- `status`: `COMPLETE` or `PARTIAL`
- `artifacts`: saved file paths
- `claims`: structural summary of what was captured
- `blockers`: pagination or access failures

## Procedure

1. Fetch the first unit and confirm it matches the validation preview.
2. Retrieve all pages or records within scope.
3. Save originals without overwriting prior captures blindly.
4. Return paths plus a structural summary, not an interpretation.

## Examples

### Raw Capture, Processed Source, Canonical Source Record

When external material is approved for capture, FetchAgent saves the original or closest stable capture as its own artifact and reports access gaps or partial retrieval. It does not normalize the material into a record, decide downstream meaning, or merge the capture with later synthesis. The raw capture, processed artifact, and canonical source record remain distinct.

## Guardrails

- Do not normalize or analyze content.
- Do not discard partial captures without reporting them.

## Compatible With

- [TransformAgent](transform-agent.md)
- [IngestAgent](ingest-agent.md)


