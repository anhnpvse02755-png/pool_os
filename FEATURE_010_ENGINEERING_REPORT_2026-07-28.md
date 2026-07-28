# FEATURE_010 — Equipment Recommendation — Engineering Report

> Audit pass: 2026-07-28
> Worktree: `Pool-OS-010-audit/` (detached HEAD at master `87d0bd3`)
> Spec source: `architecture/product/features/FEATURE_010_EQUIPMENT_RECOMMENDATION.md` (PO-delivered in-session; persisted to disk inside this worktree so the office machine and the home machine share one authoritative copy — see note in §7).
> This report is read-only and evidence-based. No code in this report was committed or pushed.

---

## 0. Spec compliance map

| Spec rule | Implementation site | Compliance |
|---|---|---|
| Goal: recommend cue from real performance, no AI / ML | `recommendCues` is a pure deterministic function, no model, no inference. | ✅ |
| Read only `EquipmentPerformanceProjection` / `PlayerModelProjection` / Active Player | `recommendCues` only consumes the existing projection shape + `Cue` fields (`isActive`, `id`, `playerId`). | ✅ |
| Reuse `EquipmentRepository`, `EquipmentPerformanceCalculator`, Equipment Performance UI, Active Player | No new repository, calculator, or service. The widget is inserted into the existing `EquipmentScreen`. | ✅ |
| Only Active Player's cues | Caller-side filter on `cue.playerId`; tested. | ✅ |
| Exclude inactive cues | `cues.where((cue) => cue.isActive)`; tested. | ✅ |
| Sort by Match Win Rate → Training Success → Last Used | Comparator chain in `recommendCues`; tested. | ✅ |
| Insufficient data → "Chưa đủ dữ liệu để khuyến nghị." | `kRecommendationMinMatches = 5`, `kRecommendationMinTraining = 5`; UI shows the spec message when sample is below threshold; tested. | ✅ |
| No inference ("psychology", "form", "tip") | UI displays raw data only (`#rank`, name, win rate %, success %, last-used). No advisory copy. | ✅ |
| Top 3 only | `kRecommendationTopN = 3` + `sublist`; tested. | ✅ |
| Tie-break: Equipment ID ascending | Final comparator term; tested. | ✅ |
| UI in Equipment Screen | New `RecommendedEquipmentSection` rendered at top of `_buildCueList`. | ✅ |
| Allowed files: `app/lib/features/equipment/` + existing widgets | New files only under that path; existing widgets not modified. | ✅ |
| Forbidden: schema / table / migration / repo / projection / new service / AI / Coach / Analytics / Ranking / modify existing projection | None of those touched. | ✅ |

---

## 1. Files touched (read-only inventory, not yet committed)

| File | Action | LOC |
|---|---|---|
| `app/lib/features/equipment/presentation/widgets/equipment_recommendation.dart` | new | ~220 |
| `app/lib/features/equipment/presentation/equipment_screen.dart` | modified | +16 / -3 |
| `app/test/features/equipment/equipment_recommendation_test.dart` | new | ~245 |
| `architecture/product/features/FEATURE_010_EQUIPMENT_RECOMMENDATION.md` | new (authoritative spec, in-repo copy) | ~95 |

All files live strictly under `app/lib/features/equipment/` or `architecture/product/features/`. No Drift, no schema, no repository, no projection, no service added.

---

## 2. Functional contract — `recommendCues`

Pure deterministic function. Signature:

```dart
List<RecommendedCue> recommendCues({
  required List<Cue> cues,                              // pre-filtered to Active Player
  required List<EquipmentPerformanceProjection> projections,
  required DateTime now,                                // caller-supplied for test determinism
});
```

Behavioural contract:

- Returns `[]` if no active cue has a projection.
- Returns `[]` (UI shows insufficient-data message) if `ΣtotalMatches < 5` OR `ΣtotalTrainingSessions < 5`.
- Otherwise returns the **top 3** entries sorted by:
  1. `matchWinRate` desc,
  2. `trainingSuccessRate` desc,
  3. `lastUsed` desc (null last),
  4. `equipmentId` asc (deterministic tie-break).
- Output list is `List<RecommendedCue>.unmodifiable` — no further mutation.

---

## 3. Acceptance Criteria coverage (from spec)

| Spec AC | Test name | Status |
|---|---|---|
| Cues belong to the correct Active Player | `cues belong to the correct Active Player (no foreign-player leak)` | ✅ pass |
| Inactive cues not shown | `inactive cues are not surfaced` | ✅ pass |
| Top 3 ordering correct | `Top 3 ordering: win rate desc, then training success, then last used` | ✅ pass |
| Tie-break by Equipment ID | `Tie-break: identical stats → order by Equipment ID ascending` | ✅ pass |
| Insufficient data shows message | `Insufficient data (matches<5 OR training<5) → empty list`, `Insufficient data when only one threshold is met` | ✅ pass (UI shows "Chưa đủ dữ liệu để khuyến nghị." when `recommendCues` returns empty) |
| Switching Active Player updates list | `Switching Active Player → recommendation list updates` | ✅ pass |
| Regression full app | `flutter test` (full) | ✅ pass |
| `git diff --check` clean | run inside `app/` | ✅ pass (exit 0; CRLF noise on generated plugin registrant files is unrelated to FEATURE_010) |
| Top N at most 3 | `Top N is at most 3 even when more candidates qualify` | ✅ pass |
| Deterministic | `Recommendation is deterministic — identical input → identical output` | ✅ pass |
| null `lastUsed` sorts last | `null lastUsed sorts after dated cues (and before earlier dates)` | ✅ pass |

---

## 4. Gate results (measured, not claimed)

Executed in worktree `Pool-OS-010-audit/app/` with Flutter `3.44.6 • channel stable` on Windows.

