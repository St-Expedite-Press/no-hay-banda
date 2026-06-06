# Implementation Spec

This spec defines the build target for the New Showbiz Hermes-backed marketing operator. It is implementation-ready documentation, not executable code.

## Architecture

```mermaid
flowchart TD
    A[newshow.biz product surfaces] --> B[Source Data Layer]
    X[X signals] --> C[Channel Read Layer]
    B --> D[Hermes newshowbiz profile]
    C --> D
    D --> E[Domain Control Plane]
    E --> F[Policy Engine]
    E --> G[Content Engine]
    E --> H[Engagement Engine]
    F --> I[Escalation Store]
    G --> J[Publishing Layer]
    H --> J
    J --> K[Channel Receipts]
    J --> L[Public channels]
    K --> M[Metrics and Attribution]
    L --> M
    M --> N[Reports and next actions]
    I --> O[Human oversight]
    O --> E
```

## Required Domain Records

The implementation must create durable records outside Hermes core.

| Record | Purpose | Required behavior |
|---|---|---|
| `ContentJob` | Tracks a content unit from source material through draft, approval, publish, receipt, and metrics | Must carry source refs, channel target, approval state, idempotency key, and final text |
| `EngagementJob` | Tracks an inbound mention, reply, comment, DM, or contact-path item | Must classify intent, sentiment, urgency, risk, and final disposition |
| `EscalationRecord` | Holds a blocked or risky item for human review | Must preserve evidence, risk class, recommended action, owner, and status |
| `PerformanceSnapshot` | Captures performance over a reporting period | Must join channel metrics to site traffic, signups, donations, activation, and support outcomes where available |

See [Domain Contracts](domain-contracts.md) for field-level detail.

## Outbound Content Flow

```mermaid
sequenceDiagram
    participant O as Orchestrator
    participant R as MovieResearchAgent
    participant C as ContentAgent
    participant V as ValidateAgent
    participant P as PublishAgent
    participant S as Domain Store
    participant X as Channel Wrapper
    O->>R: Fetch product/source facts
    R->>S: Store source refs
    O->>C: Create draft variants
    C->>S: Write ContentJob DRAFT
    O->>V: Policy and brand check
    V->>S: APPROVED or HOLD
    alt approved
        O->>P: Publish approved ContentJob
        P->>X: reviewed write with idempotency key
        X-->>P: normalized receipt
        P->>S: attach receipt and final text
    else risk
        V->>S: create EscalationRecord
    end
```

## Inbound Engagement Flow

```mermaid
flowchart TD
    A[Inbound mention, reply, comment, DM, or contact item] --> B[Persist raw payload]
    B --> C[Create EngagementJob]
    C --> D[Classify intent, sentiment, urgency, and risk]
    D --> E{Risk trigger?}
    E -- yes --> F[Create EscalationRecord]
    F --> G[Human review]
    E -- no --> H[Draft response or disposition]
    H --> I[Policy check]
    I --> J{Approved?}
    J -- yes --> K[Send through reviewed wrapper]
    K --> L[Attach receipt]
    J -- no --> F
```

## Tool Boundary Requirements

- Read tools and write tools are separate toolsets.
- Public writes are never performed through arbitrary browser or shell improvisation.
- Every write returns a durable receipt.
- Every write uses an idempotency key where possible.
- X browser automation failures must classify auth, login wall, CAPTCHA, Cloudflare or `403`, selector drift, rate limit, network, account warning, or unknown.
- Telegram is an oversight channel, not a public publishing path.
- Vault/source tools cannot publish to X.

## Policy Requirements

Policy must run before publish or reply. It must block or escalate:

- money terms beyond approved donation language
- tax, refund, wallet-choice, investment, or financial advice
- partnership, sponsorship, affiliate, or collaboration terms
- legal threats or legal claims
- creator complaints
- invalid diversity analysis reports
- factual disputes requiring validation
- identity-sensitive conflict
- platform-policy warnings
- high-visibility backlash
- unsupported claims
- `TROLL` output crossing thresholds

## Acceptance Standard

The implementation is not ready for autonomous posting until source refs, ContentJob approval state, policy checks, channel receipts, account-safety diagnostics, and human pause controls all work in the same end-to-end test.

