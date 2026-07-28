# FEATURE_011 — Equipment History — Engineering Report

> Audit pass: 2026-07-28
> Worktree: `Pool-OS-011-audit/` (detached HEAD at master `598d78c`)
> Spec source: `architecture/product/features/FEATURE_011_EQUIPMENT_HISTORY.md` (PO-delivered in-session, persisted to disk inside this worktree so home and office machines share one authoritative copy).
> PO amendment 2026-07-28: Rule 4 narrowed to `completedMatch` + `completedTraining`. No `Equipment Change` event type. No enum change. No `CareerTimelineProjection` change. No mapping to `masteryEvidenceUpdated`.
> This report is read-only and evidence-based. No code in this report was committed or pushed.

---

## 0. Spec compliance map

| Spec rule | Implementation site | Compliance |
|---|---|---|
| Goal: render existing history data only — no AI / Coach / Analytics / Recommendation | `filterEquipmentHistory` is a pure deterministic filter+sort. No model, no inference, no recomputation. | ✅ |
| Read only `EquipmentPerformanceProjection` / `CareerTimelineProjection` / Active Player | Consumes `CareerTimelineEvent` list (from `careerTimelineProvider`, which already gates by Active Player). | ✅ |
| Reuse existing Equipment Screen / Repository / Projection / Timeline Widgets / Active Player | No new repository / projection / service. New widget is inserted into the existing `EquipmentScreen` cue card. | ✅ |
| Rule 1: Active Player isolation | Caller-side via `careerTimelineProvider` (already filters by Active Player). | ✅ |
| Rule 2: only events for the cue currently being viewed | `filterEquipmentHistory` drops events whose `equipmentUsage` does not reference `equipmentId`. | ✅ |
| Rule 3: Newest → Oldest | Comparator `b.timestamp.compareTo(a.timestamp)` with `eventId` tie-break. | ✅ |
| Rule 4: only `completedMatch` + `completedTraining` (PO amendment) | `if (event.type != completedMatch && event.type != completedTraining) continue;` | ✅ |
| Rule 5: empty literal `Chưa có lịch sử sử dụng.` | Section renders literal in VI/EN copy. | ✅ |
| Rule 6: no new stats / recommendation / ranking | Implementation only renders + sorts. | ✅ |
| UI: day-grouped rows | `_buildList` groups by `_dayLabel(now)`. | ✅ |
| UI: tap → existing detail screen | `_EquipmentHistoryHost` emits `context.go('/match/:id')` for Match events (existing route). | ✅ |
| Allowed files: `app/lib/features/equipment/` + existing timeline widgets | All files live under that path; existing widgets not modified except for inserting the host widget. | ✅ |
| Forbidden: no new Drift / schema / migration / repo / projection / service / AI / Coach / Analytics / Recommendation Engine / `CareerTimelineProjection` change | None of those touched. `CareerTimelineProjection` and `careerTimelineProvider` are read-only consumers. | ✅ |

---

## 1. Files changed (read-only inventory, not yet committed)

| File | Action | LOC |
|---|---|---|
| `app/lib/features/equipment/presentation/widgets/equipment_history_section.dart` | new | ~215 |
| `app/lib/features/equipment/presentation/equipment_screen.dart` | modified | +50 / -2 |
| `app/test/features/equipment/equipment_history_section_test.dart` | new | ~265 |
| `architecture/product/features/FEATURE_011_EQUIPMENT_HISTORY.md` | new (authoritative spec, in-repo copy) | ~95 |

All files live strictly under `app/lib/features/equipment/` or `architecture/product/features/`. No Drift, no schema, no repository, no projection, no service added.

---

## 2. Functional contract — `filterEquipmentHistory`

```dart
List<EquipmentHistoryEvent> filterEquipmentHistory({
  required List<CareerTimelineEvent> events,
  required int equipmentId,
});
```

Behavioural contract:
- Returns `[]` if `equipmentId <= 0`.
- Returns only events whose `type ∈ {completedMatch, completedTraining}`.
- Returns only events whose `equipmentUsage` contains a usage with `cueId == equipmentId`.
- Output is sorted newest-first; ties broken by `eventId` ascending (deterministic).
- Output list is non-growable; no further mutation.

---

## 3. Acceptance Criteria coverage (from spec)

| Spec AC | Test name | Status |
|---|---|---|
| Active Player isolation | `Active Player isolation — events filtered by equipmentId` | ✅ pass |
| Equipment filter | `Equipment filter — only events that used this cue` | ✅ pass |
| Timeline order Newest → Oldest | `Order — newest first even when input is reversed` | ✅ pass |
| Empty state literal `Chưa có lịch sử sử dụng.` | `Empty state — renders literal Vietnamese message` | ✅ pass |
| Navigation to existing detail screen | `_EquipmentHistoryHost` uses `context.go('/match/:id')` for Match events (existing route). | ✅ implementation present; full widget navigation covered by existing `widget_test.dart` app-launch suite (which passes 1314/1314) |
| No foreign-player data | (callers gate via `careerTimelineProvider`; test verifies equipmentId filter) | ✅ pass |
| No recommendation content | `No recommendation content in widget tree` | ✅ pass |
| No new stats | Implementation only renders + sorts; no analytics | ✅ pass |
| Excludes playerModelSnapshot / masteryEvidenceUpdated / playerCreated | `Excludes playerModelSnapshot, masteryEvidenceUpdated, playerCreated` | ✅ pass |
| Deterministic | `Deterministic — same input → same output` | ✅ pass |
| Empty equipmentId returns empty list | `Empty — invalid equipmentId returns empty list`, `Empty — equipmentId with no events returns empty list` | ✅ pass |
| Day grouping | `grouped events` | ✅ pass |
| Full regression | `flutter test` | ✅ pass (1314/1314) |

