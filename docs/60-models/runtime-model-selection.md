# Runtime Model Selection

Model choice is a deployment concern, not a reason to change domain contracts. The operator exposes model endpoint and model name through `~/.hermes/config.yaml`.

## Current Live Configuration (as of 2026-06-05)

| Role | Model | Provider | Config key |
|---|---|---|---|
| Orchestrator (Tier 0 + Tier 1) | `deepseek/deepseek-v4-pro` | OpenRouter | `model:` |
| Subagents (Tier 2) | `deepseek/deepseek-v4-flash` | OpenRouter | `delegation.model:` |

**Rationale:** DeepSeek V4 Pro provides strong instruction-following and tool-call reliability for orchestration. V4 Flash is significantly cheaper and faster for the high-volume atomic leaf-node work (research, validation, formatting, transformation) where reasoning depth matters less than throughput. Both are available through OpenRouter with a single API key.

**Known behavior:** DeepSeek V4 Flash has a documented failure mode where it may substitute plausible-looking fabricated output when a tool call or network request fails, rather than reporting the blocker. All agent specs now include an explicit anti-fabrication guardrail and the shared contract (Section 4) calls this out by model family.

## Phase Defaults

| Phase | Recommended model path | Reason |
|---|---|---|
| 0-1 | OpenRouter → DeepSeek V4 Pro/Flash | Strong instruction following, cost-effective split |
| 2 | OpenRouter or direct API | Flexible while read-only integrations mature |
| 2+ | Evaluate local vLLM | Consider for sustained cron workloads on owned hardware |
| 3+ | Mixed | Strong model for policy/risk/escalation, cheaper for transforms |

## Benchmarking Criteria

When evaluating model changes, test against:

- Instruction following under Hermes prompt tiers (stable/context/volatile)
- Tool-call reliability (does it actually call tools vs describe intentions?)
- Anti-fabrication behavior (does it report blockers honestly when tools fail?)
- Brand voice stability under Kakusu Protocol constraints
- Refusal/escalation behavior on risk prompts (money_terms, identity_sensitive, etc.)
- Tier boundary compliance (do Tier 2 agents attempt `delegate_task`?)
- Cost and latency under cron workloads

## Changing Models

Update `~/.hermes/config.yaml`:

```yaml
model: deepseek/deepseek-v4-pro        # orchestrator model
delegation:
  model: deepseek/deepseek-v4-flash    # subagent model
  provider: openrouter
```

Restart the gateway after changes: `hermes gateway restart`
