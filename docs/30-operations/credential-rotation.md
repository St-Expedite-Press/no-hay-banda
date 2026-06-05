# Credential Rotation — New Showbiz Operator

*Rotate before enabling x-mcp-write. Rotate immediately on any suspected compromise.*

---

## Credentials in Scope

| Credential | Location | Used by |
|---|---|---|
| `OPENROUTER_API_KEY` | `~/.hermes/profiles/newshowbiz/.env` | All model inference |
| `TWITTER_USERNAME` / `TWITTER_PASSWORD` | `~/.hermes/profiles/newshowbiz/.env` | x-mcp Playwright login |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | `~/.hermes/config.yaml` | github MCP server |
| `GITHUB_PAT_WRITE` | `~/.hermes/.env` | repo push operations |
| `TELEGRAM_BOT_TOKEN` | `~/.hermes/profiles/newshowbiz/.env` | Phase 3 oversight gate |

---

## Rotation Procedure

### 1. Generate new credentials

| Credential | Where to generate |
|---|---|
| `OPENROUTER_API_KEY` | openrouter.ai → Keys → Create new key |
| `TWITTER_PASSWORD` | x.com → Settings → Security → Change password |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | github.com → Settings → Developer settings → Fine-grained PAT |
| `GITHUB_PAT_WRITE` | same as above |
| `TELEGRAM_BOT_TOKEN` | Telegram → @BotFather → /token |

Generate all replacements **before** revoking any existing credential.

### 2. Stop any running hermes sessions

```bash
systemctl --user stop hermes-gateway.service 2>/dev/null || true
# Kill any active hermes -p newshowbiz processes
pkill -f "hermes.*newshowbiz" || true
```

### 3. Update credential files

```bash
# Profile env
nano ~/.hermes/profiles/newshowbiz/.env
# → Update OPENROUTER_API_KEY, TWITTER_USERNAME, TWITTER_PASSWORD, TELEGRAM_BOT_TOKEN

# Global env
nano ~/.hermes/.env
# → Update GITHUB_PAT_WRITE

# Global config (GITHUB_PERSONAL_ACCESS_TOKEN is inline here)
nano ~/.hermes/config.yaml
# → Update GITHUB_PERSONAL_ACCESS_TOKEN
```

### 4. Clear X session cookie

The Barresider session cookie is tied to the previous login. After rotating the X password:

```bash
rm -f ~/.hermes/profiles/newshowbiz/x-auth/twitter.json
```

Re-authenticate in the next `hermes -p newshowbiz` interactive session by invoking the `login` tool.

### 5. Verify

```bash
# Confirm model inference works
hermes -p newshowbiz -z "say hello"

# Confirm GitHub MCP works (in interactive session)
hermes -p newshowbiz
# → ask: "what repos are in St-Expedite-Press?"
```

### 6. Revoke old credentials

Only after Step 5 confirms everything works:
- OpenRouter: revoke old key in the dashboard
- GitHub: revoke old PAT in developer settings
- Telegram: old token was already invalidated when you generated a new one via BotFather

### 7. Log the rotation

```
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] credential rotation complete — rotated: OPENROUTER, GITHUB_PAT, TWITTER_PASSWORD" \
  >> ~/.hermes/profiles/newshowbiz/logs/pipeline-failures.log
```

---

## Rotation Schedule

| Trigger | Action |
|---|---|
| Before enabling x-mcp-write | Full rotation (all credentials) |
| Suspected EC2 compromise | Full rotation + re-image instance |
| X account shows unexpected activity | Rotate TWITTER_PASSWORD immediately |
| OpenRouter billing anomaly | Rotate OPENROUTER_API_KEY immediately |
| Team member leaves | Rotate all credentials they had access to |

There is no time-based rotation schedule. Rotate on trigger, not on calendar.

---

## EC2 Security Group

Before Phase 3, restrict SSH access to your actual source IP:

```bash
# In AWS Console → EC2 → Security Groups → your instance's group
# Inbound rules → SSH (port 22) → Source: <your IP>/32
# Remove 0.0.0.0/0 if present
```

If you don't have a static IP: get one (Elastic IP or a static residential IP). A production system posting to X autonomously should not have SSH open to the world.

---

*Last updated: 2026-06-05*
