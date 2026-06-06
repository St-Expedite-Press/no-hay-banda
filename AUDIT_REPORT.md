# Hermes / no-hay-banda — Full System Audit
**Date:** 2026-06-06  
**Scope:** Repository at `/home/ec2-user/no-hay-banda` + live runtime at `/home/ec2-user/.hermes`  
**Audited dimensions:** Security · Architecture & Design · Operations & Deployment · Agent/Content Pipeline

---

## Executive Summary

The Hermes system is a well-conceived AI content pipeline with strong governance design — the tier architecture, anti-fabrication doctrine, brand voice constraints, and human-in-the-loop approval flow are all standout engineering decisions. However, a significant gap exists between the specification and the deployed reality. **The most urgent issue is that `x-mcp-write` is currently enabled in the live profile despite none of the six Phase 3 activation gates being met.** Combined with an open SSH surface, stored credentials, and no observability, the system is one misconfiguration away from unauthorized autonomous posting.

**Deployment readiness: ~65%.** Phase 0–1 gates are green. Phase 3 is architecturally blocked on multiple dimensions. Recommend holding Phase 3 activation until the blockers listed below are resolved.

---

## 1. Security

### CRITICAL

**C1 — SSH open to 0.0.0.0/0**  
`docs/30-operations/credential-rotation.md` (lines 110–118) documents the EC2 security group inbound rule as `0.0.0.0/0`. This is flagged as advisory-only. An internet-exposed machine that holds Twitter/Instagram credentials and can autonomously post to public channels is a high-value target. This must be treated as a hard prerequisite, not a suggestion.  
→ *Action: Restrict SG to known IPs immediately.*

**C2 — Twitter credentials exposed in config.yaml**  
`~/.hermes/profiles/newshowbiz/config.yaml` passes `TWITTER_USERNAME` and `TWITTER_PASSWORD` as `${...}` env-var refs into child MCP processes. The config file permissions are `rw-r--r--` (world-readable on a multi-user system). Any user on the host can read X credentials.  
→ *Action: `chmod 600 ~/.hermes/profiles/newshowbiz/config.yaml` immediately. Audit all config files.*

**C3 — GitHub PAT hardcoded in live config**  
`~/.hermes/config.yaml` contains a plaintext GitHub PAT. This is a secret in a file that may be readable.  
→ *Action: Revoke and rotate immediately. Move to env var reference.*

### HIGH

**H1 — Systemd service has no security hardening**  
`hermes/systemd/newshowbiz-log-rotate.service` runs as `ec2-user` with full filesystem access and no sandboxing directives (`NoNewPrivileges`, `PrivateTmp`, `ProtectSystem`, `ProtectHome`, `ReadOnlyPaths`). A compromised service would have unrestricted host access.  
→ *Action: Add systemd hardening directives before enabling timer.*

**H2 — Twitter auth file persists after password rotation**  
`credential-rotation.md` (lines 57–63) clears the session cookie but does not document explicitly deleting `~/.hermes/profiles/newshowbiz/x-auth/twitter.json`. Stale auth files can survive a rotation and auto-retry with invalid credentials.  
→ *Action: Add explicit deletion of `x-auth/` contents as a mandatory rotation step.*

**H3 — x-mcp-write enabled with no Phase 3 gates met (also an ops issue — see O1)**  
The write MCP is live, but the approval queue has 0 jobs, the escalation path has never been exercised, and Telegram approval has not been smoke-tested. A prompt injection or agent bug could produce an unauthorized post.  
→ *Action: Set `enabled: false` in the live profile config immediately.*

**H4 — Auth directory created world-readable (login.ts)**  
`hermes/mcp/x-mcp/src/behaviors/login.ts` calls `fs.mkdirSync(authDir, { recursive: true })` without a `mode` parameter. Inherits default umask (0o022 → 0o755). The directory containing `twitter.json` is world-readable.  
→ *Action: Pass `{ recursive: true, mode: 0o700 }` to mkdirSync.*

### MEDIUM

**M1 — Proxy credentials may leak to stderr logs (login.ts, lines 156–166)**  
If `PROXY_URL` contains embedded credentials (e.g., `http://user:pass@proxy`), they are written via `console.error`, which may be captured in `mcp-stderr.log`. Logs are rotated but not encrypted at rest.

**M2 — `TWITTER_EMAIL` / `TWITTER_PHONE` undocumented in .env.example**  
`login.ts` (lines 38–55) uses these for 2FA challenges, but neither appears in any `.env.example`. Operators will omit them and face silent cron failures.

