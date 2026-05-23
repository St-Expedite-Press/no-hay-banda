# Roster and Skills

The detailed preserved specs live under [source/](source/). This file is the high-level implementation index.

## Active Agent Families

| Family | Agents |
|---|---|
| Intake | Interrogator |
| Marketing | ContentAgent, PublishAgent, EngagementAgent, EscalationAgent, MetricsAgent |
| Acquisition and processing | ValidateAgent, FetchAgent, TransformAgent, AnalysisAgent, MovieResearchAgent |
| Operations | LintAgent, QueryAgent, DiffAgent, DistillAgent, ExecuteAgent, ReportAgent |
| Engineering standards | PythonStandardsAgent |
| System improvement | SkillBuildingAgent |
| Specialist | ComposerAgent |

## Lightweight Routing

Simple known procedures route through `Orchestrator -> ExecuteAgent -> ReportAgent` when one safe execution step is enough.

Simple read, inspection, or standards tasks may route to one matching specialist, such as QueryAgent, LintAgent, DiffAgent, PythonStandardsAgent, or AnalysisAgent, then to ReportAgent.

Repeated fast-path procedures become skills only when they satisfy the existing promotion rule: useful to at least two agents or two pipeline families.

## Skill Families

| Family | Examples |
|---|---|
| Content | content draft from movie data, policy check, source reference preservation |
| Publishing | X publish with receipt, idempotency, failure classification |
| Escalation | escalation record creation, incident evidence capture |
| Vault/source | record create, ledger update, drift check, vault query routing |
| Reporting | session log write, performance snapshot write |

## Promotion Rule

A reusable procedure becomes a skill only when it is useful to at least two agents or two pipeline families. One-off task notes remain reports, not skills.
