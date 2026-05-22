---
name: session-log-write
description: |
  Write or append to the session log for the current date. Use at the close of any task
  or subtask (episodic memory) and before any write operation (pre-operation snapshot for
  Phase 11 compensation). The pre-op snapshot is the enabling mechanism for rollback and
  compensation — do not skip it before writes.
version: 1.0.0
proposed_by: orchestrator
added: 2026-05-20
status: validated
---

# Skill: Session Log Write

## When to Use

- **Task close:** At the conclusion of any task or subtask (all agents, always).
- **Pre-operation snapshot:** Before any write or composite operation — record current state of files to be modified.
- **Failure and escalation:** When a task fails, is dead-lettered, or is escalated to the user.
- **Agent action:** When a significant intermediate action needs an audit trail.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| date | string | yes | `YYYY-MM-DD` |
| entry_type | string | yes | `task-close`, `pre-op-snapshot`, `failure`, `escalation`, or `agent-action` |
| task_id | string | yes | Unique task identifier from the orchestrator |
| agent_id | string | yes | Agent writing the entry |
| content | object | yes | Entry fields per `entry_type` (see formats below) |

## Procedure

1. Construct the session file path: `infernalis/_Index/sessions/YYYY-MM-DD.md`. Check if it exists. → `[Tool: Glob, pattern: infernalis/_Index/sessions/YYYY-MM-DD.md]`
2. If it does not exist: create it with the standard header. → `[Tool: Write]`
3. If it exists: read the tail to find the correct append position. → `[Tool: Read, offset: last 20 lines]`
4. Format the entry per `entry_type` (see formats below).
5. Append the formatted entry to the file. → `[Tool: Edit]`
6. Verify the append is syntactically correct. → `[Tool: Read, offset: last 15 lines]`

## Pitfalls

- Do not create a new session file if one already exists for the date — always append.
- Pre-op snapshots must include enough file content to restore the prior state; a timestamp alone is insufficient.
- Do not compress or summarize failure records — preserve the full error description.
- Pre-op snapshots must be written **before** the write operation begins, not after.

## Verification

Confirm the appended entry is complete, contains `task_id`, and includes all required fields for its `entry_type`.

## Outputs

Updated `infernalis/_Index/sessions/YYYY-MM-DD.md`.

## Entry Formats

### task-close

```markdown
## [task_id] agent_id — YYYY-MM-DD
type: task-close
status: COMPLETE | PARTIAL | FAILED
changed:
  - path/to/modified/file.md
  - path/to/another/file.md
summary: One-line description of what happened and what changed.
```

### pre-op-snapshot

```markdown
## [task_id] pre-op-snapshot — YYYY-MM-DD
type: pre-op-snapshot
idempotency_key: descriptive-key-for-this-write
target_files:
  - path: infernalis/_Index/ledgers/sources-ledger.md
    snapshot: |
      [Paste the current content of the section being modified —
       the full table row if updating a ledger, the full frontmatter
       block if updating a record, or the full file if under 30 lines]
```

### failure

```markdown
## [task_id] FAILURE — YYYY-MM-DD
type: failure
agent_id: agent-name
error: Specific error description — what was attempted, what was returned.
retry_count: N
recovery_action: retried | compensated | dead-lettered | escalated
notes: Any additional context for human review.
```

### escalation

```markdown
## [task_id] ESCALATION — YYYY-MM-DD
type: escalation
agent_id: agent-name
trigger: reversibility-final | retries-exhausted | ambiguous-input | policy-violation | cost-overrun
description: What the agent was attempting and why it cannot proceed without user input.
required_from_user: Specific question or decision needed.
```

## Examples

**Pre-op snapshot before adding to sources-ledger:**
1. Read the current bottom rows of `sources-ledger.md`
2. Write snapshot entry with `idempotency_key: add-kirby-smith-to-sources-ledger`
3. Paste the current last 5 rows of the sources table as `snapshot`
4. Proceed with `ledger-update`

**Task-close after a vault query:**
1. Write entry with `status: COMPLETE`, `changed: []` (no writes), `summary: "Located 3 Southern Agrarian sources in sources-ledger.md"`
