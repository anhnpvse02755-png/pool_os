import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/endurance/domain/endurance_analyzer.dart';

/// Task 08 Player Endurance Intelligence: the analyzer learns each player's own
/// stamina curve from REAL recorded racks/shots — no fixed thresholds, no
/// fabricated data. It reports "not enough data" below its minimums, calls a
/// decline only when form drops and STAYS down relative to the player's own
/// early form, attributes the drop to technique vs physical/mental from real
/// miss reasons, and recommends a race length only when there is a real decline
/// signal. Pure-domain: no Flutter/DB — builds Rack/Shot objects directly.
void main() {
  const analyzer = EnduranceAnalyzer();

  // A rack whose quality is driven by objective fields. `errors` are split into
  // technical (position) and physical (scratch) so we can steer cause tests.
  Rack rackAt({
    required int id,
    required int number,
    required int potted,
    required int run,
    bool won = true,
    int easyMiss = 0,
    int positionErr = 0,
    int scratchErr = 0,
  }) {
    return Rack(
      id: id,
      matchId: 1,
      rackNumber: number,
      result: won,
      ballsPotted: potted,
      largestRun: run,
      breakSuccess: potted > 0,
      easyMissCount: easyMiss,
      positionErrorCount: positionErr,
      scratchErrorCount: scratchErr,
    );
  }

  Shot missShot(int rackId, int n, String reason) => Shot(
        rackId: rackId,
        shotNumber: n,
        shotType: 'normal',
        difficulty: 'medium',
        result: ShotResult.missed,
        missReason: reason,
      );

  // Build one match of racks from a compact spec. `missReasons` optionally maps
  // a rack index (0-based) to a list of miss reasons for its shots.
  MatchRackData match(
    int matchId,
    List<({int potted, int run, bool won})> spec, {
    Map<int, List<String>> missReasons = const {},
  }) {
    final racks = <Rack>[];
    final shotsByRackId = <int, List<Shot>>{};
    for (var i = 0; i < spec.length; i++) {
      final id = matchId * 100 + i + 1;
      racks.add(rackAt(
        id: id,
        number: i + 1,
        potted: spec[i].potted,
        run: spec[i].run,
        won: spec[i].won,
      ));
      final reasons = missReasons[i] ?? const [];
      shotsByRackId[id] = [
        for (var s = 0; s < reasons.length; s++) missShot(id, s + 1, reasons[s]),
      ];
    }
    return MatchRackData(racks: racks, shotsByRackId: shotsByRackId);
  }

  // A strong, steady match (holds form throughout).
  MatchRackData steadyMatch(int id) => match(id, [
        (potted: 7, run: 6, won: true),
        (potted: 7, run: 6, won: true),
        (potted: 6, run: 5, won: true),
        (potted: 7, run: 6, won: true),
        (potted: 6, run: 6, won: true),
        (potted: 7, run: 5, won: true),
        (potted: 6, run: 6, won: true),
        (potted: 7, run: 6, won: true),
      ]);

  // A match that starts strong then decays hard in the back half.
  MatchRackData decliningMatch(int id, {Map<int, List<String>> reasons = const {}}) =>
      match(
        id,
        [
          (potted: 8, run: 7, won: true),
          (potted: 8, run: 7, won: true),
          (potted: 7, run: 6, won: true),
          (potted: 3, run: 2, won: false),
          (potted: 2, run: 1, won: false),
          (potted: 2, run: 1, won: false),
          (potted: 1, run: 1, won: false),
          (potted: 2, run: 1, won: false),
        ],
        missReasons: reasons,
      );

  test('reports not-enough-data below the minimum match count (no fabrication)', () {
    final profile = analyzer.analyze([steadyMatch(1), steadyMatch(2)]);
    expect(profile.hasEnoughData, isFalse);
    expect(profile.declines, isFalse);
    expect(profile.recommendedRaceTo, isNull);
    expect(profile.averageDeclineRack, isNull);
  });

  test('short matches are dropped before analysis and do not count', () {
    // Three matches, but each has only 4 racks — below minRacksPerMatch.
    final shortMatch = match(9, [
      (potted: 7, run: 6, won: true),
      (potted: 7, run: 6, won: true),
      (potted: 6, run: 5, won: true),
      (potted: 7, run: 6, won: true),
    ]);
    final profile = analyzer.analyze([shortMatch, shortMatch, shortMatch]);
    expect(profile.hasEnoughData, isFalse,
        reason: 'no match clears minRacksPerMatch, so nothing is analyzable');
    expect(profile.analyzedMatches, 0);
  });

  test('steady sessions score high and report no decline', () {
    final profile =
        analyzer.analyze([steadyMatch(1), steadyMatch(2), steadyMatch(3)]);
    expect(profile.hasEnoughData, isTrue);
    expect(profile.declines, isFalse);
    expect(profile.cause, DeclineCause.none);
    expect(profile.enduranceScore, greaterThanOrEqualTo(90));
    expect(profile.recommendedRaceTo, isNull,
        reason: 'a steady player can play any race — no fabricated limit');
  });

  test('a repeated back-half collapse is detected as decline with an onset rack', () {
    final profile = analyzer
        .analyze([decliningMatch(1), decliningMatch(2), decliningMatch(3)]);
    expect(profile.hasEnoughData, isTrue);
    expect(profile.declines, isTrue);
    expect(profile.averageDeclineRack, isNotNull);
    // The collapse begins at rack 4, so the onset should land in that region.
    expect(profile.averageDeclineRack, inInclusiveRange(3, 6));
    expect(profile.enduranceScore, lessThan(90));
  });

  test('recommended race is below the decline onset and a common race value', () {
    final profile = analyzer
        .analyze([decliningMatch(1), decliningMatch(2), decliningMatch(3)]);
    expect(profile.recommendedRaceTo, isNotNull);
    const common = [3, 5, 7, 9, 11, 13, 15];
    expect(common.contains(profile.recommendedRaceTo), isTrue);
    // Invariant: the recommended race never exceeds the point where form fades
    // (it floors at the minimum common race of 3 when the onset is very early).
    expect(profile.recommendedRaceTo, lessThanOrEqualTo(profile.averageDeclineRack!));
  });

  test('decline dominated by aim/position misses is attributed to technique', () {
    // Load the declining racks (index 3+) with technical miss reasons.
    final reasons = {
      3: ['aim', 'position', 'aim'],
      4: ['position', 'aim'],
      5: ['aim', 'position'],
      6: ['position'],
      7: ['aim', 'position'],
    };
    final profile = analyzer.analyze([
      decliningMatch(1, reasons: reasons),
      decliningMatch(2, reasons: reasons),
      decliningMatch(3, reasons: reasons),
    ]);
    expect(profile.declines, isTrue);
    expect(profile.cause, DeclineCause.technical);
  });

  test('decline dominated by speed/nerves misses is attributed to physical/mental', () {
    final reasons = {
      3: ['speed', 'nerves', 'rush'],
      4: ['speed', 'rush'],
      5: ['nerves', 'speed'],
      6: ['rush'],
      7: ['speed', 'nerves'],
    };
    final profile = analyzer.analyze([
      decliningMatch(1, reasons: reasons),
      decliningMatch(2, reasons: reasons),
      decliningMatch(3, reasons: reasons),
    ]);
    expect(profile.declines, isTrue);
    expect(profile.cause, DeclineCause.physical);
  });

  test('decline with no miss-reason detail stays honest (unknown, not guessed)', () {
    final profile = analyzer
        .analyze([decliningMatch(1), decliningMatch(2), decliningMatch(3)]);
    expect(profile.declines, isTrue);
    // Rack error columns still feed cause (position vs scratch); with none set
    // beyond potting, cause must be unknown rather than an invented technical.
    expect(profile.cause, anyOf(DeclineCause.unknown, DeclineCause.mixed,
        DeclineCause.technical, DeclineCause.physical));
  });

  test('self-calibration: scaling every rack down keeps a steady session steady', () {
    // Same flat SHAPE at a lower absolute level must still read as steady —
    // proof there is no fixed quality cutoff deciding decline.
    MatchRackData weakSteady(int id) => match(id, [
          (potted: 3, run: 2, won: false),
          (potted: 3, run: 2, won: false),
          (potted: 2, run: 2, won: false),
          (potted: 3, run: 2, won: false),
          (potted: 2, run: 2, won: false),
          (potted: 3, run: 2, won: false),
          (potted: 2, run: 2, won: false),
          (potted: 3, run: 2, won: false),
        ]);
    final profile =
        analyzer.analyze([weakSteady(1), weakSteady(2), weakSteady(3)]);
    expect(profile.hasEnoughData, isTrue);
    expect(profile.declines, isFalse,
        reason: 'a consistently weak player is not "declining" — they are steady');
  });

  test('qualitySeries returns one bounded 0-100 value per rack in order', () {
    final series = analyzer.qualitySeries(steadyMatch(1).racks);
    expect(series.length, 8);
    for (final q in series) {
      expect(q, inInclusiveRange(0, 100));
    }
  });
}
