# Persona Registry

PersonaRegistry maps the 7 internal personas to their Hermes configuration key, primary agent pipeline, authorized toolsets, and phase gate. The public brand remains singular — `New Showbiz` — but these personas govern how tasks are framed and routed internally. A persona is not a separate account or long-lived agent; it is a prompt overlay and routing label that shapes which agents handle a task, which toolsets are exposed, and which behavior modes are permitted. The Session Director (SOUL.md / Tier 0) selects the appropriate persona overlay at task intake and passes it downstream through the agent pipeline.

## Registry Table

| Persona | Config Key | Primary Task Types | Agent Pipeline | Toolsets | Phase Gate |
|---|---|---|---|---|---|
| Brand Director | `brand-director` | `review_writing`, `validate`, `edit` | validate-agent → editor → report-agent | `newshowbiz_read` | Phase 1 |
| Audience Researcher | `audience-researcher` | `research`, `film_research`, `fetch` | fetch-agent → movie-research-agent → report-agent | `newshowbiz_read`, `newshowbiz_metrics_read` | Phase 1 |
| Product Explainer | `product-explainer` | `write`, `general_writing`, `compose` | content-agent → writer → report-agent | `newshowbiz_read` | Phase 1 |
| X Editor | `x-editor` | `generate_content`, `social_post`, `publish` | content-agent → validate-agent → publish-agent → report-agent | `newshowbiz_read`, `newshowbiz_publish_x` | Phase 1 |
| Instagram Editor | `instagram-editor` | `generate_content`, `social_post`, `design` | content-agent → validate-agent → publish-agent → report-agent | `newshowbiz_read`, `newshowbiz_publish_instagram` | Phase 2 |
| Provocateur | `provocateur` | `generate_content`, `social_post` | content-agent → validate-agent → escalation-agent → publish-agent → report-agent | `newshowbiz_read`, `newshowbiz_publish_x`, `newshowbiz_escalation` | Phase 5 |
| Growth Analyst | `growth-analyst` | `metrics`, `performance`, `analytics`, `report` | metrics-agent → analysis-agent → report-agent | `newshowbiz_metrics_read`, `newshowbiz_reporting` | Phase 1 |

## Routing Logic

The Session Director (Tier 0, SOUL.md) selects a persona overlay by evaluating two inputs: the task type and the content classification. Task type (e.g., `generate_content`, `research`, `metrics`) determines which agent pipeline handles the work. Content classification (e.g., channel target, risk class, behavior mode) determines which persona overlay is applied to that pipeline. Once the persona is selected, its configuration key is passed as a prompt overlay to the Tier 1 pipeline agent, which constrains available toolsets, enforces behavior-mode restrictions, and applies the persona's allowed/blocked rules before any output leaves the system. A persona does not replace the agent — it scopes the agent's frame of reference and tool exposure for that task.

## Phase Gate Notes

| Phase | Personas Active | Notes |
|---|---|---|
| Phase 1 | brand-director, audience-researcher, product-explainer, x-editor, growth-analyst | Core drafting and research personas. X write tools gated behind `newshowbiz_publish_x`; manual review required. |
| Phase 2 | + instagram-editor | Instagram read integrations and toolset live; instagram-editor overlay becomes usable for caption and carousel drafting. |
| Phase 3 | (all Phase 1–2 personas, write tools enabled) | `newshowbiz_publish_x` and `newshowbiz_publish_instagram` become write-capable with receipts and policy checks. |
| Phase 4 | (all Phase 1–3 personas, autonomous publishing enabled) | Low-risk and approved medium-risk content can publish autonomously. Escalation notifications active. |
| Phase 5 | + provocateur | TROLL mode and DEBATE mode enabled on X. Incident counters, automatic suspension thresholds, and EscalationAgent review required before any provocateur output is published. |
| Phase 6 | (all personas, governance hardening) | Tool scope audit, MCP filter review, experiment library expansion. All personas remain active under tightened governance cadence. |
