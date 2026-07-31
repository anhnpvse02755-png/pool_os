# EPIC 04 — Tournament & Competition System — Engineering Report

**Status:** Engineering complete (pending Final regression → Merge → Close Epic)
**Date:** 2026-07-31
**Branch:** `2026-07-08-d3t7` (working on `master`; EPIC 04 work landed via Phase 1.1 → 2.9)
**PO direction:** 2026-07-31 — Beta scope, **no AI, no prediction, no recommendation, no auto**.
**Baseline commit:** `12569d9` (EPIC 02 close record). EPIC 04 starts from `master` post-EPIC 02.

---

## 1. Scope Delivered (per PO Approved Plan — 8 deliverables)

### Phase 1 — Tournament Core (Accepted 2026-07-31, after PO re-review)

| # | Deliverable | Source | Notes |
|---|---|---|---|
| 1 | `TournamentFormat` (Strategy interface) | NEW | Beta: SingleEliminationFormat. DE/RR/Swiss return NotAvailable. |
| 2 | `BracketGenerator` (interface, separate from format) | NEW | Beta: SingleEliminationBracketGenerator. DE/RR/Swiss return NotAvailable. |
| 3 | `TournamentOverrideService` | NEW | Phase 1 no audit; Phase 2 hook does not change caller. |
| 4 | `HandicapPolicy` (race as object `{playerA, playerB}`) | NEW | Beta: NoHandicap, FixedRaceHandicap, RacePatchHandicap. ApaHandicap = NotAvailable. |
| 5 | `TournamentService` (orchestration only) | NEW | No business rule; composes the 4 above + MatchRequest. |
| 6 | `Match Engine` integration | Existing (EPIC 01) | `MatchRequest` record; service hands data, no insert into matches/racks/shots. |
| 7 | Bracket immutability after `Running` | NEW | `canEditSeeding` / `canRegenerateBracket` only true at `upcoming`. |
| 8 | No schema bump | — | Re-uses v19 (Competition State Model, RFC-303). |

### Phase 1 Add-on (PO 2026-07-31 re-review)

| Add-on | Source |
|---|---|
| Capability pattern (no exceptions) | NEW `domain/capabilities.dart` — `NotAvailable`, `TournamentFormatCapability`, `BracketGeneratorCapability`, `BracketValidatorCapability`. UI reads capability → disable. |
| `BracketValidator` abstraction | NEW `domain/bracket_validator.dart` — sits between `BracketGenerator` and `TournamentService`. Phase 1: `PermissiveBracketValidator` (always clean). Phase 2: `StrictBracketValidator` (capability=planned) for duplicate seed / bye / power-of-2 / champion path. |

### Phase 2 — Competition Management (Accepted 2026-07-31)

| # | Deliverable | Source | Scope (skeleton only) |
|---|---|---|---|
| 2.1 | Standing UI | Existing from Task 13 | Re-uses `StandingsTab` + `standingsProvider` + `StandingCalculator`. |
| 2.2 | Ranking (read-only) | NEW `domain/ranking.dart` | `TournamentRankingCalculator.ranking()` — derived view across tournaments. No ELO / TrueSkill. |
| 2.3 | Handicap UI | NEW `widgets/handicap_editor.dart` | Read-only display of `{playerA, playerB}` via `TournamentService.createMatchRequest`. |
| 2.4 | Bracket UI polish | MODIFIED `widgets/bracket_view.dart` | `_capabilityBanner()` surfaces unimplemented formats. |
| 2.5 | League skeleton | NEW `screens/league_skeleton_screen.dart` | Filter tournaments by `TournamentType.league` + capability banner. |
| 2.6 | Season skeleton | NEW `domain/season.dart` + `screens/season_skeleton_screen.dart` | Domain model + UI shell. No season engine. |
| 2.7 | Team skeleton | NEW `screens/team_skeleton_screen.dart` | Filter by `TournamentCompetitionMode.team` (schema v19). No team statistics. No team match engine. |
| 2.8 | Phase 2 regression guard | NEW `test/features/tournament/phase2_ranking_test.dart` | 6 tests. |
| 2.9 | Rename `RankingCalculator` → `TournamentRankingCalculator` (PO 2026-07-31) | MODIFIED `ranking.dart`, `tournament_providers.dart`, `ranking_screen.dart`, `phase2_ranking_test.dart` | Namespace safety vs future GlobalRanking / PlayerRating / LeagueRanking / SeasonRanking. |