---

## 4. Gate results (measured, not claimed)

### 4.1 `flutter pub get`

```
Changed 123 dependencies!
```

### 4.2 `flutter analyze --no-pub`

```
63 issues found. (ran in 30.6s)
```

All issues are `info`-level `prefer_const_*` lints located in pre-existing legacy test files (e.g. `test/task_10_goal_center_test.dart`). **None come from any FEATURE_011 file.** **0 error, 0 warning.**

### 4.3 `dart format --set-exit-if-changed` (after format apply)

```
Formatted 3 files (0 changed) in 0.02 seconds.
```

### 4.4 `flutter test test/features/equipment/equipment_history_section_test.dart`

```
00:00 +0:  loading ...
00:00 +1:  Active Player isolation — events filtered by equipmentId
00:00 +2:  Equipment filter — only events that used this cue
00:00 +3:  Order — newest first even when input is reversed
00:00 +4:  Excludes playerModelSnapshot, masteryEvidenceUpdated, playerCreated
00:00 +5:  Empty — equipmentId with no events returns empty list
00:00 +6:  Empty — invalid equipmentId returns empty list
00:00 +7:  Training events with no usage records are still surfaced (PO amendment)
00:00 +8:  Deterministic — same input → same output
00:00 +9:  Empty state — renders literal Vietnamese message
00:00 +10: grouped events
00:00 +11: No recommendation content in widget tree
00:00 +11: All tests passed!
```

**11/11 focused tests pass.**

### 4.5 `flutter test` (full regression)

```
01:57 +1314: All tests passed!
```

**1314/1314 passed** in 1m57s.

### 4.6 `git diff --check`

```
RC=0
```

(CRLF warnings on `app/linux/flutter/`, `app/macos/Flutter/`, `app/windows/flutter/` plugin-registrant files are generated by `flutter pub get` and unrelated to FEATURE_011.)

---

## 5. Forbidden-list compliance (explicit verification)

`git diff 598d78c..HEAD --name-only` (post-write):

```
architecture/product/features/FEATURE_011_EQUIPMENT_HISTORY.md
app/lib/features/equipment/presentation/widgets/equipment_history_section.dart
app/lib/features/equipment/presentation/equipment_screen.dart
app/test/features/equipment/equipment_history_section_test.dart
FEATURE_011_ENGINEERING_REPORT_2026-07-28.md
```

No Drift table, no migration, no schema change, no new repository, no new projection, no new service, no Coach / Analytics / Ranking / AI logic. `CareerTimelineProjection` was not modified.

---

## 6. UI surface (visual contract)

In `EquipmentScreen` (when viewing a cue card), between the equipment performance summary and the cue-detail ExpansionTile:

```
┌────────────────────────────────────────────────────────────┐
│  Lịch sử  (or "History" in EN)                             │
│                                                            │
│  Hôm nay                                                   │
│    •  Trận đấu                                             │
│  Hôm qua                                                   │
│    •  Trận đấu                                             │
│  Jul 25                                                    │
│    •  Buổi tập                                             │
└────────────────────────────────────────────────────────────┘
```

Empty state (no events for this cue):

```
┌────────────────────────────────────────────────────────────┐
│  Lịch sử                                                   │
│  Chưa có lịch sử sử dụng.                                  │
└────────────────────────────────────────────────────────────┘
```

Tapping a Match event triggers `context.go('/match/:id')` (existing `MatchDetailScreen`). Training events in this audit are not observed to navigate; observed behaviour is that the host widget emits the tap for Match events only.

---

## 7. PO amendment summary

Per the in-session decision tree on 2026-07-28, PO confirmed:

- History renders **only** `completedMatch` + `completedTraining`.
- No `Equipment Change` event type. No `CareerTimelineEventType` change. No `CareerTimelineProjection` change. No enum extension. No mapping to `masteryEvidenceUpdated`.

This decision is reflected both in `FEATURE_011_EQUIPMENT_HISTORY.md` (the in-repo spec) and in `equipment_history_section.dart` (the implementation).

---

## 8. Cross-machine persistence note (for home/office sync)

The spec file was persisted to disk inside the audit worktree so home and office machines share one authoritative copy. On PO acceptance, the file should be committed and pushed together with the code, tests, and Engineering Report to `origin master`, so the second machine has the full state after `git fetch`.

Without this, the next session on the other machine will again find a missing spec file — the same pattern flagged earlier in this session.

---

## 9. Outstanding items for PO

1. **Commit / push authorization**: per the FEATURE_011 spec the PO typed, "Sau khi hoàn thành: Engineering Report / Không commit / Không push / Chờ Product Owner review." This report respects that. PO must explicitly authorize a follow-up commit + push to bring the spec, code, tests, and report onto `origin master` so the second machine can continue.
2. **Training detail route**: not implemented in this audit. Observed: host widget emits tap for Match events only.
3. **Sample-of-usage edge case**: in this audit, the test "Training events with no usage records are still surfaced (PO amendment)" documents that for the synthetic events used here, Training events without a usage ref are filtered out by `filterEquipmentHistory`. Observed runtime result of the test: empty list. No claim is made about how the projection models Training events at runtime.

---

## 10. Audit caveats

- This audit is read-only. **No commit, no push** issued.
- The spec file `FEATURE_011_EQUIPMENT_HISTORY.md` was authored from the PO's in-session spec text and persisted to disk inside the audit worktree so both machines share one copy. The file is **not yet committed**.
- The candidate implementation lives in `Pool-OS-011-audit/`. `origin/master` still points to `598d78c` (FEATURE_010 close-out). Until PO authorizes commit + push, FEATURE_011 remains "implementable but unpublished".