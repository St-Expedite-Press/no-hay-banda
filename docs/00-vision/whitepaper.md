# Whitepaper: A Hermes-Backed Marketing Operator for New Showbiz

## Executive Summary

New Showbiz is a structured movie-discovery product, not a generic entertainment account. It has a searchable catalog of more than 110,000 movies, AI-generated inclusivity profiles, category scores, category explanations, watch-provider links, user ratings/reviews, watchlist actions, and an independent-project support narrative. That makes it a strong candidate for a governed autonomous marketing operator.

The operator should run on Hermes Agent because Hermes already provides the hard general machinery: agent loop, prompt assembly, skills, memory, session search, cron, plugins, MCP, gateway surfaces, approvals, profiles, and container backends. New Showbiz should not rebuild that substrate.

The work is specialization. The operator must turn product evidence into social-native content and engagement while preserving policy boundaries around money, partnerships, legal exposure, identity-sensitive conflict, creator complaints, and high-risk public backlash.

## Why New Showbiz Fits Autonomous Marketing

Autonomous marketing works best when the source material is structured and repeatable. New Showbiz has that structure.

Each movie page can become:

- recommendation copy
- comparison copy
- score explanation
- category breakdown
- where-to-watch prompt
- watchlist, rating, and review activation prompt
- audience prompt
- reactive hook
- Instagram carousel
- support or donation narrative when appropriate

The operator does not need to invent the business every morning. It needs to translate existing product structure into useful distribution.

## Why Hermes Is the Right Runtime Base

Hermes is useful here because it is not just a chat wrapper. It is a persistent agent runtime with operational surfaces that matter for a real marketing system:

- `AIAgent` for tool-calling runs
- `docs/10-hermes/SOUL.md` for stable identity
- `docs/10-hermes/AGENTS.md` and context files for project rules
- skills for reusable procedures
- memory and session search for durable working context
- cron for autonomous recurring work
- plugins and MCP for custom integrations
- gateway and API surfaces for oversight
- profiles for runtime isolation
- approvals and container backends for safety

Those capabilities let the project focus on the missing business layer: `X` and `Instagram` integrations, campaign data, review workflows, analytics joins, policy rules, and live product affordances such as browse filters, watch-provider links, rating/review prompts, watchlists, contact paths, and donation constraints.

For X specifically, the best current option is to use `Barresider/x-mcp` as the X-specific Playwright MCP candidate and keep `microsoft/playwright-mcp` as the general browser-control fallback. That gives the project tools for X search, timeline/profile reads, posting, threads, replies, media upload, and trend discovery without pretending X exposes a stable automation surface. `kitadmin01/social_mcp` should inform session and retry design, while the `miles0sage` PulseMCP listing should remain experimental.

## What Hermes Does Not Solve

Hermes does not natively provide:

- `X` publishing
- Instagram publishing
- public-channel inbox moderation for those platforms
- media scheduling
- social analytics normalization
- donation attribution
- New Showbiz content-job persistence
- New Showbiz escalation ownership
- invalid-analysis report handling
- account activation attribution

Treating Hermes as if it already solves these would create an unsafe product. Hermes should call explicit tools. It should not be trusted to improvise public social operations through arbitrary shell commands or vague browser workflows.

The same rule applies to MCP. A third-party X MCP server is an adapter, not a governance model. New Showbiz still needs wrapper toolsets, policy gates, account-safety telemetry, idempotency, receipts, and human approval for beta writes.

## The Operator Model

The correct model is not "one bot with a spicy personality." The correct model is a governed operator with specialized internal roles:

- research detects opportunities
- product explanation preserves clarity
- editors adapt to channel grammar
- growth analysis measures business value
- risk governance blocks unsafe action
- controlled provocation can be used on `X` when justified
- product explanation routes users to search, filters, watch providers, watchlists, ratings, reviews, and contact paths

The public output remains singular: `New Showbiz`.

## Why One Public Voice Matters

New Showbiz is still building recognition and trust. Public persona fragmentation would make the account feel unstable and theatrical. The audience should recognize one accountable product, not a rotating cast of agent masks.

