---
title: Module Architecture
record_type: architecture-overview
status: canonical
canonical_path: modules/README.md
updated: 2026-05-21
---

# Module Architecture

This project runs on a hosted `NousResearch/hermes-agent` instance. Three modules extend Hermes for the New Showbiz product. Each is independently hookable; none assumes the others are loaded.

## Baseline

Hermes provides: AIAgent run loop, prompt assembly (docs/10-hermes/SOUL.md + docs/10-hermes/AGENTS.md + skills), sessions, cron, tool registry, toolsets, plugins, MCP, gateway, profile isolation, and safety controls.

The modules provide: domain-specific agents, data schemas, channel integrations, and user-facing oversight.

## Module 1 â€” Agent System (`agents/`)

The New Showbiz marketing agent stack.

**To activate:** drop `agents/`, `docs/10-hermes/SOUL.md`, `docs/10-hermes/AGENTS.md`, and `docs/10-hermes/hermes-config.example.yaml` into a Hermes profile directory and run `hermes -p new-showbiz`.

**Provides:**
- 12-phase Plan-and-Execute orchestrator
- 17-agent specialist roster (content, publish, engagement, escalation, metrics, research, operations, improvement)
- Skills registry with infrastructure and marketing pipeline skills
- Self-improvement loops via improvement queue

**Does not include:** channel publishing tools, durable data stores, Telegram access, vault toolsets.

See [`agents/_index.md`](../agents/_index.md) for the full agent system index.

## Module 2 â€” Telegram (`modules/telegram/`)

Human-in-the-loop oversight through Telegram.

**To activate:** enable the Hermes Telegram gateway platform in the `new-showbiz` profile config. See install instructions in `modules/telegram/README.md`.

**Provides:**
- Escalation notifications and approval flow
- Report delivery (daily, weekly)
- Operator commands (pause publishing, show pending, escalation status)
- Draft approval or rejection before publication

**Does not include:** X or Instagram write access; direct ContentJob modification.

See [`telegram/README.md`](telegram/README.md).

## Module 3 â€” Vault (`modules/vault/`)

Web research, movie data extraction, source records, and knowledge persistence.

**To activate:** available automatically when the agent system is loaded; vault toolsets are enabled in the Hermes profile toolset config.

**Provides:**
- Movie data extraction from newshow.biz
- External source capture (articles, press, interviews)
- Source record creation and ledger management
- Knowledge query and drift verification

**Does not include:** social content generation, channel publishing, Telegram interaction.

See [`vault/README.md`](vault/README.md).

## Interoperability

```
Hermes (runtime, orchestrator, cron, memory, sessions)
â”œâ”€â”€ agents/                        â† marketing agent system
â”‚   â””â”€â”€ docs/20-system-spec/  â† operator docs
â”œâ”€â”€ modules/telegram/              â† oversight and human-in-loop
â””â”€â”€ modules/vault/                 â† knowledge and research
```

### Boundary contracts

| Boundary | How it crosses |
|---|---|
| Agent system â†’ Vault | FetchAgent / MovieResearchAgent call vault toolset read tools |
| Agent system â†’ Telegram | EscalationAgent / ReportAgent deliver output via Hermes gateway |
| Telegram â†’ Agent system | Approval signals arrive as operator commands through the gateway |
| Vault â†’ Agent system | Research memos and source records are passed as file paths in ContentJob metadata |

No module writes directly to another module's stores. Handoffs are always through agent output fields and the shared status vocabulary (`CLEAR`, `BLOCKED`, `PARTIAL`, `COMPLETE`).