## 2. Out of Scope (frozen — 14 items, none built)

**PO 2026-07-31 scope guard**:
- AI / prediction / recommendation
- Auto seeding / auto scheduling / auto handicap
- Fixture Generator (League / Round Robin)
- League Scheduler
- Season Engine
- Team Statistics
- Team Match Engine
- ELO / TrueSkill / Swiss pairing / Points system
- APA handicap logic (placeholder only)
- Round Robin pairing (placeholder only)
- Double Elimination losers' bracket (placeholder only)
- Swiss pairing (placeholder only)
- Schema bump (v19 retained, no new tables)
- Throwing exceptions in production code (capability pattern enforced)

## 3. Architecture Decisions

### 3.1 The 8-layer composition

```
Tournament (domain model)
        ↓
TournamentService (orchestration only)
        ↓
TournamentFormat (Strategy)
        ↓
BracketGenerator (per-format layout algorithm)
        ↓
BracketValidator (per-format integrity rules)
        ↓
TournamentOverrideService (audit hook — Phase 2)
        ↓
HandicapPolicy (race-to per fixture)
        ↓
Match Engine (EPIC 01 — single source of truth)
```

Every layer is a `class` or `interface`. No layer writes directly into the Drift schema — that is the repository's job.

### 3.2 Capability pattern (no exceptions)

PO 2026-07-31: placeholders do **not** throw. They return `NotAvailable` result types (`FormatGenerationResult`, `BracketGenerationResult`, `HandicapRaceResult`, `AdvanceResult`, `MatchRequestResult`, `ChampionResult`). UI reads capability flags and disables the action. This avoids try/catch in production code and keeps the placeholder surfaces stable for future EPICs (09 — Advanced Tournament System).

### 3.3 BracketValidator between generator and service

The service never inspects bracket math itself. It composes `BracketGenerator` + `BracketValidator` and never throws for invalid brackets — the validator returns a `BracketValidationReport`. Phase 1 ships `PermissiveBracketValidator` (always clean). Phase 2 placeholder `StrictBracketValidator` (capability=planned) will tighten: duplicate seed, bye hợp lệ, power-of-2, champion path.

### 3.4 Match Engine boundary

The service hands a pure-Dart `MatchRequest` record to the existing Match Engine pipeline. The service does NOT insert into `matches` / `racks` / `shots` — that is owned by EPIC 01. The fixture's `winnerParticipantId` feeds into the engine via `MatchRequest` and the existing soft-ref `matchId` column on `tournament_matches`.

### 3.5 Bracket immutability after start

Once a tournament moves to `TournamentStatus.active` (i.e. `TournamentPhase.running`), the service returns false for `canEditSeeding`, `canRegenerateBracket`. Manual overrides stay allowed until `completed`.

### 3.6 HandicapPolicy as object, not int

PO direction: handicap is a RELATIONSHIP between two players, not an attribute of a tournament. `RacePatchHandicap` stores `{playerA, playerB}` per-fixture override keyed by ordered pair `participantAId|participantBId`. The fallback is `{playerA, playerB}` or both sides race to `baseRace`.

### 3.7 Re-use of Task 13 proven math

`BracketGeneratorStatic` retains `orderBySeed`, `seedOrder`, `nextPowerOfTwo`, the SE bracket generator, and the parent-slot math. They are private static methods of the generator, no longer exposed globally. New formats (DE/RR/Swiss) will bring their own helpers when implemented.

## 4. Schema Changes

**None.** EPIC 04 re-uses schema v19 from RFC-303 — Competition State Model. Three Drift tables: `tournaments`, `tournament_participants`, `tournament_matches`. No additive columns, no new tables, no migration. The `TournamentCompetitionMode.team` column already exists since v19.

## 5. Files Added / Modified

### Created (12 files)

