# Documentation Governance

This repository is a living specification package. Documentation changes must preserve the package as a coherent implementation contract, not a pile of isolated notes.

## Canonical Surfaces

| Surface | Role |
|---|---|
| `README.md` | Entry map, reading path, build status, and local secret policy |
| `docs/10-hermes/AGENTS.md` | Profile-context contract for future Hermes runtime use |
| `docs/20-system-spec/implementation-spec.md` | Primary system build contract |
| `docs/30-operations/documentation-governance.md` | Documentation update rules and loops |
| `docs/40-agents/source/orchestrator.md` | Agent control-plane doctrine |
| `docs/40-agents/source/roster/_index.md` | Active and archived agent roster |
| `docs/50-rollout/phased-checklist.md` | Phase status and readiness tracking |

When these surfaces conflict, prefer the most specific operational document, then update the broader summary so the conflict does not persist.

## Documentation Development Model

Treat each documentation change as a small spec migration:

1. Classify the change: vision, Hermes prompt/profile, system contract, operations, agent doctrine, rollout, model selection, or diagram.
2. Identify dependent surfaces before editing.
3. Make the narrowest change that keeps the package coherent.
4. Update indexes, maps, and checklists in the same pass.
5. Verify no secrets, stale links, or orphaned references were introduced.

## Update Loops

### 1. Scope Loop

Before editing, identify:

- The primary doc family being changed.
- Any cross-references in README, package maps, indexes, phase checklists, and agent specs.
- Whether current external facts are involved.
- Whether the change affects runtime behavior, public channel behavior, or only documentation wording.

Output: a short affected-surface list.

### 2. Consistency Loop

After editing the primary doc:

- Update `README.md` if the entry map, reading path, or build status changed.
- Update `docs/10-hermes/AGENTS.md` if the profile contract changed.
- Update `docs/40-agents/source/_index.md`, `docs/40-agents/source/roster/_index.md`, or `docs/40-agents/roster-and-skills.md` when agent routing changes.
- Update `docs/50-rollout/phased-checklist.md` when readiness, phase gates, or completed documentation deliverables change.
- Update diagram docs if diagrams are added, removed, or renamed.

Output: changed docs plus any surfaces intentionally left unchanged.

### 3. Evidence Loop

For claims about current tools, model capabilities, APIs, package behavior, laws, platform policies, or runtime versions:

- Prefer primary sources: official docs, specifications, standards, release notes, source repositories.
- Cite or name the source in the doc when it materially supports the recommendation.
- Mark unstable or unverified claims as `needs_source_check`.
- Do not use blog posts or secondary summaries as primary authority when official documentation exists.

Output: sourced claims or explicitly marked uncertainty.

### 4. Safety Loop

Before closing a docs task:

- Search for tokens, credential-bearing URLs, private keys, `.env` values, and live account identifiers.
- Keep `.env`, root `AGENTS.md`, and root `MEMORY.md` local and ignored.
- Use `.env.example` and redacted variable catalogs for documentation.
- Avoid embedding local-only paths unless the doc is explicitly local workspace guidance.

Output: secret-scan result and any redactions made.

### 5. Verification Loop

Before final response:

- Run `git diff --check`.
- Inspect `git status --short`.
- Review the diff for accidental scope expansion.
- For link-heavy changes, spot-check changed relative links.
- State what was not verified.

Output: verification summary.

## Agent-Specific Loop

When agent docs change:

1. Update the individual agent spec.
2. Update `docs/40-agents/source/roster/_index.md`.
3. Update `docs/40-agents/roster-and-skills.md` if families or routing changed.
4. Update `docs/40-agents/source/orchestrator.md` if assignment preferences or pipelines changed.
5. Add or update examples only when they improve behavior, not as filler.

## Fast-Path Loop

Simple doc edits may use the Orchestrator Simple Task Fast Path when:

- One doc or one tightly coupled doc family is affected.
- No external current-fact claim is introduced.
- No public channel, deployment, or security behavior changes.
- No unresolved blocker appears.

Escalate to the full documentation workflow when the change spans multiple doc families, changes runtime doctrine, or introduces a new agent, skill, tool boundary, policy, or phase gate.

## Review Checklist

- [ ] Primary doc updated.
- [ ] Entry map or index updated if needed.
- [ ] Rollout/status docs updated if needed.
- [ ] External claims sourced or marked `needs_source_check`.
- [ ] Secret scan performed.
- [ ] `git diff --check` passes.