**M3 — Instagram framework exists without credential isolation**  
Template files for Instagram exist but no Instagram MCP server is defined. When added, copy-paste from the X publish tool risks missing Instagram-specific guardrails.

### LOW

**L1 — Idempotency policy is advisory only** — no technical enforcement until `newshowbiz_x_publish_reviewed` wrapper is deployed.

**L2 — Log rotation race condition** — `rotate-logs.sh` uses `gzip -k` (keep original), then truncates. If the process dies between gzip and truncate, an uncompressed copy with sensitive content persists.

**L3 — Credential family table incomplete** — `secrets-policy.md` lists Scweet as "throwaway read account only" but Barresider is the primary path. Failover not documented.

---

## 2. Architecture & Design

### GAPS (Documented but Not Implemented)

**G1 — Policy Engine missing**  
`architecture.md` and `implementation-spec.md` define a Policy Engine as a core control-plane subsystem responsible for runtime publish checks and escalation gates. No implementation exists. Policy is currently enforced only through agent persona rules — declarative, not structural.

**G2 — Orchestrator Phase 11–12 not deployed**  
The spec defines a 12-phase Orchestrator workflow including compensation/rollback (Phase 11), semantic memory updates (Phase 12b–12d), and durable pre-op snapshots. The deployed `hermes/global/personas/orchestrator.md` is a simplified routing agent. Safety recovery logic is unimplemented.

**G3 — 8 agent personas specified but not deployed**  
Docs specify 28 agents (1 Tier 0 + 7 Tier 1 + 21 Tier 2). Deployed `hermes/global/personas/` has 20 files. Missing: Designer, Composer, ComposerTranslator, Librarian, QueryAgent, DiffAgent, PythonStandardsAgent, SkillBuilder, DistillAgent.

**G4 — PerformanceSnapshot store and analytics pipeline absent**  
`domain-contracts.md` defines the PerformanceSnapshot schema. MetricsAgent persona exists. No durable store or attribution model is deployed. Phase 4 (analytics loop) is architecturally blocked.

**G5 — EngagementJob flow not activated**  
Full Inbound Engagement pipeline is specified in `implementation-spec.md`. EngagementAgent persona exists but no job records or triage pipeline is deployed. Phase 5 (engagement) is blocked.

### INCONSISTENCIES (Docs vs. Deployed Differ)

**I1 — Agent count inconsistency**  
README says 20 agents. Source roster index says 28. Deployed count is 20. Documentation is internally contradictory.

**I2 — Shared contract predates orchestrator spec**  
Neither the source nor deployed `_shared-contract.md` references the Orchestrator's Phase 11 compensation procedures. The contract version lags the full spec.

**I3 — ContentAgent initiation ambiguous**  
Deployed ContentAgent persona says "Spawn via `delegate_task`" but the full orchestrator spec (Phase 7) implies the Orchestrator dispatches to Tier 1 agents. Who initiates ContentAgent tasks is unclear in the deployed system.

### DESIGN RISKS

**DR1 — Single source of truth: newshow.biz (HIGH)**  
All content originates from one site through MovieResearchAgent. If newshow.biz is down or auth-gated, no content can be produced. A 2026-06-05 incident proved this is a real failure mode (agent fabricated a score when the source page was inaccessible). No fallback data layer exists.

**DR2 — Anti-fabrication relies on model discipline, not architecture**  
The system addresses fabrication at multiple layers (SOUL, shared contract, prefill priming) but no hard enforcement mechanism — schema validation, output grounding checks — prevents a misconfigured agent from generating false data. The June 2026 incident is proof of concept.

**DR3 — Orchestrator sequential bottleneck at scale**  
All ambiguous/multi-domain tasks route through the single Orchestrator. At Phase 3+ publishing velocity, multiple independent pipelines will serialize. No parallel orchestration or work-queue pattern is defined.

**DR4 — No idempotency ledger**  
ContentJob records exist but no separate idempotency key store is deployed. If ContentJob records are deleted or corrupted, duplicate posts are possible.

**DR5 — Telegram approval implicit in routing**  
Telegram skills exist but `_routing.md` does not reference them. The approval workflow is embedded in agent prompt rules, not as a first-class dispatch pattern. This makes it brittle to refactoring.

### STRENGTHS

- Tier architecture enforced at config level (`max_spawn_depth: 2`), persona level, and shared contract — strong layered enforcement.
- Anti-fabrication doctrine is comprehensive and honest about model-specific failure modes (DeepSeek V4 Flash).
- Kakusu Protocol operationalized in templates — brand voice constraints are structural, not advisory.
- Source evidence preservation mandatory at persona level; ContentJob records carry `source_refs`.
- Newshowbiz profile is self-contained and portable — clean profile-scoped isolation.
- Channel operations doc explicitly separates autonomous vs. escalated behaviors.

