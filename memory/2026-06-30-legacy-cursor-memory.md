# Legacy Cursor Memory Import

Imported: 2026-07-20

## Provenance

- Original path: `.cursorrules`
- Git commit: `83cf2e405c1518b298aadbc365adeaa985bf1ef5`
- Original memory date: 2026-06-30
- Original length: 708 lines
- Related historical context: `.cursor/rules/project-context.mdc` at the same commit

This file preserves the durable history from the old Cursor memory. It is a
historical snapshot, not the current source of truth. Current specifications,
locked development rules, code, and newer RFCs take precedence.

## User and workflow preferences

- Prefer Vietnamese unless another language is requested.
- Keep explanations concise and direct.
- Run the linter/analyzer before commit.
- Use clear commit messages.
- Record important decisions, encountered problems, resolutions, and task progress.

## Stale context that must not be reused

The original memory described Pool OS as Node.js, React, and Android/Kotlin.
That context is obsolete. The current app is Flutter/Dart with Riverpod,
GoRouter, and Drift/SQLite.

## Historical implementation status as of 2026-06-30

Completed:

- Foundation architecture, RFC-001 domain model, database migration, and Clean Architecture
- EN/VI localization
- Event system
- RFC-002 Skill Engine core implementation
- P0-01 `Session.location`
- P0-02 division-by-zero handling in statistics
- P0-04 event-driven Statistics Engine refactor
- P0-05 Skill Engine analyzer cleanup
- Debug APK build

Outstanding P0 at that time:

- P0-03 Match Selection: complete `selectMatch()` without a TODO fallback

Historical P1 backlog:

- Dynamic light/dark/system theme
- JSON-driven event types
- Event-based statistics enhancement
- Dashboard consuming Skill objects only
- Coach reading Skills, Metrics, and Trends rather than raw session data

Historical P2 backlog:

- Training Program
- Achievements
- Career Timeline and Journal
- Knowledge Base
- Cloud Sync and export
- Advanced analytics

These statuses are not assumed to be current. Verify against the active branch,
the roadmap, UAT reports, and implementation code before acting.

## Durable architecture model

Historical product flow:

`Player -> Equipment -> Session -> Match -> Rack -> Shot -> Events -> Metrics -> Skills -> Statistics -> Coach -> Training -> Dashboard -> Career`

Golden definitions:

- Events: what happened
- Metrics: how often
- Skills: how good
- Coach: what to improve
- Training: how to improve
- Dashboard: current ability
- Career: long-term growth

Current implementation must still be checked against the locked architecture:

`Presentation -> Riverpod Provider -> Repository -> Domain -> Drift -> Database`

## Imported RFC memory

### RFC-010 Coach Intelligence

- Coach recommendations must come from real data.
- Coach reads Statistics rather than raw Session data.
- Every recommendation contains Observation, Evidence, Recommendation, and Expected Improvement.
- Insufficient data must produce an explicit insufficient-data result, never invented advice.

### RFC-011 Session data collection

- Data hierarchy: Player -> Session -> Match -> Rack -> optional Shot -> Event.
- End-of-rack input should remain short and measurable.
- Saving a session must produce summary/statistics/coach outputs according to the active specification.

### RFC-012 Statistics Engine

- Statistics support overall, break, potting, position, safety, cue-ball,
  mental, equipment, trend, training, session, match, rack, player, and dashboard views.
- Every statistic should expose current value, trend, target, and history.
- Statistics must update from persisted domain events rather than fake values.

### RFC-013 Coach Rule Library

- Rule priority: health, readiness, mental, skill weakness, training, equipment.
- Recommendations must be repeatable and explainable from Statistics.

### RFC-014 Training Drill Library

- Coach recommends concrete drills with measurable goals, not only a skill name.
- Drill selection maps to player data, difficulty, readiness, and expected improvement.

### RFC-015 Coach Recommendation Engine

- Pipeline: Readiness -> Statistics -> Rule Engine -> Skill Priority -> Drill Selection -> Schedule -> Coach Message.
- Training duration and pressure work depend on readiness and confidence.
- Avoid random drills and excessive repetition.

### RFC-016 Dashboard and KPI

- Dashboard is action-oriented, not a raw statistics page.
- It answers current readiness, recommended training, trend, weakness, and next action.
- No fake statistics; empty states must lead to a real next step.

### RFC-017 Complete workflows

- Every screen must provide a valid next action.
- Destructive actions require confirmation.
- Completed workflows refresh affected statistics, coach state, and dashboard state.
- Loading, empty, and error states are required.

### RFC-018 UI screens

- Fixed screen responsibilities, consistent navigation, validation, search, and localization.
- User-facing text supports Vietnamese; avoid hardcoded English.

### RFC-019 Business logic

- Session, Match, and Rack lifecycles govern when statistics and coach outputs update.
- Save/delete/edit operations trigger all required recalculations.
- Event records belong to the recording hierarchy and must not exist independently.
- Offline behavior must prevent data loss.

## Related handoff

`RFC-301-HANDOFF.md` was later added at commit
`156455fff0f51f974a408ed060f7632f91790e85`. It records a historical Recording
Pipeline diagnosis involving missing IDs, orphan rows, non-atomic persistence,
and a proposed schema migration. Treat it as handoff evidence; verify the active
branch before assuming those defects or proposed changes still apply.

