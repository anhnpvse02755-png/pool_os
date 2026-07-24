import '../../analytics/application/analytics_mvp_service.dart';
import '../../simulation/application/simulation_mvp_service.dart';

enum HomeDestination {
  match,
  training,
  coach,
  knowledge,
  analytics,
  simulation,
}

final class HomeSummary {
  const HomeSummary({required this.primary, required this.secondary});

  final String primary;
  final String secondary;
}

final class HomeRecentActivity {
  const HomeRecentActivity({
    required this.kind,
    required this.id,
    required this.occurredAt,
    required this.rate,
  });

  final AnalyticsActivityKind kind;
  final int id;
  final DateTime occurredAt;
  final double rate;
}

final class HomeDashboardView {
  HomeDashboardView({
    required Map<HomeDestination, HomeSummary> summaries,
    required List<HomeRecentActivity> recentActivity,
  })  : summaries = Map.unmodifiable(summaries),
        recentActivity = List.unmodifiable(recentActivity);

  final Map<HomeDestination, HomeSummary> summaries;
  final List<HomeRecentActivity> recentActivity;
}

typedef HomeSummaryLoader = Future<HomeSummary> Function();
typedef HomeAnalyticsLoader = Future<AnalyticsDashboardView> Function();
typedef HomeSimulationLoader = Future<SimulationPreview> Function();

final class HomeDashboardService {
  const HomeDashboardService({
    required HomeSummaryLoader loadMatch,
    required HomeSummaryLoader loadTraining,
    required HomeSummaryLoader loadCoach,
    required HomeSummaryLoader loadKnowledge,
    required HomeAnalyticsLoader loadAnalytics,
    required HomeSimulationLoader loadSimulation,
  })  : _loadMatch = loadMatch,
        _loadTraining = loadTraining,
        _loadCoach = loadCoach,
        _loadKnowledge = loadKnowledge,
        _loadAnalytics = loadAnalytics,
        _loadSimulation = loadSimulation;

  final HomeSummaryLoader _loadMatch;
  final HomeSummaryLoader _loadTraining;
  final HomeSummaryLoader _loadCoach;
  final HomeSummaryLoader _loadKnowledge;
  final HomeAnalyticsLoader _loadAnalytics;
  final HomeSimulationLoader _loadSimulation;

  Future<HomeDashboardView> load() async {
    final matchFuture = _loadMatch();
    final trainingFuture = _loadTraining();
    final coachFuture = _loadCoach();
    final knowledgeFuture = _loadKnowledge();
    final analyticsFuture = _loadAnalytics();
    final simulationFuture = _loadSimulation();

    final match = await matchFuture;
    final training = await trainingFuture;
    final coach = await coachFuture;
    final knowledge = await knowledgeFuture;
    final analytics = await analyticsFuture;
    final simulation = await simulationFuture;

    return HomeDashboardView(
      summaries: {
        HomeDestination.match: match,
        HomeDestination.training: training,
        HomeDestination.coach: coach,
        HomeDestination.knowledge: knowledge,
        HomeDestination.analytics: HomeSummary(
          primary: '${analytics.recentActivity.length} recent activities',
          secondary:
              '${_percent(analytics.matchWinRate)} match / ${_percent(analytics.trainingSuccessRate)} training',
        ),
        HomeDestination.simulation: HomeSummary(
          primary: '${simulation.samples.length} observed samples',
          secondary: '${_percent(simulation.observedRate)} observed rate',
        ),
      },
      recentActivity: [
        for (final item in analytics.recentActivity)
          HomeRecentActivity(
            kind: item.kind,
            id: item.id,
            occurredAt: item.occurredAt,
            rate: item.rate,
          ),
      ],
    );
  }
}

String _percent(double value) => '${(value * 100).round()}%';
