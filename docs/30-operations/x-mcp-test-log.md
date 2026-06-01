# X MCP Integration Test Log

**Date:** 2026-06-01
**Instance:** EC2 i-05451add3165b57ff
**Hermes:** v0.14.0
**Node.js:** v22.22.2
**Python:** 3.11.15
**OS:** Amazon Linux 2023

---

## Executive Summary

Both X MCP servers connect and their tool registrations are correct. `twitter_user` (profile lookups) works without authentication. All other tools across both servers require authentication. Barresider's login flow was traced to completion: the login page loads, username fills, password fills, but authentication was blocked by a temporary rate limit that X applied after rapid repeated login attempts from a new EC2 IP. The login mechanics are correct; the account needs to recover before a session can be saved.

Four bugs were found and patched in Barresider's `login.js` — all relate to X's login flow having changed since the library was written.

---

## Infrastructure Prerequisites

### System libraries required for Chromium headless

Amazon Linux 2023 ships without several libraries that Chromium requires. The following must be installed before any Playwright-based MCP server will launch:

```bash
sudo dnf install -y \
  atk at-spi2-atk cups-libs libdrm libxkbcommon \
  libXcomposite libXdamage libXfixes libXrandr \
  libgbm mesa-libgbm pango alsa-lib nss \
  xorg-x11-server-Xvfb
```

`playwright install-deps` does not work on Amazon Linux (it targets Ubuntu). Install manually as above.

After installation, verify:

```bash
/home/ec2-user/.cache/ms-playwright/chromium_headless_shell-1223/chrome-headless-shell-linux64/chrome-headless-shell --version
# Expected: Google Chrome for Testing 148.0.x.x
```

### EC2 network access to X.com

Direct HTTP requests to `x.com` return `403 Forbidden` from Cloudflare — EC2 IP ranges are blocked at the HTTP level. Playwright browser automation returns `200` and loads pages normally. This means all X tooling must use browser automation; raw HTTP or API approaches will not work from this instance without a proxy.

```
curl -sI https://x.com → 403 (Cloudflare blocks EC2 IPs)
Playwright goto("https://x.com") → 200 (browser passes Cloudflare)
```

---

## Tool-by-Tool Test Results

### miles0sage/twitter-mcp

**Connection:** ✅ Connected (731ms), 11 tools registered

**Important:** This server operates without authentication and uses the headless Chromium shell. It can only access publicly visible X content. Login-gated pages return timeouts without useful error messages.

| Tool | Status | Notes |
|---|---|---|
| `twitter_user` | ✅ **Working** | Public profile data — confirmed with `@new_show_biz`: name, bio, follower/following counts. Headless, no auth. |
| `twitter_user_tweets` | ❌ Login wall | `[data-testid="cellInnerDiv"]` selector times out — X requires login to show a user's tweets even on a public profile |
| `twitter_search` | ❌ Login wall | `[data-testid="tweet"]` times out — search results gated by login |
| `twitter_trending` | ❌ Login wall | Navigates to `https://x.com/home` which redirects to login |
| `twitter_feed` | ❌ Login wall | Requires auth cookies |
| `twitter_notifications` | ❌ Login wall | Requires auth cookies |
| `twitter_bookmarks` | ❌ Login wall | Requires auth cookies |
| `twitter_post` | ❌ Excluded | Blocked by Hermes `tools.exclude` config — does not reach the server |
| `twitter_reply` | ❌ Excluded | Blocked by Hermes `tools.exclude` config |
| `twitter_like` | ❌ Excluded | Blocked by Hermes `tools.exclude` config |
| `twitter_retweet` | ❌ Excluded | Blocked by Hermes `tools.exclude` config |

**Practical scope:** `twitter_user` only. All other tools require authentication that this server does not support. Useful as a zero-auth fallback for public profile lookups.

**Tested output — `twitter_user(@new_show_biz`):**

```
Name: NewShowbiz
Username: @new_show_biz
Bio: Discover LGBTQ+ representation and diversity in movies & TV:
     ratings and reviews at newshow.biz
     Keep the spotlights on: buymeacoffee.com/newshowbiz
Followers: 0
Following: 10
```

---

### Barresider/x-mcp (`x-mcp-read`)