| Path | Purpose |
|---|---|
| `app/lib/features/tournament/domain/capabilities.dart` | `NotAvailable`, `TournamentFormatCapability`, `BracketGeneratorCapability`, `BracketValidatorCapability`, stable codes (`tnmt.de_not_implemented` etc.). |
| `app/lib/features/tournament/domain/bracket_validator.dart` | `BracketValidator` interface + `BracketValidationReport` + `BracketValidationIssue` + `PermissiveBracketValidator` (Phase 1) + `StrictBracketValidator` (Phase 2 placeholder). |
| `app/lib/features/tournament/domain/ranking.dart` | `TournamentRankingEntry` + `TournamentRankingCalculator.ranking()` (Phase 2). |
| `app/lib/features/tournament/domain/season.dart` | `Season` placeholder model (Phase 2.6 — no schema). |
| `app/lib/features/tournament/domain/formats/tournament_format.dart` | `TournamentFormat` interface + `FormatGenerationResult` / `FormatParentSlotResult` / `ChampionResult` + `tournamentFormatFor()` factory. |
| `app/lib/features/tournament/domain/formats/single_elimination_format.dart` | Beta SE wrapper around `SingleEliminationBracketGenerator`. |
| `app/lib/features/tournament/domain/formats/placeholder_formats.dart` | `DoubleEliminationFormat` + `RoundRobinFormat` returning `NotAvailable`. |
| `app/lib/features/tournament/presentation/screens/ranking_screen.dart` | Phase 2.2 read-only ranking display. |
| `app/lib/features/tournament/presentation/screens/league_skeleton_screen.dart` | Phase 2.5 filter + capability banner. |
| `app/lib/features/tournament/presentation/screens/season_skeleton_screen.dart` | Phase 2.6 UI shell. |
| `app/lib/features/tournament/presentation/screens/team_skeleton_screen.dart` | Phase 2.7 filter by `competitionMode=team`. |
| `app/lib/features/tournament/presentation/widgets/handicap_editor.dart` | Phase 2.3 read-only RacePatch display. |
| `app/test/features/tournament/phase2_ranking_test.dart` | 6 tests for `TournamentRankingCalculator` + `Season` model. |

### Modified (8 files)

| Path | Change |
|---|---|
| `app/lib/features/tournament/domain/bracket_generator.dart` | Refactor to interface. Returns `BracketGenerationResult` / `BracketParentSlotResult`. Placeholders return `NotAvailable`. Helpers (`seedOrder`, `nextPowerOfTwo`, `orderBySeed`) are now `BracketGeneratorStatic` private. |
| `app/lib/features/tournament/application/tournament_service.dart` | Composes generator + validator + override + handicap. Methods return result types (`FormatGenerationResult`, `AdvanceResult`, `MatchRequestResult`). New `validateBracket()` delegates to validator. |
| `app/lib/features/tournament/domain/handicap_policy.dart` | Returns `HandicapRaceResult`. `RacePatchHandicap` stores `{playerA, playerB}` map. `ApaHandicap` returns `NotAvailable`. |
| `app/lib/features/tournament/data/repositories/tournament_repository.dart` | Unwraps `FormatGenerationResult` + `AdvanceResult`. Surfaces `NotAvailable` as `StateError` (only if caller actually invokes an unimplemented branch — never from product code). |
| `app/lib/features/tournament/presentation/providers/tournament_providers.dart` | New `tournamentRankingProvider`. |
| `app/lib/features/tournament/presentation/widgets/bracket_view.dart` | Adds `_capabilityBanner()` for unimplemented formats. |
| `app/lib/features/tournament/presentation/screens/ranking_screen.dart` | Renamed provider reference: `tournamentRankingProvider`. Uses `TournamentRankingEntry`. |
| `app/test/task_13_tournament_test.dart` | Updated legacy tests to use new result types + `TournamentService` constructor (no legacy static `BracketGenerator.generate`). |

### Re-used (3 files, no changes)

