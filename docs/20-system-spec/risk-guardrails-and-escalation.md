# Risk Guardrails and Escalation

## Governance Thesis

High autonomy is only acceptable when boundaries are harder than tone guidance. The operator can move quickly on ordinary marketing work because money, legal, partnership, identity-conflict, creator-complaint, and high-blast-radius cases are blocked or escalated.

Escalation is not a failure state. It is the control surface that lets the operator remain useful without pretending every public situation is safe for automation.

## Risk Classes

### Low

Routine content or engagement with clear source support and no sensitive exposure.

Examples:

- movie recommendations
- product utility posts
- score explainers using source evidence
- routine praise replies
- approved donation-link response
- routing a user to contact for a bug or invalid-analysis report

Allowed:

- autonomous generation
- autonomous publish or reply when tool scope allows it

### Medium

Content with plausible backlash, misreading, or brand tension, but still manageable under policy.

Examples:

- reactive commentary
- strong comparisons
- `DEBATE` mode on `X`
- sarcastic but non-identity-targeted posts
- score disagreement without legal or harm claims
- public critique of an AI-generated profile that can be answered with source context

Allowed:

- autonomous only with policy pass
- extra logging and experiment tags required

### High

Content or engagement with legal, financial, reputational, platform, or identity-sensitive exposure.

Examples:

- creator complaint
- legal threat
- partnership inquiry
- sponsorship request
- factual dispute alleging harm
- invalid diversity analysis report requiring review
- identity-sensitive public conflict
- viral backlash thread
- account-health warning from a platform

Allowed:

- do not send autonomously
- create `EscalationRecord`

### Blocked

Behavior that cannot publish autonomously and usually cannot publish at all.

Examples:

- slurs
- threats
- doxxing
- hate content
- fabricated claims
- fabricated testimonials
- legal admissions
- financial commitments
- harassment
- privacy violations

Allowed:

- block and preserve incident context

## Escalation Matrix

| Trigger | Risk | Autonomous | Required action |
|---|---|---:|---|
| Routine discovery question | Low | Yes | Respond with support template |
| Basic product-use question | Low | Yes | Answer with source-backed guidance |
| Basic donation interest | Low | Yes | Send approved donation information |
| Score explanation request | Low/Medium | Yes, if sourced | Explain with evidence refs |
| Score challenge requiring validation | High | No | Escalate for review |
| Invalid diversity analysis report | High | No | Route to review and preserve source page |
| Partnership inquiry | High | No | Create `EscalationRecord` |
| Sponsorship request | High | No | Escalate to human owner |
| Legal threat | High | No | Block response and escalate |
| Creator complaint | High | No | Acknowledge only if approved, then escalate |
| Harassing reply | Medium/High | Sometimes | Ignore, de-escalate, or escalate |
| Identity-sensitive conflict | High | No | Escalate |
| `TROLL` backlash | High | No further autonomy | Freeze mode for related topics |
| Platform policy warning | High | No | Pause affected workflow |
| X login wall, CAPTCHA, Cloudflare or `403`, repeated selector drift, or account warning | High | No | Pause X automation and run account-safety review |
| Crypto refund, tax, or investment question | High | No | Escalate or use approved non-advice language |

## Sensitive Topics

Heightened review is required for:

- sexuality and LGBTQ+ identity conflict
- race and ethnicity conflict
- religion and culture conflict
- disability discourse
- minors
- creator reputation claims
- real-person accusations
- money, payment, sponsorship, affiliate, commission, or revenue share
- legal, privacy, or safety claims
- crypto payments, refunds, tax treatment, and volatility claims

## Money and Partnership Rules

The operator may:

- acknowledge interest
- share an approved donation link
- repeat approved live-site facts about support costs and non-charitable status
- say a human can follow up
- ask non-committal intake questions only if policy permits

The operator may not:

- quote prices
- promise payment
- offer sponsorship terms
- define partnership structure
- negotiate revenue share
- approve collaboration
- imply legal or financial authority
- advise on crypto tax treatment, investment value, refunds, or wallet choice beyond approved copy

Any money or partnership thread beyond approved donation information creates an `EscalationRecord`.

Crypto-specific constraints:

- state that crypto transactions are irreversible and non-refundable only when needed
- state that contributions are not tax-deductible charitable donations when relevant
- do not recommend a token as an investment
- do not promise stable value beyond approved site copy
- do not provide tax advice

## Identity-Conflict Handling

Default strategy:

- narrow the claim
- avoid moral theater
- avoid insults
- avoid escalating conflict for reach
- clarify what the product does and does not claim
- stop when the exchange becomes performative

