# Manual Review Procedure

Phase 1 requires human sign-off on every draft before it can move toward publishing. This procedure defines what a reviewer checks, how they record a decision, and what each decision means for the ContentJob.

## Before You Start

Confirm the following before opening any draft:

- [ ] You have access to the Hermes profile directory at `~/.hermes/profiles/newshowbiz/`
- [ ] The store path `~/.hermes/profiles/newshowbiz/store/` exists and is readable
- [ ] You can start a `hermes -p newshowbiz` session, or you can read JSON files directly with `cat`
- [ ] You know the ContentJob ID you intend to review, or you are scanning the full queue

## Finding Drafts Pending Review

Drafts land in `~/.hermes/profiles/newshowbiz/store/review-queue/` as JSON files. Each file is named `{id}.json`.

To list all pending drafts:

```bash
ls ~/.hermes/profiles/newshowbiz/store/review-queue/
```

To read a specific draft:

```bash
cat ~/.hermes/profiles/newshowbiz/store/review-queue/{id}.json
```

Drafts with `status: hold` are escalation cases and must not be decided through this procedure. See section 7.

## What to Check

Work through this checklist for each draft before recording a decision:

- [ ] **Source refs present** — `source_refs` list is non-empty; every score or factual claim traces to a newshow.biz page URL
- [ ] **Character count within limit** — X posts: 280 chars max including link and hashtags.
- [ ] **Hashtag ceiling** — X: 2 max.
- [ ] **Kakusu Protocol** — No loaded advocacy terms: "subversive," "woke," "progressive," "DEI," "political activism." Representation analysis must be framed as cinematic observation, not advocacy.
- [ ] **No em dash** — Replace any em dash (—) with a comma, period, or rewrite before approving.
- [ ] **No fabricated claims** — No invented plot points, characters, scores, or statistics. Every claim must trace to a source ref.
- [ ] **CTA present** — A link or call to action is included and points to a real newshow.biz URL.
- [ ] **Risk classification correct** — The `risk_level` field matches the content. Any escalation trigger present in the content means the field should be `high` or `blocked`, not `low`.
- [ ] **No active escalation trigger** — If any of the 12 escalation triggers appear in the content (`money_terms`, `tax_investment_advice`, `partnership`, `legal`, `creator_complaint`, `invalid_analysis`, `factual_dispute`, `identity_sensitive`, `platform_policy`, `backlash`, `unsupported_claim`, `troll_threshold`), the draft should carry `status: hold` with an EscalationRecord, not sit in the review queue as a normal draft. If you find this condition, stop and follow section 7.

## Recording a Decision

Open a `hermes -p newshowbiz` session and invoke the `review-decision-record` skill. Three outcomes are available.

**Approve**

Invoke `review-decision-record` with:

- `job_id`: the draft's ID
- `decision`: `approve`
- `notes` (optional): brief note on approval, any minor edits made inline, or confirmation that all checklist items passed

Effect: ContentJob file moves from `review-queue/` to `approved/`. Status is set to `approved`. An entry is appended to `review-log.jsonl`.

**Reject**

Invoke `review-decision-record` with:

- `job_id`: the draft's ID
- `decision`: `reject`
- `notes`: explanation of the rejection reason

Effect: ContentJob file moves from `review-queue/` to `rejected/`. Status is set to `rejected`. An entry is appended to `review-log.jsonl`.

**Revise**

Invoke `review-decision-record` with:

- `job_id`: the draft's ID
- `decision`: `revise`
- `notes` (required): specific description of what must change before re-review

Effect: ContentJob stays in `review-queue/` with status `needs_revision`. The notes become the revision brief. In the same or a subsequent Hermes session, ask the agent to revise the draft according to the notes and call `content-job-write` again with a new ID. The revised draft re-enters the queue as a new file.

## Suggested Review SLA

Phase 1 recommended SLA: **24 hours** from draft creation to decision.

If a draft sits in `review-queue/` for more than 48 hours without a decision, it should be considered stale and either decided or rejected.

Why this matters: cron jobs and new sessions may attempt to draft content using the same source material. Stale unreviewed drafts create duplication risk where the same film or topic is drafted again before the original is resolved.

Check for stale drafts by comparing the `created_at` field in each ContentJob JSON against the current date.

## Escalation Drafts (HOLD status)

If a draft has `status: hold`, it contains a risk trigger flagged by SOUL.md escalation logic. Do not use `review-decision-record` on it. Instead:

1. Read the associated EscalationRecord in `~/.hermes/profiles/newshowbiz/store/escalations/`
2. Make a human judgment on the recommended action stated in the EscalationRecord
3. Update the EscalationRecord status manually or via a Hermes session
4. If approved for revision: ask the agent to revise the draft to remove the triggering content, then resubmit through the normal review queue. The revised draft should arrive in `review-queue/` as a new ContentJob with no escalation trigger present.

Drafts on HOLD must not be approved directly. The trigger must be resolved first.

## Checking the Review Log

After decisions are recorded, the audit trail is here:

```bash
cat ~/.hermes/profiles/newshowbiz/store/review-log.jsonl
```

Each line is a JSON object:

```json
{"id": "...", "decision": "...", "at": "...", "notes": "..."}
```

This log is append-only and is the canonical record of all Phase 1 review decisions. Do not edit it manually.

## Phase Gate

Phase 1 exit criterion requires at least one full week of human-reviewed drafts with documented decisions in `review-log.jsonl`. The Phase 1 exit report (see `docs/50-rollout/phase-1-exit-report.md`) should include a summary of the review log: total drafts reviewed, approval rate, rejection reasons, and any escalation cases handled.

No content moves toward live publishing until the Phase 1 exit report is complete and signed off.
