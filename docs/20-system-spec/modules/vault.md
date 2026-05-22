---
title: Vault Module
record_type: module-spec
status: canonical
canonical_path: modules/vault/README.md
updated: 2026-05-21
---

# Vault Module

> **Implementation status:** this package preserves the vault module design contract only. The future implementation should provide Hermes tools or service adapters for source reads, record writes, ledgers, and drift checks.  
> This file is the design specification, not runnable code.

Web research, movie data extraction, source records, and knowledge persistence for the New Showbiz operator. This module is the factual substrate marketing agents draw from.

## Purpose

- Extract structured data from newshow.biz movie pages (scores, categories, watch providers, analysis)
- Capture external sources (press, reviews, production notes, interviews)
- Maintain source records and ledgers so claims have traceable evidence
- Provide research memos to ContentAgent before content creation

## Hermes Integration

The vault module runs as toolsets and skills on the `new-showbiz` Hermes profile.

**Toolsets (read-only by default):**
- `newshowbiz_read` â€” movie catalog, score data, site pages, trend reads
- `newshowbiz_browser_read` â€” Playwright page inspection and fallback browser reads

**Skills (from `agents/skills/`):**
- [`vault-query-routing`](../../agents/skills/vault-query-routing.md) â€” route queries through the store index before opening records
- [`session-log-write`](../../agents/skills/session-log-write.md) â€” append task and snapshot entries to session logs
- [`record-create`](../../agents/skills/record-create.md) â€” create canonical source records from template with schema validation
- [`ledger-update`](../../agents/skills/ledger-update.md) â€” add or update entries in canonical ledgers
- [`drift-check`](../../agents/skills/drift-check.md) â€” verify control surface consistency after write operations

## Agent Roster (Vault-Oriented)

These agents in the marketing system perform vault-oriented work as part of their pipelines:

- [FetchAgent](../../agents/roster/fetch-agent.md) â€” fetches product data from newshow.biz and approved sources
- [MovieResearchAgent](../../agents/roster/movie-research-agent.md) â€” researches film context, cast, reception before content creation
- [ValidateAgent](../../agents/roster/validate-agent.md) â€” external access preflight before any fetch operation
- [TransformAgent](../../agents/roster/transform-agent.md) â€” normalizes fetched data into structured content briefs
- [QueryAgent](../../agents/roster/query-agent.md) â€” queries source records and ContentJob history

**Archived vault agents** from the prior Sandbatch system are preserved in `agents/roster/archive/` for framework portability. They are not active in the New Showbiz operator but can be adapted:
- `ingest-agent` â€” source record formalization
- `concept-agent` â€” concept promotion
- `librarian-agent` â€” organizational completeness
- `historian` â€” structural historical analysis
- `research-page` â€” archival retrieval

## Pipelines

### Movie data extraction
`Orchestrator -> FetchAgent -> TransformAgent -> [ContentJob source object] -> ContentAgent`  
Use when pulling structured data from a newshow.biz movie page to populate a ContentJob.

### External source ingest
`Interrogator -> Orchestrator -> ValidateAgent -> FetchAgent -> TransformAgent -> ReportAgent`  
Use when capturing an article, press piece, or interview as research evidence.

### Knowledge query
`Interrogator -> Orchestrator -> QueryAgent -> ReportAgent`  
Use when retrieving facts, evidence, or prior research from the source store.

### Structural maintenance
`Interrogator -> Orchestrator -> LintAgent / DiffAgent -> ReportAgent`  
Use for audits, drift repair, and index alignment.

## Store Structure

```
store/
  vault/
    sources/        â€” source records (articles, pages, interviews)
    sessions/       â€” daily session logs
    ledgers/        â€” index ledgers by record type
    _index.md       â€” vault root index
```

## Data Contracts

Each source record requires:
- `title` â€” human-readable name
- `record_type` â€” source, movie-data, research-memo
- `source_type` â€” web-article, movie-page, press-release, interview
- `status` â€” raw, processed, archived
- `url` â€” canonical source URL
- `added` â€” date captured
- `part_of` â€” campaign or research project reference

ContentAgent receives research memos from MovieResearchAgent as structured objects, not raw file reads. The memo includes representational facts, confidence ratings, and content angle recommendations.

## Phase

Vault toolsets are available from Phase 1. Movie data extraction is required before ContentAgent can generate evidence-backed posts. The vault module underpins every content creation pipeline run.

## Phase 2 Dependencies

Full vault capability requires:
- Source data read tools for newshow.biz (movie detail, scores, categories, watch providers)
- Catalog and search URL helper tools
- Playwright browser fallback (`newshowbiz_browser_read`) for page-state inspection

