import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/match/domain/models/match_context.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot_builder.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

void main() {
  final now = DateTime(2026, 7, 20, 12);

  Match match(int id, {String gameType = GameTypes.raceTo}) => Match(
        id: id,
        sessionId: id,
        matchNumber: 1,
        gameType: gameType,
        startTime: now.subtract(Duration(hours: id + 1)),
        endTime: now.subtract(Duration(hours: id)),
      );

  Shot shot(
    int rackId,
    int number, {
    bool made = true,
    String? decision,
    String? position,
    String? intent,
  }) =>
      Shot(
        rackId: rackId,
        shotNumber: number,
        shotType:
            intent == 'safety' ? ShotTypes.safetyShot : ShotTypes.normalShot,
        difficulty: ShotDifficulty.medium,
        result: made ? ShotResult.made : ShotResult.missed,
        decision: decision,
        positionQuality: position,
        intent: intent,
      );

  test('returns unavailable metrics instead of fabricated zeroes', () {
    final snapshot = PerformanceSnapshotBuilder().build([], now: now);

    expect(snapshot.sourceMatches, 0);
    for (final dimension in PerformanceDimension.values) {
      final metric = snapshot.metric(dimension);
      expect(metric.score, isNull);
      expect(metric.confidence, PerformanceConfidence.insufficient);
    }
  });

  test('uses completed competition matches and versioned measured signals', () {
    final samples = <PerformanceMatchSample>[];
    const madeByMatch = [5, 3, 2];
    for (var index = 0; index < madeByMatch.length; index++) {
      final matchId = index + 1;
      final rackId = matchId * 10;
      final shots = <Shot>[];
      for (var i = 0; i < 5; i++) {
        shots.add(shot(
          rackId,
          i + 1,
          made: i < madeByMatch[index],
          decision: i == 0 ? 'good' : (i == 1 ? 'bad' : null),
          position: PositionQuality.all[i],
        ));
      }
      samples.add(PerformanceMatchSample(
        match: match(matchId),
        racks: [
          Rack(
            id: rackId,
            matchId: matchId,
            rackNumber: 1,
            result: true,
            breakSuccess: index != 2,
          ),
          Rack(
            id: rackId + 1,
            matchId: matchId,
            rackNumber: 2,
            result: false,
            breakSuccess: index == 0,
          ),
        ],
        shots: shots,
        context: MatchContext(
          matchId: matchId,
          mentalState: [
            MentalState.ok,
            MentalState.normal,
            MentalState.pressure
          ][index],
        ),
      ));
    }

    final snapshot = PerformanceSnapshotBuilder().build(samples, now: now);

    expect(snapshot.version, PerformanceSnapshot.currentVersion);
    expect(snapshot.sourceMatches, 3);
    expect(snapshot.sourceRacks, 6);
    expect(snapshot.sourceShots, 15);
    expect(snapshot.metric(PerformanceDimension.execution).score, 66.7);
    expect(snapshot.metric(PerformanceDimension.decision).score, 50.0);
    expect(snapshot.metric(PerformanceDimension.cueBall).score, 55.0);
    expect(snapshot.metric(PerformanceDimension.breakShot).score, 50.0);
    expect(snapshot.metric(PerformanceDimension.mental).score, 56.7);
    expect(snapshot.metric(PerformanceDimension.consistency).score, 50.1);
    expect(
      snapshot.metric(PerformanceDimension.safety).score,
      isNull,
      reason: 'A potted-ball result is not a tactical safety outcome.',
    );
  });

  test('excludes active and non-competition matches', () {
    final active = Match(
      id: 1,
      sessionId: 1,
      matchNumber: 1,
      gameType: GameTypes.raceTo,
      startTime: now,
    );
    final practice = match(2, gameType: GameTypes.practiceMatch);
    final snapshot = PerformanceSnapshotBuilder().build([
      PerformanceMatchSample(match: active),
      PerformanceMatchSample(match: practice),
    ]);

    expect(snapshot.sourceMatches, 0);
  });
}
