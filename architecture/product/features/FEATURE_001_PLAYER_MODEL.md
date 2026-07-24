# FEATURE_001 Player Model And Progression

Version: 1.0

Status: Accepted; Closed

## Goal

Build a deterministic Player progression companion for the existing Player.
It supplies current skill, progress, strengths, weaknesses, trend, mastery and
confidence from completed Match, Training and Knowledge Mastery data.

This feature does not replace Player Profile and must not create a competing
Player or Player Model aggregate. The implementation is a projection bound to
the existing Player identity.

## User Value

After completed Match or Training data exists, the Player surface shows more
than win rate: overall skill, dimension scores, progress trend, top strengths,
top weaknesses, mastery and confidence.

## Existing Ownership

Player progression owns only the derived skill projection. Match owns Match and
Rack facts, Training owns Training facts, Knowledge/Mastery owns mastery facts,
Player owns identity/profile, and Coach/Analytics/Simulation/Tournament retain
their existing responsibilities.

## Constraints

- immutable, deterministic and replayable projection;
- scores use the inclusive 0-100 scale;
- refresh only after Match Finish or Training Finish, never realtime;
- use only existing Match, Training and Knowledge Mastery data;
- add an additive Player-bound persistence table through the existing Player
  repository; create no new repository;
- preserve M3.1 `PlayerProgressSnapshot` and all accepted contracts;
- no AI, LLM, prediction, online service or ELO.

## Data

The projection contains Player identity, overall, break, potting, position,
safety, cue-ball control, kick/jump, mental, consistency, confidence, trend,
mastery, source counts, top-five strengths/weaknesses, trend points,
last-updated source time, version, source digest and projection digest.

## UI

Extend the existing Player Profile surface without redesigning it. Add Player
Model overall, radar chart, trend, strengths, weaknesses, mastery and confidence.

## Prohibitions

No Coach logic, Recommendation, AI, Analytics owner, Ranking, Prediction,
League or Tournament logic. Do not modify Match, Training or Player facts.

## Acceptance Criteria

- completed Match refreshes the active Player projection;
- completed Training refreshes the active Player projection;
- Player Profile renders overall, radar, trend, strengths, weaknesses, mastery
  and confidence;
- calculations are deterministic and all scores remain 0-100;
- persisted projection survives database restart;
- existing I1-I12 behavior and full regression remain green.

## Test Checklist

- unit: calculation, trend, mastery, confidence and deterministic digest;
- persistence: projection round trip and restart;
- integration: Match finish and Training finish refresh hooks;
- widget: Player Model section, radar and trend chart;
- regression: Match, Training, Coach, Analytics, Home and I10;
- analyzer, formatter, Knowledge package and Architecture Fitness.

## Done

Product Owner accepted the feature on 2026-07-24. Engineering verification at
acceptance: focused 17/17, full app 1193/1193, Knowledge 75/75, Foundation
Freeze 76/76, Architecture Fitness 133 existing/0 new, focused analyzer and
formatter clean. SQLite close/reopen and delete/rebuild tests prove the
projection is a rebuildable cache and canonical replay is byte-for-byte stable.
