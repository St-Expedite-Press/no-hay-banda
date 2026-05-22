---
title: Worked Example — Ingest Task, 12-Phase Trace
record_type: worked-example
status: canonical
canonical_path: agents/WORKED-EXAMPLE.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-20
---

# Worked Example: Source Ingest — Edmund Kirby Smith (Wikipedia)

End-to-end trace of a source ingest request through all 12 orchestrator phases. This example is the reference implementation for ingest-class tasks. Every phase shows real inputs, decisions, and outputs.

---

## Input Prompt

```
Ingest the Wikipedia article on Edmund Kirby Smith. Source type: web-article.
Part of anglosic-research project.
```

---

## Phase 1 — Prompt Intake and Clarification

**task_id:** `INGEST-EKS-001`

**Inputs logged:**
- Raw prompt: "Ingest the Wikipedia article on Edmund Kirby Smith..."
- Session date: `2026-05-20`
- Requesting agent: user (direct)

**Clarification check:**
- Source type explicitly stated: `web-article` ✓
- URL not provided — must be inferred or confirmed. Standard Wikipedia URL pattern is deterministic; proceed.
- `part_of` field stated: `anglosic-research` ✓
- Target path follows naming convention: `infernalis/_Records/Sources/kirby-smith-wikipedia.md` ✓

**Ambiguities:** None requiring user escalation.

**Outcome:** Task accepted. Proceed to Phase 2.

---

## Phase 2 — Index Routing and Context Loading

**Skill invoked:** `vault-query-routing`

**Inputs:**
```
query: "Does a record for Edmund Kirby Smith Wikipedia already exist?"
domain: sources
```

**Procedure trace:**

1. Read `infernalis/_Index/MASTER_INDEX.md` → `[Tool: Read]`
   - Identifies: sources are tracked in `infernalis/_Index/ledgers/sources-ledger.md`
   - Section index: `infernalis/_Index/sections/sources-index.md`

2. Read `sources-ledger.md` → `[Tool: Grep, pattern: kirby-smith, path: infernalis/_Index/ledgers/sources-ledger.md]`
   - Result: no match — record does not yet exist ✓

3. Stop: question answered. No content notes opened.

**Outcome:** No duplicate. Ingest is clear to proceed.

---

## Phase 3 — Task Decomposition

**Orchestrator constructs the DAG:**

```
INGEST-EKS-001
├── INGEST-EKS-001-A: Place source material in Sources/Processed/
├── INGEST-EKS-001-B: Create source record (depends on A)
├── INGEST-EKS-001-C: Update sources-ledger.md (depends on B)
├── INGEST-EKS-001-D: Drift check (depends on B, C)
└── INGEST-EKS-001-E: Session log close (depends on D)
```

**Topological wave 1 (parallel):** A
**Topological wave 2 (sequential):** B → C → D → E

---

## Phase 4 — Job Classification

| Subtask | operation_type | computational_mode | reversibility | scope |
|---------|---------------|-------------------|---------------|-------|
| A | write | transformative | reversible | internal |
| B | write | transformative | reversible | internal |
| C | write | transformative | compensatable | internal |
| D | read | analytical | reversible | internal |
| E | write | transformative | reversible | internal |

**No `final`-class operations.** No external scope. No authorization required beyond task intake.

---

## Phase 5 — Agent Assignment

| Subtask | Assigned Agent | Rationale |
|---------|---------------|-----------|
| A | IngestAgent | Primary handler for source material placement |
| B | IngestAgent (continues) | Record creation is core ingest responsibility |
| C | IngestAgent (continues) | Ledger update follows record creation in ingest pipeline |
| D | LintAgent | Drift checking is LintAgent's primary function |
| E | IngestAgent | Closes its own task log |

**Skills pre-loaded for IngestAgent:**
- `vault-query-routing` (agents/skills/vault-query-routing.md)
- `session-log-write` (agents/skills/session-log-write.md)
- `record-create` (agents/skills/record-create.md)
- `ledger-update` (agents/skills/ledger-update.md)

**Skills pre-loaded for LintAgent:**
- `drift-check` (agents/skills/drift-check.md)

**Context budget allocated:**
- IngestAgent: 6,000 tokens
- LintAgent: 2,000 tokens

---

## Phase 6 — Subtask Dispatch: Wave 1

### Subtask A — Place source material

**task_id:** `INGEST-EKS-001-A`
**idempotency_key:** `place-kirby-smith-processed`
**reversibility:** reversible

