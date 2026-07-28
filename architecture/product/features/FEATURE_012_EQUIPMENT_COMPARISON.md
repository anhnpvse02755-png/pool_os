# FEATURE_012 — Equipment Comparison

> Authoritative spec, PO-delivered 2026-07-28.
> Persisted in-repo so home/office machines share one copy.

## Goal

Let the player compare performance of up to 2 cues from existing data.

No AI. No prediction. No recommendation. Just render what the
projection already carries.

## User Value

- How two cues differ.
- Which has higher Match Win Rate.
- Which has higher Training Success.
- Which has been used more.
- Which was used more recently.

## Ownership

Equipment is owner. The feature **reads only**:

- `EquipmentPerformanceProjection`
- Active Player

It **does not** read `Match` or `Training` directly.

## Reusable Code (mandatory reuse)

Must reuse the existing:

- Equipment Screen
- Equipment Repository
- `EquipmentPerformanceProjection`
- Equipment Performance Widget
- Active Player

## Business Rules

1. Only Active Player's cues.
2. Maximum 2 cues can be selected.
3. If only 1 is selected → hide the comparison.
4. Compare these fields:
   - Match Count
   - Match Win Rate
   - Training Count
   - Training Success Rate
   - Last Used
5. No new metrics. No aggregation. Only the projection's existing fields.
6. No "winner" highlight. No green/red conclusion. Only numbers.
7. If a cue's data is insufficient → show:
   `Chưa đủ dữ liệu.`

8. **PO amendment 2026-07-28 — Strict visibility**:
   The Comparison section only renders when **all** of the following hold:
   - Exactly 2 cues are selected.
   - Both cues belong to the Active Player.
   - Both cues are active (`isActive == true`).

   If any condition fails, **hide the entire Comparison section** —
   not just the table. This rule prevents Engineering from improvising
   partial UI in edge cases such as:
   - Only 1 cue selected.
   - 2 cues selected but one is inactive.
   - 2 cues selected but one belongs to another player (deep link,
     stale state, foreign notification).

## UI

In the Equipment Screen, add a **Comparison** section. Example:

```
               Revo    Ignite
Match Win      68%     64%
Training       72%     75%
Matches        142     58
Trainings      91      40
Last Used      Today   Jul 20
```

## Allowed Files

Only edit files under `app/lib/features/equipment/` and existing
Equipment widgets.

## Forbidden

- No new Drift table
- No new schema
- No new migration
- No new repository
- No new projection
- No new service
- No AI / Coach / Analytics / Recommendation
- No modification of `EquipmentPerformanceProjection`

## Acceptance Criteria

- Only Active Player's cues.
- Maximum 2 selections.
- Comparison table is shown.
- Only projection data used.
- No recommendation.
- No winner.
- No AI.
- Insufficient data → `Chưa đủ dữ liệu.`
- Comparison section only renders when **exactly 2 valid cues** are
  selected (valid = Active Player + `isActive == true`).
- Comparison section hides itself entirely when fewer than 2 valid
  cues are selected.

## Tests

- Active Player isolation.
- Maximum 2 selections.
- Comparison values match projection.
- Empty data path.
- Inactive cues not comparable.
- Comparison hidden with one selected cue.
- Comparison hidden with zero selected cues.
- Comparison hidden when one selected cue becomes inactive.
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