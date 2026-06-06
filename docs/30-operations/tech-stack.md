# Tech Stack

This package defines the target stack. It does not ship runnable implementation code.

## Phase Stack

| Phase | Runtime | Model | Channel capability | Persistence |
|---|---|---|---|---|
| Phase 0 | Documentation package | none | none | docs only |
| Phase 1 | Python service or Hermes profile wrapper | OpenAI/Codex API | draft-only, Scweet read-only optional | local files or durable store prototype |
| Phase 2 | Hermes profile plus domain tools | OpenAI or local vLLM | read-only integrations and reporting | ContentJob, EngagementJob, snapshots |
| Phase 3 | Hermes plus reviewed channel wrappers | OpenAI or vLLM | X write capability with receipts | production domain store |
| Phase 4 | Hermes cron and gateway oversight | vLLM preferred | low-risk autonomous publishing | production store and audit logs |
| Phase 5+ | Hardened Hermes deployment | vLLM preferred | managed edge and optimization | full incident and attribution model |

## Recommended Components

| Layer | Recommended technology |
|---|---|
| Agent runtime | `NousResearch/hermes-agent` |
| Prompt identity | `docs/10-hermes/SOUL.md` |
| Project context | `docs/10-hermes/AGENTS.md` |
| Workflow reuse | Hermes/agentskills.io `SKILL.md` |
| Oversight | Hermes gateway, Telegram, or custom dashboard |
| X read Phase 1 | Scweet with throwaway account |
| X write Phase 3+ | X MCP adapter behind New Showbiz wrapper tools |
| Browser QA | Playwright MCP or equivalent read-only diagnostics |
| Persistence | Implementation-owned database or structured records, not Hermes sessions |
| Metrics | Platform analytics plus site analytics plus support/donation joins |
| Documentation governance | Scope, consistency, evidence, safety, and verification loops in `docs/30-operations/documentation-governance.md` |

## Out of Scope for This Repo

- Installing Hermes.
- Running a Telegram bot.
- Publishing to X.
- Hosting a database.
- Storing secrets.
- Shipping Python packages.
- Treating root `AGENTS.md` or root `MEMORY.md` as canonical repo documentation; they are local ignored workspace guidance/state.


