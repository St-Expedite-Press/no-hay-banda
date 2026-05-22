# X MCP Options and Case-Specific Discussions

## Decision Thesis

The best v1 fit for X/Twitter-specific automation is `Barresider/x-mcp`, with `microsoft/playwright-mcp` retained as the durable general browser-control fallback. `kitadmin01/social_mcp` is useful as an implementation reference for broader marketing automation patterns, not as the default runtime dependency. The `miles0sage` PulseMCP listing should be treated as experimental until it has stronger public adoption and direct repo review.

The operating conclusion is not "turn on social automation." The operating conclusion is to expose X through a narrow, audited tool layer where read tools, draft generation, and public writes are separated. Public writes remain draft-first or approval-gated until receipts, rate limits, login persistence, and incident telemetry are proven.

## Verified Options

### Barresider/x-mcp

Source: `https://github.com/Barresider/x-mcp`

Verified GitHub README claims:

- unofficial X/Twitter access through Playwright browser automation
- `npx -y @barresider/x-mcp`
- Node.js 18 or newer
- environment credentials through `TWITTER_USERNAME` and `TWITTER_PASSWORD`
- optional proxy support through `PROXY_URL`, `PROXY_USERNAME`, and `PROXY_PASSWORD`
- stdio, SSE, and HTTP transports through `MCP_TRANSPORT` and `MCP_PORT`
- persistent authentication state through `AUTH_DIR`
- tools for login, tweets, threads, replies, quote tweets, likes, retweets, bookmarks, profile scraping, timeline scraping, comment scraping, search, viral search, and trending topics

Recommended use:

- default X-specific MCP candidate for read, search, trend, profile, timeline, reply-draft context, thread publishing, post publishing, media upload, and receipt capture
- only expose write tools to workflows that have passed policy and approval gates
- do not expose like, retweet, bookmark, or high-volume engagement tools to autonomous workflows in v1

Basic config:

```json
{
  "mcpServers": {
    "x-mcp": {
      "command": "npx",
      "args": ["-y", "@barresider/x-mcp"],
      "env": {
        "TWITTER_USERNAME": "your_twitter_username",
        "TWITTER_PASSWORD": "your_twitter_password"
      }
    }
  }
}
```

With proxy:

```json
{
  "mcpServers": {
    "x-mcp": {
      "command": "npx",
      "args": ["-y", "@barresider/x-mcp"],
      "env": {
        "TWITTER_USERNAME": "your_twitter_username",
        "TWITTER_PASSWORD": "your_twitter_password",
        "PROXY_URL": "http://proxy-server:port"
      }
    }
  }
}
```

New Showbiz constraints:

- treat it as unofficial browser automation, not a platform contract
- use a dedicated account session directory
- persist X post IDs, URLs, final text, media IDs, action type, and tool response
- require human approval for `tweet`, `thread`, `reply_to_post`, and `quote_tweet` until a production beta proves safe
- block autonomous `like_post`, `retweet_post`, and `bookmark_post` unless a future policy explicitly approves limited engagement actions

### microsoft/playwright-mcp

Source: `https://github.com/microsoft/playwright-mcp`

Verified GitHub README claims:

- general Playwright MCP server for browser automation
- uses structured accessibility snapshots rather than screenshot-only interaction
- runs with `npx @playwright/mcp@latest`
- requires Node.js 18 or newer
- supports persistent profiles, isolated contexts, storage state, user data directories, browser selection, proxy options, and optional capabilities
- the README itself notes that CLI plus skills can be more token-efficient for coding agents, while MCP is useful for persistent state, introspection, and long-running browser workflows

Recommended use:

- fallback browser-control layer when X-specific MCP tools fail or lag behind UI drift
- exploratory browser reads for login-wall diagnosis, selector drift, and page-state verification
- non-X browser automation for New Showbiz site QA, landing-page checks, donation-page checks, and social-link verification
- custom X workflow development when a narrow tool should later be promoted into a New Showbiz plugin or service adapter

Config:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

New Showbiz constraints:

- do not use raw browser control as a shortcut around policy
- do not publish through general browser actions when a write-specific channel tool should exist
- save storage state only in approved local or secrets-managed paths
- prefer read-only browser inspection unless the workflow is explicitly in a supervised publishing mode

### kitadmin01/social_mcp

Source: `https://github.com/kitadmin01/social_mcp`

Verified GitHub README claims:

- multi-agent social media automation system for Twitter and Bluesky
- uses LLMs for content generation, Playwright for Twitter browser automation, and APIs for platform integration
- includes persistent sessions, login detection, tweet posting with retry logic, hashtag search, engagement automation, content scheduling, Google Sheets integration, and retry/secrets utilities
- configured with `TWITTER_USERNAME`, `TWITTER_PASSWORD`, `PLAYWRIGHT_SESSION_DIR`, and `HEADLESS`

Recommended use:

- reference implementation for persistent session management, login-state checks, retry logic, scheduling, and Google Sheets-style campaign operations
- not the default runtime dependency for v1 because it combines generation, scheduling, and engagement automation in a broad scaffold
- avoid importing its engagement-automation posture directly; New Showbiz has stricter approval, evidence, and account-safety requirements

