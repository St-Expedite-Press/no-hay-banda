# Qwen3.6 35B A3B Model Card

Standardized: 2026-05-19  
Source model ID: `Qwen/Qwen3.6-35B-A3B`  
License: Apache 2.0  
Model class: vision-language causal model with mixture-of-experts routing

## Summary

Qwen3.6 35B A3B is an open-weight, multimodal model from Qwen. It has 35B total parameters with about 3B activated per token, supports text, image, and video inputs, and is positioned for agentic coding, long-context reasoning, tool use, and real-world developer workflows.

For New Showbiz, this model is best considered a multimodal operator and engineering assistant candidate: useful for browser/screenshot review, visual QA, long-document reasoning, repository work, and media-aware content support. It should not be treated as a direct publisher or source of business truth.

## Core Capabilities

| Area | Notes |
| --- | --- |
| Modality | Text, image, and video input; text output |
| Architecture | 35B total parameters; about 3B activated; MoE with 256 experts |
| Context length | 262,144 tokens natively; source card describes extension up to about 1,010,000 tokens with YaRN |
| Reasoning | Thinking mode is enabled by default |
| Tool use | Supports agentic tool-calling workflows |
| Coding | Strong focus on repository-level and frontend workflows |
| Vision | Supports image, document, spatial, and video understanding benchmarks |
| License | Apache 2.0 |

## Fit for New Showbiz

Use Qwen3.6 35B A3B when the operator needs multimodal or long-context capability:

- Inspect screenshots of New Showbiz pages for visual QA, copy fit, broken layout, and accessibility issues.
- Review rendered social media creative before publication.
- Analyze long batches of operator documentation, campaign history, or site pages.
- Assist with frontend, browser-automation, and repository-level implementation tasks.
- Extract structured observations from images or videos used in QA and marketing review.
- Compare draft content against screenshots or source pages before a human review step.

For pure text drafting, classification, and policy routing, Hermes 4.3 36B may be simpler to operate. For image/video-aware checks, Qwen is the stronger candidate.

## Prompting and Thinking Behavior

Qwen3.6 thinks by default and may emit reasoning content using:

```text
<think>
...
</think>
```

The source card states that Qwen3.6 does not officially support the older `/think` and `/nothink` soft switches. To request direct non-thinking responses through OpenAI-compatible APIs, use chat template options where supported:

```json
{
  "chat_template_kwargs": {
    "enable_thinking": false
  }
}
```

For agent workflows, the source card describes `preserve_thinking` as a way to retain reasoning context across historical messages:

```json
{
  "chat_template_kwargs": {
    "preserve_thinking": true
  }
}
```

For New Showbiz, preserve operational decisions, tool calls, evidence references, receipts, and concise rationales. Do not expose raw chain-of-thought in public content or durable business records.

## Suggested Inference Settings

Source-card starting points:

| Mode | Suggested settings |
| --- | --- |
| Thinking, general tasks | `temperature=1.0`, `top_p=0.95`, `top_k=20`, `presence_penalty=1.5`, `repetition_penalty=1.0` |
| Thinking, precise coding/WebDev | `temperature=0.6`, `top_p=0.95`, `top_k=20`, `presence_penalty=0.0`, `repetition_penalty=1.0` |
| Instruct/non-thinking | `temperature=0.7`, `top_p=0.80`, `top_k=20`, `presence_penalty=1.5`, `repetition_penalty=1.0` |

The source card recommends 32,768 output tokens for most queries and up to 81,920 tokens for highly complex benchmark-style math or programming tasks. In New Showbiz workflows, keep output limits much lower unless a specific long-form analysis requires the budget.

## Serving Notes

The source card recommends current serving engines for production and high-throughput use:

- SGLang `>=0.5.10`
- vLLM `>=0.19.0`
- KTransformers for CPU/GPU heterogeneous inference
- Transformers serving for quick testing or moderate load

Example SGLang command:

```powershell
python -m sglang.launch_server --model-path Qwen/Qwen3.6-35B-A3B --port 8000 --tp-size 8 --mem-fraction-static 0.8 --context-length 262144 --reasoning-parser qwen3
```

Example vLLM command:

```powershell
vllm serve Qwen/Qwen3.6-35B-A3B --port 8000 --tensor-parallel-size 8 --max-model-len 262144 --reasoning-parser qwen3
```

Tool-calling examples from the source card add `qwen3_coder` as the parser:

```powershell
vllm serve Qwen/Qwen3.6-35B-A3B --port 8000 --tensor-parallel-size 8 --max-model-len 262144 --reasoning-parser qwen3 --enable-auto-tool-choice --tool-call-parser qwen3_coder
```

For text-only serving, the source card notes that vLLM can skip the vision encoder:

```powershell
vllm serve Qwen/Qwen3.6-35B-A3B --port 8000 --tensor-parallel-size 8 --max-model-len 262144 --reasoning-parser qwen3 --language-model-only
```

## Multimodal Input Pattern

OpenAI-compatible image input shape:

```json
{
  "role": "user",
  "content": [
    {
      "type": "image_url",
      "image_url": {
        "url": "https://example.com/image.png"
      }
    },
    {
      "type": "text",
      "text": "Describe the image in one sentence."
    }
  ]
}
```

For New Showbiz QA, prefer concise, task-specific prompts such as:

```text
Identify visible layout problems, cropped text, overlapping controls, missing movie information, or unclear calls to action. Return JSON with severity, location, evidence, and recommended fix.
```

## Evaluation Signals From Source Card

The copied source card highlights:

- SWE-bench Verified: 73.4.
- Terminal-Bench 2.0: 51.5.
- MCPMark: 37.0.
- GPQA: 86.0.
- LiveCodeBench v6: 80.4.
- AIME 2026: 92.7.
- MMMU: 81.7.
- RealWorldQA: 85.3.
- OmniDocBench 1.5: 89.9.
- VideoMMMU: 83.7.

Treat benchmark numbers as vendor-reported reference data, not as New Showbiz production validation.

## Risks and Constraints

- Multimodal outputs still need source verification, especially for identity-sensitive or factual claims.
- Long-context use can become expensive and slow; prefer retrieval and scoped context where possible.
- Thinking mode may produce hidden or verbose reasoning; do not persist raw chain-of-thought.
- Vision observations should be treated as QA evidence, not final truth.
- Video handling depends heavily on serving configuration and frame sampling.
- Tool-calling must be constrained to New Showbiz toolsets with review gates and durable receipts.
- Public channel writes still require explicit New Showbiz X adapters.

## Usage Notes for New Showbiz

Qwen3.6 35B A3B is a strong candidate for multimodal review, long-context analysis, and engineering support inside the New Showbiz marketing operator.

Recommended uses:

- Screenshot QA for New Showbiz homepage, movie search, movie detail, donate, about, contact, sign-up, and account flows.
- Visual review of social image assets before scheduling.
- Browser-read fallback analysis when a page's rendered state matters.
- Long-document synthesis across operator docs, campaign plans, source evidence, and incident records.
- Frontend and automation implementation support, especially where screenshot feedback is available.
- Structured extraction from images or video snippets used in internal QA.

Avoid or gate:

- Unreviewed public copy about representation scores or sensitive identity categories.
- Direct X publishing or browser automation without approved New Showbiz adapters.
- Donation, crypto, tax, refund, investment, legal, partnership, or creator-complaint responses without escalation.
- Claims about live site behavior unless verified against the current site or source.
- Treating visual inference as definitive evidence for film content, identity representation, or user intent.
