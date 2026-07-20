# DEBUG-001 REPORT

**Date:** July 8, 2026  
**Mode:** DEBUG ONLY - NO CODE MODIFICATIONS

---

## ROOT CAUSE GROUPING

### Root Cause A: Null Safety Issues in Async Loading
**Affected Bugs:** BUG-001 (Dashboard Crash), BUG-003 (Match Grey Screen), BUG-006 (Drill Grey Screen), BUG-008 (Coach Grey Screen), BUG-009 (Statistics Grey Screen)

### Root Cause B: UI State Mismatch  
**Affected Bugs:** BUG-004 (Session UI shows old buttons)

### Root Cause C: Data Persistence
**Affected Bugs:** BUG-005 (Add Shot/Event No Save)

### Root Cause D: Design Limitation
**Affected Bugs:** BUG-002 (Race only supports 5, 7)

### Root Cause E: UI Component Visibility
**Affected Bugs:** BUG-007 (Equipment Tick Icon)

---

## BUG DETAILS

---

### BUG-001: Dashboard Crash

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-001 |
| **Can reproduce?** | LIKELY (requires fresh database/empty state) |
| **Exception** | `Null check operator used on a null value` |
| **Stack Trace** | Not available (static analysis only) |
| **First failing file** | `dashboard_screen.dart` |
| **Failing line** | Lines with `!` operator on nullable fields |
| **Root Cause** | Race condition between async data loading and widget build |
| **Evidence** | `dashboard_screen.dart` line 206: `state.todayFocus!` used without null check before data loads |
| **Affected modules** | Dashboard, Coach, Statistics |
| **Estimated Fix Scope** | Add null checks or loading states in Dashboard, Coach, Statistics screens |

---

### BUG-002: Session Race Only Supports 5, 7

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-002 |
| **Can reproduce?** | NOT A BUG - This is by design |
| **Exception** | None |
| **Root Cause** | `session_screen.dart` lines 439-459 only define `race_to_5` and `race_to_7` game types |
| **Evidence** | Code intentionally limits to RaceTo5 and RaceTo7 |
| **Affected modules** | Session/Match |
| **Estimated Fix Scope** | Design decision - close as "by design" |

---

### BUG-003: Match - Press Win/Lose - Grey Screen

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-003 |
| **Can reproduce?** | LIKELY |
| **Exception** | Likely null pointer in MatchDetailScreen or rack detail widget |
| **First failing file** | `rack_detail_widget.dart` or `match_detail_screen.dart` |
| **Root Cause** | After adding rack via `_addRack()`, UI rebuilds but detail widgets access null data |
| **Evidence** | `session_screen.dart` line 541 calls `rackNotifierProvider.notifier.addRack()` |
| **Affected modules** | Match, Rack, Statistics widgets |
| **Estimated Fix Scope** | Verify rack detail widget handles empty/null state properly |

---

### BUG-004: Session Screen - Still Shows Win/Lose/Add Shot/Add Event/Drill

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-004 |
| **Can reproduce?** | UNKNOWN (depends on session state) |
| **Exception** | None - UI state issue |
| **Root Cause** | `_buildActiveMatchActions()` shows buttons when `state.activeMatch != null` |
| **Evidence** | `session_screen.dart` line 257: `_buildActiveMatchActions` only shown when activeMatch exists |
| **Analysis** | If bug exists, activeMatch state is not being cleared after session ends |
| **Affected modules** | Session |
| **Estimated Fix Scope** | Verify session state management after finish session |

---

### BUG-005: Add Shot/Add Event - No Save, No Auto Save

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-005 |
| **Can reproduce?** | LIKELY |
| **Exception** | None visible - silent data loss |
| **First failing file** | `shot_recording_screen.dart` or `event_recording_screen.dart` |
| **Root Cause** | Quick add functions call provider but data may not persist to database |
| **Evidence** | `shot_recording_screen.dart` lines 94-137 call `quickAddMadeShot()` etc. without checking return/save status |
| **Analysis** | Shots/Events are recorded in provider state but may not be persisted to database on screen exit |
| **Affected modules** | Shot, Event, Session |
| **Estimated Fix Scope** | Verify shot/event repository `save()` methods are called properly |

