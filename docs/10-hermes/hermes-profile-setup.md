# Hermes Profile Setup

This is the target profile shape for the future runnable implementation. This documentation package does not install Hermes or run the operator.

## Profile Files

```mermaid
flowchart TD
    A[~/.hermes/profiles/newshowbiz/] --> B[docs/10-hermes/SOUL.md]
    A --> C[docs/10-hermes/AGENTS.md]
    A --> D[config.yaml]
    A --> E[.env]
    A --> F[skills/]
    D --> G[model provider and toolsets]
    D --> H[gateway settings]
    D --> I[cron jobs]
    E --> J[secrets, tokens, account IDs]
```

## Installation Shape

1. Create `~/.hermes/profiles/newshowbiz/`.
2. Copy the package's `docs/10-hermes/SOUL.md` to the profile root.
3. Copy the package's `docs/10-hermes/AGENTS.md` to the profile root.
4. Translate `docs/10-hermes/hermes-config.example.yaml` into the active Hermes `config.yaml` format used by the installed Hermes version.
5. Populate a profile-local `.env` from `docs/30-operations/.env.example`.
6. Install skills from `docs/40-agents/source/skills/` only after reviewing them against the current implementation.

## Profile Boundaries

| Surface | Rule |
|---|---|
| Secrets | Profile-local only; never committed |
| Gateway | Internal oversight only |
| X writes | Disabled until Phase 3+ reviewed wrappers exist |
| Instagram writes | Disabled until channel spec is complete |
| Memory | Trace material, not business truth |
| Cron | Must fetch durable state before acting |
| Toolsets | Least privilege per workflow |

## Personality Overlays

The retained `hermes-config.example.yaml` documents intended overlays such as `x-editor`, `instagram-editor`, `brand-director`, and `growth-analyst`. They are prompt conveniences, not public personas. All public output remains the single New Showbiz brand voice.