---

## 3. Operations & Deployment

### CRITICAL BLOCKER

**O1 — x-mcp-write is live; all Phase 3 gates are unmet**  
The live profile has `x-mcp-write: enabled: true`. Gate status:
| Gate | Requirement | Status |
|------|-------------|--------|
| 1 | ≥14 approved jobs in store | 0 jobs |
| 2 | ≥1 escalation exercised | 0 escalations |
| 3 | Telegram approval smoke-tested | No log |
| 4 | Credentials rotated | Unverified |
| 5 | Clean error log for 14 days | Log mostly empty |
| 6 | x-mcp-read search verified | Rate-limited June 1 |

→ *Action: Disable x-mcp-write immediately. Re-enable only after all gates pass.*

### GAPS

**O2 — OpenRouter credits exhausted**  
Error log shows repeated `402: insufficient credits` from June 1. The system cannot run orchestrator or subagents. Silent failure risk in automated cron runs.  
→ *Action: Top up OpenRouter balance and verify before any Phase 2+ work.*

**O3 — No observability**  
Zero metrics dashboard, no alerting on MCP failures, no health checks for X API connectivity. All logs are local flat files with no aggregation or structured export.

**O4 — Deployment runbook is strategic, not operational**  
`deployment-runbook.md` describes phases but lacks step-by-step procedures. No pre-flight checklist (AWS permissions, DNS, X API rate limits, MCP health). No failure recovery path for write failures, Telegram timeout, or session leaks.

**O5 — No credential rotation automation or audit log**  
`credential-rotation.md` is a manual procedure with no scheduled reminders, no audit trail, and no enforcement before Phase 3 activation.

**O6 — Log rotation timer never verified**  
`newshowbiz-log-rotate.timer` targets Monday 02:00 UTC but no log of past executions exists. No verification that systemd timer is even enabled.

**O7 — Minimal cron jobs**  
`cron/jobs.json` has only one job (S3 sync, 60min). No content publish jobs, no daily report, no escalation sweep, no health check. Phase 2 analytics pipeline has no scheduled entry point.

**O8 — No pause/disable path documented**  
If something goes wrong during a live run, there is no documented emergency stop procedure. The phased checklist requires a Telegram pause path but no skill or command implements it.

### RECOMMENDATIONS

**Immediate (before any Phase 3 work):**
1. Disable x-mcp-write in live config
2. Top up OpenRouter credits and verify inference works
3. Rotate all credentials; log completion
4. Chmod 600 all config files containing credentials
5. Seed 14+ draft ContentJobs; exercise escalation path once; smoke-test Telegram approval

**Short-term (1–2 weeks):**
6. Add a simple health-check cron: x-mcp-read ping, OpenRouter balance check, log size monitor → alert via Telegram
7. Expand runbook with Phase 3 pre-flight checklist
8. Define and document emergency stop: Telegram `/pause` command or kill-switch flag in config

**Medium-term (month 1):**
9. Structured JSON event log (SQLite in `store/metrics.db`) for job starts, receipts, escalations
10. Add 90-day credential rotation reminder to cron
11. Add systemd hardening to all service units

---

## 4. Agent/Content Pipeline

### STRENGTHS

- Shared contract is rigorous: three-tier enforcement, output schema (status/claims/artifacts/blockers), anti-fabrication rules, source citation requirements
- Escalation matrix is comprehensive: 12 risk classes with explicit triggers and no auto-resolution
- Human-in-the-loop is structural: `telegram-await-approval` enforces gating before publish; timeout → hold (never discard)
- Template library is consistent: all templates enforce the same hard rules (no em dash, 2-hashtag ceiling, source refs required)
- Kakusu Protocol brand voice is sophisticated and operationalizable

### GAPS

**P1 — Tier 2 persona specs mostly missing**  
SOUL.md names a 25-agent roster. Only a handful of Tier 2 specs are provided (MovieResearchAgent, plus generic roles). Missing complete specs for: writer, editor, validate-agent, report-agent, escalation-agent, engagement-agent, transform-agent, analysis-agent.

**P2 — `x-publish-with-receipt` skill deferred but unspecified**  
Marked "Phase 3+ only" — documents 8 failure classes but lacks retry strategy, endpoint signatures, and idempotency key storage spec.

**P3 — `instagram-publish-with-receipt` skill does not exist**  
Instagram is a documented publish target with templates, but no corresponding publish skill is defined.

