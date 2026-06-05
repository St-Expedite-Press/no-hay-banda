---
name: review-decision-record
description: |
  Record a human review decision (approve, reject, or revise) on a ContentJob.
  Updates the ContentJob JSON status, moves the file to the correct directory,
  and appends a decision line to review-log.jsonl.
version: 1.0.0
license: MIT
---

# Skill: Review Decision Record

## When to Use

When the human reviewer has made a decision on a draft in store/review-queue/. Called
with the job ID and the decision. Do NOT call this on EscalationRecords — escalations
have a separate resolution path.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `job_id` | string | yes | ContentJob ID from store/review-queue/ |
| `decision` | string | yes | One of: approve, reject, revise |
| `notes` | string | no | Required when decision is "revise". Describes what needs to change. |

## Procedure

1. Read `store/review-queue/{job_id}.json`. If not found, return BLOCKED with "Job not in review-queue".
2. Based on decision:
   - **approve**: set status to "approved", set approval to `{"by": "human", "at": "{ISO timestamp}", "notes": notes or ""}`. Move file from review-queue/ to approved/. Remove from review-queue/.
   - **reject**: set status to "rejected", set approval to `{"by": "human", "at": "{ISO timestamp}", "notes": notes or ""}`. Move file from review-queue/ to rejected/. Remove from review-queue/.
   - **revise**: set status to "needs_revision", append notes to the JSON as "revision_notes". Leave file in review-queue/ (do not move — it stays for the revised draft). Update store/jobs/ copy too.
3. Write the updated JSON back to `store/jobs/{job_id}.json` (canonical record).
4. Append one JSON line to `store/review-log.jsonl`:
   `{"id": "{job_id}", "decision": "{decision}", "at": "{ISO timestamp}", "notes": "{notes or empty string}"}`
5. Return: job_id, decision, new status, destination path.

## Pitfalls

- Always update store/jobs/ as the canonical record, even when moving files between review-queue/, approved/, and rejected/.
- For "revise", do NOT delete from review-queue/ — the file stays pending the next draft submission.
- Notes are required for "revise" — return BLOCKED if notes is empty and decision is "revise".
- Do not call this skill more than once per job per review cycle — if a job already has status "approved" or "rejected", return BLOCKED with "Job already decided".

## Verification

- For approve: file exists in store/approved/, not in review-queue/. store/jobs/ copy has status "approved".
- For reject: file exists in store/rejected/, not in review-queue/. store/jobs/ copy has status "rejected".
- For revise: file remains in review-queue/ with status "needs_revision" and revision_notes present.
- review-log.jsonl has a new line with the correct job_id, decision, and timestamp.

## Outputs

Returns:
- `job_id`: the job that was decided
- `decision`: approve | reject | revise
- `status`: the new ContentJob status
- `path`: final file location
