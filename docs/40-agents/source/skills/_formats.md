---
title: Skill Format Reference
record_type: format-reference
status: canonical
canonical_path: agents/skills/_formats.md
maintainer: agent
human_owned: false
agent_owned: true
updated: 2026-05-20
---

# Skill Format Reference

Canonical reference for the default Hermes/agentskills.io SKILL.md format and conversion mappings to all supported agent frameworks.

The **default format is SKILL.md** — the agentskills.io open standard adopted by Hermes, Claude Code, Cursor, and Codex CLI. Skills are stored in this format. All other formats are targets for on-demand export.

---

## Default Format: Hermes / agentskills.io SKILL.md

Skills live at `agents/skills/<kebab-case-name>.md`.

### Frontmatter

```yaml
---
name: kebab-case-name                     # required; max 64 chars; alphanumeric, hyphen, underscore
description: |                            # required; max 1024 chars; loaded first for skill selection
  One-sentence purpose. Include domain, capabilities provided, and trigger phrases from user requests.
version: 1.0.0                            # recommended; semantic version
platforms: [linux, macos, windows]        # optional; omit if platform-agnostic
required_environment_variables:           # optional; list secrets or env vars the skill needs
  - ENV_VAR_NAME
proposed_by: agent-name                   # vault-local; agent that proposed this skill
added: YYYY-MM-DD                         # vault-local; date constructed by SkillBuildingAgent
status: draft | validated | stable        # vault-local; lifecycle stage
---
```

**Description is critical.** Agents load descriptions first to decide whether to load full skill content. A good description states: what the skill does, when to invoke it, and what distinguishes it from adjacent skills.

### Markdown Body

```markdown
Skill: Name

## When to Use

Conditions that should trigger this skill. Include positive triggers and negative constraints (when NOT to use).

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| param_name | string | yes | What this input represents and acceptable values |

## Procedure

Numbered steps. Each step should be a discrete, verifiable action.
Annotate each step with the tool, skill, or script it invokes — this is the bridge between spec and execution:

- `→ [Tool: Read, path: infernalis/_Index/MASTER_INDEX.md]`
- `→ [Tool: Grep, pattern: canonical_path, path: ledger_path]`
- `→ [Tool: Edit, target: path/to/file.md]`
- `→ [Tool: Write, path: agents/skills/new-skill.md]`
- `→ [Tool: Glob, pattern: directory/_index.md]`
- `→ [Skill: session-log-write, entry_type: pre-op-snapshot]`
- `→ [Skill: drift-check, changed_paths: [path]]`
- `→ [Script: scripts/main.ps1, args: --param value]`

1. Step one. → [Tool: Name, param: value]
2. Step two. → [Skill: skill-name, input: value]
3. ...

## Pitfalls

Known failure modes, edge cases, or common errors.

## Verification

How to confirm the skill completed correctly.

## Outputs

What the skill produces. Include types and shapes where relevant.

## Examples

Concrete worked examples with inputs and expected outputs.
```

### Scripts Subdirectory

For skills that require executable scripts, place them at `agents/skills/scripts/<skill-name>/`:

```
agents/skills/
├── my-skill.md          ← skill spec (this file)
└── scripts/
    └── my-skill/
        ├── main.ps1     ← primary entry point (PowerShell or Bash)
        ├── main.sh      ← Bash variant (if platform-agnostic)
        └── lib.ps1      ← helpers (optional)
```

Reference scripts in Procedure steps as `→ [Script: scripts/my-skill/main.ps1, args: --param value]`.

Scripts must:
- Accept the same inputs defined in the SKILL.md `## Inputs` table as named flags
- Write results to stdout; errors to stderr
- Exit 0 on success, non-zero on failure
- Be idempotent when possible

---

## Inference-Time Format: Hermes `<tools>` XML

Used when the skill is presented to a Hermes model at inference time. Constructed from the SKILL.md frontmatter and Inputs table.

```xml
<tools>
[
  {
    "name": "skill-name",
    "description": "One-sentence description from frontmatter",
    "parameters": {
      "type": "object",
      "properties": {
        "param_name": {
          "type": "string",
          "description": "Parameter description from Inputs table",
          "enum": ["value1", "value2"]
        }
      },
      "required": ["param_name"]
    }
  }
]
</tools>
```

**Call format:**
```xml
<tool_call>
{"name": "skill-name", "arguments": {"param_name": "value"}}
</tool_call>
```

**Response format:**
```xml
<tool_response>
{"tool_call_id": "call_id", "name": "skill-name", "content": "result"}
</tool_response>
```

---

## Conversion Table: SKILL.md → Target Framework

| SKILL.md field | Hermes `<tools>` | OpenAI | Anthropic | LangChain | CrewAI | AutoGen | MCP |
|---|---|---|---|---|---|---|---|
| `name` | `"name"` | `function.name` | `"name"` | `"name"` | `name` attribute | `function.name` | `"name"` |
| `description` | `"description"` | `function.description` | `"description"` | `"description"` | `description` attribute | `function.description` | `"description"` |
| Inputs → JSON Schema | `"parameters"` | `function.parameters` | `"input_schema"` | `"parameters"` | `args_schema` (Pydantic) | `function.parameters` | `"inputSchema"` |
| _(none)_ | _(no wrapper)_ | `"type": "function"` wrapper | _(no wrapper)_ | _(flexible)_ | `BaseTool` subclass | `"type": "function"` wrapper | _(no wrapper)_ |

