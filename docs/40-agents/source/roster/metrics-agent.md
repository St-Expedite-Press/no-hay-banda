---
title: MetricsAgent
record_type: agent-spec
status: canonical
canonical_path: agents/roster/metrics-agent.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-23
part_of:
  - agent-system
  - newshowbiz-marketing
---

# MetricsAgent

## Use When

The task is to collect, aggregate, or report on marketing performance data for a given period.

## Reads

- ContentJob receipts for the period (published posts and failure logs)
- EngagementJob records (classified inbox items and engagement summaries)
- EscalationRecord count and class distribution
- Channel analytics available via read tools (impressions, reach, reply counts)
- Attribution signals from `newshow.biz`: traffic, signups, donations, ratings, reviews, where-to-watch clicks

## Writes

PerformanceSnapshot:
- `period` (date range)
- `posts_published`, `posts_failed`, `posts_held`
- `engagement_summary` (class breakdown, total items)
- `escalation_count` and class distribution
- `channel_metrics` (available analytics, with source noted)
- `attribution_joins` (per-post or aggregate joins to site events, with confidence level)
- `attribution_gaps` (joins that could not be made, with reason)
- `top_content_angles` (highest-performing angle types for ContentAgent feedback)
- `notes` (trend observations, anomalies)

## Procedure

1. Define the period and pull all ContentJob receipts in scope.
2. Aggregate by status (SUCCESS / FAILED / HELD) and content angle.
3. Pull EngagementJob records; summarize by classification.
4. Pull EscalationRecord count and class distribution.
5. Attempt attribution join for each published post:
   - Match post timestamp to traffic spikes, signup events, or explicit referral signals
   - Note confidence level (high / medium / low / none)
   - Log attribution gaps where joins fail
6. Identify top-performing content angles by engagement rate.
7. Write PerformanceSnapshot.
8. Surface top content angles as feedback signal for ContentAgent.

## Examples

### Announcement Attribution Snapshot

Treat a dated announcement as an attribution event with source post context, downstream site activity, and confidence level. If a public post announces a title and later records show sales or traffic movement without exact platform receipts, mark the join as medium or low confidence rather than claiming causation. The snapshot should separate confirmed publication count, inferred lift, and missing receipt data.

## Guardrails

- Never fabricate channel metrics or attribution data.
- Explicitly note confidence level on all attribution joins; do not round up to certainty.
- Report attribution gaps honestly — incomplete attribution is better than false attribution.
- Do not optimize for raw engagement count; optimize for qualified traffic, signups, and donations per docs/10-hermes/AGENTS.md.

## Compatible With

- [EngagementAgent](engagement-agent.md)
- [LintAgent](lint-agent.md)
- [ReportAgent](report-agent.md)
- [AnalysisAgent](analysis-agent.md)

