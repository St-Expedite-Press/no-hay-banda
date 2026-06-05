# Skill: telegram-await-approval

**Trigger:** After `telegram-notify` succeeds. Call this skill before invoking `x-publish-with-receipt`. Do not proceed to publish without a confirmed APPROVE from this skill.

**Required env vars:** `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`

---

## Purpose

Poll the Telegram Bot API for a human reply to the notification sent by `telegram-notify`. Returns `APPROVED`, `REJECTED`, or `TIMED_OUT`. Only `APPROVED` permits the publish step to proceed.

---

## Inputs

| Field | Type | Description |
|---|---|---|
| `job_id` | string | ContentJob ID |
| `notification_message_id` | integer | `message_id` returned by `telegram-notify` |
| `timeout_seconds` | integer | Maximum wait time. Default: 14400 (4 hours) |

---

## Procedure

### Step 1 — Poll getUpdates

Poll `https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates` in a loop with a 60-second interval. Use an `offset` parameter to avoid re-processing old messages.

```bash
OFFSET=0
ELAPSED=0
INTERVAL=60
TIMEOUT=${timeout_seconds:-14400}

while [ $ELAPSED -lt $TIMEOUT ]; do
  UPDATES=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=${OFFSET}&timeout=55")
  
  # Check each update for a reply to notification_message_id
  REPLY=$(echo "$UPDATES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for u in data.get('result', []):
  msg = u.get('message', {})
  reply_to = msg.get('reply_to_message', {}).get('message_id')
  if reply_to == ${notification_message_id}:
    print(msg.get('text', '').strip().upper())
    break
")

  if [ "$REPLY" = "APPROVE" ]; then
    echo "APPROVED"
    exit 0
  elif [ "$REPLY" = "REJECT" ]; then
    echo "REJECTED"
    exit 2
  fi

  # Advance offset to mark updates as read
  LAST_ID=$(echo "$UPDATES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ids = [u['update_id'] for u in data.get('result', [])]
print(max(ids) + 1 if ids else 0)")
  [ "$LAST_ID" -gt 0 ] && OFFSET=$LAST_ID

  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "TIMED_OUT"
exit 3
```

### Step 2 — Handle result

| Result | Action |
|---|---|
| `APPROVED` | Set `status: COMPLETE`. Proceed to `x-publish-with-receipt`. |
| `REJECTED` | Set `status: HOLD`. Move ContentJob to `store/rejected/`. Log decision in `review-log.jsonl`. Do NOT publish. |
| `TIMED_OUT` | Set `status: HOLD`. Leave ContentJob in `store/approved/`. Log timeout. Notify operator via a follow-up Telegram message: `"[{job_id}] Approval timed out after 4h. Job held."` |

### Step 3 — Return

```
status:    COMPLETE | HOLD
claims:    Human approval received / rejected / timed out
artifacts: review-log.jsonl entry
blockers:  [empty on COMPLETE; reason on HOLD]
```

---

## Critical rules

- Never return `COMPLETE` unless the literal string `APPROVED` was received from a reply to `notification_message_id`.
- A timed-out job is held, not discarded. It can be resubmitted.
- Do not fabricate approval. If polling fails due to a network error, set `status: BLOCKED` and surface the error.
