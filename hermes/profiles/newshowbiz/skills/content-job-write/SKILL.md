---
name: content-job-write
description: |
  Write a new ContentJob JSON record to the Phase 1 flat-file store. Places the
  job in store/jobs/ and copies it to store/review-queue/ when status is draft.
version: 1.0.0
license: MIT
---

# Skill: Content Job Write

## When to Use

After content-draft-from-movie-data produces a draft variant that needs to be persisted
for human review. Call once per draft variant (X post and X thread each get their own ContentJob).

Do NOT use for EngagementJobs or EscalationRecords — those have separate skills.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `kind` | string | yes | One of: original, reply, quote, thread, report |
| `platform` | string | yes | `x` |
| `text` | string | yes | Draft text (final or near-final) |
| `objective` | string | yes | One of: discovery, explain, activate, respond, support |
| `source_refs` | list | yes | At least one product URL or file path backing the content |
| `risk_level` | string | yes | One of: low, medium, high, blocked |
| `cta` | string | yes | The call-to-action phrase or link included in the draft |
| `status` | string | no | Defaults to "draft". Use "hold" to pre-flag for escalation review. |

## Procedure

1. Generate a stable ID: ISO date + T + HHMMSS + hyphen + 4-char hex from the first 4 chars of a hash of (text + platform + timestamp). Format: `2026-06-05T143022-a3f1`.
2. Assemble the ContentJob JSON with all required fields from domain-contracts.md: id, kind, platform, status, objective, text, source_refs, risk_level, cta, approval (null initially), idempotency_key (same as id for Phase 1), receipt_ids (empty list).
3. Write the JSON to `~/.hermes/profiles/newshowbiz/store/jobs/{id}.json`.
4. If status is "draft" or "hold": also copy the file to `~/.hermes/profiles/newshowbiz/store/review-queue/{id}.json`.
5. Return: the job id, file path, and a one-line summary of the draft (platform, kind, first 60 chars of text).

## Pitfalls

- source_refs must contain at least one entry — reject with BLOCKED if the list is empty.
- Never write a ContentJob with status "published" from this skill — that status is set by x-publish-with-receipt after a write succeeds.
- Do not generate a ContentJob for content that triggered a risk escalation — use escalation-record-write instead and set the ContentJob status to "hold".
- The idempotency_key must be unique. If writing the same draft twice (e.g., after a revision), generate a new ID — do not reuse the original.

## Verification

- Confirm the JSON file exists at `store/jobs/{id}.json`.
- Confirm `store/review-queue/{id}.json` exists when status is "draft".
- Confirm the JSON parses cleanly and contains all required fields.

## Outputs

Returns:
- `id`: the generated ContentJob ID
- `path`: absolute path to the written file
- `summary`: platform | kind | first 60 chars of text
