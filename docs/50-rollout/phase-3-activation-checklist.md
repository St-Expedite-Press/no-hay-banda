# Phase 3 Activation Checklist

*All six gates must be GREEN before enabling `x-mcp-write` in the profile config. Check this list in order — earlier gates are prerequisites for later ones.*

---

## Gate 1 — Approved content queue exists

```bash
ls ~/.hermes/profiles/newshowbiz/store/approved/ | wc -l
```

**Required:** ≥ 14 files (7-day queue, minimum 2 posts/day).

**What to check:** Open 3 random approved ContentJobs. Confirm each has:
- `source_refs` — at least one with a URL or file path
- `risk_level` — set to `low`, `medium`, or `high` (not null)
- `cta` — non-empty
- `objective` — non-empty
- `draft_text` — character count within platform limit

☐ **GATE 1 GREEN**

---

## Gate 2 — At least one escalation exercised

```bash
ls ~/.hermes/profiles/newshowbiz/store/escalations/ | wc -l
```

**Required:** ≥ 1 EscalationRecord file.

The escalation path (risk_level = `high` → escalation-agent → HOLD) must have been exercised at least once before autonomous publishing starts. If no organic high-risk draft has been produced, deliberately draft one that triggers it (e.g., donation CTA with specific dollar amount).

☐ **GATE 2 GREEN**

---

## Gate 3 — Telegram gate functional

```bash
source ~/.hermes/profiles/newshowbiz/.env

# Confirm bot token is set
[ -n "$TELEGRAM_BOT_TOKEN" ] && echo "token set" || echo "MISSING"
[ -n "$TELEGRAM_CHAT_ID" ] && echo "chat_id set" || echo "MISSING"

# Send test message
curl -s -X POST \
  "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d "chat_id=${TELEGRAM_CHAT_ID}" \
  -d "text=Gate 3 test — reply APPROVE to confirm" | python3 -c "import sys,json; r=json.load(sys.stdin); print('OK' if r.get('ok') else r)"
```

**Required:**
1. Test message appears in the Telegram chat
2. Reply `APPROVE` from the chat
3. Confirm `telegram-await-approval` skill receives and logs the reply

Run a full dry-run: `telegram-notify` → `telegram-await-approval` → confirm APPROVED without triggering any actual publish.

☐ **GATE 3 GREEN**

---

## Gate 4 — Credentials rotated

All credentials must be rotated immediately before enabling write access. See `docs/30-operations/credential-rotation.md`.

Confirm:
- [ ] `OPENROUTER_API_KEY` rotated
- [ ] `TWITTER_PASSWORD` rotated (and x-auth/twitter.json deleted + re-authenticated)
- [ ] `GITHUB_PERSONAL_ACCESS_TOKEN` rotated
- [ ] Old credentials revoked in their respective dashboards

☐ **GATE 4 GREEN**

---

## Gate 5 — Pipeline failure log clean for 2 weeks

```bash
cat ~/.hermes/profiles/newshowbiz/logs/pipeline-failures.log
```

**Required:** No unresolved entries in the past 14 days. If there are entries, each must have a documented resolution (add a note inline in the log file explaining what was fixed).

☐ **GATE 5 GREEN**

---

## Gate 6 — x-mcp-read search confirmed working

```bash
# In interactive session:
hermes -p newshowbiz
# → invoke search_twitter("newshow.biz")
# → confirm results are returned, not a 403 or empty set
```

**Required:** `search_twitter` returns at least one result. If X is blocking the EC2 IP, x-mcp-read is not functional and Phase 3 cannot proceed until that is resolved (proxy, residential IP, or alternative approach).

☐ **GATE 6 GREEN**

---

## Activation Steps (all 6 gates green)

### Step 1 — Enable x-mcp-write in profile config

```bash
nano ~/.hermes/profiles/newshowbiz/config.yaml
```

Find the `x-mcp-write` server block. Change `enabled: false` to `enabled: true`.

### Step 2 — First supervised publish

Run one post with a human watching in real time:

```bash
hermes -p newshowbiz
# → "publish the next approved ContentJob in store/approved/ — use the full publish pipeline including telegram-notify and telegram-await-approval"
```

Watch the Telegram chat for the notification. Reply `APPROVE`. Confirm the post appears on `@stex_press`. Confirm a receipt file is written to `store/receipts/` (or equivalent).

### Step 3 — Record activation

```bash
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Phase 3 activated — first supervised publish complete" \
  >> ~/.hermes/profiles/newshowbiz/logs/pipeline-failures.log
```

Commit the updated profile config and this checklist (with all gates marked GREEN) to the repo.

---

## If a gate fails during Step 2

Stop immediately. Set the ContentJob back to `approved` status. Disable `x-mcp-write`. Investigate before retrying.

Do not attempt to work around a failed gate. The gates exist because the blast radius of a bad autonomous post (wrong framing, fabricated claim, Kakusu Protocol violation, unintended escalation) is higher than the cost of waiting.

---

*Last updated: 2026-06-05*