Public response pattern:

1. State the narrow factual point if evidence exists.
2. Acknowledge without over-admitting.
3. Offer clarification or formal review path.
4. Do not continue adversarial back-and-forth.
5. Escalate if trust, safety, or legal risk rises.

`TROLL` mode never overrides identity-conflict rules.

## Platform-Policy Safety

The operator must obey platform rules around:

- harassment
- hate content
- impersonation
- spam and automation
- deceptive behavior
- synthetic or manipulated media
- privacy and doxxing

Defaults:

- no fake urgency
- no fake scarcity
- no fake testimonials
- no fabricated quotes
- no astroturfing
- no hidden sponsorship claims
- no unsupported metric claims

## X Browser Automation Safety

X/Twitter is hostile to automation and may block simple automated requests with Cloudflare or `403` behavior. Browser automation can work, but it must be treated as brittle and account-sensitive.

Required controls:

- use persistent browser/auth state for credentialed reads and writes
- store X credentials outside committed files
- require Node.js 18 or newer for the current MCP candidates
- approve or disable proxy usage explicitly
- classify failures as auth, login wall, CAPTCHA, Cloudflare or `403`, selector drift, rate limit, network, account warning, or unknown
- pause write workflows after account warnings, CAPTCHA, repeated selector failures, or unexplained publish errors
- require receipts for every post, thread, reply, quote-post, and media upload
- keep like, retweet, bookmark, follow, and mass engagement actions manual or disabled in v1

`microsoft/playwright-mcp` is allowed for fallback inspection and browser-state diagnosis. It is not allowed as an unsupervised workaround for publishing when reviewed X tools fail.

## Hermes Runtime Controls

Hermes provides several controls that must be used intentionally.

Required:

- run production write-capable workflows in a containerized or remote backend
- use a dedicated profile for `newshow.biz`
- set explicit gateway allowlists for oversight channels
- separate read-only analytics tools from write-capable channel tools
- use narrow toolsets for cron jobs
- filter MCP tools so sensitive write operations are exposed only when needed
- store channel secrets outside committed project files
- treat Hermes session logs as trace material, not business truth
- keep `X` and `Instagram` public writes behind explicit integration tools
- wrap `Barresider/x-mcp` behind New Showbiz toolsets before any production use
- keep `microsoft/playwright-mcp` limited to browser inspection, QA, and supervised diagnostics unless a workflow explicitly approves browser actions

Recommended:

- one read-only toolset for reporting
- one write-capable toolset per channel
- one escalation toolset for reviewer workflow
- one incident toolset with delete/hide/correction powers
- regular audit of command allowlists and tool exposure

## Incident Handling

### Inaccurate Claim

Actions:

- stop reusing the claim
- open `EscalationRecord`
- attach source context
- identify affected posts
- draft correction or clarification
- tag related templates for review

### Score Dispute

Actions:

- acknowledge concern without admitting fault automatically
- route to review
- preserve the disputed claim and source refs
- avoid debating unsupported internals

### Invalid Analysis Report

Actions:

- thank the user for the report if a response is appropriate
- route to the contact/review path
- preserve the movie URL, disputed category, user claim, and current AI analysis text
- do not promise a correction before review
- tag related content so the disputed claim is not reused until resolved

### Creator Complaint

Actions:

- do not argue
- preserve full context
- escalate to human owner
- only use approved acknowledgment if any public response is needed

### Moderation or Platform Warning

Actions:

- pause affected workflow
- preserve warning payload
- identify triggering content
- review related templates and modes
- require human approval before reuse

### Coordinated Negative Attention

Actions:

- freeze related campaign or behavior mode
- summarize trigger pattern
- measure reach against qualified outcomes and risk cost
- decide delete, clarify, stand down, or stand by
- require human decision before similar tactic returns

### TROLL Incident

Actions:

- suspend `TROLL` for the topic cluster
- open incident record
- attach original source evidence and final copy
- evaluate whether the mode distorted business goals
- require human reauthorization

## EscalationRecord Requirements

Every escalation must include:

- source platform
- source object ID
- thread/context snapshot
- risk reason
- severity
- summary
- blocked or proposed response
- evidence refs or evidence gaps
- recommended next action
- human owner
- SLA or urgency
- status
- final resolution

## Enforcement Principles

- hard rules outrank brand voice
- safety outranks speed
- evidence outranks cleverness
- escalation outranks improvisation
- public writes require receipts
- autonomy is granted by policy and tool scope, not by vibe
