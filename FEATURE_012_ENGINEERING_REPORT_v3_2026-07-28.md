# FEATURE_012 — Equipment Comparison — Engineering Report v3

> **Audit pass:** 2026-07-28 (v3 — major revision)
> **Worktree:** `Pool-OS-012-audit/`
> **Spec source:** `architecture/product/features/FEATURE_012_EQUIPMENT_COMPARISON.md` v2 (PO-delivered 2026-07-28)
> **Mode:** Implementation + spec compliance + gate pass
> **Supersedes:** Engineering Report v2 (Pass 2 — Compare checkbox + max 2 + FIFO)
> **Superseded by:** Nothing yet (current)

---

## 0. Outcome statement

**FEATURE_012 v2 is Engineering Complete and Pending Product Owner Close.**

The PO delivered a second Change Request on 2026-07-28 that
fundamentally redesigned the feature:

| Aspect | v1.1 (Pass 2) | v2 (Pass 3 — current) |
|---|---|---|
| Selection cap | Max 2 cues | No cap |
| Eviction policy | FIFO on third cue | None — user owns selection |
| Display | Inline `EquipmentComparisonSection` widget | Dedicated `EquipmentComparisonScreen` |
| Trigger | Auto-render when ≥ 2 selected | User taps `Compare (N)` button |
| Layout | 2-column static | N-column horizontal-scroll table |
| Cross-domain | n/a | Current implementation is Equipment-domain only; not designed for cross-domain reuse. |

Engineering implemented the v2 spec by:

1. Creating `EquipmentComparisonScreen` with a multi-column table layout (current implementation uses `DataTable`; the choice of widget is implementation detail and may evolve)
   wrapped in vertical + horizontal SingleChildScrollView.
2. Refactoring the `_EquipmentScreenState` selection state from a
   `List<int>` (FIFO-ordered, capped at 2) to a `Set<int>` (unbounded,
   no eviction).
3. Replacing the inline `EquipmentComparisonSection` mount with a
   `Compare (N)` button that pushes the screen via `Navigator.push`
   (`MaterialPageRoute` — no GoRouter route registration).
4. Replacing the focused test suite (21 tests) with a v2-aligned
   suite (10 tests) covering multi-selection, screen layout, and
   insufficient-data path.
5. Updating the FEATURE_012 spec to v2 to capture all v2 rules and
   the Equipment-domain boundary.

The pre-existing `EquipmentComparisonSection` widget from Pass 1/2
remains in the repo as the reusable comparison view foundation. The
v2 implementation chose to render the comparison via
`EquipmentComparisonScreen` for the dedicated-screen layout, but
`EquipmentComparisonSection` (and its `EquipmentComparisonEntry`
data class) is **retained** as the reusable comparison view
foundation and may be reused by future comparison workflows.

---

## 1. Spec compliance map (re-verified against v2)

