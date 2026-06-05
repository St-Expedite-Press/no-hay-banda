# Hermes Runtime — Install Guide

This directory is the complete runtime source for the New Showbiz marketing operator. It maps directly to `~/.hermes/` on the EC2 instance. Clone the repo and follow the steps below to bring up a fresh instance.

---

## Prerequisites

**Platform:** Amazon Linux 2023 (or equivalent). The MCP servers use Playwright-based browser automation; the dependency list below is AL2023-specific.

**Required:** Node.js v22+, Python 3.11+, npm.

**Hermes version:** v0.15.1 (2026.5.29). Install via:

```bash
pip install hermes-agent==0.15.1
# or
pip install hermes-agent   # then pin after confirming version with: hermes --version
```

---

## Step 1 — Playwright system dependencies (Amazon Linux 2023)

Playwright's `install-deps` targets Ubuntu/Debian only. Install manually:

```bash
sudo dnf install -y \
  atk at-spi2-atk cups-libs libdrm libxkbcommon \
  libXcomposite libXdamage libXfixes libXrandr \
  libgbm mesa-libgbm pango alsa-lib nss \
  xorg-x11-server-Xvfb
```

Verify Chromium headless shell:
```bash
~/.cache/ms-playwright/chromium_headless_shell-*/chrome-headless-shell-linux64/chrome-headless-shell --version
```

---

## Step 2 — Global Hermes files

Copy the global runtime files into `~/.hermes/`:

```bash
REPO=/path/to/no-hay-banda

# Global SOUL.md (Session Director persona)
cp $REPO/hermes/global/SOUL.md ~/.hermes/SOUL.md

# Prefill messages (few-shot delegation cycle priming)
cp $REPO/hermes/global/prefill_messages.json ~/.hermes/prefill_messages.json

# Global config — copy example, then edit with real API keys
cp $REPO/hermes/global/config.example.yaml ~/.hermes/config.yaml
# Edit ~/.hermes/config.yaml: set OPENROUTER_API_KEY, GITHUB_PERSONAL_ACCESS_TOKEN

# Global env
cp $REPO/hermes/global/.env.example ~/.hermes/.env
# Edit ~/.hermes/.env: set OPENROUTER_API_KEY, GITHUB_PERSONAL_ACCESS_TOKEN, GITHUB_PAT_WRITE

# All 30 persona files
mkdir -p ~/.hermes/personas
cp $REPO/hermes/global/personas/*.md ~/.hermes/personas/
```

---

## Step 3 — MCP servers

### Barresider x-mcp (patched local fork)

The upstream `@barresider/x-mcp` npm package has bugs that prevent login from EC2 IP ranges. Use this patched local fork:

```bash
git clone https://github.com/Barresider/x-mcp ~/.hermes/mcp/x-mcp
cd ~/.hermes/mcp/x-mcp
npm install

# Apply patches from repo source
cp $REPO/hermes/mcp/x-mcp/src/behaviors/login.ts src/behaviors/login.ts
npm run build

# Verify dist was rebuilt
node dist/mcp.js --version 2>/dev/null || echo "built OK (no --version flag)"
```

Full patch notes: `hermes/mcp/x-mcp/PATCHES.md` (also at `~/.hermes/mcp/x-mcp/PATCHES.md` after copy).

### miles0sage/twitter-mcp

```bash
git clone https://github.com/Miles0sage/twitter-mcp.git ~/.hermes/mcp/twitter-mcp
cd ~/.hermes/mcp/twitter-mcp
python3.11 -m venv venv
./venv/bin/pip install mcp playwright
./venv/bin/playwright install chromium
```

### kitadmin01/social_mcp (reference only — keep disabled)

```bash
git clone https://github.com/kitadmin01/social_mcp.git ~/.hermes/mcp/social_mcp
cd ~/.hermes/mcp/social_mcp
python3.11 -m venv venv
./venv/bin/pip install mcp playwright   # requirements.txt has a formatting bug — install manually first
./venv/bin/pip install -r requirements.txt
```

This server is kept `enabled: false`. It contains a mass-engagement tool (`engage_twitter`) that must never be activated.

---

## Step 4 — newshowbiz profile

```bash
REPO=/path/to/no-hay-banda
PROFILE=~/.hermes/profiles/newshowbiz

mkdir -p $PROFILE/docs/10-hermes
mkdir -p $PROFILE/x-auth
mkdir -p $PROFILE/store/{jobs,escalations,review-queue,approved,rejected}
mkdir -p $PROFILE/logs
mkdir -p $PROFILE/memories
mkdir -p $PROFILE/sessions
mkdir -p $PROFILE/cron

# Profile config
cp $REPO/hermes/profiles/newshowbiz/config.yaml $PROFILE/config.yaml

# Profile env (credentials)
cp $REPO/hermes/profiles/newshowbiz/.env.example $PROFILE/.env
# Edit $PROFILE/.env: set TWITTER_USERNAME, TWITTER_PASSWORD, OPENROUTER_API_KEY

# Profile SOUL.md and AGENTS.md
cp $REPO/hermes/profiles/newshowbiz/docs/10-hermes/SOUL.md $PROFILE/docs/10-hermes/SOUL.md
cp $REPO/hermes/profiles/newshowbiz/docs/10-hermes/AGENTS.md $PROFILE/docs/10-hermes/AGENTS.md

# Custom skills
for skill in content-draft-from-movie-data content-job-write escalation-record-write \
             review-decision-record x-publish-with-receipt escalation-record-create; do
  mkdir -p $PROFILE/skills/$skill
  cp $REPO/hermes/profiles/newshowbiz/skills/$skill/SKILL.md $PROFILE/skills/$skill/SKILL.md
done

# Template library
mkdir -p $PROFILE/skills/templates/{x,instagram}
cp $REPO/hermes/profiles/newshowbiz/skills/templates/_index.md $PROFILE/skills/templates/
cp $REPO/hermes/profiles/newshowbiz/skills/templates/x/*.md $PROFILE/skills/templates/x/
cp $REPO/hermes/profiles/newshowbiz/skills/templates/instagram/*.md $PROFILE/skills/templates/instagram/

# Empty store (review-log starts empty)
touch $PROFILE/store/review-log.jsonl
```