**P4 — Validation underspecified**  
ContentAgent scans for "donation/financial/identity language" but exact keywords/patterns are not listed. ValidateAgent is mentioned but no spec file exists. Risk class assignment from draft → escalation trigger is implicit.

**P5 — Failure recovery incomplete**  
PublishAgent's "new approval signal" for retry is undefined. Per-class action for X publish failures (rate_limit, auth, selector_drift) is not detailed.

### RISKS

**P-R1 — Template enforcement is declarative, not structural**  
Templates define rules but no automated linter verifies compliance before post. Em-dash rule, hashtag ceiling, fabrication ban all rely on the model following instructions.

**P-R2 — Escalation ownership undefined**  
EscalationRecords require "human owner or review queue" but the newshowbiz profile does not define the default owner, routing rules by risk class, or SLA per class. An unassigned escalation is a dead letter.

**P-R3 — Telegram availability not resilient**  
`telegram-await-approval` uses only `getUpdates` polling (no webhook fallback). Behavior on missing/invalid `TELEGRAM_BOT_TOKEN` or rate limit hits is not specified. Notification loss (message deleted before approval) is unhandled.

**P-R4 — TROLL mode lacks incident counter**  
TROLL mode (sarcasm, challenge lazy opinions) has no incident tracking or auto-suspend logic. The spec notes "incident counter required" but no implementation exists. A creator complaint after a TROLL post is live has no auto-circuit-breaker.

**P-R5 — Data freshness assumption unvalidated**  
No SLA or cache-invalidation rule for movie page data. Release dates, credits, or scores may change between research and publish.

### RECOMMENDATIONS

1. **Write Tier 2 persona specs** — at minimum writer, editor, validate-agent, escalation-agent. Follow the shared contract signature.
2. **Add a template linter skill** — called from ContentAgent before risk-check; validates em-dash, hashtag count, character limit, source-ref presence, no-emoji-lead.
3. **Define escalation routing in newshowbiz profile** — owner by risk class, review queue, SLA per class, resolution workflow.
4. **Strengthen Telegram resilience** — add webhook support as primary path; define explicit behavior on timeout, missing token, rate limit.
5. **Specify idempotency strategy** — where keys are stored, key format, what duplicate detection returns.
6. **Add TROLL incident counter** — `incident-counter` skill that auto-suspends TROLL mode after N high-risk events, requires human re-auth.
7. **Phase-gate clarity** — explicitly mark each skill/flow as Phase 1 (live now) vs Phase 3 (deferred).

---

## Priority Action Matrix

| # | Action | Severity | Effort |
|---|--------|----------|--------|
| 1 | Disable x-mcp-write in live profile | CRITICAL | 5 min |
| 2 | Revoke/rotate hardcoded GitHub PAT in config.yaml | CRITICAL | 15 min |
| 3 | chmod 600 all config files with credentials | CRITICAL | 5 min |
| 4 | Restrict EC2 security group SSH rule from 0.0.0.0/0 | CRITICAL | 10 min |
| 5 | Top up OpenRouter credits; verify inference works | HIGH | 15 min |
| 6 | Fix login.ts auth dir mode (add 0o700) | HIGH | 15 min |
| 7 | Add systemd hardening to service units | HIGH | 1 hr |
| 8 | Add TWITTER_EMAIL/PHONE to all .env.example files | MEDIUM | 10 min |
| 9 | Seed 14+ ContentJobs; exercise escalation path | HIGH | 2–4 hr |
| 10 | Telegram approval end-to-end smoke test | HIGH | 1 hr |
| 11 | Write missing Tier 2 persona specs | MEDIUM | 4–8 hr |
| 12 | Add template linter skill | MEDIUM | 4 hr |
| 13 | Define escalation routing + SLAs in profile | MEDIUM | 2 hr |
| 14 | Add health-check cron + Telegram alerts | MEDIUM | 2 hr |
| 15 | Expand deployment runbook with pre-flight checklist | MEDIUM | 2 hr |

---

## Overall Assessment

| Dimension | Score | Notes |
|-----------|-------|-------|
| Security | 4/10 | Open SSH, world-readable configs, live write tool with no gates met |
| Architecture | 7/10 | Strong design; significant spec-to-deployment lag |
| Operations | 5/10 | Good runbook docs; execution thin; zero observability |
| Agent Pipeline | 7/10 | Strong governance; enforcement too declarative; Tier 2 specs thin |
| **Overall** | **6/10** | Solid foundation; not yet production-safe |

The system should not advance to Phase 3 autonomous publishing until items 1–10 in the priority matrix are resolved.
