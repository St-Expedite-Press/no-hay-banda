---
name: escalation-record-create
description: "Create an EscalationRecord when a ContentJob or EngagementJob triggers a risk class that blocks autonomous action"
version: 1.0.0
author: New Showbiz
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [newshowbiz, escalation, risk, policy, content-job, engagement-job]
---

# Skill: Escalation Record Create

## When to Use

Use when a ContentJob, EngagementJob, draft, inbound item, or platform warning triggers
any of the following risk classes:

money_terms · tax_investment_advice · partnership · legal · creator_complaint ·
invalid_analysis · factual_dispute · identity_sensitive · platform_policy · backlash ·
unsupported_claim · troll_threshold

This is a hard stop. Do not proceed with publishing or responding until a human resolves the record.

## Inputs

| Input | Required | Notes |
|---|---:|---|
| `source_record_id` | yes | ContentJob or EngagementJob ID triggering escalation |
| `risk_class` | yes | One of the 12 defined escalation triggers |
| `summary` | yes | Neutral one-paragraph summary of the incident |
| `evidence_refs` | yes | All relevant payloads, links, screenshots, source data |
| `recommended_action` | yes | approve, revise, hold, investigate, or reject |

## Procedure

1. Preserve the full source record and all evidence_refs — do not discard or summarize raw signals.
2. Classify the risk using the AGENTS.md risk rules. Use exactly one of the 12 defined classes.
3. Write a neutral incident summary — not editorialized, not minimized, not alarmist.
4. Set initial status to `open`. If the situation requires immediate suspension of related actions, set `held`.
5. Assign a human owner or review queue. If no owner is named, route to the default oversight queue.
6. Return the EscalationRecord ID and the recommended_action.

## What Happens Next

The source ContentJob or EngagementJob must remain on hold until a human makes one of:
- approved: proceed with original or revised action
- rejected: discard the item
- hold: extend review without decision
- resolved: close after post-hoc review

Do not auto-resolve escalation records. Do not retry the blocked action until the record is resolved.

## Verification

An EscalationRecord is only valid if:
- It has a source_record_id linking to the triggering job
- It has evidence_refs (not an empty list)
- It has a human owner or named review queue
- The source job status is `hold` or `blocked`

An escalation without evidence or without a human owner is not actionable. Fix these before closing the record.