---

## Step 5 — First run verification

```bash
# Confirm profile resolves
hermes profile list

# Confirm oneshot mode works (requires model block in profile config)
hermes -p newshowbiz -z "say hello"

# Confirm MCP servers start
hermes -p newshowbiz
# In session: ask "what tools do you have?" — should list x-mcp-read and twitter-mcp tools

# Confirm skills are registered
hermes -p newshowbiz skills list | grep content-draft
```

---

## Step 6 — X authentication (one-time)

```bash
hermes -p newshowbiz
# In session: invoke the login tool
# Barresider launches headless Chromium, logs in, saves session to x-auth/twitter.json
```

**Rate limit:** X may restrict login from a new IP. If blocked, wait several hours and retry once. Do not loop. See `docs/30-operations/x-mcp-test-log.md` for the incident record.

---

## Directory Map

```
hermes/
  global/
    SOUL.md                   → ~/.hermes/SOUL.md
    prefill_messages.json     → ~/.hermes/prefill_messages.json
    config.example.yaml       → ~/.hermes/config.yaml  (edit: add real keys)
    .env.example              → ~/.hermes/.env          (edit: add real keys)
    personas/                 → ~/.hermes/personas/
      _shared-contract.md     ← governing contract for all agents
      _routing.md             ← task-to-agent routing registry
      orchestrator.md         ← Tier 1
      content-agent.md        ← Tier 1
      publish-agent.md        ← Tier 1
      metrics-agent.md        ← Tier 1
      fetch-agent.md          ← Tier 1
      project-manager.md      ← Tier 1
      analysis-agent.md       ← Tier 2
      editor.md               ← Tier 2
      engagement-agent.md     ← Tier 2
      escalation-agent.md     ← Tier 2
      execute-agent.md        ← Tier 2
      interrogator.md         ← Tier 2
      lint-agent.md           ← Tier 2
      movie-research-agent.md ← Tier 2
      report-agent.md         ← Tier 2
      researcher.md           ← Tier 2
      transform-agent.md      ← Tier 2
      validate-agent.md       ← Tier 2
      writer.md               ← Tier 2
  profiles/
    newshowbiz/
      config.yaml             → ~/.hermes/profiles/newshowbiz/config.yaml
      .env.example            → ~/.hermes/profiles/newshowbiz/.env  (edit: add credentials)
      docs/10-hermes/
        SOUL.md               → ~/.hermes/profiles/newshowbiz/docs/10-hermes/SOUL.md
        AGENTS.md             → ~/.hermes/profiles/newshowbiz/docs/10-hermes/AGENTS.md
      skills/
        content-draft-from-movie-data/SKILL.md
        content-job-write/SKILL.md
        escalation-record-write/SKILL.md
        review-decision-record/SKILL.md
        x-publish-with-receipt/SKILL.md
        escalation-record-create/SKILL.md
        templates/
          _index.md           ← template selection logic
          x/                  ← 5 X post templates
          instagram/          ← 3 Instagram caption templates
      store/                  ← empty ContentJob store (create on install)
      x-auth/                 ← empty session dir (populated after login)
  mcp/
    x-mcp/
      PATCHES.md              ← patch documentation (5 fixes to login.ts)
      src/behaviors/login.ts  ← patched TypeScript source (apply after git clone)
```

---

## Known Operational Notes

**Profile config must be self-contained for oneshot mode.** `hermes -p <profile> -z` reads only the profile's `config.yaml`, not the global config. The profile config must define `model.default` and `delegation.model` or oneshot will return empty responses. This config already includes those blocks.

**EC2 → x.com returns 403.** Cloudflare blocks EC2 IP ranges on direct HTTP. All X interaction must go through Playwright browser automation (x-mcp or global playwright). Raw API calls to X will fail.

**Hermes update = config audit.** The global config format has changed between versions (v24 → v25 during this deployment). After any `hermes update`, review `~/.hermes/config.yaml` before running a profile session.

**Engagement tools are excluded.** `like_post`, `retweet_post`, `bookmark_post` are filtered at the Hermes MCP level across all servers. Do not add them.

**x-mcp-write is disabled.** Enable only after Phase 3 acceptance criteria pass: ContentJob store validated at production volume, policy engine built, receipt store operational, Telegram oversight configured.
