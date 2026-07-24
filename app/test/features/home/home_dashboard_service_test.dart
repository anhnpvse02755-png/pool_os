import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/analytics/application/analytics_mvp_service.dart';
import 'package:pool_os/features/home/application/home_dashboard_service.dart';
import 'package:pool_os/features/simulation/application/simulation_mvp_service.dart';

void main() {
  test('composes all six existing-service sources in stable destination order',
      () async {
    final calls = <String>[];
    final service = HomeDashboardService(
      loadMatch: () async {
        calls.add('match');
        return const HomeSummary(primary: '2 matches', secondary: '60%');
      },
      loadTraining: () async {
        calls.add('training');
        return const HomeSummary(primary: '3 sessions', secondary: '75%');
      },
      loadCoach: () async {
        calls.add('coach');
        return const HomeSummary(primary: 'next action', secondary: 'ready');
      },
      loadKnowledge: () async {
        calls.add('knowledge');
        return const HomeSummary(primary: '36 articles', secondary: '5 kinds');
      },
      loadAnalytics: () async {
        calls.add('analytics');
        return _analytics;
      },
      loadSimulation: () async {
        calls.add('simulation');
        return _simulation;
      },
    );

    final view = await service.load();

    expect(calls.toSet(), {
      'match',
      'training',
      'coach',
      'knowledge',
      'analytics',
      'simulation',
    });
    expect(view.summaries.keys.toList(), HomeDestination.values);
    expect(view.summaries[HomeDestination.analytics]!.primary,
        '2 recent activities');
    expect(view.summaries[HomeDestination.simulation]!.secondary,
        '70% observed rate');
    expect(view.recentActivity.map((item) => item.id), [21, 11]);
  });

  test('empty existing data remains an empty read-only summary', () async {
    final service = HomeDashboardService(
      loadMatch: () async => const HomeSummary(primary: '0', secondary: '0%'),
      loadTraining: () async =>
          const HomeSummary(primary: '0', secondary: '0%'),
      loadCoach: () async => const HomeSummary(primary: 'none', secondary: ''),
      loadKnowledge: () async =>
          const HomeSummary(primary: '0', secondary: '0'),
      loadAnalytics: () async => AnalyticsDashboardView(
        matches: MatchAnalyticsSource(
          matchCount: 0,
          rackCount: 0,
          wins: 0,
          losses: 0,
          duration: Duration.zero,
          recent: const [],
        ),
        training: TrainingAnalyticsSource(
          sessionCount: 0,
          exerciseCount: 0,
          attempts: 0,
          successes: 0,
          duration: Duration.zero,
          recent: const [],
        ),
        recentActivity: const [],
      ),
      loadSimulation: () async => SimulationPreview(
        request: const SimulationRequest(
          requestId: 'empty',
          scenario: SimulationScenarioKind.combinedReplay,
        ),
        samples: const [],
      ),
    );

    final view = await service.load();

    expect(view.recentActivity, isEmpty);
    expect(view.summaries[HomeDestination.analytics]!.secondary,
        '0% match / 0% training');
    expect(view.summaries[HomeDestination.simulation]!.primary,
        '0 observed samples');
  });

  test('dashboard collections are immutable', () async {
    final view = await _service.load();

    expect(
      () => view.summaries[HomeDestination.match] =
          const HomeSummary(primary: 'changed', secondary: ''),
      throwsUnsupportedError,
    );
    expect(
      () => view.recentActivity.add(HomeRecentActivity(
        kind: AnalyticsActivityKind.match,
        id: 99,
        occurredAt: DateTime.utc(2026),
        rate: 1,
      )),
      throwsUnsupportedError,
    );
  });
}

final _service = HomeDashboardService(
  loadMatch: () async => const HomeSummary(primary: '2', secondary: '60%'),
  loadTraining: () async => const HomeSummary(primary: '3', secondary: '75%'),
  loadCoach: () async => const HomeSummary(primary: 'next', secondary: 'ready'),
  loadKnowledge: () async => const HomeSummary(primary: '36', secondary: '5'),
  loadAnalytics: () async => _analytics,
  loadSimulation: () async => _simulation,
);

final _analytics = AnalyticsDashboardView(
  matches: MatchAnalyticsSource(
    matchCount: 2,
    rackCount: 5,
    wins: 3,
    losses: 2,
    duration: const Duration(minutes: 90),
    recent: const [],
  ),
  training: TrainingAnalyticsSource(
    sessionCount: 3,
    exerciseCount: 6,
    attempts: 20,
    successes: 15,
    duration: const Duration(minutes: 120),
    recent: const [],
  ),
  recentActivity: [
    AnalyticsActivity(
      kind: AnalyticsActivityKind.training,
      id: 21,
      occurredAt: DateTime.utc(2026, 7, 23),
      rate: 0.75,
      duration: const Duration(minutes: 70),
    ),
    AnalyticsActivity(
      kind: AnalyticsActivityKind.match,
      id: 11,
      occurredAt: DateTime.utc(2026, 7, 22),
      rate: 0.6,
      duration: const Duration(minutes: 50),
    ),
  ],
);

final _simulation = SimulationPreview(
  request: const SimulationRequest(
    requestId: 'home',
    scenario: SimulationScenarioKind.combinedReplay,
  ),
  samples: [
    SimulationReplaySample(
      kind: SimulationSampleKind.match,
      id: 11,
      occurredAt: DateTime.utc(2026, 7, 22),
      observedRate: 0.6,
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
