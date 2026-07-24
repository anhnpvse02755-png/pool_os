import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/analytics/application/analytics_mvp_service.dart';
import 'package:pool_os/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:pool_os/features/analytics/presentation/analytics_providers.dart';

void main() {
  testWidgets('renders Match and Training overview, charts, and timeline',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          analyticsMvpServiceProvider.overrideWithValue(_screenService),
        ],
        child: const MaterialApp(home: AnalyticsDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('Training'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.text('Performance rates'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -250));
    await tester.pumpAndSettle();
    expect(find.text('Recorded duration'), findsOneWidget);
    expect(find.byType(BarChart), findsWidgets);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Training #21'), findsOneWidget);
    expect(find.text('Match #11'), findsOneWidget);
  });
}

final _screenService = AnalyticsMvpService(
  loadMatches: () async => MatchAnalyticsSource(
    matchCount: 2,
    rackCount: 5,
    wins: 3,
    losses: 2,
    duration: const Duration(minutes: 90),
    recent: [
      MatchAnalyticsActivity(
        id: 11,
        occurredAt: DateTime.utc(2026, 7, 22),
        winRate: 0.6,
        duration: const Duration(minutes: 50),
      ),
    ],
  ),
  loadTraining: () async => TrainingAnalyticsSource(
    sessionCount: 3,
    exerciseCount: 6,
    attempts: 20,
    successes: 15,
    duration: const Duration(minutes: 120),
    recent: [
      TrainingAnalyticsActivity(
        id: 21,
        occurredAt: DateTime.utc(2026, 7, 23),
        successRate: 0.75,
        duration: const Duration(minutes: 70),
      ),
    ],
  ),
);
