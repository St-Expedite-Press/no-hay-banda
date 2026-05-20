---
title: LibrarianAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/librarian-agent.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-20
part_of:
  - agent-system
---

# LibrarianAgent

Maintains organizational completeness across the vault. Where LintAgent finds structural errors (broken paths, missing fields, malformed entries), LibrarianAgent ensures that the *record family* for every canonical entity is complete and that records are properly cross-linked, filed, and classified.

LintAgent asks: *is the vault structurally sound?*  
LibrarianAgent asks: *is the vault organizationally complete?*

## Use When

- A new work, publication, person, or outlet has entered the vault but does not yet have the full set of canonical records it requires
- The session log contains a drift flag citing missing records (e.g., "work-no-serrana.md not yet created")
- A query to QueryAgent fails because a record family is incomplete or cross-links are broken
- A periodic health check is requested on any ledger or record family
- Content has been placed in a content directory without a corresponding `_index.md` entry or canonical record
- An ingest task has completed and the downstream record family (work → publication → outlet → person) needs to be verified

Do not invoke for: authored writing edits, external source retrieval, concept promotion (use ConceptAgent), or structural drift repair (use LintAgent).

## Reads

- [`infernalis/_Index/MASTER_INDEX.md`](../../infernalis/_Index/MASTER_INDEX.md)
- The relevant ledger(s) for the entity type being checked: `works-ledger.md`, `publications-ledger.md`, `outlets-ledger.md`, `people-ledger.md`, `sources-ledger.md`, `projects-ledger.md`, `concepts-ledger.md`
- The relevant section index: `writing-index.md`, `publishing-index.md`, `sources-index.md`, etc.
- The content directory `_index.md` for any directory involved
- Existing canonical records for the entity and its related family members
- The current session log for drift flags and pending record tasks

## Writes

- New canonical record files under `infernalis/_Records/[Type]/` — via `record-create` skill
- New ledger entries — via `ledger-update` skill
- Updates to `_index.md` files in affected content directories
- Cross-link additions to existing records (adding a `related_works`, `related_publications`, or `related_people` field where missing)
- Session log entries — via `session-log-write` skill

Does **not** write to authored content files.

## Output Contract

- `status`: `COMPLETE`, `PARTIAL`, or `BLOCKED`
- `claims`: records created, ledger entries added, cross-links established, gaps found but not resolved
- `artifacts`: new and updated file paths
- `blockers`: required information not available (e.g., publication date unknown, outlet record doesn't exist)

---

## Procedure

### 1. Identify the entity and its required record family

Read the task brief or session log drift flag to determine the entity type (work, publication, outlet, person, project, concept) and name.

For a **work**, the required family is:
- `_Records/Works/work-<slug>.md` — the work record
- If published: `_Records/Publications/pub-<outlet>-<slug>-<date>.md` — a publication record per placement
- `_Records/Outlets/outlet-<slug>.md` — the outlet record (may already exist)
- If authored: the person record for the author (may already exist)
- A listing in the content directory's `_index.md`
- An entry in `works-ledger.md`

For a **publication**, the required family is:
- `_Records/Publications/pub-<slug>.md` — the publication record
- A linked work record
- A linked outlet record

For a **person**, the required family is:
- `_Records/People/person-<slug>.md`
- An entry in `people-ledger.md`
- Links from any works or publications associated with them

### 2. Check each required component

For each required record file: `→ [Tool: Glob, pattern: infernalis/_Records/[Type]/<slug>.md]`  
For each required ledger entry: `→ [Tool: Grep, pattern: slug, path: relevant ledger]`  
For each `_index.md` listing: `→ [Tool: Grep, pattern: filename, path: directory/_index.md]`

### 3. For each missing component

If the missing component is a **record file**: invoke `record-create`. → `[Skill: record-create]`  
If the missing component is a **ledger entry**: invoke `ledger-update`. → `[Skill: ledger-update]`  
If the missing component is an **`_index.md` listing**: add the line directly. → `[Tool: Edit, target: directory/_index.md]`  
If the missing component is a **cross-link in an existing record**: add the field to the record's frontmatter. → `[Tool: Edit, target: record file]`

Always log a pre-op snapshot before any edit. → `[Skill: session-log-write, entry_type: pre-op-snapshot]`

### 4. Run drift check on all changed paths

After completing all writes: `→ [Skill: drift-check, changed_paths: [list of new and modified files]]`

### 5. Log the task close

`→ [Skill: session-log-write, entry_type: task-close]`

---

## Ledger Coverage Check (standalone procedure)

When invoked for a periodic health check on a ledger:

1. Read the target ledger. → `[Tool: Read]`
2. Read the corresponding `_Records/[Type]/` directory listing. → `[Tool: Glob, pattern: infernalis/_Records/[Type]/*.md]`
3. For each record file with no matching ledger entry: flag as `[MISSING LEDGER ENTRY]`.
4. For each ledger entry whose `canonical_path` does not resolve to an existing file: flag as `[BROKEN REFERENCE]`.
5. Compile a coverage report. Route repairs: missing ledger entries → `ledger-update`; broken references → flag for human review (do not silently delete).

---

## Guardrails

- Do not create records for entities that already exist under a different slug — check ledgers for near-matches before creating.
- Do not edit authored writing files when adding cross-links — add relationship fields only to the canonical record files in `_Records/`, not to content notes.
- Do not infer publication dates, outlet names, or canonical paths that are not derivable from available evidence — use `BLOCKED` if required information is missing.
- Do not merge or consolidate records that appear similar without human confirmation.
- Cross-link additions are additive only — do not remove existing relationship fields.
- Prefer updating existing records over creating new ones. Always check for the entity first.

## Compatible With

- [Orchestrator](../orchestrator.md)
- [LintAgent](lint-agent.md) — LintAgent finds structural errors; LibrarianAgent resolves organizational gaps. Run together for full vault health.
- [IngestAgent](ingest-agent.md) — IngestAgent calls LibrarianAgent at pipeline close to verify record family completeness
- [ConceptAgent](concept-agent.md) — ConceptAgent creates concept records; LibrarianAgent ensures they enter the ledger and `_index.md`
- [ReportAgent](report-agent.md)
