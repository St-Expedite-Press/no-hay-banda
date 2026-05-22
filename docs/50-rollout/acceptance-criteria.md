# Acceptance Criteria

These criteria decide when the operator can move between phases.

## Dependency Graph

```mermaid
flowchart TD
    P0[Phase 0 docs package] --> P1[Phase 1 draft-only]
    P1 --> P2[Phase 2 read-only integrations]
    P2 --> P3[Phase 3 reviewed X writes]
    P3 --> P4[Phase 4 low-risk autonomy]
    P4 --> P5[Phase 5 managed edge]
    P3 --> IG[Instagram spec]
    IG --> P6[Phase 6 scaling and governance]
```

## Phase Gates

| Phase | Must be true before exit |
|---|---|
| 0 | Docs package complete, env template documented, risks and domain contracts specified |
| 1 | Drafts generated with source refs, validation results, and no public writes |
| 2 | Read-only integrations cannot access write tools; metrics snapshots are reproducible |
| 3 | Reviewed X writes return durable receipts and classify failures |
| 4 | Pause path works, low-risk autonomous jobs are bounded, daily reports reconcile receipts |
| 5 | TROLL or edge workflows are incident-reviewed, fact-bound, and suspendable |
| 6 | Instagram, scale, and governance hardening have their own tested wrappers |

## End-to-End Write Readiness

No autonomous write is allowed until:

- ContentJob schema exists.
- Policy engine blocks all escalation classes.
- Human approval path exists.
- Reviewed channel wrapper exists.
- Receipt store exists.
- Idempotency is tested.
- Account safety diagnostics exist.
- Pause command or equivalent interrupt exists.

