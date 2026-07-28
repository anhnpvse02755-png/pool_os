# FEATURE_012 — Equipment Comparison

> Authoritative spec v2, PO-delivered 2026-07-28.
> This version supersedes v1.0 and v1.1.
> **Change log:**
> - v1.0 (2026-07-28): Initial authoritative spec.
> - v1.1 (2026-07-28): UI Placement, Cue Selection checkbox (max 2 + FIFO), Insufficient Data threshold.
> - **v2 (2026-07-28):** Major revision. Removed max 2 / FIFO rules. Added Compare (N) button and dedicated Comparison Screen with horizontal scroll. Multi-selection, no automatic eviction. App does not decide for the user.

## Goal

Allow the player to select an arbitrary number of cues from their own
Equipment and open a dedicated Comparison Screen that renders existing
performance data side-by-side.

No AI. No prediction. No recommendation. No winner. No green/red
comparison colours. Just render what `EquipmentPerformanceProjection`
already carries.

This feature is **Equipment-domain only**. It is not a generic
Comparison Platform, reusable across Marketplace / Review / Community
Equipment. Those are out of scope.

## User Value

- Player owns multiple cues (typical: 3–5).
- Player wants to compare 2, 3, or 5 cues by their real performance.
- Player decides when to open the Comparison Screen — not the app.

## Ownership

Equipment is the feature owner. The feature **reads only**:

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

1. Only Active Player's cues may be selected.
2. Selection has **no upper bound**. The user can select 2, 3, 5, or any
   number of cues.
3. **No automatic eviction.** The app never removes a user's selection.
4. **No FIFO.** Selection order does not auto-rotate.
5. The Comparison Screen opens only when `selectedCues.length >= 2`.
   Selecting a single cue is allowed but the button is disabled.
6. Compare only these existing projection fields:
   - Match Count
   - Match Win Rate
   - Training Count
   - Training Success Rate
   - Last Used
7. No new metrics. No aggregation. Only the projection's existing
   fields.
8. No "winner" highlight. No green/red conclusion. Only numbers.
9. If a cue's data is insufficient → show:
   `Chưa đủ dữ liệu.`
10. The Comparison Screen does not mutate selection. Returning to
    Equipment Screen preserves the same selection (in-memory widget
    state, lost on rebuild — acceptable).

## UI Flow

### 1. Equipment Screen — selection surface

Each cue card exposes one `Select for Compare` checkbox. There is no
cap and no auto-eviction.

A `Compare (N)` button is shown at the top of the Equipment List:

- `Compare (2)`, `Compare (3)`, `Compare (5)` — labelled with the
  current selection count.
- The button is **hidden or disabled** when `selectedCues.length < 2`.
- Tapping the button opens the Comparison Screen via
  `Navigator.push(EquipmentComparisonScreen(...))`.

### 2. Comparison Screen — render surface

`EquipmentComparisonScreen` is a dedicated screen. It receives the
selected cues and their projections, and renders a comparison table.

Layout (single row, multiple columns):

```
| Metric       | Revo     | Ignite   | Predator | Mezz    |
|--------------|----------|----------|----------|---------|
| Win Rate     |  68%     |  64%     |   71%    |  65%    |
| Training …   |   …      |   …      |    …     |   …     |
| Matches      |  142     |   58     |   200    |   30    |
| Trainings    |   91     |   40     |   120    |   15    |
| Last Used    |  Today   |  Jul 20  |  Today   |  Never  |
```

**Scrolling:**

- Vertical: the metric rows scroll normally.
- **Horizontal**: when the number of cues exceeds the visible width
  (~3 columns on a phone), the comparison table must scroll
  horizontally so every cue column is reachable.

### 3. Insufficient data

When a cue's `totalMatches < 5` OR `totalTrainingSessions < 5` (per
FEATURE_010 threshold reuse), display the literal
`Chưa đủ dữ liệu.` in that cue's column.

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
- No persistence of selection state (selection is in-memory only)
- No GoRouter route registration (use `Navigator.push` directly)
- No cross-domain Comparison Platform / engine / framework

## Acceptance Criteria

- Each cue card exposes a `Select for Compare` checkbox.
- Selecting any cue adds it to the selection; deselecting removes it.
- No cap on selection size.
- No automatic eviction.
- The `Compare (N)` button appears only when selection ≥ 2.
- Tapping `Compare (N)` opens `EquipmentComparisonScreen` via
  `Navigator.push`.
- `EquipmentComparisonScreen` renders the metric table.
- The table supports horizontal scroll for > 3 cues.
- Only projection data is rendered; no new metrics.
- No recommendation, no winner, no green/red colouring.
- Insufficient cue shows `Chưa đủ dữ liệu.` in its column.
- Returning to Equipment Screen preserves selection (until rebuild).

## Tests

- Multi-selection: select 5 cues → all 5 stay.
- No automatic eviction.
- Compare button hidden / disabled when 0 or 1 cue selected.
- Compare button enabled when ≥ 2 cues selected.
- Compare button label shows the correct count.
- Tapping Compare pushes `EquipmentComparisonScreen`.
- Comparison Screen renders N columns for N cues.
- Horizontal scroll works when columns exceed viewport.
- Insufficient data renders `Chưa đủ dữ liệu.`
- Only projection data is used.
- No recommendation / winner / AI logic.
- `flutter analyze`
- `dart format`
- `git diff --check`

## Stop Conditions

After completion:

- Produce Engineering Report v3.
- **Do not commit.**
- **Do not push.**
- **Stop and wait for Product Owner review.**
