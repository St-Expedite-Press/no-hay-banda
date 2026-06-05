---
title: Agent Roster Index
record_type: agent-index
status: canonical
canonical_path: agents/roster/_index.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-06-05
part_of:
  - agent-system
---

# Agent Roster Index

Directory of all agents in the New Showbiz operator system. Updated 2026-06-05 for three-tier execution architecture.

**Total agents: 28** (1 Session Director + 7 Tier 1 pipeline agents + 21 Tier 2 subagents)

---

## Tier 1 — Pipeline Agents

These agents manage multi-step workflows and can spawn Tier 2 subagents via `delegate_task`.

- [Orchestrator](../orchestrator.md) — task classification, pipeline planning, output validation
- [ContentAgent](content-agent.md) — content generation pipeline: validate → draft → report
- [PublishAgent](publish-agent.md) — publication pipeline: validate → publish → receipt → report
- [MetricsAgent](metrics-agent.md) — metrics pipeline: collect → analysis → report
- [FetchAgent](fetch-agent.md) — data capture pipeline: validate → fetch → transform → report
- [DistillAgent](distill-agent.md) — distillation pipeline: evaluate → skill-builder → report
- [ProjectManager](project-manager.md) — project coordination: plan → dispatch → consolidate

---

## Tier 2 — Subagents (Leaf Nodes)

These agents execute atomic tasks and cannot delegate further.

### Intake

- [Interrogator](interrogator.md) — task clarification and structured brief production

### Research and Evidence

- [Researcher](researcher.md) — multi-source web research, fact-checking, literature review
- [MovieResearchAgent](movie-research-agent.md) — film evidence: production context, scores, representational claims

### Content and Voice

- [Compose](composer.md) — literary writing, criticism, essays (C. Composer voice)
- [Writer](writer.md) — general prose, documentation, marketing copy, scripts
- [ComposerTranslator](composer-translator.md) — Golden Age Castilian translation in Composer register
- [Editor](editor.md) — editing, proofreading, tone calibration, quality gating

### Design

- [Designer](designer.md) — visual design, diagrams, HTML/CSS/SVG, layout

### Analysis and Data

- [AnalysisAgent](analysis-agent.md) — computation over normalized data, rankings, summaries
- [QueryAgent](query-agent.md) — evidence-based vault lookups
- [DiffAgent](diff-agent.md) — snapshot comparison, change detection
- [ValidateAgent](validate-agent.md) — pre-fetch access checks, schema gating
- [TransformAgent](transform-agent.md) — normalization of captured material

### Operations

- [LintAgent](lint-agent.md) — vault/record health checks, structural repair
- [PythonStandardsAgent](python-standards-agent.md) — Python code standards audit
- [ExecuteAgent](execute-agent.md) — run known procedures from the live skill registry

### Content Operations

- [EngagementAgent](engagement-agent.md) — inbox triage, mention classification, escalation routing
- [EscalationAgent](escalation-agent.md) — risk incident logging, human routing, HOLD status

### System Improvement

- [SkillBuilder](skill-builder.md) — construct skill files from distilled proposals
- [ReportAgent](report-agent.md) — format and package specialist output for delivery

### Knowledge Management

- [Librarian](librarian.md) — Obsidian vault organization, MOCs, PKM

---

## Archived (not active for New Showbiz)

These agents were built for the Sandbatch Vault Knowledge OS and are preserved for reference.

- `archive/ingest-agent.md`
- `archive/concept-agent.md`
- `archive/librarian-agent.md` (superseded by active Librarian above)
- `archive/historian.md`
- `archive/research-page.md`

*Last updated: 2026-06-05 — added 6 new active agents (writer, designer, researcher, editor, librarian, project-manager); restructured for three-tier model.*
