---
name: ledger-update
description: |
  Add a new entry to or update an existing entry in any canonical vault ledger.
  Use when ingest, record creation, or structural changes require a ledger to reflect new state.
  Covers all seven types: sources, works, publications, outlets, people, projects, concepts.
  Always run a pre-operation snapshot via session-log-write before executing the edit.
version: 1.0.0
proposed_by: ingest-agent
added: 2026-05-20
status: validated
---

# Skill: Ledger Update

## When to Use

When a new canonical record has been created, or when an existing record's status, path, or metadata has changed. Always run after `record-create`. Always run `drift-check` after completing a ledger update.

Do not run if no corresponding record file exists at `canonical_path` — create the record first.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| ledger_path | string | yes | Full vault path, e.g. `infernalis/_Index/ledgers/sources-ledger.md` |
| entry_name | string | yes | Human-readable identifier for the record (used to check for duplicates) |
| canonical_path | string | yes | Path to the record file, e.g. `infernalis/_Records/Sources/kirby-smith-wikipedia.md` |
| fields | object | yes | Key-value pairs for all columns in the ledger row |
| action | string | yes | `add` or `update` |

## Procedure

1. Log a pre-operation snapshot of the ledger's relevant table section before making any change. → `[Skill: session-log-write, entry_type: pre-op-snapshot, target: ledger_path]`
2. Read the target ledger to confirm its current column structure and format. → `[Tool: Read, path: ledger_path]`
3. Check for an existing entry matching `entry_name` or `canonical_path`. → `[Tool: Grep, pattern: canonical_path, path: ledger_path]`
4. If `action` is `update` and no existing entry is found: return `BLOCKED` — use `add` instead or verify the path.
5. If `action` is `add` and an existing entry is found: return `BLOCKED` — the record is already registered.
6. Confirm the record file exists at `canonical_path`. → `[Tool: Glob, pattern: canonical_path]`
7. If `action` is `add`: append the new row at the end of the appropriate table, matching column order exactly. → `[Tool: Edit]`
8. If `action` is `update`: replace the matching row with the updated fields. → `[Tool: Edit]`
9. Re-read the modified table section to verify syntactic correctness and no column misalignment. → `[Tool: Read, targeted section]`

## Pitfalls

- Do not add a ledger entry before the canonical record file exists.
- Do not alter the ledger's column structure — populate only existing columns.
- Do not skip the pre-operation snapshot (step 1) — it is required for Phase 11 compensation.
- If the ledger uses a format different from expectation, stop and report rather than guessing at structure.

## Verification

Re-read the modified row. Confirm: `canonical_path` is valid and resolves to an existing file, `status` is a recognized value for this ledger type, no required columns are blank.

## Outputs

- Updated ledger file at `ledger_path`
- Session log snapshot entry
- Report: action taken, `canonical_path` confirmed, row content summary

## Examples

**Add a source record:**
```
ledger_path: infernalis/_Index/ledgers/sources-ledger.md
entry_name: Edmund Kirby Smith - Wikipedia
canonical_path: infernalis/_Records/Sources/kirby-smith-wikipedia.md
fields: {name: "Edmund Kirby Smith - Wikipedia", type: web-article, status: processed, added: 2026-05-20}
action: add
```
