# Deployment Runbook

This is the target deployment sequence for implementers. It is intentionally gated by phase.

## Phase 0: Documentation Package

1. Review this package.
2. Review `docs/30-operations/documentation-governance.md` and confirm docs update loops are in force.
3. Confirm the implementation repository or service boundary.
4. Confirm who owns `.env` and production secrets.
5. Confirm the human oversight channel.

## Phase 1: Draft-Only Build

1. Create the implementation project.
2. Populate `.env` from `docs/30-operations/.env.example`.
3. Enable OpenAI/Codex model access.
4. Keep all public channel writes disabled.
5. Implement source fetch and draft output.
6. Log source refs, prompts, draft IDs, and validation results.

## Phase 2: Read-Only Integrations

1. Add New Showbiz source data tools.
2. Add X read-only ingestion if `INGEST_ENABLED=true`.
3. Add analytics reads.
4. Create `PerformanceSnapshot` reports.
5. Verify that read-only workers cannot access write tools.

## Phase 3: Reviewed Writes

1. Build `newshowbiz_x_publish_reviewed`.
2. Add idempotency keys and receipt normalization.
3. Add account-safety diagnostics.
4. Require human approval for medium/high risk content.
5. Canary low-volume writes.

## Phase 4+: Autonomous Operation

1. Enable only low-risk autonomous posts.
2. Keep Telegram or equivalent pause path active.
3. Run daily reports.
4. Review incidents before expanding behavior modes.
5. Add Instagram only after its channel contract is complete.
