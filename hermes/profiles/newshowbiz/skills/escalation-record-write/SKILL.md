---
name: escalation-record-write
description: |
  Write an EscalationRecord JSON to the Phase 1 flat-file store when a ContentJob
  or EngagementJob triggers a risk class that blocks autonomous action.
version: 1.0.0
license: MIT
---

# Skill: Escalation Record Write

## When to Use

When a risk trigger fires during content review, draft generation, or engagement
classification. Pairs with content-job-write: set the ContentJob status to "hold"
before calling this skill.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `source_record_id` | string | yes | ID of the ContentJob or EngagementJob that triggered escalation |
| `risk_class` | string | yes | One of the 12 defined classes: money_terms, tax_investment_advice, partnership, legal, creator_complaint, invalid_analysis, factual_dispute, identity_sensitive, platform_policy, backlash, unsupported_claim, troll_threshold |
| `summary` | string | yes | Neutral incident summary (1–3 sentences, no advocacy) |
| `evidence_refs` | list | yes | Links, file paths, or quoted text supporting the escalation |
| `recommended_action` | string | yes | One of: approve, revise, hold, respond, ignore, investigate |

## Procedure

1. Generate an EscalationRecord ID: `ESC-{ISO-date}T{HHMMSS}-{4-char-hex}`.
2. Assemble the EscalationRecord JSON: id, source_record_id, risk_class, summary, evidence_refs, status ("open"), human_owner (null — must be filled by human), recommended_action, created_at (ISO timestamp).
3. Write to `~/.hermes/profiles/newshowbiz/store/escalations/{id}.json`.
4. Return the escalation id, path, and risk_class.
5. In your agent response, output a visible HOLD notice: "⚠ HOLD — EscalationRecord {id} written. Risk class: {risk_class}. Recommended action: {recommended_action}. Awaiting human review."

## Pitfalls

- Do not write an EscalationRecord without a source_record_id — escalations must always trace back to a job.
- The summary must be neutral — no advocacy, no inflammatory language, no speculation about intent.
- Do not set human_owner in this skill — that field is set by the human reviewer.
- evidence_refs must contain at least one entry.

## Verification

- JSON file exists at `store/escalations/{id}.json`.
- JSON parses cleanly with all required fields.
- HOLD notice is visible in agent response output.

## Outputs

Returns:
- `id`: EscalationRecord ID
- `path`: absolute path to the written file
- `risk_class`: the class that triggered escalation