### miles0sage Twitter/X Playwright MCP

Source: `https://www.pulsemcp.com/servers/miles0sage-twitter`

PulseMCP currently describes this as a community Twitter/X Playwright MCP server released on March 17, 2026, with tweet reading, posting, search, and trend tracking. PulseMCP also lists the GitHub repo at 0 stars. Treat it as experimental.

Recommended use:

- research-only candidate
- do not use for production or credentialed New Showbiz accounts until the repo, maintenance history, install path, security posture, and tool semantics are reviewed directly

## Hermes Evidence

Hermes issue `NousResearch/hermes-agent#10959` is useful design evidence, not an active upstream commitment. It is closed as `not_planned`, but the issue records the core operational problem: simple automated requests to X can hit Cloudflare or `403 Forbidden`, while browser automation can still work when it resembles a real browser session.

Implications:

- browser automation is a pragmatic X access path, not a stable API guarantee
- X workflows must expect login walls, Cloudflare blocks, CAPTCHA, selector drift, account-health warnings, and session expiry
- persistent browser sessions and storage state are required
- account-safety telemetry is a first-class metric
- write actions need human approval, rate limits, receipts, and rollback/incident paths

## Case-Specific Usage

### Trend Discovery and Audience Research

Default tool:

- `Barresider/x-mcp` search, trend, profile, and timeline reads

Fallback:

- `microsoft/playwright-mcp` for page inspection when X-specific reads fail

Policy:

- read-only
- no likes, retweets, follows, or bookmarks
- store source URLs and timestamps for any trend used in a campaign brief

### Reactive X Post Drafting

Default tool:

- `Barresider/x-mcp` for source thread/profile context

Fallback:

- `microsoft/playwright-mcp` for manual browser verification

Policy:

- draft-only unless the `ContentJob` has source evidence, risk classification, policy disposition, and approval
- quote-posts require preserved source context
- `TROLL` requires a separate policy pass

### Publishing Single Posts and Threads

Default tool:

- `Barresider/x-mcp` `tweet` and `thread`

Fallback:

- no automatic fallback to raw Playwright publishing in v1

Policy:

- human approval required during beta
- final sent text must match approved copy or create a new review event
- every write must return a durable receipt
- retry logic must be idempotent or explicitly single-shot

### Public Replies

Default tool:

- `Barresider/x-mcp` reply tools, only after thread-context retrieval

Fallback:

- `microsoft/playwright-mcp` for context reconstruction, not autonomous sending

Policy:

- routine product help may become autonomous after beta
- score disputes, identity-sensitive conflict, creator complaints, money, legal, and platform warnings escalate
- second adversarial turn usually triggers disengagement or escalation

### Engagement Actions

Default tool:

- none for autonomous v1

Discussion:

`Barresider/x-mcp` exposes like, retweet, bookmark, and comment-interaction tools. These are useful capabilities but high-risk as autonomous defaults because they look like spam or manipulation at scale and can damage account health. New Showbiz should treat them as manual or incident-specific tools until a formal engagement policy exists.

### Media Upload

Default tool:

- `Barresider/x-mcp` media upload if it proves reliable in canary testing

Fallback:

- platform-native manual upload or a custom service adapter

Policy:

- media must be approved separately from text
- screenshots, posters, and generated visuals must respect rights, attribution, and platform policy
- upload receipts must include media IDs

### Site QA and Landing-Page Verification

Default tool:

- `microsoft/playwright-mcp` or the local Playwright skill

Policy:

- use before campaigns that route to `/movies`, movie detail pages, `/donate`, `/contact`, or `/sign-up`
- verify live URLs, visible CTA, and basic page status before publishing high-volume campaigns

## Required Wrapper Layer

Do not expose third-party MCP tools directly to all Hermes workflows. Wrap them behind New Showbiz toolsets:

- `newshowbiz_x_read`: search, trend, profile, timeline, post status, account status
- `newshowbiz_x_draft_context`: context retrieval plus evidence packing for draft jobs
- `newshowbiz_x_publish_reviewed`: approved publish, thread, reply, quote-post, media upload
- `newshowbiz_x_account_safety`: login status, CAPTCHA/block detection, rate-limit and account-health diagnostics
- `newshowbiz_browser_read`: general browser QA and page-state reads

The wrapper layer should normalize tool results into New Showbiz records and hide unapproved capabilities from cron jobs.

## Acceptance Criteria

The X MCP layer is implementation-ready when:

- Node.js 18 or newer is available in the deployment environment
- X credentials are stored outside committed files
- a persistent auth/session directory is configured
- proxy policy is approved or explicitly disabled
- read-only canary runs succeed without account warnings
- write canary runs require approval and return receipts
- retries cannot duplicate posts
- tool failures are classified as auth, selector, block, rate-limit, network, or unknown
- `TROLL` and engagement actions cannot access write tools unless explicitly authorized
- documentation links each public action to `ContentJob`, `EngagementJob`, policy disposition, and receipt
