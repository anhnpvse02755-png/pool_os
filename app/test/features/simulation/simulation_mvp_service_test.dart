import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/simulation/application/simulation_mvp_service.dart';

void main() {
  group('SimulationMvpService', () {
    test('replays only the selected existing-data scenario', () async {
      final preview = await _service.preview(const SimulationRequest(
        requestId: 'match-only',
        scenario: SimulationScenarioKind.matchReplay,
      ));

      expect(preview.samples.map((item) => item.kind).toSet(),
          {SimulationSampleKind.match});
      expect(preview.samples.map((item) => item.id), [11, 10]);
      expect(preview.observedRate, closeTo(0.6, 0.0001));
    });

    test('combined replay is newest-first and respects sample limit', () async {
      final preview = await _service.preview(const SimulationRequest(
        requestId: 'combined',
        scenario: SimulationScenarioKind.combinedReplay,
        sampleLimit: 3,
      ));

      expect(
        preview.samples.map((item) => '${item.kind.name}:${item.id}').toList(),
        ['training:21', 'match:11', 'match:10'],
      );
    });

    test('comparison exposes observed replay delta without prediction',
        () async {
      final comparison = await _service.compare(
        left: const SimulationRequest(
          requestId: 'left',
          scenario: SimulationScenarioKind.matchReplay,
        ),
        right: const SimulationRequest(
          requestId: 'right',
          scenario: SimulationScenarioKind.trainingReplay,
        ),
      );

      expect(comparison.left.observedRate, closeTo(0.6, 0.0001));
      expect(comparison.right.observedRate, closeTo(0.75, 0.0001));
      expect(comparison.observedRateDelta, closeTo(0.15, 0.0001));
    });

    test('preview is deterministic and samples are immutable', () async {
      const request = SimulationRequest(
        requestId: 'replay',
        scenario: SimulationScenarioKind.combinedReplay,
      );
      final first = await _service.preview(request);
      final second = await _service.preview(request);

      expect(first, second);
      expect(
        () => first.samples.add(first.samples.first),
        throwsUnsupportedError,
      );
    });
  });
}

final _service = SimulationMvpService(
  loadMatches: () async => [
    SimulationReplaySample(
      kind: SimulationSampleKind.match,
      id: 10,
      occurredAt: DateTime.utc(2026, 7, 20),
      observedRate: 0.5,
      duration: const Duration(minutes: 40),
    ),
    SimulationReplaySample(
      kind: SimulationSampleKind.match,
      id: 11,
      occurredAt: DateTime.utc(2026, 7, 22),
      observedRate: 0.7,
      duration: const Duration(minutes: 50),
    ),
  ],
  loadTraining: () async => [
    SimulationReplaySample(
      kind: SimulationSampleKind.training,
      id: 20,
      occurredAt: DateTime.utc(2026, 7, 19),
      observedRate: 0.7,
      duration: const Duration(minutes: 50),
    ),
    SimulationReplaySample(
      kind: SimulationSampleKind.training,
      id: 21,
      occurredAt: DateTime.utc(2026, 7, 23),
      observedRate: 0.8,
      duration: const Duration(minutes: 70),
    ),
  ],
);
