import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/analytics/application/analytics_mvp_service.dart';
import 'package:pool_os/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:pool_os/features/analytics/presentation/analytics_providers.dart';
import 'package:pool_os/features/home/application/home_dashboard_service.dart';
import 'package:pool_os/features/home/presentation/home_dashboard_provider.dart';
import 'package:pool_os/features/home/presentation/home_dashboard_screen.dart';

void main() {
  testWidgets('renders six product destinations and existing recent activity',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    for (final title in [
      'Match',
      'Training',
      'Coach',
      'Knowledge',
      'Analytics',
      'Simulation',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    await tester.scrollUntilVisible(
      find.text('Match #11'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Match #11'), findsOneWidget);
    expect(find.text('Training #21'), findsOneWidget);
  });

  testWidgets('destination card opens the existing Analytics screen',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    final analyticsCard = find.byKey(const ValueKey('home-analytics'));
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(analyticsCard);
    await tester.pumpAndSettle();

    expect(find.byType(AnalyticsDashboardScreen), findsOneWidget);
  });
}

Widget _app() => ProviderScope(
      overrides: [
        homeDashboardProvider.overrideWith((ref) async => _homeView),
        analyticsMvpServiceProvider.overrideWithValue(_analyticsService),
      ],
      child: const MaterialApp(home: HomeDashboardScreen()),
    );

final _homeView = HomeDashboardView(
  summaries: {
    for (final destination in HomeDestination.values)
      destination: HomeSummary(
        primary: '${destination.name} summary',
        secondary: '${destination.name} detail',
      ),
  },
  recentActivity: [
    HomeRecentActivity(
      kind: AnalyticsActivityKind.training,
      id: 21,
      occurredAt: DateTime.utc(2026, 7, 23),
      rate: 0.75,
    ),
    HomeRecentActivity(
      kind: AnalyticsActivityKind.match,
      id: 11,
      occurredAt: DateTime.utc(2026, 7, 22),
      rate: 0.6,
    ),
  ],
);

final _analyticsService = AnalyticsMvpService(
  loadMatches: () async => MatchAnalyticsSource(
    matchCount: 2,
    rackCount: 5,
    wins: 3,
    losses: 2,
    duration: const Duration(minutes: 90),
    recent: const [],
  ),
  loadTraining: () async => TrainingAnalyticsSource(
    sessionCount: 3,
    exerciseCount: 6,
    attempts: 20,
    successes: 15,
    duration: const Duration(minutes: 120),
    recent: const [],
  ),
);