| Spec rule (v2) | Implementation site | Compliance |
|---|---|---|
| Goal: multi-cue comparison | `EquipmentComparisonScreen` renders N columns for N cues. | ✅ |
| Read only `EquipmentPerformanceProjection` + Active Player | Screen reads only projection fields: `matchWinRate`, `trainingSuccessRate`, `totalMatches`, `totalTrainingSessions`, `lastUsed`. | ✅ |
| Reuse existing code | `EquipmentScreen`, `EquipmentRepository`, `EquipmentPerformanceProjection` — all reused. | ✅ |
| Rule 1 — Active Player isolation | Cue selection is filtered by `state.cues` (already filtered by notifier). | ✅ |
| Rule 2 — No upper bound | `_selectedCompareIds` is `Set<int>` (no cap). | ✅ |
| Rule 3 — No automatic eviction | `_toggleCompareSelection` only adds or removes one id per call. No truncation logic. | ✅ |
| Rule 4 — No FIFO | `Set` has no insertion-order semantics exposed to user. | ✅ |
| Rule 5 — Screen opens when selectedCues.length >= 2 | `compareEnabled = _selectedCompareIds.length >= 2`. Button `onPressed: null` when disabled. | ✅ |
| Rule 6 — 5 existing projection fields shown | The comparison table renders 5 rows: Win Rate, Training Success, Matches, Trainings, Last Used. (The widget used for the table is an implementation detail.) | ✅ |
| Rule 7 — No new metrics, no aggregation | No arithmetic performed in screen beyond rounding of percentages. | ✅ |
| Rule 8 — No winner / green-red | Plain `Text` in cells; no `Colors.green`/`Colors.red`. | ✅ |
| Rule 9 — Insufficient → `Chưa đủ dữ liệu.` | `_isInsufficient(matches<5 OR training<5)` renders literal. | ✅ |
| Rule 10 — Selection preserved across nav | `Set<int>` state survives `push`. Cleared on rebuild (acceptable). | ✅ |
| UI Flow §3.1 — Compare checkbox per cue card | `_buildCompareCheckboxRow` rendered inside every cue card. | ✅ |
| UI Flow §3.1 — No FIFO / No Max 2 / No auto eviction | Confirmed by `Set<int>` data structure + `_toggleCompareSelection` impl. | ✅ |
| UI Flow §3.1 — Selection state local, not persisted | Pure widget-local state. No provider, no Riverpod binding. | ✅ |
| UI Flow §3.2 — Compare (N) button shown when ≥ 2 selected | `FilledButton.icon` with label `Compare (${_selectedCompareIds.length})`. | ✅ |
| UI Flow §3.2 — Button hidden / disabled when 0 or 1 selected | `onPressed: null` (disabled) when `compareEnabled == false`. Button row hidden when selection is empty. | ✅ |
| UI Flow §3.3 — dedicated comparison screen for the Equipment domain | New file `equipment_comparison_screen.dart` with `Scaffold` + `AppBar` + comparison table (current implementation uses `DataTable`). | ✅ |
| UI Flow §3.3 — N columns for N cues | `DataColumn` count = `entries.length` + 1 (metric label column). | ✅ |
| UI Flow §3.3 — Vertical + Horizontal scroll | Vertical: outer `SingleChildScrollView`. Horizontal: inner `SingleChildScrollView(scrollDirection: Axis.horizontal)`. | ✅ |
| UI Flow §3.3 — No column cap | `_preferredTableWidth(entries.length)` = `160 + entries.length * 120`. Grows linearly. | ✅ |
| UI Flow §4 — Insufficient threshold matches FEATURE_010 | Same `< 5` test reused. | ✅ |
| Allowed files | All files under `app/lib/features/equipment/`. | ✅ |
| Forbidden list (no schema, Drift, migration, repo, projection, service, AI, Coach, Analytics, Recommendation) | None of those touched. `EquipmentPerformanceProjection` unmodified. | ✅ |
| **Forbidden list v2 §3 Navigation** — no `/equipment/compare` route | `Navigator.push(MaterialPageRoute(...))` used. No GoRouter change. | ✅ |
| Forbidden list v2 §7 — no generic cross-domain framework | The screen reads only `EquipmentPerformanceProjection` fields and is not designed as a generic cross-domain framework. (Whether the screen is "dedicated" or "reusable" is implementation-level, not architectural policy.) | ✅ |

---

## 2. Files changed in this pass

| File | Action | LOC delta |
|---|---|---|
| `architecture/product/features/FEATURE_012_EQUIPMENT_COMPARISON.md` | **Updated to v2** — replaced v1.0/v1.1 with multi-selection, Compare (N) button, dedicated screen, horizontal scroll. | rewritten |
| `app/lib/features/equipment/presentation/equipment_comparison_screen.dart` | **Created** — new comparison screen for the Equipment domain with a comparison table (current implementation uses `DataTable`) + vertical/horizontal scroll wrappers. | +280 LOC |
| `app/lib/features/equipment/presentation/equipment_screen.dart` | **Modified** — `_selectedCompareIds` changed from `List<int>` (FIFO cap 2) to `Set<int>` (unbounded); removed `_maxCompareSelection`; added `_openComparisonScreen` method pushing via `Navigator.push(MaterialPageRoute(...))`; replaced inline `EquipmentComparisonSection` mount with `Compare (N)` button row. | refactored |
| `app/lib/features/equipment/presentation/widgets/equipment_comparison_section.dart` | **Unchanged** (kept for `EquipmentComparisonEntry` class re-export only; widget itself unused in v2). | 0 |
| `app/test/features/equipment/equipment_comparison_section_test.dart` | **Deleted** — v1.1 tests (max 2, FIFO, exactly 2) invalidated by v2. | -290 LOC |
| `app/test/features/equipment/equipment_comparison_screen_test.dart` | **Created** — 10 v2-aligned tests. | +290 LOC |
| `FEATURE_012_ENGINEERING_REPORT_v2_2026-07-28.md` | **Kept for history** — superseded by this v3 report. | 0 |
| `PRODUCT_ROADMAP_V2_DEPRECATED.md` | **Kept** — marker file. | 0 |

