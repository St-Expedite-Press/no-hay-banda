# Skill: telegram-notify

**Trigger:** Before any publish action. Call this skill after a ContentJob reaches `approved` status in the review queue and before invoking `x-publish-with-receipt`.

**Required env vars:** `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` (in profile `.env`)

---

## Purpose

Send a publish notification to the Telegram oversight channel. Returns a `message_id` that must be stored in the ContentJob receipt and passed to `telegram-await-approval`.

---

## Inputs

| Field | Type | Description |
|---|---|---|
| `job_id` | string | ContentJob ID (e.g. `2026-06-05T140012-e98f`) |
| `platform` | string | `x` or `instagram` |
| `draft_text` | string | Full post text (or thread post 1 if thread) |
| `source_refs` | array | Source references from ContentJob |
| `risk_level` | string | `low`, `medium`, or `high` |
| `template_used` | string | Template name (e.g. `original-discovery`) |

---

## Procedure

### Step 1 — Build notification message

Format the message as plain text (Telegram HTML parse mode):

```
🎬 <b>PUBLISH REQUEST</b>

<b>Job:</b> {job_id}
<b>Platform:</b> {platform}
<b>Template:</b> {template_used}
<b>Risk:</b> {risk_level}

<b>Draft:</b>
{draft_text}

<b>Sources:</b>
{source_refs joined as bullet list}

Reply APPROVE to publish. Reply REJECT to discard. No reply within 4h = HOLD.
```

### Step 2 — Send via Telegram Bot API

```bash
RESPONSE=$(curl -s -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
  --data-urlencode "text=${MESSAGE}" \
  -d "parse_mode=HTML")

MESSAGE_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin)['result']['message_id'])")
```

### Step 3 — Verify send succeeded

Check that `MESSAGE_ID` is a non-empty integer. If the API call failed:
- Set `status: BLOCKED`
- Log the error response
- Do NOT proceed to publish

### Step 4 — Return

```
status:    COMPLETE
claims:    Notification sent to Telegram oversight channel
artifacts: message_id: {MESSAGE_ID}
blockers:  [empty on success]
```

Pass `MESSAGE_ID` to `telegram-await-approval` as `notification_message_id`.

---

## Anti-fabrication

Do NOT fabricate a `message_id` if the API call fails. A fabricated ID will cause `telegram-await-approval` to poll forever or approve without human confirmation. Report the blocker.
