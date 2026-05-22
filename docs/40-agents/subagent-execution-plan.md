# Subagent Execution Plan

Subagents are the execution pattern for building and operating the New Showbiz system. The orchestrator decomposes work, assigns workers with narrow toolsets, validates outputs, and stores durable results outside Hermes.

## Implementation Subagent DAG

```mermaid
flowchart TD
    A[Orchestrator] --> B[DocumentationArchitect]
    A --> C[HermesPromptArchitect]
    A --> D[ProductSpecWriter]
    A --> E[OpsStackWriter]
    A --> F[AgentSystemWriter]
    A --> G[RolloutPlanner]
    B --> H[DiagramSpecialist]
    C --> H
    D --> H
    E --> H
    F --> H
    G --> H
    H --> I[QA LinkAuditor]
    I --> J[Final integrated package]
```

## Build-Time Worker Ownership

| Worker | Owns | Must not edit |
|---|---|---|
| DocumentationArchitect | `README.md`, link map, package organization | domain contracts, env details |
| HermesPromptArchitect | `docs/10-hermes/` | rollout docs, operations docs |
| ProductSpecWriter | `docs/00-vision/`, `docs/20-system-spec/` | secrets, model cards |
| OpsStackWriter | `docs/30-operations/` | product positioning, agent roster |
| AgentSystemWriter | `docs/40-agents/` | env setup, channel specs |
| RolloutPlanner | `docs/50-rollout/` | source agent specs |
| DiagramSpecialist | Mermaid diagrams across docs | prose contracts unless fixing labels |
| QA LinkAuditor | stale links, one-H1, secret scan, path scan | substantive product decisions |

## Runtime Worker Pattern

```mermaid
flowchart LR
    I[Interrogator] --> O[Orchestrator]
    O --> R[MovieResearchAgent]
    R --> C[ContentAgent]
    C --> V[ValidateAgent]
    V -->|approved| P[PublishAgent]
    V -->|risk| E[EscalationAgent]
    P --> M[MetricsAgent]
    M --> A[AnalysisAgent]
    A --> Rep[ReportAgent]
```

## Worker Rules

- Workers receive the minimum context needed.
- Workers get only the toolsets needed for the task.
- Workers do not publish unless they are the reviewed PublishAgent path.
- Workers return structured outputs with status, claims, artifacts, and blockers.
- The orchestrator validates outputs before downstream propagation.
- Any reusable procedure missing from the skill registry becomes a skill proposal.