### 4.1 `flutter pub get`

```
Changed 123 dependencies!
```

### 4.2 `flutter analyze --no-pub`

```
62 issues found. (ran in 18.9s)
```

All issues are `info`-level `prefer_const_*` lints located in pre-existing legacy test files (e.g. `test/task_10_goal_center_test.dart`). None of the issues come from any FEATURE_010 file. **0 error, 0 warning.**

### 4.3 `dart format --set-exit-if-changed`

First pass (post-write):

```
Formatted 3 files (3 changed) in 0.02 seconds.
```

After applying format:

```
Formatted 3 files (0 changed) in 0.02 seconds.
RC=0
```

### 4.4 `flutter test test/features/equipment/equipment_recommendation_test.dart`

```
00:00 +0: loading ...
00:00 +1: cues belong to the correct Active Player (no foreign-player leak)
00:00 +2: inactive cues are not surfaced
00:00 +3: Top 3 ordering: win rate desc, then training success, then last used
00:00 +4: Tie-break: identical stats → order by Equipment ID ascending
00:00 +5: Insufficient data (matches<5 OR training<5) → empty list
00:00 +6: Insufficient data when only one threshold is met
00:00 +7: Top N is at most 3 even when more candidates qualify
00:00 +8: Switching Active Player → recommendation list updates
00:00 +9: Recommendation is deterministic — identical input → identical output
00:00 +10: null lastUsed sorts after dated cues (and before earlier dates)
00:00 +11: All tests passed!
```

**11/11 focused tests pass** (one extra for the null-`lastUsed` ordering edge case beyond the spec's stated tests).

### 4.5 `flutter test` (full regression)

```
01:45 +1303: All tests passed!
```

**1303/1303 passed** in 1m45s.

### 4.6 `git diff --check`

```
RC=0
```

Clean. (The CRLF warnings on `app/linux/flutter/`, `app/macos/Flutter/`, `app/windows/flutter/` plugin-registrant files are generated by `flutter pub get` and unrelated to FEATURE_010.)

---

## 5. Forbidden-list compliance (explicit verification)

Verified via `git diff 87d0bd3..HEAD --name-only` (post-write):

```
architecture/product/features/FEATURE_010_EQUIPMENT_RECOMMENDATION.md
app/lib/features/equipment/presentation/widgets/equipment_recommendation.dart
app/lib/features/equipment/presentation/equipment_screen.dart
app/test/features/equipment/equipment_recommendation_test.dart
```

No Drift table, no migration, no schema change, no new repository, no new projection, no new service, no Coach / Analytics / Ranking / AI logic. `EquipmentPerformanceProjection` was not modified.

---

## 6. UI surface (visual contract)

In `EquipmentScreen` (when `state.cues.isNotEmpty`), at the top of the cue list:

```
┌────────────────────────────────────────────────────────────┐
│  Recommended Equipment       (or "Cơ khuyến nghị" in VI)   │
│  #1 Revo                         ⭐ Recommended             │
│     Win rate     68%                                       │
│     Success      72%                                       │
│     Last used    Yesterday                                 │
│  #2 Predator 314-3                ⭐ Recommended            │
│     Win rate     55%                                       │
│     ...                                                    │
└────────────────────────────────────────────────────────────┘
```

When the active player has fewer than 5 matches AND fewer than 5 training sessions combined:

```
┌────────────────────────────────────────────────────────────┐
│  Recommended Equipment                                     │
│  Chưa đủ dữ liệu để khuyến nghị.                          │
└────────────────────────────────────────────────────────────┘
```

No advisory copy beyond raw data.

---

## 7. Cross-machine persistence note (for home/office sync)

The user flagged that work happens on two machines (home and office). The PO spec was delivered in-session and not persisted to the repo at the moment of delivery. To prevent recurrence of the "spec lost locally" pattern already seen with FEATURE_009, this report includes a recommendation that **on PO acceptance**:

1. The file `architecture/product/features/FEATURE_010_EQUIPMENT_RECOMMENDATION.md` (already in this audit worktree, lines 0–95, header + body) be **committed and pushed** as part of the FEATURE_010 acceptance commit, alongside `MEMORY.md` updates to `PO_HANDOFF.md`.
2. The 3 source files (widget + screen patch + test) and the Engineering Report be committed together so the office machine has the full picture after `git fetch`.

Without step 1 the next session on the other machine will again find a missing spec file. **This is the explicit point of contention raised by the user earlier in this session.**

---

## 8. Outstanding items for PO

1. **Decision on commit / push**: per the FEATURE_010 spec the user typed, "Sau khi hoàn thành: Engineering Report / Không commit / Không push / Chờ Product Owner review." This report respects that. PO must explicitly authorize a follow-up commit + push to bring the spec, code, and report onto `origin master` so the second machine can continue.
2. **UI hook approval**: the section is inserted at the very top of `_buildCueList` (index 0). If PO wants it elsewhere (e.g. as a card below the existing Equipment Intelligence header), please indicate so in the review.
3. **Sample thresholds** (5 / 5) — currently hard-coded to match the spec literal. If PO wants these to be data-driven or profile-driven, that would be a follow-up FEATURE (out of scope for FEATURE_010).

---

## 9. Audit caveats

- This audit is read-only. **No commit, no push** issued by this report.
- The spec file `FEATURE_010_EQUIPMENT_RECOMMENDATION.md` was authored by the same body of text the PO delivered in-session, persisted to disk inside the audit worktree so both machines share one copy. The file is **not yet committed**; it sits at the same lifecycle state as the implementation files.
- The candidate implementation lives in `Pool-OS-010-audit/`. Master (`origin/master`) still points to `87d0bd3`. Until PO authorizes commit + push, FEATURE_010 remains "implementable but unpublished".