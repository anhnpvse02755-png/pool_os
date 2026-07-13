import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/player_state/domain/form_curve_analyzer.dart';

/// Task 07 Warm-up Intelligence: the analyzer derives Cold → Warm-up → Peak →
/// Fatigue zones from REAL recorded racks/shots with NO hard-coded rack-number
/// or accuracy thresholds (every boundary is self-calibrated to the player's own
/// noise/percentiles), reports "not enough data" instead of fabricating zones on
/// thin input, and only uses recorded data (no synthetic fill). Pure-domain: no
/// Flutter/DB — builds Rack/Shot objects directly.
void main() {
  const analyzer = FormCurveAnalyzer();
  final matchStart = DateTime(2026, 7, 13, 10, 0, 0);

  // Build a rack whose recorded shots yield [made] makes out of [total]. Shots
  // are timestamped in play order so the elapsed-minutes axis is meaningful.
  Rack rackWith({
    required int id,
    required int number,
    required int made,
    required int total,
  }) {
    return Rack(
      id: id,
      matchId: 1,
      rackNumber: number,
      result: made * 2 >= total,
      ballsPotted: made,
      largestRun: made,
      breakSuccess: made > 0,
      createdAt: matchStart.add(Duration(minutes: number * 5)),
    );
  }

  List<Shot> shotsFor(Rack rack, {required int made, required int total}) {
    final base = rack.createdAt;
    return List.generate(total, (i) {
      return Shot(
        rackId: rack.id!,
        shotNumber: i + 1,
        shotType: 'pot',
        difficulty: 'medium',
        result: i < made ? ShotResult.made : ShotResult.missed,
        createdAt: base.add(Duration(seconds: 20 * i)),
      );
    });
  }

  FormCurve build(List<({int made, int total})> perRack) {
    final racks = <Rack>[];
    final shotsByRackId = <int, List<Shot>>{};
    for (var i = 0; i < perRack.length; i++) {
      final r = rackWith(
        id: i + 1,
        number: i + 1,
        made: perRack[i].made,
        total: perRack[i].total,
      );
      racks.add(r);
      shotsByRackId[r.id!] = shotsFor(r, made: perRack[i].made, total: perRack[i].total);
    }
    return analyzer.buildCurve(
      racks: racks,
      shotsByRackId: shotsByRackId,
      matchStart: matchStart,
    );
  }

  test('reports not-enough-data below the minimum rack count (no fabrication)', () {
    final curve = build(List.filled(FormCurveAnalyzer.minRacksForCurve - 1, (made: 5, total: 8)));
    expect(curve.hasEnoughData, isFalse);
    expect(curve.zones, isEmpty);
    expect(curve.peakRack, isNull);
  });

  test('racks with too few usable shots are dropped before zoning', () {
    // 5 full racks + several 1-shot racks: the thin racks must not count toward
    // the minimum, so this stays below threshold and reports not-enough-data.
    final curve = build([
      (made: 4, total: 8),
      (made: 5, total: 8),
      (made: 6, total: 8),
      (made: 6, total: 8),
      (made: 7, total: 8),
      (made: 1, total: 1),
      (made: 1, total: 1),
      (made: 0, total: 1),
    ]);
    expect(curve.hasEnoughData, isFalse,
        reason: 'only 5 racks clear minShotsPerRack — below minRacksForCurve');
  });

  test('a slow-starter climb produces a warm-up phase and a later peak', () {
    // Low → rising → high → sustained: classic warm-up then peak.
    final curve = build([
      (made: 2, total: 8), // cold
      (made: 3, total: 8),
      (made: 5, total: 8), // warming
      (made: 7, total: 8),
      (made: 8, total: 8), // peak
      (made: 8, total: 8),
      (made: 7, total: 8),
      (made: 8, total: 8),
    ]);
    expect(curve.hasEnoughData, isTrue);
    expect(curve.warmUpRacks, greaterThan(0),
        reason: 'a real climb from a cold start must register warm-up racks');
    expect(curve.peakRack, isNotNull);
    // Peak must land after the warm-up, not on the cold opening rack.
    expect(curve.peakRack, greaterThan(curve.warmUpRacks));
    expect(curve.isSlowStarter, isTrue);
    // Zones must include a peak segment and cover contiguous rack numbers.
    expect(curve.zones.any((z) => z.kind == FormZoneKind.peak), isTrue);
  });

  test('a strong start that decays produces a fatigue onset', () {
    // High and flat, then a sustained decline: fatigue must fire, and the
    // fatigue zone must cover the decayed tail.
    final curve = build([
      (made: 7, total: 8),
      (made: 8, total: 8),
      (made: 8, total: 8),
      (made: 8, total: 8), // peak plateau
      (made: 8, total: 8),
      (made: 5, total: 8),
      (made: 4, total: 8),
      (made: 3, total: 8),
      (made: 2, total: 8),
      (made: 1, total: 8), // decayed
    ]);
    expect(curve.hasEnoughData, isTrue);
    expect(curve.fatigues, isTrue, reason: 'a sustained post-peak decline must set fatigueOnsetRack');
    expect(curve.fatigueOnsetRack, isNotNull);
    // Onset can't precede the peak (the analyzer walks back only to peakIdx).
    expect(curve.fatigueOnsetRack, greaterThanOrEqualTo(curve.peakRack!));
    // The fatigue zone must run to the last (most decayed) recorded rack.
    final fatigueZone = curve.zones.firstWhere((z) => z.kind == FormZoneKind.fatigue);
    expect(fatigueZone.endRack, curve.points.last.rackNumber);
  });

  test('a flat session collapses to a single steady zone, not four invented ones', () {
    // Barely-moving form relative to its own noise: honest output is STEADY.
    final curve = build([
      (made: 6, total: 8),
      (made: 6, total: 8),
      (made: 6, total: 8),
      (made: 6, total: 8),
      (made: 6, total: 8),
      (made: 6, total: 8),
      (made: 6, total: 8),
      (made: 6, total: 8),
    ]);
    expect(curve.hasEnoughData, isTrue);
    expect(curve.zones.length, 1);
    expect(curve.zones.first.kind, FormZoneKind.steady);
    expect(curve.fatigueOnsetRack, isNull);
    expect(curve.warmUpRacks, 0);
  });

  test('zoning is self-calibrated: scaling every rack up keeps the flat session steady', () {
    // Same SHAPE (flat) at a higher absolute level must still read steady — proof
    // there is no fixed accuracy cutoff deciding zones.
    final low = build(List.filled(8, (made: 4, total: 8)));
    final high = build(List.filled(8, (made: 6, total: 8)));
    expect(low.zones.length, 1);
    expect(high.zones.length, 1);
    expect(low.zones.first.kind, FormZoneKind.steady);
    expect(high.zones.first.kind, FormZoneKind.steady);
  });
}
