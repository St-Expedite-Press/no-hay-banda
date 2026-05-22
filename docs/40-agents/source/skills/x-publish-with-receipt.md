# Skill: X Publish With Receipt

## When to Use

Use only for approved X ContentJobs routed through the reviewed New Showbiz X publish wrapper.

## Inputs

| Input | Required | Notes |
|---|---:|---|
| `content_job_id` | yes | Approved job ID |
| `final_text` | yes | Text after policy review |
| `idempotency_key` | yes | Duplicate prevention |
| `media_refs` | no | Approved media IDs or paths |

## Procedure

1. Confirm ContentJob status is `approved`.
2. Confirm no pause or hold state is active.
3. Confirm the write path is `newshowbiz_x_publish_reviewed`.
4. Send the post, thread, reply, or quote-post.
5. Normalize the returned platform receipt.
6. Attach final sent text, media IDs, canonical URL, timestamp, status, and error code if failed.

## Failure Classification

Classify failure as auth, login wall, CAPTCHA, Cloudflare or `403`, selector drift, rate limit, network, account warning, or unknown.

## Verification

No ContentJob is complete until the durable receipt is attached or the failure is recorded.

