---
name: vault-query-routing
description: |
  Route any vault question through the index hierarchy before opening content files.
  Use whenever an agent needs to locate information inside infernalis/. Prevents broad
  reading by narrowing through MASTER_INDEX → section index → ledger → record.
  Trigger phrases: "find in vault", "look up", "what exists", "locate record", "check ledger".
version: 1.0.0
proposed_by: orchestrator
added: 2026-05-20
status: validated
---

# Skill: Vault Query Routing

## When to Use

Any time an agent needs to find information inside `infernalis/` and does not already know the exact file path. Do not open content files before completing steps 1–4. Use this skill for vault queries of any type: source lookup, work status, publication history, concept presence, ledger counts.

Do not use if the exact canonical path is already known — read directly instead.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| query | string | yes | What needs to be found, in plain terms |
| domain | string | no | Limiting domain: Writing, Thinking, Sources, Publishing, Projects, Admin. Omit if unknown. |

## Procedure

1. Read `infernalis/_Index/MASTER_INDEX.md` to identify which section index, ledger, or queue is most relevant to the query. → `[Tool: Read, path: infernalis/_Index/MASTER_INDEX.md]`
2. If `domain` is specified: read the corresponding section index (e.g., `sections/sources-index.md`). If `domain` is unknown: read the section index most likely to cover the query. → `[Tool: Read]`
3. Narrow to the specific ledger, queue, dashboard, or report that the section index points to. → `[Tool: Read]`
4. Scan the identified surface for the answer. If found: stop here. Return the finding with the vault path that answered it.
5. Only if steps 1–4 are insufficient: open the minimum number of content files or records needed to answer. → `[Tool: Read]`
6. Return findings with citations to the specific vault path(s) that answered the question.

## Pitfalls

- Do not open content files before step 4 fails.
- Do not read all section indexes if domain is clear from the query.
- `MASTER_INDEX.md` is a router, not an inventory. It points to surfaces; the surfaces answer the question.
- If the query spans multiple domains, route each domain leg separately rather than reading broadly.

## Verification

The returned answer must cite a specific vault path (e.g., `infernalis/_Index/ledgers/sources-ledger.md`, line N). An answer citing "I read broadly" indicates the skill was not followed.

## Outputs

Finding with vault path citations. If not found: explicit statement that the routing surfaces do not contain the answer, with the surfaces checked listed.

## Examples

**Query:** "What sources exist on the Southern Agrarians?"
**Route:** `MASTER_INDEX` → `sources-index.md` → `sources-ledger.md` → filter by topic keyword
**Stop at:** ledger, unless a specific source record is needed

**Query:** "Has the poem 'Lift Wind' been published?"
**Route:** `MASTER_INDEX` → `writing-index.md` → `works-ledger.md` → filter by title → `publications-ledger.md` if status is "placed"