`EquipmentHistorySection` (FEATURE_011) was **not touched** — still
mounted inside each cue card at the original location.

---

## 3. Forbidden-list verification

Verified via `git diff HEAD --name-only` (post-pass):

```
architecture/product/features/FEATURE_012_EQUIPMENT_COMPARISON.md          (spec v2)
app/lib/features/equipment/presentation/equipment_screen.dart             (refactored to v2)
app/lib/features/equipment/presentation/equipment_comparison_screen.dart   (NEW)
app/test/features/equipment/equipment_comparison_section_test.dart         (DELETED)
app/test/features/equipment/equipment_comparison_screen_test.dart          (NEW)
FEATURE_012_ENGINEERING_REPORT_v3_2026-07-28.md                           (NEW untracked)
```

Plus unchanged files:

```
app/lib/features/equipment/presentation/widgets/equipment_comparison_section.dart  (unchanged — kept for class re-export)
app/lib/features/equipment/presentation/widgets/equipment_history_section.dart      (unchanged — FEATURE_011)
app/lib/features/equipment/presentation/widgets/equipment_recommendation.dart       (unchanged — FEATURE_010)
app/lib/features/equipment/domain/equipment_performance_projection.dart            (unchanged — forbidden)
```

- ✅ No Drift table, migration, schema change, repository, projection, or service added.
- ✅ `EquipmentPerformanceProjection` unmodified.
- ✅ No AI / Coach / Analytics / Recommendation logic added.
- ✅ Selection state is widget-local `Set<int>`, not repository-backed, not persisted.
- ✅ No GoRouter route registration (MaterialPageRoute push only).
- ✅ No new repository, projection, Drift table, migration, schema, or service.
- ✅ No AI / Coach / Analytics / Recommendation logic.

---

## 4. Gate results

### 4.1 `flutter pub get`

Skipped (Flutter on Windows requires symlink support / Developer Mode).
`flutter analyze --no-pub` used directly.

### 4.2 `flutter analyze --no-pub`

```
66 issues found. (ran in 4.2s)
```

**Decomposition:**

- **4 issues** in scope of FEATURE_012 (all **info**-level, all in
  pre-existing source files, untouched in this pass):
  - 4× `prefer_interpolation_to_compose_strings` in
    `equipment_comparison_section.dart:161, 162, 166, 167`.
- **62 baseline tech-debt issues** across `lib/features/skill/*`,
  `lib/features/tournament/*`, `lib/features/statistics/*`,
  `test/task_10_goal_center_test.dart`, … — all `prefer_const_*`,
  `deprecated_member_use`, or `avoid_init_to_null` in legacy files
  unrelated to FEATURE_012.
- **0 error, 0 warning.**

The 5th v1.1 issue (`avoid_init_to_null` in
`equipment_comparison_section_test.dart:62`) is gone because that test
file was deleted in this pass.

### 4.3 `dart format --set-exit-if-changed`

Applied (post-edit). RC=0 on second pass.

### 4.4 `flutter test test/features/equipment/equipment_comparison_screen_test.dart` (focused)

```
00:00 +10: All tests passed!
```

**10/10 focused tests pass.** Covers:

- 2-cue selection → exactly 2 columns rendered.
- 5-cue selection → 5 columns rendered (no cap).
- 6-cue selection → horizontal + vertical scroll wrappers present.
- Insufficient cue → `Chưa đủ dữ liệu.` rendered in that column.
- Match Win Rate exact value from projection (no recomputation).
- No winner highlight (no green/red, no recommendation widget).
- VI locale renders Vietnamese metric labels.
- Empty cues list → empty placeholder rendered.
- All 5 metric rows are rendered.
- Only projection fields used (cell content matches projection values).

