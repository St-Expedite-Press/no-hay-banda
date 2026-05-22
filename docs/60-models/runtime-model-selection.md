# Runtime Model Selection

Model choice is a deployment concern, not a reason to change domain contracts. The operator should expose model endpoint and model name through configuration.

## Phase Defaults

| Phase | Recommended model path | Reason |
|---|---|---|
| 0-1 | OpenAI/Codex API | Fastest path for draft generation and docs-to-build iteration |
| 2 | OpenAI/Codex or OpenRouter | Flexible while read-only integrations mature |
| 2+ | Local vLLM | Preferred for sustained marketing copy composition on owned hardware |
| 3+ | Mixed | Strong model for policy/risk, cheaper model for repetitive transforms |

## Local Model Notes

See the cards in [cards/](cards/) for Hermes and Qwen notes. The implementation should benchmark:

- instruction following under Hermes prompt tiers
- tool-call reliability
- long-context behavior with source refs
- brand voice stability
- refusal/escalation behavior on risk prompts
- cost and latency under cron workloads

