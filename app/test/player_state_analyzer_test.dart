import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/player_state/domain/player_state_analyzer.dart';

/// Unit tests for the Player State warm-up analysis (doc §3, §9).
/// Pure logic — no DB, no Flutter widgets.
void main() {
  const analyzer = PlayerStateAnalyzer();

  // Helpers to build racks of a given quality without repeating every field.
  Rack goodRack(int n) => Rack(
        matchId: 1,
        rackNumber: n,
        result: true,
        ballsPotted: 8,
        largestRun: 6,
        breakSuccess: true,
        confidence: 8,
      );

  Rack badRack(int n) => Rack(
        matchId: 1,
        rackNumber: n,
        result: false,
        ballsPotted: 1,
        largestRun: 0,
        easyMissCount: 3,
        scratchErrorCount: 1,
        confidence: 3,
      );

  group('rackQuality', () {
    test('good rack scores higher than bad rack', () {
      expect(analyzer.rackQuality(goodRack(1)),
          greaterThan(analyzer.rackQuality(badRack(1))));
    });

    test('score stays within 0..100', () {
      expect(analyzer.rackQuality(goodRack(1)), inInclusiveRange(0, 100));
      expect(analyzer.rackQuality(badRack(1)), inInclusiveRange(0, 100));
    });
  });

  group('warmUpIndex — insufficient data (doc §9: never fabricate)', () {
    test('returns not-enough-data below the minimum rack count', () {
      final racks = [goodRack(1), goodRack(2)]; // < minRacksForWarmUp
      final insight = analyzer.warmUpIndex(racks);
      expect(insight.hasEnoughData, isFalse);
      expect(insight.isSlowStarter, isFalse);
    });

    test('empty list is handled without throwing', () {
      final insight = analyzer.warmUpIndex(const []);
      expect(insight.hasEnoughData, isFalse);
    });
  });

  group('warmUpIndex — slow starter (doc §3)', () {
    test('bad early racks then good later racks => needs warm-up', () {
      // Racks 1-3 poor, racks 4-8 strong: the classic "vào tay" curve.
      final racks = [
        badRack(1),
        badRack(2),
        badRack(3),
        goodRack(4),
        goodRack(5),
        goodRack(6),
        goodRack(7),
        goodRack(8),
      ];
      final insight = analyzer.warmUpIndex(racks);

      expect(insight.hasEnoughData, isTrue);
      expect(insight.warmUpRacks, greaterThanOrEqualTo(2),
          reason: 'the leading poor racks should be counted as warm-up');
      expect(insight.improvementSlope, greaterThan(0),
          reason: 'later form is better than early form');
      expect(insight.isSlowStarter, isTrue);
    });
  });

  group('warmUpIndex — fast starter', () {
    test('consistently strong racks => no warm-up needed', () {
      final racks = [
        goodRack(1),
        goodRack(2),
        goodRack(3),
        goodRack(4),
        goodRack(5),
        goodRack(6),
      ];
      final insight = analyzer.warmUpIndex(racks);

      expect(insight.hasEnoughData, isTrue);
      expect(insight.warmUpRacks, 0,
          reason: 'no leading rack falls below the settled baseline');
      expect(insight.isSlowStarter, isFalse);
    });
  });
}