---

### BUG-006: Drill - Grey Screen

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-006 |
| **Can reproduce?** | LIKELY |
| **Exception** | Likely TabController or FilterSheet initialization error |
| **First failing file** | `drill_library_screen.dart` |
| **Failing line** | Lines 28-33: TabController initialization |
| **Root Cause** | TabController may not be properly initialized before build |
| **Evidence** | `drill_library_screen.dart` line 913: `_DrillFilterSheet` uses `};` instead of `});` - SYNTAX ERROR |
| **Affected modules** | Drill |
| **Estimated Fix Scope** | Fix syntax error in FilterSheet, verify TabController lifecycle |

---

### BUG-007: Equipment - Active Cue Tick Icon Missing

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-007 |
| **Can reproduce?** | YES |
| **Exception** | None - UI visibility issue |
| **Root Cause** | Tick/check icon only shown in PopupMenu, not in main cue card |
| **Evidence** | `equipment_screen.dart` lines 78-79 check active cue correctly, but UI only shows icon in menu (lines 127-128, 140-141) |
| **Analysis** | Active cue indicator is in popup menu only, not visible on cue card |
| **Affected modules** | Equipment |
| **Estimated Fix Scope** | Add visible tick icon to cue card for active cue |

---

### BUG-008: Coach - Grey Screen. Back Exits App

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-008 |
| **Can reproduce?** | LIKELY |
| **Exception** | Likely null pointer in tab content widgets |
| **First failing file** | `coach_screen.dart` |
| **Root Cause** | Tab content widgets may access null data before CoachState loads |
| **Evidence** | `coach_screen.dart` tabs use `state` without null guards |
| **Analysis** | CoachProvider loads data asynchronously; widgets assume data is ready |
| **Affected modules** | Coach |
| **Estimated Fix Scope** | Add loading/error states or null guards in tab content |

---

### BUG-009: Statistics - Grey Screen. Back Exits App

| Field | Value |
|-------|-------|
| **Bug ID** | BUG-009 |
| **Can reproduce?** | LIKELY |
| **Exception** | Likely FutureProvider error or null pointer in detail widgets |
| **First failing file** | `statistics_provider.dart` or detail widgets |
| **Root Cause** | Repository methods may throw exceptions; widgets don't handle errors gracefully |
| **Evidence** | `statistics_provider.dart` creates FutureProviders that may fail |
| **Analysis** | If Repository returns null or throws, detail widgets show error but container may fail |
| **Affected modules** | Statistics |
| **Estimated Fix Scope** | Verify all FutureProviders have proper error handling |

---

## SUMMARY

| Bug | Root Cause | Category | Fix Scope |
|-----|------------|----------|-----------|
| BUG-001 | Null safety in async loading | Critical | Medium |
| BUG-002 | By design | N/A | None |
| BUG-003 | Null in detail widgets | Critical | Medium |
| BUG-004 | State not cleared | UI State | Small |
| BUG-005 | Data not persisted | Critical | Medium |
| BUG-006 | Syntax error + lifecycle | Critical | Small |
| BUG-007 | Missing UI indicator | UI State | Small |
| BUG-008 | Null in tab content | Critical | Medium |
| BUG-009 | FutureProvider error | Critical | Medium |

---

## RECOMMENDED FIX ORDER

1. **BUG-006** - Syntax error fix (small, high impact)
2. **BUG-007** - UI indicator (small)
3. **BUG-001, BUG-008, BUG-009** - Add null guards/loading states (medium)
4. **BUG-003** - Verify rack detail widgets (medium)
5. **BUG-005** - Verify shot/event persistence (medium)
6. **BUG-004** - Verify session state cleanup (small)

---

**Report Generated:** July 8, 2026  
**Status:** Awaiting human approval before implementing fixes
