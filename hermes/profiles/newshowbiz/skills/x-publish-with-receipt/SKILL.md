---
name: x-publish-with-receipt
description: "Publish an approved ContentJob through newshowbiz_x_publish_reviewed and return a durable receipt. Phase 3+ only — disabled until ContentJob store, policy engine, and approval path exist."
version: 1.0.0
author: New Showbiz
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [newshowbiz, x, publish, receipt, content-job, phase3]
---

# Skill: X Publish With Receipt

## Phase Gate

**This skill is Phase 3+ scope.** Do not invoke it until the following exist:
- ContentJob store with `approved` status
- Policy engine with pre-publish validation
- `newshowbiz_x_publish_reviewed` toolset wrapper
- Receipt store

In Phase 1, the correct path is: draft via x-publish-with-receipt → human reviews → human posts manually.

## When to Use

Use only for approved X ContentJobs routed through the reviewed New Showbiz X publish wrapper.
Never invoke for unapproved drafts, EngagementJobs, or non-X content.

## Inputs

| Input | Required | Notes |
|---|---:|---|
| `content_job_id` | yes | Approved job ID |
| `final_text` | yes | Text after policy review |
| `idempotency_key` | yes | Duplicate prevention key |
| `media_refs` | no | Approved media IDs or paths |

## Procedure

1. Confirm ContentJob status is `approved` in the domain store.
2. Confirm no pause or hold state is active for the account or campaign.
3. Check idempotency key — if this key was already used successfully, return `COMPLETE` without re-sending.
4. Confirm the write path is `newshowbiz_x_publish_reviewed` (not raw browser, not unreviewed MCP call).
5. Send the post, thread, reply, or quote-post through the reviewed wrapper.
6. Normalize the returned platform receipt.
7. Attach to the ContentJob: final sent text, media IDs, canonical URL, timestamp, status, error code if failed.
8. Return the receipt and updated ContentJob status.

## Failure Classification

Classify any failure as exactly one of:
auth | login_wall | captcha | cloudflare_403 | selector_drift | rate_limit | network | account_warning | unknown

Do not leave failures unclassified. The classification drives retry strategy.

## Verification

No ContentJob is complete until the durable receipt is attached to it, or the failure is recorded with classification and next action.
