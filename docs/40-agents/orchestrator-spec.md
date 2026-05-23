# Orchestrator Spec

The canonical detailed source spec is preserved at [source/orchestrator.md](source/orchestrator.md). This file summarizes the New Showbiz-specific implementation interpretation.

## Responsibilities

- Intake and clarify tasks.
- Classify reversibility and risk.
- Select fast path or full DAG; build a DAG when task complexity requires it.
- Select context and workers.
- Assign narrow toolsets.
- Validate outputs.
- Route escalations.
- Record receipts and durable outputs.
- Close the self-improvement loop.

## New Showbiz Pipeline Families

| Pipeline | Route |
|---|---|
| Simple known task | Orchestrator -> ExecuteAgent or one specialist -> ReportAgent |
| Content creation | Interrogator -> Orchestrator -> MovieResearchAgent -> ContentAgent -> ValidateAgent -> PublishAgent -> ReportAgent |
| Scheduled publishing | Cron -> Orchestrator -> ContentAgent -> ValidateAgent -> PublishAgent -> MetricsAgent |
| Engagement triage | Orchestrator -> EngagementAgent -> EscalationAgent or MetricsAgent |
| Factual dispute | EngagementAgent -> EscalationAgent -> MovieResearchAgent -> human review -> ReportAgent |
| Metrics reporting | Orchestrator -> MetricsAgent -> AnalysisAgent -> ReportAgent |
| Python standards review | Orchestrator -> PythonStandardsAgent -> ReportAgent |
| Self-improvement | Any Agent -> improvement queue -> SkillBuildingAgent -> ReportAgent |

## Simple Task Fast Path

For narrow, low-risk, single-hop work, the orchestrator may bypass full DAG construction and dispatch one specialist or ExecuteAgent directly. The fast path is allowed only when the task is interpretable, one agent can complete it, no `final` operation or public/external write is involved, output contracts are clear, and any write has an idempotency key plus a possible pre-operation snapshot.

If a fast-path gate fails, or the assigned agent returns `BLOCKED`, `INSUFFICIENT`, `NO BASELINE`, or invalid output, the orchestrator escalates back to the full 12-phase workflow or surfaces the blocker.

## Required Validation

Before any public write, the orchestrator must confirm:

- ContentJob status is `approved`.
- Policy result is `clear`.
- Source refs exist for factual and score-based claims.
- Idempotency key is present.
- Toolset is the reviewed channel wrapper.
- Human hold or pause state is not active.
