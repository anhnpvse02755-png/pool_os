import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../match/application/match_statistics_service.dart';
import '../../training/application/training_statistics_service.dart';
import '../application/simulation_mvp_service.dart';

final simulationMvpServiceProvider = Provider<SimulationMvpService>((ref) {
  final matches = ref.watch(matchStatisticsServiceProvider);
  final training = ref.watch(trainingStatisticsServiceProvider);
  return SimulationMvpService(
    loadMatches: () async {
      final source = await matches.load();
      return [
        for (final item in source.performance)
          SimulationReplaySample(
            kind: SimulationSampleKind.match,
            id: item.match.id!,
            occurredAt: item.match.endTime!,
            observedRate: item.winRate,
            duration: item.match.duration ?? Duration.zero,
          ),
      ];
    },
    loadTraining: () async {
      final source = await training.load();
      return [
        for (final item in source.recent)
          SimulationReplaySample(
            kind: SimulationSampleKind.training,
            id: item.sessionId,
            occurredAt: item.date,
            observedRate: item.successRate,
            duration: item.duration,
          ),
      ];
    },
  );
});

final simulationSessionProvider =
    StateNotifierProvider<SimulationSessionNotifier, SimulationSessionState>(
        (ref) {
  return SimulationSessionNotifier(ref.watch(simulationMvpServiceProvider));
});

final class SimulationSessionState {
  SimulationSessionState({
    this.leftScenario = SimulationScenarioKind.matchReplay,
    this.rightScenario = SimulationScenarioKind.trainingReplay,
    this.comparison,
    List<SimulationPreview> history = const [],
    this.isLoading = false,
    this.errorCode,
  }) : history = List.unmodifiable(history);

  final SimulationScenarioKind leftScenario;
  final SimulationScenarioKind rightScenario;
  final SimulationComparison? comparison;
  final List<SimulationPreview> history;
  final bool isLoading;
  final String? errorCode;
}

final class SimulationSessionNotifier
    extends StateNotifier<SimulationSessionState> {
  SimulationSessionNotifier(this._service) : super(SimulationSessionState());

  final SimulationMvpService _service;
  var _sequence = 0;

  void selectLeft(SimulationScenarioKind value) {
    state = SimulationSessionState(
      leftScenario: value,
      rightScenario: state.rightScenario,
      comparison: state.comparison,
      history: state.history,
    );
  }

  void selectRight(SimulationScenarioKind value) {
    state = SimulationSessionState(
      leftScenario: state.leftScenario,
      rightScenario: value,
      comparison: state.comparison,
      history: state.history,
    );
  }

  Future<void> compare() async {
    if (state.isLoading) return;
    final left = state.leftScenario;
    final right = state.rightScenario;
    state = SimulationSessionState(
      leftScenario: left,
      rightScenario: right,
      comparison: state.comparison,
      history: state.history,
      isLoading: true,
    );
    try {
      _sequence += 1;
      final comparison = await _service.compare(
        left: SimulationRequest(
          requestId: 'left-$_sequence',
          scenario: left,
        ),
        right: SimulationRequest(
          requestId: 'right-$_sequence',
          scenario: right,
        ),
      );
      state = SimulationSessionState(
        leftScenario: left,
        rightScenario: right,
        comparison: comparison,
        history: [...state.history, comparison.left, comparison.right],
      );
    } on StateError catch (error) {
      state = SimulationSessionState(
        leftScenario: left,
        rightScenario: right,
        comparison: state.comparison,
        history: state.history,
        errorCode: error.message.toString(),
      );
    }
  }

  void clearHistory() {
    state = SimulationSessionState(
      leftScenario: state.leftScenario,
      rightScenario: state.rightScenario,
      comparison: state.comparison,
    );
  }
}