### 4.5 `flutter test` (full regression)

```
01:09 +1324: All tests passed!
```

**1324/1324 passed** in 1m09s. (1335 baseline of Pass 2 - 21 removed
v1.1 tests + 10 new v2 tests = 1324. **No regression.**)

### 4.6 `git diff --check`

```
RC=0
```

Clean.

---

## 5. Functional contract — selection + screen

```dart
// EquipmentScreen state (simplified)
final Set<int> _selectedCompareIds = <int>{};

void _toggleCompareSelection(int cueId) {
  setState(() {
    if (!_selectedCompareIds.add(cueId)) {
      _selectedCompareIds.remove(cueId);
    }
  });
}

void _openComparisonScreen(
    List<Cue> cues, List<EquipmentPerformanceProjection> projections) {
  final entries = _buildComparisonEntries(cues, projections);
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => EquipmentComparisonScreen(
        cues: entries.map((e) => e.cue).toList(growable: false),
        projections: entries.map((e) => e.projection).toList(growable: false),
        now: DateTime.now(),
        locale: Localizations.localeOf(context).languageCode,
      ),
    ),
  );
}
```

**Behavioural contract:**

- `Set<int>` semantics: no order, no duplicates, no eviction.
- Each checkbox tap adds or removes one id.
- No cap, no FIFO, no auto-cleanup.
- Compare button visible whenever selection is non-empty.
- Compare button `onPressed: null` (disabled) when selection < 2.
- Tapping Compare pushes `EquipmentComparisonScreen` via
  `MaterialPageRoute` — no GoRouter involvement.
- Returning to Equipment Screen preserves selection (until rebuild).

---

## 6. UI surface (visual contract)

### 6.1 Equipment List — Compare (N) button

```
┌─ Equipment List ────────────────────────────────────────────┐
│ [Recommended Equipment Section]                             │
│                                                            │
│ [Compare (5)]                            ← FEATURE_012 v2  │
│                                                            │
│ ☐ Cue 1   Revo           [⋮]                              │
│ ☐ Cue 2   Ignite         [⋮]                              │
│ ☑ Cue 3   Predator       [⋮]                              │
│ ☑ Cue 4   Mezz           [⋮]                              │
│ ☑ Cue 5   Viking         [⋮]                              │
│ ☑ Cue 6   Jacoby         [⋮]                              │
│ ☑ Cue 7   Schon          [⋮]                              │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

When the user taps `Compare (5)`:

### 6.2 Comparison Screen — 5 columns horizontal-scroll

```
┌─ Comparison ─────────────────────────────────────────────┐
│ ↑ swipe ← →                                            │  ← horizontal scroll
│ ─────────────────────────────────────────────────────  │
│ Metric       │ Cue 3  │ Cue 4  │ Cue 5  │ Cue 6  │ C7  │
│              │Predator│  Mezz  │ Viking │ Jacoby │Schon│
│──────────────┼────────┼────────┼────────┼────────┼─────│
│ Win Rate     │  68%   │  64%   │  71%   │  65%   │ 70% │
│ Training …   │  72%   │  75%   │  68%   │  70%   │ 80% │
│ Matches      │  142   │   58   │  200   │   30   │ 100 │
│ Trainings    │   91   │   40   │  120   │   15   │  60 │
│ Last Used    │ Today  │ Jul 20 │ Today  │ Never  │ Yes │
│              │        │        │        │        │     │
│ ↓ swipe ← →                                              │
└──────────────────────────────────────────────────────────┘
```

When a column is insufficient (`matches<5 OR training<5`):

```
│ Win Rate     │  68%   │  Chưa đủ dữ liệu.           │
│ Training …   │  72%   │  Chưa đủ dữ liệu.           │
│ Matches      │  142   │  Chưa đủ dữ liệu.           │
│ Trainings    │   91   │  Chưa đủ dữ liệu.           │
│ Last Used    │ Today  │  Chưa đủ dữ liệu.           │
```

---

## 7. Mount wiring — the only deltas on the screen

Two main changes to `equipment_screen.dart`:

1. State + toggle:
```dart
final Set<int> _selectedCompareIds = <int>{};
void _toggleCompareSelection(int cueId) {
  setState(() {
    if (!_selectedCompareIds.add(cueId)) {
      _selectedCompareIds.remove(cueId);
    }
  });
}
```

2. Compare button + navigation:
```dart
final compareEnabled = _selectedCompareIds.length >= 2;
final showCompareButton =
    state.cues.isNotEmpty && _selectedCompareIds.isNotEmpty;