**IngestAgent action:**

Source material is the Wikipedia article content (pasted or fetched). Written to:
`infernalis/Sources/Processed/kirby-smith-wikipedia.md`

Content written includes article title, date accessed, URL, and raw article text.

**Output:** File exists at `infernalis/Sources/Processed/kirby-smith-wikipedia.md`

---

## Phase 7 — Pre-Operation Snapshot

Before each write subtask (B and C), IngestAgent invokes `session-log-write`.

### Pre-op snapshot for Subtask B (record creation)

**Skill invoked:** `session-log-write`

```markdown
## [INGEST-EKS-001-B] pre-op-snapshot — 2026-05-20
type: pre-op-snapshot
idempotency_key: create-kirby-smith-source-record
target_files:
  - path: infernalis/_Records/Sources/kirby-smith-wikipedia.md
    snapshot: |
      [File does not yet exist — creation, not modification]
```

### Pre-op snapshot for Subtask C (ledger update)

**Skill invoked:** `session-log-write`

```markdown
## [INGEST-EKS-001-C] pre-op-snapshot — 2026-05-20
type: pre-op-snapshot
idempotency_key: add-kirby-smith-to-sources-ledger
target_files:
  - path: infernalis/_Index/ledgers/sources-ledger.md
    snapshot: |
      | [last 3 rows of sources table pasted verbatim here] |
```

---

## Phase 8 — Subtask Execution: Waves 2–4

### Subtask B — Create source record

**Skill invoked:** `record-create`

**Inputs:**
```
record_type: source
canonical_path: infernalis/_Records/Sources/kirby-smith-wikipedia.md
fields:
  title: "Edmund Kirby Smith"
  record_type: source
  source_type: web-article
  status: processed
  url: https://en.wikipedia.org/wiki/Edmund_Kirby_Smith
  added: 2026-05-20
  part_of: [anglosic-research]
```

**Procedure trace:**

1. Grep sources-ledger for `kirby-smith-wikipedia` → `[Tool: Grep]` → no match ✓
2. Read template `infernalis/_Templates/Records/source-template.md` → `[Tool: Read]`
3. Read `infernalis/_System/schema/metadata-schema.md` → `[Tool: Read]`
   - Required fields for `source`: title, record_type, source_type, status, url, added
   - All required fields present ✓
4. Write populated record to `infernalis/_Records/Sources/kirby-smith-wikipedia.md` → `[Tool: Write]`

**Output:** Record file created.

---

### Subtask C — Update sources ledger

**Skill invoked:** `ledger-update`

**Inputs:**
```
ledger_path: infernalis/_Index/ledgers/sources-ledger.md
entry_name: Edmund Kirby Smith - Wikipedia
canonical_path: infernalis/_Records/Sources/kirby-smith-wikipedia.md
fields:
  name: "Edmund Kirby Smith — Wikipedia"
  type: web-article
  status: processed
  added: 2026-05-20
  part_of: anglosic-research
action: add
```

**Procedure trace:**

1. Pre-op snapshot already logged in Phase 7 ✓
2. Read `sources-ledger.md` → `[Tool: Read]` — confirms column structure
3. Grep for `kirby-smith-wikipedia` → `[Tool: Grep]` → no match ✓ (not already registered)
4. Glob `infernalis/_Records/Sources/kirby-smith-wikipedia.md` → `[Tool: Glob]` → exists ✓
5. Append new row to ledger table → `[Tool: Edit]`
6. Re-read modified row → `[Tool: Read]` — verified ✓

**Output:** Ledger entry added.

---

### Subtask D — Drift check

**Skill invoked:** `drift-check`

**Inputs:**
```
changed_paths:
  - infernalis/_Records/Sources/kirby-smith-wikipedia.md
  - infernalis/Sources/Processed/kirby-smith-wikipedia.md
check_scope: targeted
```

**Procedure trace:**

1. Identify surfaces referencing these paths:
   - `sources-ledger.md` → `[Tool: Grep, pattern: kirby-smith-wikipedia]` → match found ✓
   - `infernalis/Sources/Processed/_index.md` → `[Tool: Glob]` → exists
   - Read `_index.md` → `[Tool: Read]` — check for listing
2. Check: record `canonical_path` field resolves → `[Tool: Glob, pattern: infernalis/_Records/Sources/kirby-smith-wikipedia.md]` → exists ✓
3. Check: `infernalis/Sources/Processed/_index.md` lists the new file

