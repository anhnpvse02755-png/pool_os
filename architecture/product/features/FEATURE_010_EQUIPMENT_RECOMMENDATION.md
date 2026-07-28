# FEATURE_010 — Equipment Recommendation

> Authoritative spec, PO-delivered 2026-07-28.
> This file is the in-repo authoritative spec for FEATURE_010.

## Goal

Recommend which cue a player should use today, based on real historical
performance in matches and training.

No AI. No prediction. No Machine Learning.

## User Value

A player owns multiple cues. The app helps answer:

- Which cue should I use today?
- Which cue has the highest win rate?
- Which cue is most effective in training?
- Which cue has not been used for a while?

## Ownership

Equipment is the owner. The feature **reads only**:

- `EquipmentPerformanceProjection`
- `PlayerModelProjection`
- Active Player

It **does not** read `Match` or `Training` tables directly.

## Reusable Code (mandatory reuse)

Must reuse the existing:

- `EquipmentPerformanceProjection`
- `EquipmentRepository`
- `EquipmentPerformanceCalculator`
- Equipment Performance UI
- Active Player wiring

Must **not** create:

- Recommendation engine
- AI / Coach / Analytics logic
- New repository
- New projection
- Business rules

## Business Rules

1. Only consider cues that belong to the Active Player.
2. Exclude inactive cues.
3. Sort by:
   - Match Win Rate
   - Training Success Rate
   - Last Used (more recent first)
4. If data is insufficient (e.g. fewer than 5 matches AND fewer than 5
   training sessions), show:
   > "Chưa đủ dữ liệu để khuyến nghị."
5. Do **not** infer. No "this cue fits your psychology", "today your
   form is low", "you should switch tip". The feature only presents
   raw data.
6. Show at most Top 3 cues.
7. Ties are broken deterministically by `Equipment.ID` ascending order.

## UI

Inside the Equipment Screen, add a **Recommended Equipment** section
displaying:

```
#1 Revo
Match Win Rate      68%
Training Success    72%
Last Used           Yesterday
Recommended         ⭐
```

Top 3, ordered by the rules above.

## Allowed Files

Only edit files under `app/lib/features/equipment/` and any existing
Equipment widget in that subtree.

## Forbidden

Must not:

- add schema
- add Drift table
- add migration
- add repository
- add projection
- add new service
- add AI / Coach / Analytics / Ranking
- modify `EquipmentPerformanceProjection`

## Acceptance Criteria

- User opens Equipment.
- If data is sufficient: see Top 3 Recommended Equipment.
- If data is insufficient: see "Chưa đủ dữ liệu để khuyến nghị."
- Switch Active Player → the recommendation list updates accordingly.
  Other players' data never leaks.
- Order is always deterministic.
- Top 3 are shown in the spec-defined order, no more, no less.

## Tests

- Cue belongs to the correct Active Player.
- Inactive cues are not shown.
- Top 3 ordering is correct.
- Tie-break is by Equipment ID.
- Insufficient data shows the message.
- Switching Active Player updates the list.
- Full app regression passes.
- `git diff --check` is clean.

## Stop Conditions

After completion:

- Produce Engineering Report.
- **Do not commit.**
- **Do not push.**
- **Stop and wait for Product Owner review.**