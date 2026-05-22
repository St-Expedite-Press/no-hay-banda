# Risk Register

## Escalation Flow

```mermaid
flowchart TD
    A[Draft, inbound item, or report] --> B[Policy classification]
    B --> C{Risk trigger?}
    C -- no --> D[Proceed within tool boundary]
    C -- yes --> E[Create EscalationRecord]
    E --> F[Hold related ContentJob or EngagementJob]
    F --> G[Notify human oversight]
    G --> H{Human decision}
    H -- approve --> I[Proceed with recorded approval]
    H -- revise --> J[Return to drafting or analysis]
    H -- reject --> K[Keep hold and close with reason]
```

## Primary Risks

| Risk | Severity | Control |
|---|---|---|
| Unsupported score or plot claim | high | Source refs required, MovieResearchAgent validation |
| Identity-sensitive conflict | high | EscalationRecord and human review |
| Creator complaint | high | Hold and route to human owner |
| Money/tax/crypto advice | high | Approved donation language only |
| X account warning or automation block | high | Account safety toolset, kill switch, pause writes |
| Duplicate publish | medium | Idempotency key and receipt lookup |
| Persona fragmentation | medium | One public New Showbiz voice |
| Metrics over-optimization for outrage | medium | Optimize qualified traffic, signup, support, trust |
| Secret leakage | high | `.env` local only, redacted docs only |

