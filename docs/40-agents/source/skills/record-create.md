---
name: record-create
description: |
  Create a new canonical record file for any record type (source, work, publication, outlet,
  person, project, concept) using the correct template and validating against the metadata schema.
  Always followed by ledger-update. Always preceded by a duplicate check.
version: 1.0.0
proposed_by: ingest-agent
added: 2026-05-20
status: validated
---

# Skill: Record Create

## When to Use

When a new source, work, person, outlet, project, or concept needs a canonical record page in `_Records/`. Do not create records without first confirming no record already exists for the same entity. Always follow this skill with `ledger-update` to register the record.

Do not use to update an existing record — use a targeted edit instead.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| record_type | string | yes | `source`, `work`, `publication`, `outlet`, `person`, `project`, or `concept` |
| canonical_path | string | yes | Target path: `infernalis/_Records/[Type]/kebab-case-name.md` |
| fields | object | yes | Frontmatter field values; see `metadata-schema.md` for required fields per record type |
| source_content | string | no | Raw or transformed source material to embed or reference in the record body |

## Procedure

1. Check the relevant ledger for an existing entry at or near `canonical_path`. → `[Tool: Grep, pattern: canonical_path, path: relevant ledger]`
2. If an entry already exists: return `BLOCKED` — do not duplicate. Retrieve the existing record instead.
3. Read the template for this `record_type` from `infernalis/_Templates/Records/`. → `[Tool: Read]`
4. Read `infernalis/_System/schema/metadata-schema.md` to confirm which frontmatter fields are required for this `record_type`. → `[Tool: Read]`
5. Populate the template with `fields`. Validate: all required fields are present and non-null; types are correct (string, list, date).
6. If any required field is missing and cannot be inferred: return `PARTIAL` with a list of missing fields. Do not write an incomplete record.
7. Write the populated record to `canonical_path`. → `[Tool: Write]`
8. Run `ledger-update` to register the new record in the appropriate ledger.
9. Run `drift-check` with `changed_paths: [canonical_path]` to confirm the new file is reflected in control surfaces.

## Pitfalls

- Do not write a record with a `canonical_path` outside `infernalis/_Records/`.
- Do not omit required schema fields — downstream ledger operations depend on them.
- Do not create a record for an entity that already exists — check step 1 every time.
- Templates are in `_Templates/Records/` — do not write freeform records without consulting the template.

## Verification

Re-read the created record. Confirm: all required frontmatter fields are populated; `canonical_path` in the frontmatter matches the actual file path; `record_type` matches the directory it was written to.

## Outputs

- New record file at `canonical_path`
- Ledger entry added via `ledger-update`
- Drift check passed via `drift-check`
- Report: fields written, `canonical_path` confirmed, ledger status

## Examples

**Create a source record:**
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