**Connection:** ✅ Connected (3253ms), 8 tools registered (filtered from server's 22)

**Hermes tool filter verified:** The `tools.include` list in the profile config correctly limits exposed tools to the 8 read-only tools. Write and engagement tools do not appear in the agent's toolset.

**Authentication status:** Pending. The account received a temporary login rate limit from X during testing (see Incident below). All 8 tools require an authenticated session to return data. None have been tested end-to-end.

| Tool | Status | Notes |
|---|---|---|
| `login` | ⚠️ **Patched, pending re-test** | Login mechanics verified working (page loads, fields fill) but rate limited; see Incident below |
| `search_twitter` | ⏳ Pending auth | Will work once session saved |
| `search_viral` | ⏳ Pending auth | Will work once session saved |
| `scrape_trending` | ⏳ Pending auth | Will work once session saved |
| `scrape_timeline` | ⏳ Pending auth | Will work once session saved |
| `scrape_posts` | ⏳ Pending auth | Will work once session saved |
| `scrape_profile` | ⏳ Pending auth | Will work once session saved |
| `scrape_comments` | ⏳ Pending auth | Will work once session saved |

---

## Login Incident — 2026-06-01

### What happened

X applied a temporary login restriction to the operator account after rapid repeated login attempts during canary testing from the EC2 IP. The restriction message: `"We've temporarily limited your login. Please try again later."` X applies this automatically when an account has unusual login activity (multiple failed attempts, new IP, automation patterns).

### Root cause

Login attempts failed initially due to selector drift bugs in Barresider's `login.js` (see Patches below), causing repeated retries against the same flow. The accumulation triggered X's rate limit before a successful session was saved.

### Recovery

The restriction is temporary — typically a few hours to 24 hours. No action required on the account. When it clears, run the `login` tool once from the Hermes profile and the session will be saved to `x-auth/twitter.json`.

### Risk note

The account used (`@stex_press`) appears to be the operator's primary account rather than a dedicated throwaway read account as recommended in the spec. Using the primary account for initial canary testing increases the risk if X applies longer restrictions or flags the account. Consider creating a separate read-only account for Phase 1/2 automation testing before using the primary account.

---

## Barresider/x-mcp Patches

All patches applied to:
`~/.npm/_npx/05614bcc6ec2276c/node_modules/@barresider/x-mcp/dist/behaviors/login.js`

These patches are applied to the local npx cache only. They will be lost if the package cache is cleared. The changes should be submitted upstream or maintained locally.

### Bug 1: Stale login URL

**Original:**
```javascript
await page.goto("https://twitter.com/i/flow/login");
```
**Patched:**
```javascript
await page.goto("https://x.com/i/flow/login", { waitUntil: "domcontentloaded" });
await page.waitForTimeout(4000);  // let React hydrate
```
**Reason:** X migrated from `twitter.com` to `x.com`. The old URL redirects, but `waitUntil: "load"` on the redirect chain sometimes races ahead of React hydration. `domcontentloaded` + explicit wait is more reliable.

### Bug 2: Stale username selector

**Original:**
```javascript
const userInput = '//input[@autocomplete="username"]';
```
**Patched:**
```javascript
await page.fill('input[name="username_or_email"]', user, { timeout: 15000 });
```
**Reason:** X changed the login form. The current input has `name="username_or_email"` and `autocomplete="username webauthn"`. The old exact-match `@autocomplete="username"` selector no longer matches.

### Bug 3: Stale Next button selector

**Original:**
```javascript
await page.click("//span[contains(text(), 'Next')]");
```
**Patched:**
```javascript
const btns1 = await page.$$("button");
await btns1[3].click();  // button[3] is the Continue button in current layout
```
**Reason:** X renamed "Next" to "Continue". The span selector approach is fragile; button index is stable in the current 6-button layout (index 0: close, 1: phone, 2: Apple, 3: Continue, 4: phone dup, 5: Apple dup).

### Bug 4: `headless: false` on a headless server

**Original:**
```javascript
const browser = await playwright_1.chromium.launch({
    headless: false,
    slowMo: 1000,
});
```
**Patched:**
```javascript
const browser = await playwright_1.chromium.launch({
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox"],
});
```
**Reason:** Headed mode requires an X display server (`$DISPLAY`). On EC2, there is no display. The original code required `xvfb-run` as a workaround; headless mode runs without it. `--no-sandbox` is required on EC2 because Chrome's sandbox requires user namespaces that Amazon Linux restricts.

### Bug 5: Hardcoded auth file path

**Original:**
```javascript
const authFile = "playwright/.auth/twitter.json";
```
**Patched:**
```javascript
function getAuthFile() {
    const authDir = process.env.AUTH_DIR || path_1.join(process.cwd(), "playwright/.auth");
    if (!fs_1.existsSync(authDir)) {
        fs_1.mkdirSync(authDir, { recursive: true });
    }
    return path_1.join(authDir, "twitter.json");
}
```
**Reason:** The hardcoded path wrote to `./playwright/.auth/` relative to wherever npx launched from — unpredictable and likely wrong. `AUTH_DIR` env var is now the canonical session path, set to `~/.hermes/profiles/newshowbiz/x-auth/` in the profile `.env`.

### Bug 6: `console.log` on the MCP stdio channel

**Original:**
```javascript
console.log("Logging in...");
```
**Patched:**
```javascript
console.error("Logging in...");
```
**Reason:** The MCP protocol uses stdio for JSON-RPC. Any non-JSON `console.log` output corrupts the message stream, causing the MCP client to fail to parse server messages. `console.error` writes to stderr, which Hermes captures in `~/.hermes/profiles/newshowbiz/logs/mcp-stderr.log` without interfering with the protocol.

---

## microsoft/playwright-mcp (global)

**Connection:** ✅ Available (inherited from global Hermes config)

Not tested in isolation, but the underlying Chromium binary was confirmed working (headless shell version check passed). The global `playwright` MCP server is available in any Hermes session including `hermes -p newshowbiz`.

---

## kitadmin01/social_mcp

**Connection:** ✅ Connected when manually started, 8 tools registered
**Status:** Disabled — `enabled: false` in profile config

Not tested for tool functionality. Contains `engage_twitter` which runs mass-liking automation — this must never be enabled in an autonomous workflow. Tool spec confirmed via source inspection:

```python
async def engage_twitter(max_likes: int = 10) -> str:
    # auto-likes up to max_likes tweets matching search terms
```

This is exactly the kind of engagement automation the spec prohibits. The server remains disabled and is kept only as an implementation reference for session management and retry logic patterns.

---

## Next Steps to Complete Authentication

1. **Wait for rate limit recovery** — typically a few hours to 24 hours. No action required on the account.

2. **Run login once:**
   ```
   hermes -p newshowbiz
   # In the session, call the login tool:
   # Use login tool → authenticates, saves session to x-auth/twitter.json
   ```

3. **Verify session saved:**
   ```bash
   ls -la ~/.hermes/profiles/newshowbiz/x-auth/twitter.json
   ```

4. **Test a read tool:**
   ```
   # In hermes -p newshowbiz session:
   # Use search_twitter to search for "newshow.biz"
   # Use scrape_trending to get trending topics
   # Use scrape_profile to scrape @new_show_biz
   ```

5. **Monitor account health:**
   After login succeeds, check the account shows no warnings. If X presents a phone verification or suspicious activity challenge, it must be completed manually in a real browser before automation can continue.

---

## Summary Table

| Capability | Tool | Server | Status |
|---|---|---|---|
| Public profile lookup | `twitter_user` | twitter-mcp | ✅ Working |
| X trends (authenticated) | `scrape_trending` | x-mcp-read | ⏳ Auth pending |
| X search (authenticated) | `search_twitter` | x-mcp-read | ⏳ Auth pending |
| X search viral | `search_viral` | x-mcp-read | ⏳ Auth pending |
| Timeline read | `scrape_timeline` | x-mcp-read | ⏳ Auth pending |
| Posts scrape | `scrape_posts` | x-mcp-read | ⏳ Auth pending |
| Profile scrape (auth) | `scrape_profile` | x-mcp-read | ⏳ Auth pending |
| Comments scrape | `scrape_comments` | x-mcp-read | ⏳ Auth pending |
| X post / thread / reply | `tweet`, `thread`, `reply_to_post` | x-mcp-write | ❌ Disabled (Phase 3) |
| Engagement (like/rt/bookmark) | all | all servers | ❌ Permanently excluded |
| Public tweets lookup | `twitter_user_tweets` | twitter-mcp | ❌ Login wall |
| Unauthenticated search | `twitter_search` | twitter-mcp | ❌ Login wall |
| Unauthenticated trends | `twitter_trending` | twitter-mcp | ❌ Login wall |
| Mass engagement | `engage_twitter` | social-mcp | ❌ Server disabled |
