import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/app/router/app_router.dart';
import 'package:pool_os/features/analytics/application/analytics_mvp_service.dart';
import 'package:pool_os/features/analytics/presentation/analytics_dashboard_screen.dart';
import 'package:pool_os/features/coach/presentation/coach_screen.dart';
import 'package:pool_os/features/dashboard/presentation/dashboard_screen.dart';
import 'package:pool_os/features/home/application/home_dashboard_service.dart';
import 'package:pool_os/features/home/presentation/home_dashboard_provider.dart';
import 'package:pool_os/features/home/presentation/home_dashboard_screen.dart';
import 'package:pool_os/features/knowledge/presentation/screens/knowledge_library_screen.dart';
import 'package:pool_os/features/match/presentation/match_history_view.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/simulation/presentation/simulation_mvp_screen.dart';
import 'package:pool_os/features/training/presentation/training_history_view.dart';
import 'package:pool_os/main.dart';

void main() {
  testWidgets('Home is the application entry and dashboard deep link remains',
      (tester) async {
    final db = await _pumpApp(tester);
    addTearDown(db.close);

    expect(find.byType(HomeDashboardScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    appRouter.go('/dashboard');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  for (final target in _targets) {
    testWidgets('Home opens ${target.destination.name} and returns on back',
        (tester) async {
      final db = await _pumpApp(tester);
      addTearDown(db.close);

      final card = find.byKey(ValueKey('home-${target.destination.name}'));
      tester.widget<InkWell>(card).onTap!();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(target.screenType), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
    });
  }
}

Future<AppDatabase> _pumpApp(WidgetTester tester) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  appRouter.go('/home');
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        homeDashboardProvider.overrideWith((ref) async => _homeView),
      ],
      child: const PoolOSApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

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
      kind: AnalyticsActivityKind.match,
      id: 11,
      occurredAt: DateTime.utc(2026, 7, 22),
      rate: 0.6,
    ),
  ],
);

const _targets = <({HomeDestination destination, Type screenType})>[
  (destination: HomeDestination.match, screenType: MatchHistoryView),
  (destination: HomeDestination.training, screenType: TrainingHistoryView),
  (destination: HomeDestination.coach, screenType: CoachScreen),
  (destination: HomeDestination.knowledge, screenType: KnowledgeLibraryScreen),
  (
    destination: HomeDestination.analytics,
    screenType: AnalyticsDashboardScreen
  ),
  (destination: HomeDestination.simulation, screenType: SimulationMvpScreen),
];
