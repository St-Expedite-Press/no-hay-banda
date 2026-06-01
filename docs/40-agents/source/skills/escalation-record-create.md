# Skill: Escalation Record Create

## When to Use

Use when a ContentJob, EngagementJob, draft, inbound item, or platform warning triggers a risk class that blocks autonomous action.

## Inputs

| Input | Required | Notes |
|---|---:|---|
| `source_record_id` | yes | ContentJob or EngagementJob ID |
| `risk_class` | yes | Escalation trigger |
| `summary` | yes | Neutral summary |
| `evidence_refs` | yes | Payloads, links, screenshots, source data |
| `recommended_action` | yes | approve, revise, hold, investigate, reject |

## Procedure

1. Preserve the source record and all relevant evidence refs.
2. Classify risk using docs/10-hermes/AGENTS.md risk rules.
3. Set status to `open` or `held`.
4. Assign a human owner or review queue.
5. Return an EscalationRecord ID and recommended next action.

## Verification

The source item must remain on hold until a human decision or documented policy resolution exists.


