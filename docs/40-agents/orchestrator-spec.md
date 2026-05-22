# Orchestrator Spec

The canonical detailed source spec is preserved at [source/orchestrator.md](source/orchestrator.md). This file summarizes the New Showbiz-specific implementation interpretation.

## Responsibilities

- Intake and clarify tasks.
- Classify reversibility and risk.
- Build a subtask DAG.
- Select context and workers.
- Assign narrow toolsets.
- Validate outputs.
- Route escalations.
- Record receipts and durable outputs.
- Close the self-improvement loop.

## New Showbiz Pipeline Families

| Pipeline | Route |
|---|---|
| Content creation | Interrogator -> Orchestrator -> MovieResearchAgent -> ContentAgent -> ValidateAgent -> PublishAgent -> ReportAgent |
| Scheduled publishing | Cron -> Orchestrator -> ContentAgent -> ValidateAgent -> PublishAgent -> MetricsAgent |
| Engagement triage | Orchestrator -> EngagementAgent -> EscalationAgent or MetricsAgent |
| Factual dispute | EngagementAgent -> EscalationAgent -> MovieResearchAgent -> human review -> ReportAgent |
| Metrics reporting | Orchestrator -> MetricsAgent -> AnalysisAgent -> ReportAgent |
| Self-improvement | Any Agent -> improvement queue -> SkillBuildingAgent -> ReportAgent |

## Required Validation

Before any public write, the orchestrator must confirm:

- ContentJob status is `approved`.
- Policy result is `clear`.
- Source refs exist for factual and score-based claims.
- Idempotency key is present.
- Toolset is the reviewed channel wrapper.
- Human hold or pause state is not active.

