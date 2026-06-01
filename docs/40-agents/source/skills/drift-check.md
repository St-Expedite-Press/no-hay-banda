---
name: drift-check
description: |
  Verify that control surfaces remain consistent after a write operation. Use after any
  task that adds, moves, or modifies vault files. Identifies ledger entries missing records,
  records missing ledger entries, broken canonical paths, and _index.md files not listing
  new files. Returns a structured drift report.
version: 1.0.0
proposed_by: lint-agent
added: 2026-05-20
status: validated
---

# Skill: Drift Check

## When to Use

After any write that changes file structure: ingest, record creation, file moves, renames, deletions. Also invoked standalone when LintAgent runs a health check. Always run after `record-create` and `ledger-update` complete.

Do not use as a substitute for fixing drift — the skill reports and routes repairs; it does not silently rewrite.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| changed_paths | array | yes | Paths of files added, moved, modified, or deleted in the triggering operation |
| check_scope | string | no | `targeted` (only surfaces touching `changed_paths`) or `full` (all surfaces). Default: `targeted` |

## Procedure

1. For each path in `changed_paths`, identify which control surfaces reference it:
   - The relevant ledger in `infernalis/_Index/ledgers/` (match by record type) → `[Tool: Grep, pattern: path fragment, path: relevant ledger]`
   - The local `_index.md` in the same directory → `[Tool: Glob, pattern: directory/_index.md]`
   - Any section index that routes to this directory → `[Tool: Grep, pattern: directory name, path: infernalis/_Index/sections/]`
2. Read each identified surface. → `[Tool: Read]`
3. For each `changed_path`, apply the appropriate check:
   - **Added file:** Is there a matching ledger entry? Does the local `_index.md` list the file?
   - **Moved/renamed file:** Are old path references updated everywhere? Is the `canonical_path` field in the record correct?
   - **Deleted file:** Are references removed or flagged as stale? Is the ledger entry marked or removed?
   - **Modified record:** Does the ledger `status` field reflect the current state?
4. Check that `canonical_path` in each affected record resolves to an actual file. → `[Tool: Glob, confirm existence]`
5. For missing `_index.md` entries: note the file path and the directory's `_index.md` that needs updating.
6. Compile the drift report (see Outputs).
7. Route each fixable discrepancy:
   - Missing ledger entry → `ledger-update`
   - Missing `_index.md` entry → targeted `[Tool: Edit]` to add the listing
   - Broken `canonical_path` → flag for LintAgent or human review (do not silently rename)
   - Stale section index reference → flag for LintAgent

## Pitfalls

- Do not silently skip discrepancies — every finding must appear in the report.
- Do not rewrite authored content as a drift repair.
- Missing `_index.md` entries for new files are the most common miss — check step 3 every time.
- A ledger entry pointing to a non-existent file is a broken reference, not a minor formatting issue — flag it explicitly.

## Verification

After all repairs: re-run steps 1–4 on `changed_paths`. Confirm zero new discrepancies.

## Outputs

Structured drift report:

```
## Drift Check Report — [task_id] — YYYY-MM-DD

### Changed paths checked
- path/to/file.md

### Discrepancies found
- [MISSING LEDGER ENTRY] path/to/file.md not in sources-ledger.md
- [MISSING _INDEX ENTRY] path/to/file.md not listed in directory/_index.md
- [BROKEN CANONICAL PATH] infernalis/_Records/Sources/example.md → canonical_path field does not resolve

### Repairs made
- Added ledger entry via ledger-update
- Added _index.md listing

### Flagged for human review
- [BROKEN CANONICAL PATH] requires manual verification before repair
```

## Examples

**After adding a source record:**
- `changed_paths: [infernalis/_Records/Sources/kirby-smith-wikipedia.md, infernalis/Sources/Processed/kirby-smith-wikipedia.md]`
- Check `sources-ledger.md` for entry
- Check `infernalis/Sources/Processed/_index.md` for file listing
- Confirm `canonical_path` in the record resolves