**Drift report:**

```
## Drift Check Report — INGEST-EKS-001 — 2026-05-20

### Changed paths checked
- infernalis/_Records/Sources/kirby-smith-wikipedia.md
- infernalis/Sources/Processed/kirby-smith-wikipedia.md

### Discrepancies found
- [MISSING _INDEX ENTRY] infernalis/Sources/Processed/kirby-smith-wikipedia.md
  not listed in infernalis/Sources/Processed/_index.md

### Repairs made
- Added _index.md listing → [Tool: Edit, target: infernalis/Sources/Processed/_index.md]

### Flagged for human review
- None
```

**Repair applied:** LintAgent edits `infernalis/Sources/Processed/_index.md` to add the listing.

**Re-verification:** Grep confirms listing present. Drift: zero ✓

---

## Phase 9 — Output Validation

**Orchestrator checks output contracts:**

| Subtask | Contract | Pass? |
|---------|---------|-------|
| A | Source file exists at expected path | ✓ |
| B | Record at canonical_path; all required fields populated; canonical_path matches file path | ✓ |
| C | Ledger entry added; canonical_path resolves; no blank required columns | ✓ |
| D | Drift report produced; zero discrepancies remaining | ✓ |

**Compatibility check:** Record type `web-article` is valid per `record-taxonomy.md`. `part_of: anglosic-research` references a known project. No schema violations.

---

## Phase 10 — Escalation Check

**Escalation triggers reviewed:**

| Trigger | Status |
|---------|--------|
| `final`-class operation without authorization | Not applicable — all ops reversible/compensatable |
| Retries exhausted on any subtask | No retries required |
| Ambiguous input blocking progress | Resolved in Phase 1 |
| Policy violation detected | None |
| Context budget overrun | All agents within budget |

**Outcome:** No escalation. Proceed to close.

---

## Phase 11 — Compensation Log (Not Triggered)

No subtasks failed. Compensation was not required.

**For reference — what compensation would have looked like if Subtask C (ledger update) had failed:**

1. Locate pre-op snapshot in session log tagged `INGEST-EKS-001-C` / `add-kirby-smith-to-sources-ledger`
2. Read the snapshot's `target_files[0].snapshot` — the verbatim last rows of the ledger before the edit
3. Use `[Tool: Edit]` to restore those rows (removing the partially-written entry if any)
4. Mark `INGEST-EKS-001-C` as failed in the session log
5. Escalate to user with recovery options: retry, skip, or abort

---

## Phase 12 — Task Close

**Skill invoked:** `session-log-write`

```markdown
## [INGEST-EKS-001] IngestAgent — 2026-05-20
type: task-close
status: COMPLETE
changed:
  - infernalis/Sources/Processed/kirby-smith-wikipedia.md
  - infernalis/_Records/Sources/kirby-smith-wikipedia.md
  - infernalis/_Index/ledgers/sources-ledger.md
  - infernalis/Sources/Processed/_index.md
summary: Ingested Edmund Kirby Smith Wikipedia article. Source material placed, record created,
  ledger registered, _index.md updated. Drift check passed after LintAgent repaired one missing
  _index.md entry. No escalations.
```

---

## Summary

| Phase | Action | Outcome |
|-------|--------|---------|
| 1 | Prompt intake, clarification | Task accepted, no user escalation |
| 2 | Index routing, duplicate check | No duplicate; ingest clear |
| 3 | DAG decomposition | 5 subtasks in 2 waves |
| 4 | Job classification | No final-class ops; no external scope |
| 5 | Agent assignment | IngestAgent (A–C, E), LintAgent (D) |
| 6 | Wave 1 dispatch | Source material placed |
| 7 | Pre-op snapshots | Two snapshots logged before write subtasks |
| 8 | Wave 2–4 execution | Record created, ledger updated |
| 9 | Output validation | All contracts met |
| 10 | Escalation check | None triggered |
| 11 | Compensation | Not required |
| 12 | Task close | Session log updated; COMPLETE |

**Files created or modified:**
- `infernalis/Sources/Processed/kirby-smith-wikipedia.md` (new)
- `infernalis/_Records/Sources/kirby-smith-wikipedia.md` (new)
- `infernalis/_Index/ledgers/sources-ledger.md` (updated)
- `infernalis/Sources/Processed/_index.md` (updated by drift repair)
- `infernalis/_Index/sessions/2026-05-20.md` (updated — session log)
