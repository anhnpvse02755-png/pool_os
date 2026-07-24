import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../analytics/presentation/analytics_providers.dart';
import '../../coach/application/coach_conversation_service.dart';
import '../../coach/presentation/coach_conversation_provider.dart';
import '../../coach/presentation/coach_v2_provider.dart';
import '../../knowledge/application/knowledge_mvp_service.dart';
import '../../knowledge/presentation/providers/knowledge_providers.dart';
import '../../match/application/match_statistics_service.dart';
import '../../simulation/application/simulation_mvp_service.dart';
import '../../simulation/presentation/simulation_providers.dart';
import '../../training/application/training_statistics_service.dart';
import '../application/home_dashboard_service.dart';

final homeDashboardServiceProvider = Provider<HomeDashboardService>((ref) {
  final match = ref.watch(matchStatisticsServiceProvider);
  final training = ref.watch(trainingStatisticsServiceProvider);
  final coach = ref.watch(coachConversationServiceProvider);
  final knowledge = ref.watch(knowledgeMvpServiceProvider);
  final analytics = ref.watch(analyticsMvpServiceProvider);
  final simulation = ref.watch(simulationMvpServiceProvider);

  return HomeDashboardService(
    loadMatch: () => _loadMatch(match),
    loadTraining: () => _loadTraining(training),
    loadCoach: () async {
      final output = await ref.read(coachOutputProvider.future);
      final turn = await coach.ask(
        intent: CoachConversationIntent.nextAction,
        output: output,
      );
      return HomeSummary(
        primary: turn.responseKey,
        secondary: turn.detailKey ?? turn.metric ?? 'Structured coach action',
      );
    },
    loadKnowledge: () => _loadKnowledge(knowledge),
    loadAnalytics: analytics.load,
    loadSimulation: () => simulation.preview(const SimulationRequest(
      requestId: 'home-combined-preview',
      scenario: SimulationScenarioKind.combinedReplay,
      sampleLimit: 3,
    )),
  );
});

final homeDashboardProvider = FutureProvider<HomeDashboardView>(
  (ref) => ref.watch(homeDashboardServiceProvider).load(),
);

Future<HomeSummary> _loadMatch(MatchStatisticsService service) async {
  final value = await service.load();
  final rate = value.rackCount == 0 ? 0 : value.wins / value.rackCount;
  return HomeSummary(
    primary: '${value.matchCount} matches',
    secondary: '${(rate * 100).round()}% win rate',
  );
}

Future<HomeSummary> _loadTraining(TrainingStatisticsService service) async {
  final value = await service.load();
  final rate = value.attempts == 0 ? 0 : value.successes / value.attempts;
  return HomeSummary(
    primary: '${value.sessionCount} sessions',
    secondary: '${(rate * 100).round()}% success rate',
  );
}

Future<HomeSummary> _loadKnowledge(KnowledgeMvpService service) async {
  final value = await service.browse(const KnowledgeBrowseRequest());
  return HomeSummary(
    primary: '${value.catalog.entries.length} articles',
    secondary: '${value.categories.length} categories',
  );
}
