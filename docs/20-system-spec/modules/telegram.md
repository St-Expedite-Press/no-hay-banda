---
title: Telegram Module
record_type: module-spec
status: canonical
canonical_path: docs/20-system-spec/modules/telegram.md
implementation_note: >
  Telegram platform is bundled in hermes-agent (gateway/platforms/telegram.py).
  The future newshowbiz gateway implementation should add operator-specific
  hooks and /ns-* commands on top of Hermes gateway support. This file is the design spec.
updated: 2026-05-21
---

# Telegram Module

Human-in-the-loop oversight for the New Showbiz operator through Telegram. This module connects to Hermes as a gateway platform plugin.

## Purpose

Telegram is the oversight surface for a human operator — not a public social channel. It handles:

- escalation notifications and human approval requests
- report delivery (daily and weekly)
- operator commands (pause publishing, show pending, escalation status)
- draft approval or rejection before publication

## Hermes Integration

Hermes supports Telegram natively as a gateway platform. Enable it in the `new-showbiz` profile config.

**Runtime reference:** Hermes gateway includes Telegram platform support in the external `NousResearch/hermes-agent` project. This package documents the New Showbiz-specific oversight contract, not runnable gateway code.

**Profile scope:** `new-showbiz` only; not global.

**Install:**
1. Enable the Telegram gateway platform in `~/.hermes/profiles/new-showbiz/config.yaml`
2. Set `TELEGRAM_BOT_TOKEN` in the profile `.env`
3. Add oversight user Telegram IDs to the gateway allowlist
4. Configure command allowlist (see Command Reference below)

## Incoming Message Routing

| Message type | Routed to |
|---|---|
| `APPROVE` reply to draft request | PublishAgent — signals ContentJob status change to `APPROVED` |
| `REJECT` reply to draft request | ContentAgent — returns ContentJob to `DRAFT` with rejection note |
| `YES` reply to escalation | EscalationAgent — marks EscalationRecord human_owner action: approve |
| `NO` reply to escalation | EscalationAgent — marks EscalationRecord as rejected; holds ContentJob |
| `REVIEW` reply to escalation | ReportAgent — returns full EscalationRecord context |
| `PAUSE` command | Orchestrator → PublishAgent → all ContentJobs set to HOLD |
| `STATUS` command | Orchestrator → Researcher → ReportAgent — returns pending queue summary |
| `REPORT` command | Orchestrator → MetricsAgent → ReportAgent — returns latest report |
| Freeform query | Orchestrator → appropriate agent → ReportAgent |

## Notification Format

### Escalation Alert

```
[ESCALATION] {escalation_id}
Trigger: {risk_reason}
Severity: {severity}
Summary: {summary}
Recommended: {recommended_next_action}

Reply YES to approve, NO to hold, or REVIEW for full context.
```

### Draft Approval Request

```
[DRAFT APPROVAL] {content_job_id}
Platform: {platform}
Risk: {risk_level}
Behavior mode: {behavior_mode}

{draft_text}

Reply APPROVE or REJECT.
```

### Daily Report

```
[REPORT] {date}
Published: {count} posts
Engagement: {summary}
Escalations open: {count}
Top performer: {content_job_id}
```

## Command Reference

| Command | Action |
|---|---|
| `PAUSE` | Halt all autonomous publishing immediately |
| `RESUME` | Re-enable publishing after a PAUSE |
| `STATUS` | Return pending ContentJobs, open escalations, last publish time |
| `REPORT` | Deliver latest daily or weekly report |
| `ESCALATIONS` | List open EscalationRecords with severity |

## Guardrails

- This module is never a publishing path to X or Instagram. Approval here signals status; PublishAgent performs the actual write.
- No draft content is modified through this module — only approved or rejected.
- Sensitive escalation details (creator complaints, legal threats) are delivered here for human review; autonomous action is blocked until resolved.
- The oversight user list is fixed in gateway config; it is not reconfigurable through chat commands.
- `critical` severity escalations are routed immediately and do not queue.

## Phase

Active from Phase 1 (manual review) onward. Becomes load-bearing in Phase 4 when autonomous publishing requires a reliable human interrupt path.

## Dependencies

- Hermes gateway Telegram platform enabled
- `TELEGRAM_BOT_TOKEN` in profile secrets
- Oversight user list in gateway config
- Command allowlist in Hermes settings