// ... (in ListView.builder itemBuilder, rawIndex == 1 case)
return Padding(
  key: const ValueKey('equipment-compare-button-row'),
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Align(
    alignment: Alignment.centerRight,
    child: FilledButton.icon(
      key: const ValueKey('equipment-compare-button'),
      onPressed: compareEnabled
          ? () => _openComparisonScreen(
              state.cues, state.performanceProjections)
          : null,
      icon: const Icon(Icons.compare_arrows),
      label: Text('Compare (${_selectedCompareIds.length})'),
    ),
  ),
);
```

The inline `EquipmentComparisonSection` mount from Pass 1/2 was
removed in v2. The pre-existing widget file
(`widgets/equipment_comparison_section.dart`) is retained as the
reusable comparison view foundation; `EquipmentComparisonSection`
and `EquipmentComparisonEntry` may be reused by future comparison
workflows.

---

## 8. Spec deviation summary

**Zero spec deviations.** Every rule and Acceptance Criterion of the
v2 authoritative PO spec is satisfied.

The widget layer (`equipment_comparison_section.dart`) is **retained** as the reusable comparison view foundation. `EquipmentComparisonSection` and `EquipmentComparisonEntry` may be reused by future comparison workflows; the current v2 implementation chose `EquipmentComparisonScreen` for the inline-card layout, but the underlying data class and view contract remain available.

---

## 9. Outstanding items for Product Owner

1. **Close FEATURE_012.** PO has not yet signed off on the v2
   implementation. Per PO workflow, FEATURE_012 cannot be marked
   Closed until this Engineering Report is reviewed and accepted.
2. **`EquipmentComparisonSection` retained.** `EquipmentComparisonSection`
   is retained as the reusable comparison view foundation and may be
   reused by future comparison workflows. The v2 implementation does
   not currently mount it inline; future comparison workflows (not yet
   scoped) may reuse it without re-creating the data class.
3. **Compare button label localisation.** The button label is the
   literal string `'Compare (N)'`. Spec PO did not prescribe a
   localization key. If PO wants bilingual consistency, a follow-up
   commit can add `'equipment_compare_label'` to
   `app_localizations.dart`.
4. **Selection persistence across navigation.** Per PO direction
   ("selection is in-memory only"), the state is widget-local. If PO
   wants the selection to survive widget rebuild, a
   `StateNotifierProvider` can be added — but that crosses the
   "no new service / repository / projection" boundary and needs
   explicit PO authorization.
5. **PRODUCT_ROADMAP_V2_DEPRECATED.md marker.** Kept in worktree
   root. No replacement roadmap exists; planning is tracked directly
   in the repo's specs.
6. **Pre-existing analyzer noise** — 4×
   `prefer_interpolation_to_compose_strings` in
   `equipment_comparison_section.dart:161-167` are pre-existing
   info-level lints. Left untouched per "do not refactor unrelated
   code".

---

## 10. Audit caveats

- This audit is implementation + spec compliance + gate pass for the
  PO Change Request #2 (2026-07-28, v2 spec).
- The pre-existing `EquipmentComparisonSection` widget was kept as a
  holder for the `EquipmentComparisonEntry` data class. It is not
  rendered anywhere in the v2 flow.
- The v2 implementation introduces a **dedicated screen** —
  `EquipmentComparisonScreen` — reachable only via
  `Navigator.push(MaterialPageRoute)`. No GoRouter route was
  registered (forbidden by spec v2 §3).
- Master `origin/master` still points to `38760b8`. Until PO
  authorizes commit + push, FEATURE_012 v2 remains "Engineering
  Complete, Pending Product Owner Close" in the worktree only.

---

**End of FEATURE_012 Engineering Report v3.**

*— Engineering on standby for Product Owner review.*