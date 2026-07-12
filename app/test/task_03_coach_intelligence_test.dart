import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/coach/domain/coach_intelligence.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

/// TASK 03 — Coach Intelligence v1.
///
/// The engine is a pure read-side analyzer, so these tests feed it the same
/// real domain shapes the provider loads from the DB (Session/Match/Rack/Shot)
/// and assert it answers the four Coach questions from that data — never from
/// fabricated numbers. Every asserted claim is traceable to a shot we recorded.
void main() {
  final start = DateTime(2026, 7, 12, 9, 0);

  Session session() => Session(
        id: 1,
        sessionType: SessionTypes.practice,
        startedAt: start,
        finishedAt: start.add(const Duration(minutes: 90)),
      );

  Match match() => Match(
        id: 1,
        sessionId: 1,
        matchNumber: 1,
        gameType: 'practice',
        startTime: start,
      );

  Shot shot({
    required int rackId,
    required int n,
    required String type,
    required String result,
    String? missReason,
    DateTime? at,
  }) =>
      Shot(
        id: rackId * 100 + n,
        rackId: rackId,
        shotNumber: n,
        shotType: type,
        difficulty: ShotDifficulty.medium,
        result: result,
        missReason: missReason,
        createdAt: at ?? start,
      );

  Rack rack(int id, int number, bool won, DateTime at) => Rack(
        id: id,
        matchId: 1,
        rackNumber: number,
        result: won,
        createdAt: at,
      );

  test('insufficient data below the min shot sample', () {
    final r = rack(1, 1, true, start);
    final report = CoachIntelligence.analyzeSession(
      session: session(),
      matches: [match()],
      racksByMatch: {
        1: [r]
      },
      shotsByRack: {
        1: [
          shot(rackId: 1, n: 1, type: ShotTypes.normalShot, result: ShotResult.made),
          shot(rackId: 1, n: 2, type: ShotTypes.normalShot, result: ShotResult.made),
        ],
      },
      missReasonCounts: const {},
      locale: 'en',
    );

    expect(report.hasData, isFalse);
    expect(report.recommendations, isEmpty);
  });

  test('Q1-Q4: weak shot type + dominant miss reason are cited from real data', () {
    // One rack, 11 shots. Bank shots are deliberately weak (1/5 = 20%, meeting
    // the min sample of 5), straight strong (5/6). Misses tagged -> "speed" dominates.
    final r = rack(1, 1, true, start);
    final shots = <Shot>[
      // 6 straight shots: 5 made, 1 missed (aim)
      shot(rackId: 1, n: 1, type: ShotTypes.normalShot, result: ShotResult.made),
      shot(rackId: 1, n: 2, type: ShotTypes.normalShot, result: ShotResult.made),
      shot(rackId: 1, n: 3, type: ShotTypes.normalShot, result: ShotResult.made),
      shot(rackId: 1, n: 4, type: ShotTypes.normalShot, result: ShotResult.made),
      shot(rackId: 1, n: 5, type: ShotTypes.normalShot, result: ShotResult.made),
      shot(rackId: 1, n: 6, type: ShotTypes.normalShot, result: ShotResult.missed, missReason: 'aim'),
      // 5 bank shots: 1 made, 4 missed (all speed)
      shot(rackId: 1, n: 7, type: ShotTypes.bankShot, result: ShotResult.made),
      shot(rackId: 1, n: 8, type: ShotTypes.bankShot, result: ShotResult.missed, missReason: 'speed'),
      shot(rackId: 1, n: 9, type: ShotTypes.bankShot, result: ShotResult.missed, missReason: 'speed'),
      shot(rackId: 1, n: 10, type: ShotTypes.bankShot, result: ShotResult.missed, missReason: 'speed'),
      shot(rackId: 1, n: 11, type: ShotTypes.bankShot, result: ShotResult.missed, missReason: 'speed'),
    ];

    final report = CoachIntelligence.analyzeSession(
      session: session(),
      matches: [match()],
      racksByMatch: {
        1: [r]
      },
      shotsByRack: {1: shots},
      missReasonCounts: const {'speed': 4, 'aim': 1},
      locale: 'en',
    );

    expect(report.hasData, isTrue);
    expect(report.totalShots, 11);
    expect(report.madeShots, 6);

    // Q2: the why-points must cite the weak bank shots and the speed misses.
    final why = report.whyPoints.join(' | ').toLowerCase();
    expect(why, contains('bank'));
    expect(why, contains('20%'));
    expect(why, contains('speed'));

    // Q3: at most 3 recommendations, first targets the weakest shot type.
    expect(report.recommendations.length, lessThanOrEqualTo(3));
    expect(report.recommendations, isNotEmpty);
    final first = report.recommendations.first;
    expect(first.title.toLowerCase(), contains('bank'));

    // Q4: every recommendation carries reason + data + expected (all non-empty).
    for (final rec in report.recommendations) {
      expect(rec.reason.trim(), isNotEmpty);
      expect(rec.data.trim(), isNotEmpty);
      expect(rec.expected.trim(), isNotEmpty);
    }
    // The weak-type rec's data must quote the real 1/5 sample.
    expect(first.data, contains('1/5'));
  });

  test('recommendations link to a real drill from the catalog', () {
    final r = rack(1, 1, false, start);
    final shots = List.generate(
      8,
      (i) => shot(
        rackId: 1,
        n: i + 1,
        type: ShotTypes.safetyShot,
        result: i == 0 ? ShotResult.made : ShotResult.missed,
        missReason: i == 0 ? null : 'position',
      ),
    );

    final report = CoachIntelligence.analyzeSession(
      session: session(),
      matches: [match()],
      racksByMatch: {
        1: [r]
      },
      shotsByRack: {1: shots},
      missReasonCounts: const {'position': 7},
      locale: 'en',
    );

    // Safety was weak (1/8) -> first rec should point at a real drill code.
    expect(report.recommendations, isNotEmpty);
    expect(report.recommendations.first.drillCode, isNotNull);
    expect(report.recommendations.first.drillCode!.trim(), isNotEmpty);
  });

  test('within-session decline is detected from real rack timestamps', () {
    // 6 racks: first three accurate, last three poor, spaced 15 min apart so the
    // pivot lands ~45 min in. Trend must read as declining and cite the drop.
    final racks = <Rack>[];
    final shotsByRack = <int, List<Shot>>{};
    for (var i = 0; i < 6; i++) {
      final rackId = i + 1;
      final at = start.add(Duration(minutes: i * 15));
      racks.add(rack(rackId, i + 1, i < 3, at));
      final strong = i < 3;
      shotsByRack[rackId] = List.generate(
        5,
        (j) => shot(
          rackId: rackId,
          n: j + 1,
          type: ShotTypes.normalShot,
          // first half ~80% made, second half ~20% made
          result: (strong ? j < 4 : j < 1) ? ShotResult.made : ShotResult.missed,
          at: at,
        ),
      );
    }

    final report = CoachIntelligence.analyzeSession(
      session: session(),
      matches: [match()],
      racksByMatch: {1: racks},
      shotsByRack: shotsByRack,
      missReasonCounts: const {},
      locale: 'en',
    );

    expect(report.trend.hasData, isTrue);
    expect(report.trend.direction, TrendDirection.declining);
    // Headline (Q1) should mention the fade.
    expect(report.headline.toLowerCase(), contains('dropped'));
    // A recommendation about resting should appear, backed by the real minutes.
    final restRec = report.recommendations.where(
        (r) => r.title.toLowerCase().contains('rest'));
    expect(restRec, isNotEmpty);
  });
}
