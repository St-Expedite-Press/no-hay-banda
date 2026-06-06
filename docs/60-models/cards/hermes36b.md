# Hermes 4.3 36B Model Card

Standardized: 2026-05-19  
Source model ID: `NousResearch/Hermes-4.3-36B`  
License: Apache 2.0  
Base model: `ByteDance-Seed/Seed-OSS-36B-Base`

## Summary

Hermes 4.3 36B is an open-weight, text-only, hybrid-reasoning instruction model from Nous Research. It is based on ByteDance Seed 36B and post-trained for reasoning, coding, STEM, structured outputs, tool use, long-context work, and steerable assistant behavior.

For New Showbiz, this model is best considered a strong general-purpose operator model for text-heavy planning, drafting, policy-aware classification, structured JSON generation, and tool-calling workflows where the task does not require native image/video understanding.

## Core Capabilities

| Area | Notes |
| --- | --- |
| Modality | Text generation |
| Reasoning | Hybrid reasoning mode with optional `<think>...</think>` reasoning segments |
| Tool use | Supports function calling through `<tool_call>{...}</tool_call>` tags |
| Structured output | Trained for JSON/schema adherence and malformed-object repair |
| Coding | Strong code and repository reasoning relative to its size class |
| Creative writing | Tuned for broad expression and steerability |
| Long context | Marketed as long-context capable; confirm practical limits in the serving stack before production use |
| License | Apache 2.0 |

## Fit for New Showbiz

Use Hermes 4.3 36B when the operator needs careful text work, structured decisions, or workflow reasoning:

- Generate reviewed X draft copy from approved source evidence.
- Convert movie profile data into structured captions, alt text, thread outlines, or content briefs.
- Classify inbound messages into support, bug, invalid-analysis report, creator complaint, partnership, donation, or escalation categories.
- Draft escalation summaries with source references and required review gates.
- Produce JSON for `ContentJob`, `EngagementJob`, `EscalationRecord`, and reporting summaries.
- Run policy-bound internal personas without exposing persona fragmentation publicly.

Do not treat Hermes as a social publishing product. It can reason over channel workflows, but New Showbiz still needs explicit X read/write adapters, durable receipts, review controls, and account-safety handling.

## Prompting Format

Hermes 4 uses a Llama-style chat format with role headers:

```text
<|start_header_id|>system<|end_header_id|>

You are Hermes 4. Be concise and helpful.<|eot_id|>
<|start_header_id|>user<|end_header_id|>

Explain the photoelectric effect simply.<|eot_id|>
<|start_header_id|>assistant<|end_header_id|>
```

Reasoning mode can be enabled by the tokenizer chat template where supported, or by a system instruction that permits hidden deliberation inside `<think>...</think>` tags. For production New Showbiz workflows, do not persist or expose chain-of-thought text in public records. Persist final decisions, evidence references, tool calls, receipts, and concise rationale instead.

## Tool Use Pattern

Hermes can emit tool calls with explicit tags:

```text
<tool_call>{"name":"get_weather","arguments":{"city":"Chicago"}}</tool_call>
```

Serving stacks may provide Hermes-specific parsers:

| Stack | Parser note |
| --- | --- |
| vLLM | Use the Hermes tool parser where supported |
| SGLang | The copied source notes `qwen25` parser support for Hermes-style tool calls |

For New Showbiz, toolsets should remain narrow:

- `newshowbiz_x_read`
- `newshowbiz_x_draft_context`
- `newshowbiz_x_publish_reviewed`
- `newshowbiz_x_account_safety`
- `newshowbiz_browser_read`

Keep like, repost, bookmark, follow, and mass-engagement actions disabled or manual-only in v1.

## Suggested Inference Settings

General starting point from the source card:

```text
temperature = 0.6
top_p = 0.95
top_k = 20
```

Operational suggestions:

| Workflow | Suggested mode |
| --- | --- |
| Structured JSON | Lower temperature; validate against schema |
| Public copy drafting | Moderate temperature; require evidence and review |
| Escalation classification | Low-to-moderate temperature; favor recall and conservative routing |
| Tool calling | Use explicit tool schemas and parser support |
| Long planning | Enable reasoning internally, but store only final rationale |

## Serving Notes

Common serving paths listed in the source card:

```powershell
pip install vllm
vllm serve "NousResearch/Hermes-4.3-36B"
```

```powershell
pip install sglang
python -m sglang.launch_server --model-path "NousResearch/Hermes-4.3-36B" --host 0.0.0.0 --port 30000
```

For production workloads, prefer a dedicated inference server with tensor parallelism, prefix caching, observability, request logging, and per-workflow limits.

## Evaluation Signals From Source Card

The copied source card highlights:

- RefusalBench: strong helpfulness/steerability compared with many open and closed models in the reported benchmark.
- AIME 2024: 71.9 for the Psyche variant.
- AIME 2025: 69.3 for the Psyche variant.
- MATH-500: 93.8 for the Psyche variant.
- MMLU: 87.7 for the Psyche variant.
- GPQA Diamond: 65.5 for the Psyche variant.
- SimpleQA: 6.0 for the Psyche variant, which suggests factuality still needs retrieval, citations, and verification.

Treat benchmark numbers as vendor-reported reference data, not as New Showbiz production validation.

## Risks and Constraints

- The model is text-only; it should not be used for direct screenshot, image, or video understanding.
- Strong steerability is useful for operator work but increases the need for policy-bound prompts, tool allowlists, and review gates.
- Public-facing factual claims about films, people, protected classes, donation terms, or platform policy must be grounded in source evidence.
- Do not rely on the model's internal memory for durable business truth.
- Reasoning output may include hidden or verbose deliberation; do not expose it publicly.
- Any money, tax, refund, crypto, partnership, legal, creator-complaint, invalid-analysis, or identity-sensitive case must route through the documented escalation rules.

## Usage Notes for New Showbiz

Hermes 4.3 36B is a candidate default text operator model for governed marketing workflows. Use it behind Hermes Agent for drafting, classification, planning, and structured output, not as a direct channel actor.

Recommended uses:

- Draft reviewed X posts from approved movie/profile evidence.
- Generate content variants for "watch more of what matters to you" campaigns.
- Summarize inbound public replies and DMs into escalation-ready records.
- Classify reports of bugs or invalid diversity analysis and route them to the contact/review path.
- Produce daily or weekly performance summaries from durable metrics snapshots.
- Prepare internal briefs for campaigns, incidents, and audience questions.

Avoid or gate:

- Unreviewed publishing.
- Live platform automation without New Showbiz adapters and durable receipts.
- Final factual assertions without source evidence.
- Donation, crypto, tax, refund, legal, partnership, or creator-complaint responses without escalation.
- Identity-sensitive conflict, high-visibility backlash, or platform-policy warnings without human review.