Internal personas are useful because they decompose work. They should not appear as public characters.

## Why TROLL Mode Exists

On `X`, attention often rewards contrast, challenge, and friction. A small independent project may need sharper hooks to enter conversation. A controlled `TROLL` mode can:

- challenge lazy movie discourse
- make comparisons more visible
- create reach without paid media
- give the brand more nerve on the only channel where that can be useful

The value is real, but narrow.

## Why TROLL Mode Is Dangerous

New Showbiz touches representation, identity, taste, and cultural judgment. Reckless provocation can quickly become harassment, misrepresentation, identity conflict, or brand collapse. It can also corrupt the metrics loop by rewarding noise instead of qualified traffic or trust.

Therefore `TROLL` mode must be:

- restricted to `X`
- forbidden in DMs and support
- forbidden for donation or partnership content
- fact-bound
- policy-bound
- incident-reviewed
- suspendable

If the operator cannot measure risk-adjusted business value, it should not scale provocation.

## Governance Model

The governance stack should have five layers.

### Brand Rules

Define promise, tone, banned claims, donation language, and product-positioning boundaries.

### Persona Controls

Define each internal role, allowed tasks, blocked tasks, channel permissions, and escalation triggers.

### Policy Engine

Evaluate channel, risk, evidence, money, identity-sensitive topics, legal exposure, and platform-policy exposure before public action.

### Escalation System

Capture high-risk cases with source context, draft response, evidence gap, human owner, and final resolution.

### Incident Review

Review backlash, inaccurate claims, creator complaints, and `TROLL` incidents before similar tactics return.

## Strategic Risks

- optimizing for raw engagement instead of qualified traffic
- using donation messaging too often
- letting `X` tone drift away from product usefulness
- overproducing generic posts
- treating AI analysis as more objective than it is
- making evidence-weak score claims
- allowing Hermes convenience to blur tool boundaries
- ignoring support constraints around non-tax-deductible contributions and irreversible crypto payments

## Ethical Risks

- exploiting identity-centered topics for attention
- implying certainty where the score framework is interpretive
- fabricating social proof
- responding to users in a manipulative or unfair way
- creating a public voice that feels automated, defensive, or evasive

## Platform Risks

- automation enforcement
- Cloudflare or `403` blocks against simple automated X requests
- X login walls, CAPTCHA, selector drift, session expiry, and account locks
- spam classification
- harassment moderation
- account-health damage from repeated high-friction posting
- misinformation or deceptive-behavior interpretation
- privacy violations in DM handling

## Recommended Rollout

### Stage 1: Documentation and Manual Review

Lock brand rules, domain objects, persona contracts, policy, templates, and reporting. Use Hermes for drafting and reporting, but keep publication human-reviewed.

### Stage 2: Read-Only Integrations and Reporting

Expose source data, site analytics, and platform metrics through read-only tools. Prove reporting and attribution before adding public writes.

For X, canary `Barresider/x-mcp` read workflows first. Track login state, block behavior, selector failures, and account-health warnings before any publishing test.

### Stage 3: Low-Risk Autonomous Publishing

Add write-capable `X` and Instagram tools with receipts and narrow toolsets. Allow low-risk and approved medium-risk content.

For X, writes should start as reviewed `Barresider/x-mcp` calls through `newshowbiz_x_publish_reviewed`. Do not fall back to raw Playwright publishing when the reviewed path fails.

### Stage 4: Routine Engagement

Handle routine questions, praise, basic product help, and low-risk DMs. Escalate disputes and sensitive matters.

### Stage 5: Managed Edge and Optimization

Introduce `DEBATE` and controlled `TROLL` workflows on `X` only after policy, incident review, and risk-adjusted metrics are working.

## Conclusion

New Showbiz should use Hermes as the agentic operating layer and build a disciplined business layer around it. The opportunity is operational leverage: more useful content, faster reaction, better learning loops, and less manual drafting.

The danger is unmanaged autonomy. The operator should never become a free-roaming social persona. It should remain a governed marketing system with durable records, explicit channel tools, one public voice, and hard escalation boundaries.

