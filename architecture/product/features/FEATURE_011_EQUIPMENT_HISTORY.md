# FEATURE_011 — Equipment History

> Authoritative spec, PO-delivered 2026-07-28.
> PO amendment 2026-07-28: Rule 4 narrows to "Match" + "Training" only.
> No `Equipment Change` event type. No `CareerTimelineEventType` change.
> No projection change. No enum extension. No mapping to
> `masteryEvidenceUpdated`. History renders only the events that the
> existing projection already carries as `completedMatch` /
> `completedTraining`.

## Goal

Let the player see the full history of each cue's use.

No AI. No new stats. No recommendation. No Coach. Just render
existing history data.

## User Value

- When the cue was used.
- Which match it was used in.
- Which training session it was used in.
- Last-used time.

## Ownership

Equipment is owner. The feature **reads only**:

- `EquipmentPerformanceProjection`
- `CareerTimelineProjection`
- Active Player

It **does not** read `Match` or `Training` directly.

## Reusable Code (mandatory reuse)

Must reuse the existing:

- Equipment Screen
- Equipment Repository
- `EquipmentPerformanceProjection`
- Existing Timeline Widgets
- Existing Timeline Navigation
- Active Player

## Business Rules

1. Show only Active Player's data.
2. Show only events that belong to the cue currently being viewed.
3. Newest → Oldest.
4. Show only these event types:
   - `completedMatch` (rendered as "Match")
   - `completedTraining` (rendered as "Training")

   Exclude:
   - `playerCreated`
   - `playerModelSnapshot`
   - `masteryEvidenceUpdated`

   No `Equipment Change` event (per PO amendment 2026-07-28).
5. Empty state: literal `Chưa có lịch sử sử dụng.`
6. No new stats. No computation. No recommendation. No ranking.
   Just render the existing Timeline.

## UI

In the Equipment Detail (rendered from `EquipmentScreen`), add a
section titled **History** showing day-grouped rows:

```
Today
  • Match
  • Training
Yesterday
  • Match
Jul 12
  • Match
```

Tapping a row navigates to the **existing** detail screen for that
event (e.g. `MatchDetailScreen`). **No new detail screens.**

## Allowed Files

Only edit files under `app/lib/features/equipment/` and existing
timeline widgets.

## Forbidden

- No new Drift table
- No new schema
- No new migration
- No new repository
- No new projection
- No new service
- No AI / Coach / Analytics / Recommendation Engine
- No modification of `CareerTimelineProjection`

## Acceptance Criteria

- Equipment Detail has a History section.
- Only events for the cue currently being viewed are shown.
- Only Active Player's events are shown.
- Order is always Newest → Oldest.
- Tap opens the existing detail screen.
- Empty case renders literal `Chưa có lịch sử sử dụng.`
- No other player's data leaks.
- No recommendation content.
- No new stats.

## Tests

- Active Player isolation.
- Equipment filter.
- Timeline order.
- Empty state.
- Navigation.
- No foreign-player data.
- No recommendation content.
- Full regression.
- `flutter analyze`
- `dart format`
- `git diff --check`

## Stop Conditions

After completion:

- Produce Engineering Report.
- **Do not commit.**
- **Do not push.**
- **Stop and wait for Product Owner review.**