# FEATURE_002 Equipment Performance Profile

Version: 1.0

Status: Accepted; Closed

## Goal

Allow the active Player to manage existing Equipment and inspect the measured
performance of each cue from completed Match and Training facts.

## User Value

The Equipment surface shows completed matches, match win rate, completed
training sessions, training success rate, recorded duration and last-used time
for each cue. It provides facts only and does not recommend an equipment choice.

## Ownership

Equipment owns cue identity/profile, active selection and the rebuildable
Equipment performance projection. Match and Training retain their source facts;
Player retains identity. Player Model, Coach, Analytics, Recommendation,
Ranking, League and Tournament ownership do not change.

## Inputs And Outputs

Inputs are the active Player, existing cues, immutable Match equipment
snapshots, completed Match facts, completed Training Session facts and recorded
Rack outcomes. Output is immutable `EquipmentPerformanceProjection` v1 with
Player/Cue binding, totals, rates, duration, last used, source digest and digest.

## Allowed Surfaces

- `app/lib/features/equipment/`;
- existing Player/Match/Training completion and display integration;
- additive Drift schema and generated output;
- related tests, this feature spec and `MEMORY.md` after acceptance.

## Prohibitions

No AI, Coach, Recommendation, Prediction, Ranking, Analytics Engine, new
repository, new runtime, HTTP/API, cloud sync, League, Tournament or background
worker. Match and Training facts and FEATURE_001 Player Model remain unchanged.

## Acceptance Criteria

- canonical replay and digest are deterministic;
- deleting the projection cache and rebuilding reproduces identical JSON;
- refresh happens only after successful Match Finish or Training Finish;
- SQLite restart preserves the projection;
- immutable Match equipment snapshots preserve equipment-switch attribution;
- Equipment UI shows performance for each cue;
- full regression and protected suites remain green.

## Tests

Unit determinism and validation, persistence/rebuild, completion refresh,
equipment-switch correctness, widget rendering, full app, Knowledge, Foundation
Freeze, analyzer, formatter and Architecture Fitness.

## Stop

After implementation and verification, send only an Engineering Report and
wait for Product Owner review before commit or push.

## Engineering Evidence

Product Owner accepted and closed FEATURE_002 on 2026-07-24. Focused tests pass
19/19 and prove canonical calculation, SQLite persistence, Player-scoped active
selection, immutable Match and Training equipment attribution, and complete
source-fact rebuild equality across every serialized projection field. Full app
tests pass 1202/1202, Knowledge passes 75/75, Foundation Freeze passes 76/76,
and Architecture Fitness remains 133 existing violations with 0 new. Focused
analyzer, formatter and `git diff --check` are clean. Protected artifacts,
Golden fixtures, production Knowledge, publication artifacts, Player Model and
the Constitution are unchanged.