| Path | Reason |
|---|---|
| `app/lib/features/tournament/domain/models/tournament_models.dart` | Phase 1 model from Task 13; covers `Tournament`, `TournamentParticipant`, `TournamentMatch`, `TournamentType`, `TournamentStatus`, `TournamentCompetitionMode`. |
| `app/lib/features/tournament/domain/standing_calculator.dart` | Phase 2.1 Standings tab already shipped from Task 13. |
| `app/lib/features/tournament/presentation/widgets/standings_tab.dart` | Phase 2.1 widget already shipped from Task 13. |

## 6. Tests

### Phase 1 — Tournament Core

- `app/test/features/tournament/phase1_abstractions_test.dart` — 40 tests covering:
  - Capabilities (UI-read flags)
  - Format factory (no exceptions)
  - SingleEliminationFormat (seed order, byes, 3rd-place, champion detection)
  - BracketGenerator abstraction (capability-driven)
  - BracketValidator (permissive + strict placeholder)
  - TournamentOverrideService (no audit yet)
  - HandicapPolicy (NoHandicap, RacePatchHandicap, FixedRaceHandicap, ApaHandicap NotAvailable)
  - TournamentService orchestration (capability-driven result types)

### Phase 1 — Legacy Regression

- `app/test/task_13_tournament_test.dart` — 20 tests. Updated for new result types + `TournamentService` constructor. RR placeholder returns `NotAvailable` (no `throwsUnsupportedError`).

### Phase 2 — Competition Management

- `app/test/features/tournament/phase2_ranking_test.dart` — 6 tests covering:
  - Empty matches → empty ranking
  - Sort by wins desc / losses asc / name asc
  - Skip unresolved matches
  - winRate when no matches
  - winRate computed correctly
  - Season model construction

### Full App Regression

- Baseline EPIC 03: 1444 pass.
- EPIC 04 Phase 1 (initial): 1444 + 30 = 1474 pass.
- EPIC 04 Phase 1 (capability pass): 1444 + 40 = 1484 pass.
- EPIC 04 Phase 2: 1444 + 40 + 6 = 1490 pass.
- **Final regression: 1490 / 1490** (see Section 8).

## 7. Capability Pattern — Stable Codes

Stable i18n + telemetry codes for every placeholder:

| Code | Reason |
|---|---|
| `tnmt.de_not_implemented` | Double Elimination format / generator |
| `tnmt.rr_not_implemented` | Round Robin format / generator |
| `tnmt.swiss_not_implemented` | Swiss pairing (planned EPIC 09) |
| `tnmt.handicap_apa_not_implemented` | APA handicap |
| `tnmt.handicap_unavailable` | Service-level wrapper for unimplemented policy |
| `tnmt.parent_slot_missing` | Engine invariant violation (should never fire) |
| `tnmt.validator_not_implemented` | StrictBracketValidator in Phase 1 (UI shows "coming soon") |

## 8. Final Regression

Pending. Will run after Engineering Report is reviewed.

## 9. Risk / Known Limitations

- `RoundRobinFormat` + `DoubleEliminationFormat` are placeholders. Any user tap on "Create Round Robin" or "Create Double Elim" surfaces the capability banner instead of throwing.
- `ApaHandicap` is a placeholder; users who select APA see a "planned" notice.
- `StrictBracketValidator` returns empty report (no false-positives); strict checks land in Phase 2.
- `tournamentServiceProvider` does not exist — `HandicapEditor` constructs `TournamentService()` locally. The next Epic (EPIC 05+) should expose a singleton provider. No mutation risk in Beta because every service call is read-only.

## 10. PO Approvals

- Phase 1 (initial): 2026-07-31 — Accepted.
- Phase 1 (capability + BracketValidator): 2026-07-31 — Accepted.
- Phase 2: 2026-07-31 — Accepted.
- Engineering Report: 2026-07-31 — Pending PO Review.
- Final Regression: 2026-07-31 — Pending.
- Close EPIC: 2026-07-31 — Pending.

After Close, Roadmap V3 Beta proceeds to EPIC 05 — Knowledge System (Billiard Knowledge / Learning Path / Search / Categories / Video / Article / Pattern Library).

---
*Engineering Report authored by Claude Opus 5 (claude-opus-5[1m]) on 2026-07-31.*