---

## Target Format Templates

### OpenAI / AutoGen

```json
{
  "type": "function",
  "function": {
    "name": "skill-name",
    "description": "Description from frontmatter",
    "parameters": {
      "type": "object",
      "properties": {
        "param_name": {
          "type": "string",
          "description": "Parameter description"
        }
      },
      "required": ["param_name"]
    }
  }
}
```

### Anthropic (Claude API)

```json
{
  "name": "skill-name",
  "description": "Description from frontmatter",
  "input_schema": {
    "type": "object",
    "properties": {
      "param_name": {
        "type": "string",
        "description": "Parameter description"
      }
    },
    "required": ["param_name"]
  },
  "input_examples": [
    {"param_name": "example_value"}
  ]
}
```

Note: `input_schema` is the Anthropic equivalent of `parameters`. `input_examples` is optional but improves reliability — populate from the skill's `## Examples` section.

### LangChain (OpenAI-compatible dict)

```python
{
    "name": "skill-name",
    "description": "Description from frontmatter",
    "parameters": {
        "type": "object",
        "properties": {
            "param_name": {
                "type": "string",
                "description": "Parameter description"
            }
        },
        "required": ["param_name"]
    }
}
```

### LangChain (Pydantic)

```python
from pydantic import BaseModel, Field

class SkillNameInput(BaseModel):
    param_name: str = Field(..., description="Parameter description")
```

### CrewAI

```python
from crewai.tools import BaseTool
from pydantic import BaseModel, Field
from typing import Type

class SkillNameInput(BaseModel):
    param_name: str = Field(..., description="Parameter description")

class SkillNameTool(BaseTool):
    name: str = "skill-name"
    description: str = "Description from frontmatter"
    args_schema: Type[BaseModel] = SkillNameInput

    def _run(self, param_name: str) -> str:
        # Implementation from skill Procedure
        pass
```

### MCP (Model Context Protocol)

```json
{
  "name": "skill-name",
  "description": "Description from frontmatter",
  "inputSchema": {
    "type": "object",
    "properties": {
      "param_name": {
        "type": "string",
        "description": "Parameter description"
      }
    },
    "required": ["param_name"]
  }
}
```

Note: MCP uses `inputSchema` (camelCase) where other frameworks use `parameters` or `input_schema`.

---

## Decompose Procedure: SKILL.md → Any Target Format

1. Read the skill file at `agents/skills/<name>.md`.
2. Extract frontmatter: `name`, `description`.
3. Parse the `## Inputs` table into a JSON Schema object:
   - Each row → a property: `name` (key), `type`, `description`, `required` flag.
   - Collect required inputs into the `required` array.
   - If `enum` values are listed in the description, extract them into an `"enum"` field.
4. Apply the target framework mapping from the Conversion Table above.
5. Add framework-specific wrappers (e.g., `"type": "function"` for OpenAI/AutoGen).
6. For Anthropic: rename `parameters` → `input_schema`; populate `input_examples` from `## Examples`.
7. For CrewAI/LangChain (Pydantic): generate a `BaseModel` class from the JSON Schema properties.
8. For MCP: rename `parameters` → `inputSchema`.
9. Emit the target-format definition.

## Reform Procedure: Any Target Format → SKILL.md

1. Extract `name` and `description` from the source definition.
2. Extract the parameter schema (from `parameters`, `input_schema`, `inputSchema`, or Pydantic model as appropriate).
3. Construct frontmatter with `name`, `description`, `version: 1.0.0`, `status: draft`.
4. Build the `## Inputs` table from the parameter schema properties.
5. Mark `required` inputs from the `required` array.
6. Populate `## When to Use`, `## Procedure`, `## Pitfalls`, `## Verification`, `## Outputs`, `## Examples` from any available documentation, docstrings, or examples in the source. Leave sections as `_(to be filled)_` where no source exists.
7. Set `status: draft` — the body sections need human or agent review before the skill is `validated`.
8. Register in `agents/skills/_index.md`.

---

## JSON Schema Field Reference

All frameworks converge on JSON Schema for parameter definitions.

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | `"object"`, `"string"`, `"number"`, `"boolean"`, `"array"`, `"null"` |
| `properties` | object | Dictionary of parameter definitions |
| `required` | array | Parameter names that are mandatory |
| `description` | string | Explanation for the LLM — critical for decision quality |
| `enum` | array | Constrained set of allowed values — reduces hallucination |
| `items` | object | Schema for array elements |
| `minLength` / `maxLength` | number | String length constraints |
| `minimum` / `maximum` | number | Numeric range constraints |
| `pattern` | string | Regex pattern for string validation |
| `default` | any | Default value when parameter is omitted |
