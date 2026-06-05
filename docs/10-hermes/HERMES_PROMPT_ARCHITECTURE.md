# Hermes System Prompt Architecture
### A Reference for Agent Orchestration

> Derived from source at `/usr/local/lib/hermes-agent/agent/system_prompt.py`,
> `prompt_builder.py`, and `agent_init.py` on `hermes-dev` (i-05451add3165b57ff).

> **Terminology note (added 2026-06-05):** This document uses "Tier 1/2/3" to describe Hermes's internal *prompt assembly* layers (stable identity / session context / volatile state). The New Showbiz agent execution architecture uses a separate "Tier 0/1/2" taxonomy to describe *agent spawn authority* (Session Director / Pipeline Agents / Leaf Subagents). These are orthogonal concepts. See [Tier Architecture](tier-architecture.md) for the agent execution model.

---

## Table of Contents

1. [The Three-Tier Model](#1-the-three-tier-model)
2. [Tier 1: Stable](#2-tier-1-stable)
   - [1a. Identity — docs/10-hermes/SOUL.md](#1a-identity--soulmd)
   - [1b. Tool-Aware Guidance Blocks](#1b-tool-aware-guidance-blocks)
   - [1c. Tool-Use Enforcement and Model-Family Guidance](#1c-tool-use-enforcement-and-model-family-guidance)
   - [1d. Skills Prompt](#1d-skills-prompt)
   - [1e. Environment and Platform Hints](#1e-environment-and-platform-hints)
3. [Tier 2: Context](#3-tier-2-context)
   - [2a. system_message](#2a-system_message)
   - [2b. Context File Priority Cascade](#2b-context-file-priority-cascade)
   - [2c. ephemeral_system_prompt](#2c-ephemeral_system_prompt)
4. [Tier 3: Volatile](#4-tier-3-volatile)
   - [3a. Memory Snapshot](#3a-memory-snapshot)
   - [3b. USER.md Profile](#3b-usermd-profile)
   - [3c. Timestamp and Session Metadata](#3c-timestamp-and-session-metadata)
5. [Prompt Caching Strategy](#5-prompt-caching-strategy)
6. [Injection Security Scanner](#6-injection-security-scanner)
7. [Orchestration Primitives](#7-orchestration-primitives)
   - [Built-in Kanban System](#built-in-kanban-system)
   - [Shared Iteration Budget](#shared-iteration-budget)
   - [Shared Credential Pool](#shared-credential-pool)
   - [Parent Session Linkage](#parent-session-linkage)
   - [prefill_messages](#prefill_messages)
8. [Agent Spawn Reference](#8-agent-spawn-reference)
9. [Common Orchestration Patterns](#9-common-orchestration-patterns)
   - [Orchestrator + Isolated Workers](#pattern-1-orchestrator--isolated-workers)
   - [Assembly Line (Worker Chain)](#pattern-2-assembly-line-worker-chain)
   - [Role-Differentiated Workers via Toolsets](#pattern-3-role-differentiated-workers-via-toolsets)
   - [Dynamic Task Injection](#pattern-4-dynamic-task-injection)
   - [Multi-Repo Agent Fleet](#pattern-5-multi-repo-agent-fleet)
10. [Quick Reference: What Goes Where](#10-quick-reference-what-goes-where)

---

## 1. The Three-Tier Model

Every LLM call Hermes makes sends a single assembled system prompt built from three ordered tiers:

```
┌─────────────────────────────────────────┐
│  STABLE                                 │  ← Built once at agent init, cached
│  identity · tools · skills · env        │    for the entire session lifetime
├─────────────────────────────────────────┤
│  CONTEXT                                │  ← Session-stable, CWD-dependent
│  system_message · project files         │    can differ across agents
├─────────────────────────────────────────┤
│  VOLATILE                               │  ← Per-session/turn state
│  memory · user profile · timestamp      │    never prefix-cached
└─────────────────────────────────────────┘
```

The tiers are joined with `\n\n` and the full string is cached on `agent._cached_system_prompt`. It is **never partially rebuilt mid-session** — only a context compression event triggers a full rebuild. This is a deliberate cache strategy: keeping the prefix stable across all turns maximizes upstream LLM prefix cache hits and reduces latency and cost.

The only exception is `ephemeral_system_prompt`, which is injected at API-call time on every turn and intentionally bypasses the cache entirely.

---

## 2. Tier 1: Stable

The stable tier is the longest and most expensive part of the prompt. It is assembled in a fixed order from the components below.

Source: `agent/system_prompt.py` → `build_system_prompt_parts()`, lines 83–219.

---

### 1a. Identity — docs/10-hermes/SOUL.md

**Position:** First thing in the entire system prompt.

**Source:** `/.hermes/docs/10-hermes/SOUL.md` (read via `load_soul_md()` in `prompt_builder.py:1313`).

**Behavior:**
- Read from disk at session start (not every turn — the result is cached into stable)
- Scanned for prompt injection before use (see [Injection Security Scanner](#6-injection-security-scanner))
- Truncated at a configurable char limit with head/tail preservation
- If the file is empty or missing, falls back to the hardcoded `DEFAULT_AGENT_IDENTITY` constant

**Hot-reload:** Because docs/10-hermes/SOUL.md is read once at session init and then cached into the stable tier, changes to the file take effect on the **next session start**, not the next message. The `load_soul_md()` function does read from disk each time it is called, but `build_system_prompt_parts()` only calls it once — at the moment the stable tier is first assembled.

**For orchestration:**

docs/10-hermes/SOUL.md is the orchestrator's identity. It defines personality, operating principles, constraints, and communication style for the top-level agent. Worker agents spawned programmatically should not inherit this — use `skip_context_files=True` and `load_soul_identity=False` to give them a clean slate.

```python
# Orchestrator — uses docs/10-hermes/SOUL.md persona
orchestrator = AIAgent(
    load_soul_identity=True,
)

# Worker — no persona, no project files, fully task-driven
worker = AIAgent(
    skip_context_files=True,
    load_soul_identity=False,
    system_message="You are a JSON extractor. Return only valid JSON, no commentary.",
)

# Cron/gateway worker — keeps persona, skips project files
scheduled_agent = AIAgent(
    skip_context_files=True,
    load_soul_identity=True,  # Still reads docs/10-hermes/SOUL.md as identity
)
```

The `load_soul_identity` flag exists specifically for cron jobs and gateway sessions that should maintain the configured personality while not accidentally picking up whatever project's legacy Claude context file or docs/10-hermes/AGENTS.md happens to be in the working directory.

---

### 1b. Tool-Aware Guidance Blocks

**Position:** After identity, before enforcement.

These are constant strings from `prompt_builder.py`, each injected **only if the corresponding tool is present in `agent.valid_tool_names`**. If the agent doesn't have the tool, it doesn't see the guidance for it.

| Condition | Block injected | What it does |
|---|---|---|
| `"memory"` in tools | `MEMORY_GUIDANCE` | How and when to write persistent memories |
| `"session_search"` in tools | `SESSION_SEARCH_GUIDANCE` | How to search past sessions for context |
| `"skill_manage"` in tools | `SKILLS_GUIDANCE` | How to create and improve skills |
| `HERMES_KANBAN_TASK` env set | `KANBAN_GUIDANCE` | Worker/orchestrator lifecycle, completion reporting |
| `"computer_use"` in tools | `COMPUTER_USE_GUIDANCE` | macOS automation behavior and safety |

The kanban block deserves special attention: it is only injected when the `HERMES_KANBAN_TASK` environment variable is present on the process. This means normal interactive sessions never see orchestration instructions — the distinction between orchestrator and worker is enforced at the environment level.

**For orchestration:** Use `enabled_toolsets` and `disabled_toolsets` at spawn time to give workers a minimal, role-appropriate toolset. A worker that only does file I/O doesn't need memory or session-search tools — and without those tools, those guidance blocks are omitted, keeping the context lean.

```python
# Minimal file-processing worker
worker = AIAgent(
    enabled_toolsets=["bash", "files"],
    skip_context_files=True,
    load_soul_identity=False,
)
# This worker's stable tier has: DEFAULT_AGENT_IDENTITY + HERMES_AGENT_HELP_GUIDANCE only.
# No memory guidance, no skills guidance, no session search. ~60% smaller stable tier.
```

---

### 1c. Tool-Use Enforcement and Model-Family Guidance

**Position:** After tool guidance blocks.

Controlled by `agent.tool_use_enforcement` (configurable in `config.yaml`). Values:

| Value | Effect |
|---|---|
| `"auto"` (default) | Inject for models in `TOOL_USE_ENFORCEMENT_MODELS` list |
| `true` | Always inject for all models |
| `false` | Never inject |
| `[list]` | Inject when model name contains any substring in the list |

When enforcement is injected, a second model-family-specific block is also added:

- **Gemini / Gemma:** conciseness, absolute path requirements, parallel tool call usage, verify-before-edit discipline
- **GPT / Codex / Grok:** tool persistence (don't claim completion without calling tools), prerequisite checks, anti-hallucination guardrails

These are injected automatically based on `agent.model`. For orchestration across a heterogeneous fleet (different workers using different models), each worker gets the right behavioral guardrails without any extra configuration. This is particularly important when routing to Grok or GPT models, which have a documented tendency to describe intended actions instead of executing them.

---

### 1d. Skills Prompt

**Position:** After enforcement blocks.

Injected when the agent has any of `skills_list`, `skill_view`, or `skill_manage` in its toolset. Contains a compact index of all skills available in `/.hermes/skills/` — each skill is a markdown file describing a reusable behavior pattern.

**Skills are global.** They live at `/.hermes/skills/` and are shared across all agent instances on the machine. A worker that creates a skill via `skill_manage` makes it immediately available to the orchestrator and all future workers. This is Hermes's self-improvement mechanism: the agent fleet learns collectively.

For orchestration, skills are the right place to encode reusable sub-procedures: "how to parse a particular data format", "how to handle a specific API's pagination", "how to structure a code review". Write them once (manually or let an agent write them), and every agent automatically picks them up.

---

### 1e. Environment and Platform Hints

**Position:** Last items in the stable tier.

**Environment hints** (`build_environment_hints()`) auto-detect the runtime environment — WSL, Termux, Docker, bare Linux — and inject relevant facts (path translation rules, shell differences, etc.). These are fully automatic.

**Platform hints** are controlled by the `platform` parameter at spawn time. Supported values: `"cli"`, `"telegram"`, `"discord"`, `"whatsapp"`. Each injects a formatting hint block telling the agent how to structure responses for that delivery channel.

```python
# Agent delivering output to Telegram
telegram_worker = AIAgent(
    platform="telegram",
    # Stable tier now includes Telegram-specific formatting hints:
    # use short paragraphs, avoid wide tables, use *bold* not **bold**, etc.
)
```

For multi-platform deployments, set `platform` per agent based on where its output will be delivered. A worker that outputs to the orchestrator (not a user) should use `"cli"` or leave it unset.

---

## 3. Tier 2: Context

Session-stable context. Built once per session alongside stable, but varies based on the working directory and caller-supplied instructions.

Source: `agent/system_prompt.py` → `build_system_prompt_parts()`, lines 221–238.

---

### 2a. system_message

The `system_message` parameter passed to `AIAgent.__init__`. Goes directly into the context tier as the first element.

This is the **primary role injection point** for orchestration. It persists for the lifetime of the session and is appropriate for instructions that define the worker's role, output format, and behavioral constraints.

```python
worker = AIAgent(
    system_message="""
You are a security auditor reviewing Python source code.

Your output must be a JSON array of findings, each with:
  { "file": str, "line": int, "severity": "high|medium|low", "description": str }

Do not produce any other output. If you find no issues, return an empty array [].
""",
    skip_context_files=True,
    load_soul_identity=False,
)
```

`system_message` is the right channel when the instruction is:
- Fixed for the lifetime of the worker session
- Defining the worker's role and output contract
- Something you want saved to trajectories (unlike `ephemeral_system_prompt`)

---

### 2b. Context File Priority Cascade

When `skip_context_files=False`, Hermes auto-discovers project context from the working directory (`TERMINAL_CWD` env var, or `os.getcwd()` as fallback). Exactly **one** project context type is loaded — the first match wins:

```
Priority 1: .hermes.md or HERMES.md    ← walks up to git root
Priority 2: docs/10-hermes/AGENTS.md or agents.md     ← CWD only
Priority 3: legacy Claude context file or claude.md     ← CWD only
Priority 4: .cursorrules               ← CWD only
            .cursor/rules/*.mdc        ← CWD only (all .mdc files, sorted)
```

docs/10-hermes/SOUL.md from `HERMES_HOME` is independent and **always** included when present (unless `skip_context_files=True`). It is not part of the cascade — it is loaded separately as the identity block.

**File details:**

`.hermes.md` / `HERMES.md` — Hermes's native project context format. Walks up to the git root, so a file at the repo root covers all subdirectories. Preferred over docs/10-hermes/AGENTS.md for Hermes-specific projects.

`docs/10-hermes/AGENTS.md` — CWD-scoped. Compatible with other agent frameworks (Claude Code, etc.). Use when the project needs to be portable across agent systems.

`legacy Claude context file` — CWD-scoped. Claude Code's native format. Hermes reads it as a fallback, so a Claude Code project works in Hermes without modification.

`.cursorrules` / `.cursor/rules/*.mdc` — Cursor IDE format. Lowest priority. Hermes reads these as a last resort for compatibility with Cursor-configured repos.

**For orchestration across multiple repositories:**

Set `TERMINAL_CWD` per worker to point each agent at the right project directory. Each worker then auto-loads the appropriate project context without any manual configuration.

```python
import os

def spawn_worker_for_repo(repo_path: str, task: str) -> AIAgent:
    env = os.environ.copy()
    env["TERMINAL_CWD"] = repo_path
    return AIAgent(
        system_message=task,
        # Worker runs in the context of this specific repo's .hermes.md
    )
```

**Cap:** Each context file is truncated at 20,000 characters using head/tail preservation with a marker in the middle. Plan context files to put the most critical instructions at the top and bottom.

---

### 2c. ephemeral_system_prompt

Not strictly part of the three tiers — this is injected at API-call time on **every LLM call**, separately from the cached system prompt string.

```python
# agent/agent_init.py line 157:
ephemeral_system_prompt: str = None
```

Key properties:
- **Not cached** — changes take effect immediately on the next call
- **Not saved to trajectories** — invisible to session replay and data collection
- **Not stored** — does not persist in `agent._cached_system_prompt`
- **Injected fresh every turn** — the orchestrator can change it between turns

This is the **dynamic task channel** for runtime orchestration. It does not invalidate the warm prefix cache on stable/context/volatile because it is appended at call time, not baked into the cached string.

```python
# Orchestrator controlling a worker turn-by-turn
for task in task_queue:
    worker.ephemeral_system_prompt = f"""
CURRENT TASK: {task['instruction']}
INPUT DATA: {task['data']}
EXPECTED OUTPUT FORMAT: {task['output_schema']}
"""
    result = worker.chat(task['instruction'])
    task_queue.mark_done(task['id'], result)
```

Use `ephemeral_system_prompt` when the instruction is:
- Different on every turn
- Derived from runtime state (queue contents, previous worker output, dynamic routing decisions)
- Something you explicitly do not want saved to trajectories
- Injecting structured context from a previous step

---

## 4. Tier 3: Volatile

Per-session state that changes at compression boundaries and on fresh session starts. Always at the bottom of the assembled prompt.

Source: `agent/system_prompt.py` → `build_system_prompt_parts()`, lines 241–278.

---

### 3a. Memory Snapshot

When `agent._memory_store` is set and `agent._memory_enabled` is `True`, the full memory store is formatted and appended here. Memory lives on disk at `/.hermes/memories/` and is reloaded from disk on every system prompt rebuild.

**Shared memory is the default.** All agents on the machine read the same `/.hermes/memories/` directory unless you point them at different `HERMES_HOME` paths. This means:

- An orchestrator that writes a memory (`memory_write("discovered: API rate limit is 100/min")`) makes it immediately visible to all current and future workers.
- A worker that learns something during execution can write it to memory as a side-effect, benefiting the whole fleet.
- A compression event on any agent reloads memory from disk, so late-written memories get picked up even mid-session.

To isolate workers from shared memory:

```python
# Worker with no memory access
isolated_worker = AIAgent(skip_memory=True)

# Worker with its own isolated memory store
import os
env = os.environ.copy()
env["HERMES_HOME"] = "/tmp/worker-42-home"
isolated_worker = AIAgent()  # now reads from /tmp/worker-42-home/memories/
```

---

### 3b. USER.md Profile

A persistent profile document about the human user — preferences, working style, context. Stored under the `user` namespace in the memory store. Injected when `agent._user_profile_enabled` is `True`.

In gateway deployments, this is populated per `user_id`, so different users get personalized behavior from the same agent process. An agent that learns a user prefers concise responses will write that to their USER.md profile, and every future session for that user starts with that preference already loaded.

For orchestration, USER.md is typically only relevant for the outermost agent that interfaces with a human. Worker agents operating in automated pipelines should have this disabled (`skip_memory=True` suppresses it, or it can be disabled separately via config).

---

### 3c. Timestamp and Session Metadata

Always the last element. Format:

```
Conversation started: Thursday, May 22, 2026
Session ID: <uuid>
Model: <model name>
Provider: <provider name>
```

The timestamp is **date-only, not minute-precision**. This is an explicit cache optimization — minute-precision timestamps invalidate the prefix cache on every rebuild (compression boundary, fresh gateway turn, session resume without a stored prompt). The model can query exact wall-clock time via tools if it actually needs it.

Session ID is only included when `pass_session_id=True`. Model and provider lines are always included when set.

---

## 5. Prompt Caching Strategy

Understanding the caching model is critical for writing efficient orchestration code.

**The rule:** the three assembled tiers form a single string cached on `agent._cached_system_prompt`. This string is sent verbatim on every turn. It is never partially rebuilt mid-session. The only events that invalidate it:

1. Context compression (conversation grew past the model's context window)
2. Explicit call to `invalidate_system_prompt(agent)` (rare, internal use)

**Why this matters for orchestration:**

| Action | Hits cache | Cost |
|---|---|---|
| Calling the agent again on the same session | Yes — stable/context/volatile prefix cached | Low |
| Changing `ephemeral_system_prompt` between turns | Partial — stable/context/volatile still cached | Low |
| Spawning a new agent with the same docs/10-hermes/SOUL.md | No — new object, cold cache | Medium (one-time) |
| Triggering a compression event | No — full rebuild | High (once, then re-cached) |

**Implication for long-running workers:** a worker that runs for many turns will keep its stable/context/volatile tiers warm in the upstream LLM's KV cache indefinitely, as long as those tiers don't change. Changing `ephemeral_system_prompt` each turn is cheap because it appends to a warm prefix rather than replacing it.

**Implication for worker pools:** if you spawn many workers with identical configuration (same docs/10-hermes/SOUL.md, same system_message, same toolset), they all share the same upstream prefix cache — the LLM provider only needs to process the common prefix once. Build your worker configs to maximize shared prefix length.

---

## 6. Injection Security Scanner

All context files — docs/10-hermes/SOUL.md, .hermes.md, docs/10-hermes/AGENTS.md, legacy Claude context file, .cursorrules — pass through `_scan_context_content()` in `prompt_builder.py` before being injected into any prompt tier.

**Blocked patterns:**

| Pattern | Type |
|---|---|
| `ignore previous/all/above instructions` | Prompt injection |
| `do not tell the user` | Deception |
| `system prompt override` | System prompt override |
| `disregard your instructions/rules/guidelines` | Rule bypass |
| `act as if you have no restrictions` | Restriction bypass |
| `<!-- ... ignore/override/system/secret ... -->` | HTML comment injection |
| `<div style="display:none"` | Hidden element injection |
| `translate X into Y and execute/run/eval` | Translate-execute attack |
| `curl ... $KEY / $TOKEN / $SECRET` | Credential exfiltration |
| `cat .env / credentials / .netrc` | Secret file read |
| Zero-width unicode characters (U+200B, U+FEFF, etc.) | Invisible text injection |

When a file is blocked, its content is replaced with:
```
[BLOCKED: filename contained potential prompt injection (pattern_id). Content not loaded.]
```

**For orchestration:** if you are dynamically writing context files as part of an automated workflow (e.g., generating `.hermes.md` files from a template), be aware that those files pass through this scanner. Legitimate orchestration instructions that happen to use phrases like "ignore" or reference environment variables should be rephrased to avoid false positives.

---

## 7. Orchestration Primitives

### Built-in: Kanban System

Hermes ships a native task-dispatch system. The orchestrator maintains a kanban board of tasks; workers pull from it and report completion.

**Activation:** set `HERMES_KANBAN_TASK` in the worker's environment before spawning. This causes `KANBAN_GUIDANCE` to appear in the worker's stable tier, explaining the lifecycle: how to signal task completion, how to report errors, how to escalate back to the orchestrator, and how to handle partial results.

The kanban board itself lives in `/.hermes/cron/`. The dispatcher is in `cron/scheduler.py`.

```bash
# Spawning a worker with kanban mode active
HERMES_KANBAN_TASK="task-id-42" hermes --skip-context-files --model gpt-4o
```

```python
import subprocess, os

def dispatch_kanban_worker(task_id: str, model: str = "gpt-4o"):
    env = os.environ.copy()
    env["HERMES_KANBAN_TASK"] = task_id
    return subprocess.Popen(
        ["hermes", "--skip-context-files"],
        env=env,
    )
```

### Shared Iteration Budget

```python
from agent.iteration_budget import IterationBudget

# Create a shared budget — all agents consume from the same pool
budget = IterationBudget(max_iterations=200)

orchestrator = AIAgent(iteration_budget=budget, model="claude-opus-4-7")
worker_a     = AIAgent(iteration_budget=budget, model="gpt-4o")
worker_b     = AIAgent(iteration_budget=budget, model="gpt-4o")

# Total LLM turns across all three agents is capped at 200.
# A runaway worker cannot exhaust the full budget.
```

The budget is consumed on every LLM turn across all agents that share it. Check `budget.remaining` before spawning additional workers to avoid spawning agents that immediately hit the limit.

### Shared Credential Pool

```python
pool = CredentialPool(...)  # configured with multiple API key sets

# All workers share the same rotating credential pool
for i in range(10):
    worker = AIAgent(
        credential_pool=pool,
        model="openai/gpt-4o",
    )
```

Useful when parallelizing across many workers and you want to distribute load across multiple API keys or avoid rate limits on a single key.

### Parent Session Linkage

```python
worker = AIAgent(
    parent_session_id=orchestrator.session_id,
    pass_session_id=True,
)
```

Links the worker's session record to its parent in the session database (`/.hermes/sessions/`). Enables `session_search` to traverse the parent-child graph — a future agent debugging a past run can reconstruct the full execution tree, see which worker handled which task, and inspect intermediate outputs.

Set `pass_session_id=True` on workers so the session ID appears in their volatile tier, which makes it available to tools and logging.

### prefill_messages

Prepends synthetic conversation history to prime the worker's starting context.

```python
worker = AIAgent(
    system_message="You are a code reviewer. Find security issues.",
    prefill_messages=[
        {
            "role": "user",
            "content": f"Here is the output from the static analyzer:\n\n{analyzer_output}"
        },
        {
            "role": "assistant",
            "content": "I have reviewed the static analyzer output. I will now examine the source code with that context in mind."
        }
    ]
)
```

This is the right way to hand off one worker's output to the next without re-spending tokens to explain it. The prefill is injected as if that conversation already happened — the worker starts with full context of the prior step.

**Important:** Anthropic Sonnet 4.6+ and Opus 4.6+ reject conversations ending on an `assistant` role turn (HTTP 400). For those models, end `prefill_messages` on a `user` turn, or use `system_message` to pass the prior context instead.

---

## 8. Agent Spawn Reference

Complete reference of `AIAgent.__init__` parameters relevant to orchestration:

```python
AIAgent(
    # ── Model and provider ────────────────────────────────────────
    model="claude-opus-4-7",          # Model to use
    provider="anthropic",             # Provider hint for routing
    base_url=None,                    # Custom endpoint (local models, proxies)
    api_key=None,                     # Override env var
    api_mode=None,                    # "chat_completions" | "codex_responses" | "anthropic_messages"

    # ── Prompt tiers ──────────────────────────────────────────────
    system_message=None,              # → Context tier slot 1. Role definition, output contract.
    ephemeral_system_prompt=None,     # → Injected per-call, never cached, never saved.
    prefill_messages=None,            # → Synthetic history prepended before first user turn.

    # ── Identity and context files ────────────────────────────────
    skip_context_files=False,         # True → skip docs/10-hermes/SOUL.md, docs/10-hermes/AGENTS.md, .cursorrules, legacy Claude context file
    load_soul_identity=False,         # True → load docs/10-hermes/SOUL.md even when skip_context_files=True
    platform=None,                    # "cli" | "telegram" | "discord" | "whatsapp"

    # ── Toolset ───────────────────────────────────────────────────
    enabled_toolsets=None,            # Allowlist: only load these toolsets
    disabled_toolsets=None,           # Denylist: skip these toolsets

    # ── Memory ────────────────────────────────────────────────────
    skip_memory=False,                # True → no memory/USER.md in volatile tier

    # ── Session and identity ──────────────────────────────────────
    session_id=None,                  # Pre-assign session ID (auto-generated if None)
    parent_session_id=None,           # Link to parent orchestrator session
    pass_session_id=False,            # Include session ID in volatile tier timestamp line
    user_id=None,                     # Platform user identifier (gateway sessions)
    user_name=None,
    chat_id=None,
    chat_name=None,
    chat_type=None,
    thread_id=None,
    gateway_session_key=None,         # Stable per-chat key (e.g. "agent:main:telegram:dm:123")

    # ── Execution limits ──────────────────────────────────────────
    max_iterations=90,                # Max tool-calling iterations
    iteration_budget=None,            # Shared IterationBudget object (pass same instance to workers)
    max_tokens=None,                  # Max response tokens (uses model default if None)
    tool_delay=1.0,                   # Seconds between tool calls

    # ── Shared resources ──────────────────────────────────────────
    credential_pool=None,             # Shared CredentialPool for rotating keys

    # ── Trajectory saving ─────────────────────────────────────────
    save_trajectories=False,          # Save conversation to JSONL (excludes ephemeral_system_prompt)

    # ── Callbacks (for streaming orchestration) ───────────────────
    tool_progress_callback=None,      # fn(tool_name, args_preview)
    tool_start_callback=None,
    tool_complete_callback=None,
    thinking_callback=None,
    stream_delta_callback=None,
    step_callback=None,
    status_callback=None,
)
```

---

## 9. Common Orchestration Patterns

### Pattern 1: Orchestrator + Isolated Workers

An orchestrator with full identity and memory coordinates workers that have no shared state and no persona.

```python
from agent.iteration_budget import IterationBudget

budget = IterationBudget(max_iterations=300)

# Orchestrator: full identity, memory, skills
orchestrator = AIAgent(
    model="claude-opus-4-7",
    load_soul_identity=True,
    iteration_budget=budget,
    pass_session_id=True,
)

# Workers: role-specific, isolated, minimal toolset
def spawn_worker(role: str, task: str):
    return AIAgent(
        model="gpt-4o",
        system_message=role,
        skip_context_files=True,
        load_soul_identity=False,
        skip_memory=True,
        enabled_toolsets=["bash", "files"],
        iteration_budget=budget,          # Same budget — shared cap
        parent_session_id=orchestrator.session_id,
        ephemeral_system_prompt=task,
    )
```

---

### Pattern 2: Assembly Line (Worker Chain)

Each worker's output becomes the next worker's prefill context.

```python
stages = [
    ("fetch",    "Download the URL and return the raw HTML."),
    ("extract",  "Extract all article text from the HTML. Return plain text only."),
    ("summarize","Summarize the article in three sentences."),
    ("classify", "Classify the summary into one of: tech, science, politics, other."),
]

context = initial_input
for role, instruction in stages:
    worker = AIAgent(
        system_message=instruction,
        skip_context_files=True,
        load_soul_identity=False,
        skip_memory=True,
        prefill_messages=[
            {"role": "user",      "content": f"Input:\n\n{context}"},
            {"role": "assistant", "content": "I have received the input. Processing now."},
        ] if context != initial_input else None,
    )
    context = worker.chat(instruction)

final_result = context
```

---

### Pattern 3: Role-Differentiated Workers via Toolsets

Different workers get different capabilities by varying `enabled_toolsets`. This also controls which guidance blocks appear in their stable tiers.

```python
# Researcher: can search and browse, read files — no write access
researcher = AIAgent(
    system_message="Research the topic and return a structured findings report.",
    enabled_toolsets=["web_search", "browser", "files_read"],
    skip_context_files=True,
)
# Stable tier includes: DEFAULT_IDENTITY + HERMES_AGENT_HELP_GUIDANCE only.
# No memory guidance (no memory tool). No skills guidance.

# Writer: can read and write files, no web access
writer = AIAgent(
    system_message="Write a report based on the provided research.",
    enabled_toolsets=["files"],
    skip_context_files=True,
    prefill_messages=[
        {"role": "user", "content": f"Research findings:\n\n{researcher_output}"}
    ],
)

# Reviewer: read-only, memory enabled so it can learn review patterns
reviewer = AIAgent(
    system_message="Review the draft for accuracy and clarity. Return structured feedback.",
    enabled_toolsets=["files_read", "memory"],  # memory tool → MEMORY_GUIDANCE injected
    skip_context_files=True,
    load_soul_identity=False,
)
```

---

### Pattern 4: Dynamic Task Injection

Using `ephemeral_system_prompt` to drive a persistent worker through a queue of tasks without rebuilding its session.

```python
worker = AIAgent(
    model="gpt-4o",
    system_message="You process data transformation tasks. For each task you receive ephemeral instructions.",
    skip_context_files=True,
    load_soul_identity=False,
    skip_memory=True,
    enabled_toolsets=["bash", "files"],
    save_trajectories=True,
)

# Drive the same worker through many tasks.
# The stable/context/volatile prefix stays warm across all of them.
for task in task_queue.fetch_batch(50):
    worker.ephemeral_system_prompt = f"""
TASK ID: {task['id']}
OPERATION: {task['operation']}
INPUT FILE: {task['input_path']}
OUTPUT FILE: {task['output_path']}
CONSTRAINTS: {task['constraints']}
"""
    result = worker.chat(f"Execute task {task['id']}")
    task_queue.complete(task['id'], result)
```

The session accumulates history across all tasks — the worker has full context of what it processed previously, which can help it handle edge cases and pattern-match against earlier successes.

---

### Pattern 5: Multi-Repo Agent Fleet

Each worker is bound to a specific repository's context via `TERMINAL_CWD`.

```python
import os

repos = [
    "/home/ec2-user/projects/service-a",
    "/home/ec2-user/projects/service-b",
    "/home/ec2-user/projects/service-c",
]

workers = []
for repo_path in repos:
    env = os.environ.copy()
    env["TERMINAL_CWD"] = repo_path
    # Each worker auto-loads that repo's .hermes.md / docs/10-hermes/AGENTS.md / legacy Claude context file
    worker = AIAgent(
        system_message="Audit this codebase for dependency vulnerabilities.",
        skip_context_files=False,   # Load project context from TERMINAL_CWD
        load_soul_identity=False,
        skip_memory=True,
        enabled_toolsets=["bash", "files_read"],
        parent_session_id=orchestrator.session_id,
    )
    workers.append((repo_path, worker))

# Run in parallel, collect results
results = {}
for repo_path, worker in workers:
    results[repo_path] = worker.chat("Begin the audit.")
```

---

## 10. Quick Reference: What Goes Where

| You want to... | Use | Tier |
|---|---|---|
| Define the orchestrator's personality and principles | `/.hermes/docs/10-hermes/SOUL.md` | Stable (identity) |
| Give a worker a specific role and output contract | `system_message=` at spawn | Context |
| Inject the current task dynamically, turn-by-turn | `agent.ephemeral_system_prompt` | (bypass — per call) |
| Give a project's agents shared repo-level instructions | `.hermes.md` at git root | Context (auto-discovered) |
| Hand off one worker's output to the next | `prefill_messages=` | (message history) |
| Strip persona from automated batch workers | `skip_context_files=True, load_soul_identity=False` | — |
| Keep docs/10-hermes/SOUL.md persona on cron/gateway workers | `load_soul_identity=True, skip_context_files=True` | Stable |
| Share learned facts across all agents | Memory store (default — no config) | Volatile |
| Isolate worker memory from orchestrator | `skip_memory=True` | — |
| Cap total LLM turns across a multi-agent run | Shared `IterationBudget` | — |
| Prevent workers from seeing each other's state | Separate `HERMES_HOME` per worker | — |
| Route agent output to a messaging platform | `platform="telegram"` etc. | Stable (hints) |
| Give different workers different capabilities | `enabled_toolsets=[...]` | Stable (tool guidance) |
| Use the native task dispatch system | Kanban via `HERMES_KANBAN_TASK` + `kanban_show` | Stable (guidance) |
| Link worker sessions to their orchestrator | `parent_session_id=orchestrator.session_id` | — |
| Inject structured context without saving to trajectories | `ephemeral_system_prompt` | (bypass — per call) |
| Teach the fleet a reusable pattern | Write a skill to `/.hermes/skills/` | Stable (skills prompt) |

