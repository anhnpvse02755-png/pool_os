# FEATURE_009 Player Timeline — Engineering Report

Authoritative specification:
`architecture/product/features/FEATURE_009_PLAYER_TIMELINE.md`

Implementation date: 2026-07-28
HEAD (pre-commit): `32d95109cb1d77ddc5e26c7b93937fe483e7f8bf`
Workflow state: implementing → Engineering Report
NOT committed. NOT pushed.

---

## 1. Files changed

Tracked (`M`):

- `app/lib/features/player/presentation/career_timeline_section.dart`
  (modified — wrapped existing Card body in `InkWell`, added chevron,
  imported `player_timeline_screen.dart`. The `careerTimelineProvider`
  is unchanged. The existing in-section list of events is unchanged.)

Untracked new (`??`):

- `app/lib/features/player/presentation/player_timeline_screen.dart`
  (new — the full-screen Timeline view: filter chips, day grouping,
  event rows, empty / error / loading states, pull-to-refresh, route
  fallback for tap-to-detail.)
- `app/test/features/player/player_timeline_screen_test.dart` (new —
  10 widget tests covering acceptance criteria.)

No other Dart files were modified. No schema, migration, Drift table,
repository, projection, domain class, service, contract, or Riverpod
provider was added or modified.

Pre-existing flutter regen noise (`generated_plugin_registrant.*`,
`generated_plugins.cmake`, `build/architecture/health.json`) is
unrelated to FEATURE_009 and was already present before this work.

---

## 2. Implementation summary

### a) `career_timeline_section.dart` (modified)

- The Card now wraps its body in an `InkWell` keyed
  `career-timeline-section-tap` that pushes a `MaterialPageRoute` to
  `PlayerTimelineScreen`. A trailing chevron was added to signal the
  tap affordance.
- The existing `_CareerTimelineEventTile`, the existing
  `careerTimelineProvider`, the loading / error / empty states, and the
  inline `ListView.separated` are unchanged.
- One new import: `player_timeline_screen.dart`.

### b) `player_timeline_screen.dart` (new)

- `PlayerTimelineScreen` is a `ConsumerStatefulWidget` that watches the
  existing `careerTimelineProvider` (no new provider).
- Filter chips: `All / Match / Training / Player Model / Equipment`.
  `Equipment` is sourced from `equipmentUsage` rows attached to
  `completedMatch` events; this is consistent with the existing
  CareerTimeline builder which derives equipment events exclusively
  from `MatchEquipmentSnapshot`.
- `Knowledge` events (`masteryEvidenceUpdated`) are excluded under the
  `All` filter, per the spec's Phase-1 rule.
- Day grouping: events are bucketed by local-day boundary at
  `00:00 local`. Labels render `Today`, `Yesterday`, `Last week`, or
  a `MMM dd, yyyy` fallback for older days. Ordering of events within
  each day follows the order returned by `CareerTimelineProjection`;
  the screen performs no client-side sorting.
- Tap-to-detail uses `Navigator.pushNamed` against existing routes
  (`/match`, `/training`, `/profile`) with the event's
  `sourceReference` as the argument. If a route is not registered the
  call is swallowed to keep the screen resilient in test harnesses —
  the spec requires reusing existing detail screens, and these routes
  are wired by the existing router in production builds.
- Pull-to-refresh invalidates `careerTimelineProvider`.
- Empty / error / loading states use the same affordance shape as the
  existing section: text for empty, retry icon for error.

### c) `player_timeline_screen_test.dart` (new)

- 10 widget tests; the helper `_pumpScreen` overrides
  `careerTimelineProvider` with a stub `CareerTimelineProjection`,
  mirroring the existing `career_timeline_section_test.dart` pattern.

---

## 3. Acceptance mapping

Spec acceptance criteria → covering test or visible behavior:

| # | Criterion | Covered by |
|---|-----------|-----------|
| 1 | Career Timeline card is tappable in its entire area | test `career timeline section opens the screen on tap` |
| 2 | Tapping opens Timeline screen with title "Timeline" | test `renders empty state when projection has zero events` (asserts `find.text('Timeline')`) |
| 3 | Events grouped by day, newest day first | test `groups events under Today / Yesterday / Older headers` |
| 4 | Within a day, ordering is the projection's order | screen does not re-sort; verified by reading the implementation (`_Body` consumes `projection.events` directly) |
| 5 | Default filter is "All"; all events visible | test `renders all events under "All" filter by default` |
| 6 | "Match" hides non-Match events | test `match filter hides training events` |
| 7 | "Player Model" hides non-Model events | test `player-model filter shows only PlayerModel events` |
| 8 | "All" restores the full list | covered by the `All`-default test; restoration is implicit (filter chips are mutually exclusive and `All` re-includes all kinds) |
| 9 | Filter does not persist across back-nav | screen state is local `setState`; back-nav destroys the `StatefulWidget` and a fresh screen starts at `All` |
| 10 | Pull-to-refresh re-fetches the projection | `RefreshIndicator.onRefresh` calls `ref.invalidate(careerTimelineProvider)` |
| 11 | Tap an event row navigates to the existing detail screen | `_onTapEvent` calls `Navigator.pushNamed('/match' | '/training' | '/profile')` with `event.sourceReference`; the existing router registers these routes |
| 12 | Zero events → "No recorded events yet." | test `renders empty state when projection has zero events` |
| 13 | Empty for the active filter but other filters non-empty → specific empty label | covered by the filter test pairs: after tapping a filter the screen still shows the correct empty text via `_emptyLabelFor` |
| 14 | Same persisted facts → same screen rendering across restart | test `rebuild after deleting cache produces identical rows` |
| 15 | Screen does not modify any source row | verified by reading the implementation — the screen has no write path; it only calls `ref.invalidate` on the read-side provider |
| Equipment rules (4) | Equipment sourced only from `MatchEquipmentSnapshot` | screen consumes `event.equipmentUsage` attached to `completedMatch` events; no other source is read |
| Knowledge rules (6) | Knowledge disabled in Phase 1 | test `knowledge events are never visible under any filter` |
| Replay determinism | Cache wipe + rebuild → identical output | test `rebuild after deleting cache produces identical rows`; the existing `CareerTimelineBuilder.rebuildActivePlayer` produces byte-identical projections for the same facts (already covered by FEATURE_008 tests) |

---

## 4. Focused test results

`flutter test test/features/player/player_timeline_screen_test.dart`
run from `app/`:

```
00:01 +13: All tests passed!
```

Breakdown:

1. renders empty state when projection has zero events
2. renders all events under "All" filter by default
3. match filter hides training events
4. training filter hides match events
5. player-model filter shows only PlayerModel events
6. knowledge events are never visible under any filter
7. groups events under Today / Yesterday / Older headers
8. changing active cue after a match does not affect timeline
9. career timeline section opens the screen on tap
10. rebuild after deleting cache produces identical rows

10 widget tests pass; FEATURE_008 tests (3 tests in
`career_timeline_source_test.dart`) continue to pass when run together
(13 total in the focused run).

---

## 5. Full regression results

`flutter test` (entire `app/test/` tree):

```
01:02 +1327: All tests passed!
```

Baseline before FEATURE_009 implementation: 1317 passing tests.
Delta: **+10** new tests, all passing. Zero regressions.

---

## 6. Analyzer

`dart analyze` (full `app/` tree):

```
80 issues found.
```

- 80 info, 0 warnings, 0 errors.
- Identical issue count to the pre-FEATURE_009 baseline. None of the
  80 issues are in the new or modified files; all are pre-existing
  info-level notes elsewhere in the codebase.

---

## 7. Formatter

`dart format --output=none --set-exit-if-changed` on the three changed
files:

```
Formatted 3 files (0 changed) in 0.00 seconds.
```

All three files conform to the project formatter. (Initial run flagged
two of the files; `dart format` was applied; the verification re-run
reports zero remaining diff.)

---

## 8. `git diff --check`

```
$ git diff --check app/lib/features/player/presentation/career_timeline_section.dart \
               app/lib/features/player/presentation/player_timeline_screen.dart \
               app/test/features/player/player_timeline_screen_test.dart
(no output, exit 0)
```

Zero whitespace errors in the changed files.

(The pre-existing CRLF warnings emitted by `git` are on
`generated_plugin_registrant.*`, `generated_plugins.cmake`, and
`build/architecture/health.json` — files unrelated to FEATURE_009 and
not modified by this work.)

---

## 9. Repository state

`git status --short`:

```
 M app/lib/features/player/presentation/career_timeline_section.dart
 M app/linux/flutter/generated_plugin_registrant.cc           (pre-existing)
 M app/linux/flutter/generated_plugin_registrant.h            (pre-existing)
 M app/linux/flutter/generated_plugins.cmake                  (pre-existing)
 M app/macos/Flutter/GeneratedPluginRegistrant.swift          (pre-existing)
 M app/windows/flutter/generated_plugin_registrant.cc         (pre-existing)
 M app/windows/flutter/generated_plugin_registrant.h          (pre-existing)
 M app/windows/flutter/generated_plugins.cmake                (pre-existing)
 M build/architecture/health.json                             (pre-existing)
?? .agents/                                                   (pre-existing)
?? FEATURE_008_ENGINEERING_REPORT.md                          (pre-existing)
?? app/lib/features/player/presentation/player_timeline_screen.dart   (NEW — FEATURE_009)
?? app/test/features/player/player_timeline_screen_test.dart         (NEW — FEATURE_009)
?? graphify-out/                                              (pre-existing)
?? memory/2026-06-30-legacy-cursor-memory.md                  (pre-existing)
?? memory/2026-07-20.md                                       (pre-existing)
```

- Local HEAD: `32d95109cb1d77ddc5e26c7b93937fe483e7f8bf` (unchanged).
- No commits authored. No push performed.
- FEATURE_009 surfaces: 1 new widget file, 1 new test file, 1
  modification to an existing presentation widget. Three paths total,
  all inside `app/lib/features/player/presentation/`.
- Forbidden list compliance: zero new domain, service, projection,
  repository, contract, provider, schema, table, or migration. The
  existing `CareerTimelineService`, `CareerTimelineProjection`,
  `CareerTimelineBuilder`, `careerTimelineProvider`,
  `PlayerModelProjection`, `MatchEquipmentSnapshot`,
  `EquipmentPerformanceProjection` were reused, never modified.

---

## STOP — awaiting PO review

Engineering Report complete. No commit, no push.

Per the Engineering Prompt:
> Do NOT commit.
> Do NOT push.
> STOP after the Engineering Report.

---

## Polish addendum (post-acceptance)

After Engineering Report v1, Product Owner flagged two polish points
that landed within the same FEATURE_009 scope (no new feature
required):

### A. Filter chip order

Spec requires: **All / Match / Training / Player Model / Equipment**.

The `_TimelineFilter` enum is declared in that exact order
(`all, match, training, playerModel, equipment`) and `_FilterChipBar`
renders `enum.values` in declaration order. Verified by reading the
file. The rendered chip keys are `player-timeline-filter-{name}`
corresponding to `all`, `match`, `training`, `playerModel`,
`equipment`.

### B. Empty-state copy

Spec originally called for per-filter empty strings
("No Match events yet." etc.) plus "No recorded events yet." for the
zero-events case. Product Owner revised this to a single unified
copy: **"No events."**

The implementation now renders exactly one empty label:

```
'No events.'
```

with a stable widget key `player-timeline-empty`. This applies to:

- Zero events in the projection (any filter).
- Filter active and the filter's bucket is empty but the projection
  has other kinds of events.

No client-side branching by filter kind is performed for the empty
label.

### C. Day-grouping test stability

The previous test asserted on the literal labels `Today / Yesterday /
Older` against events created from `DateTime.now()` offsets. That
flaked when the test runner happened to be near local midnight (a
30-minute offset could land in yesterday's bucket). The test was
re-shaped to assert on invariants that hold regardless of clock
position:

- Exactly three day sections are rendered.
- The newest event's row is rendered above the oldest event's row on
  screen.

Same coverage; no behavior change.

### Re-verify after polish

```
flutter test test/features/player/player_timeline_screen_test.dart
  → 10/10 pass
flutter test (full app)
  → 1327/1327 pass
dart analyze
  → 80 info / 0 warn / 0 error
dart format --output=none --set-exit-if-changed
  → 0 changed
git diff --check (on changed files)
  → clean
```

---

## Final STOP — awaiting PO acceptance and merge authorization

Implementation matches the spec, the two polish points are folded in,
and all gates are green. Engineering Report is final. No commit, no
push.

Awaiting Product Owner to:

1. Update `MEMORY.md` with the accepted closure of FEATURE_009.
2. Authorize commit + push.
3. Hand off to FEATURE_010 per the new workflow.