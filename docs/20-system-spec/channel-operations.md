# Channel Operations

## Channel Thesis

The v1 operator owns one public channel:

- `X`: speed, reach, reaction, argument, and controlled edge

## Hermes Integration Model

Hermes is the operator runtime. It is not the public `X` transport.

Operational consequences:

- all public channel writes must use explicit custom tools
- write-capable tools must be separated from read-only tools
- X-specific operations should use `Barresider/x-mcp` only through New Showbiz wrappers
- general browser automation should use `microsoft/playwright-mcp` for fallback inspection, not unsupervised publishing
- catalog, search, movie-detail, account-activation, and donation URLs should be generated from live site data rather than typed manually
- publishing tools must return durable receipts
- inbox tools must preserve source payloads and thread context
- metrics tools must normalize platform data without becoming the attribution source of truth
- human review should run through Hermes CLI, gateway, API server, or a custom dashboard
- internal oversight channels must remain separate from public brand channels

## Required Channel Tool Surface

Each channel integration should expose these classes of tools.

### Read Tools

- fetch account status
- fetch recent posts
- fetch post status
- fetch mentions, replies, comments, and quote-like interactions
- fetch DMs where allowed
- fetch analytics snapshots
- fetch media status
- fetch rate-limit or account-health signals where available
- fetch canonical movie, browse-filter, signup, contact, and donation URLs for CTA construction

### Write Tools

- create immediate post
- create scheduled post
- update scheduled post where supported
- upload media
- attach media to post
- send public reply or comment
- send DM only where policy and platform support allow it
- hide, delete, or correct content only through incident-specific tooling

### Receipt Requirements

Every write tool must return:

- platform
- action type
- platform object ID
- canonical URL where available
- final sent text
- media IDs
- timestamp
- idempotency key or request ID where available
- status
- error code and retry hint on failure

## X MCP Operating Model

Recommended stack:

- primary X-specific candidate: `Barresider/x-mcp`
- general browser fallback: `microsoft/playwright-mcp`
- scaffold reference only: `kitadmin01/social_mcp`
- experimental research only: `miles0sage` PulseMCP listing

Case-specific use:

- trend discovery: use `Barresider/x-mcp` read tools for search, trends, profiles, and timelines; fall back to Playwright MCP inspection only when the X-specific reader fails
- reactive drafting: retrieve source thread context through read-only wrappers; do not quote-post without preserved source context
- publishing: call `tweet`, `thread`, `reply_to_post`, or `quote_tweet` only through `newshowbiz_x_publish_reviewed`
- media upload: require separate media approval and media receipt capture
- replies: retrieve thread context first; routine replies may become autonomous only after beta
- engagement actions: keep like, retweet, bookmark, and mass engagement manual or disabled in v1
- account health: track login failures, CAPTCHA, Cloudflare or `403`, selector drift, rate limits, and warning banners

Default config:

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

Proxy config:

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

General Playwright fallback:

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

## Content Programs

### Evergreen Discovery

Purpose:

- drive qualified traffic to movie pages
- build repeatable recommendation formats
- help users find titles before movie night

Formats:

- recommendations
- "if you liked X, try Y"
- overlooked title prompts
- family or group watch prompts
- genre or mood lists

Primary KPI:

- qualified traffic

### Score Explainers

Purpose:

- make the New Showbiz framework legible
- build trust in the analysis
- answer predictable user questions

Formats:

- "what this score means"
- category breakdowns
- why a title scored high or low
- score misconception correction

Primary KPI:

- clicks, support-question reduction, trust indicators

### Comparison Posts

Purpose:

- teach the product through contrast
- create useful debate without losing evidence

Formats:

- movie versus movie
- old franchise entry versus new entry
- mainstream hit versus under-discussed alternative
- category-level comparison

Primary KPI:

- qualified traffic, replies with usable signal

### Reactive Commentary

Purpose:

- connect current movie discourse to New Showbiz source objects
- move quickly when attention is concentrated

Formats:

- quick take
- quote-post
- "we checked the score"
- title-specific response
- trend-linked comparison

Primary KPI:

- reach converted to traffic, not reach alone

### Product Utility

Purpose:

- teach people how to use the site
- lower friction to signup or repeat visit

Formats:

- "how to use New Showbiz before movie night"
- watchlist/rating/review explanations
- search and representation-filter walkthroughs
- where-to-watch link prompts
- score category walkthroughs
- search and browse tips

Primary KPI:

- signups, repeat visits, support deflection

### Support the Project

Purpose:

- convert trust into donations
- explain why independent support matters

Formats:

- transparent cost posts
- milestone posts
- supporter thank-yous
- "what support funds" explainers

Primary KPI:

- donation-page visits and conversions

### Feedback and Correction Intake

Purpose:

- route bug reports and invalid diversity analysis reports to the right contact path
- show that AI-generated profiles can be challenged without turning every disagreement into a public fight

Formats:

- contact-path reminders
- "spot an issue?" posts
- transparent correction-process replies

Primary KPI:

- resolved reports, fewer public disputes, trust preservation

## Cadence

### X

Default daily cadence:

- 4 to 8 posts
- 1 comparison or score explainer
- 1 to 2 reactive posts on high-opportunity days
- active reply windows during selected periods

Default mix:

- 40% discovery and utility
- 25% reactive commentary
- 20% comparison and score explanation
- 10% support-the-project
- 5% experimental edge, including eligible `TROLL`

## Formatting Rules

### X

- lead with the strongest line
- keep paragraphs short
- prefer specificity over generic sentiment
- use links when the objective is traffic
- use threads only when compression weakens the idea
- use quote-posts only when the source context is safe and preserved
- use `TROLL` only when the campaign objective and policy allow it

## Reply Model

### Public Replies: Autonomous

Autonomous replies are allowed for:

- where to find a movie or page
- what a score means
- how to use the site
- routine praise
- routine feedback
- approved donation information
- low-risk clarification
- where-to-watch or browse-filter guidance
- bug-report and invalid-analysis routing

### Public Replies: Escalated

Escalate when:

- legal risk appears
- money, sponsorship, partnership, or collaboration terms appear
- protected identity conflict appears
- a creator complaint appears
- the user alleges factual error, harm, defamation, or discrimination
- the thread is high-visibility backlash
- the channel tool cannot provide enough context
- the answer requires evidence the system cannot verify
- the user asks for refunds, tax treatment, or investment advice related to crypto support

### Response Postures

Allowed response postures:

- answer
- acknowledge
- clarify
- redirect
- de-escalate
- ignore
- escalate

The system should not debate indefinitely. A second adversarial turn should usually trigger disengagement or escalation.

## DM Model

Allowed autonomous DM uses:

- basic product help
- where-to-start guidance
- bug-report intake
- donation link using approved language
- routing a user to support or review path

Escalated DM uses:

- partnership
- sponsorship
- creator complaint
- collaboration terms
- legal threat
- money negotiation
- safety-sensitive disclosure

If a platform integration cannot provide safe thread context, DM automation should be disabled.

## Channel-Specific Autonomy

### X

Autonomous by default:

- low-risk posts
- utility posts
- routine replies
- source-backed comparisons
- low-risk reactive posts

Require extra policy check:

- `DEBATE` mode
- reactive claims about external people or brands
- score claims likely to provoke dispute
- high-reach quote-posts
- any write through X browser automation during beta

Escalate:

- `TROLL` crossing risk threshold
- viral backlash
- creator complaint
- legal, money, partnership, or identity-sensitive issues
- X login wall, CAPTCHA, Cloudflare block, account warning, or repeated selector failure before a publish window

## Template Categories

### X Templates

- fast recommendation
- discourse correction
- score punchline
- movie comparison
- product utility
- trend reaction
- donation transparency
- supporter thank-you
- controlled provocation

## Operational Defaults

- `X` is the publishing channel.
- Every post gets one primary objective.
- Every claim needs source support.
- Every publish action returns a receipt.
- Every escalation creates a durable record.
- Hermes cron schedules and initiates work; custom integrations perform public channel actions.
- X MCP servers are implementation adapters, not autonomy permissions.
