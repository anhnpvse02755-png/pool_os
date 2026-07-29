import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/app/router/app_router.dart';
import 'package:pool_os/features/coach/domain/brain/coach_output.dart';
import 'package:pool_os/features/coach/domain/brain/knowledge_registry.dart';
import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/coach/presentation/coach_v2_provider.dart';
import 'package:pool_os/features/competition/presentation/competition_hub_screen.dart';
import 'package:pool_os/features/home/presentation/home_dashboard_screen.dart';
import 'package:pool_os/features/performance/presentation/performance_screen.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/skill/presentation/widgets/skill_radar_chart_widget.dart';
import 'package:pool_os/features/statistics/presentation/statistics_hub_screen.dart';
import 'package:pool_os/features/training_center/presentation/screens/training_center_screen.dart';
import 'package:pool_os/main.dart';

/// RC-01 app-launch smoke test. Bootstraps the app exactly like main() does — a
/// ProviderScope with an in-memory database override (PoolOSApp is a
/// ConsumerWidget and databaseProvider throws unless overridden) — then settles
/// the async router and asserts a real routed screen rendered. Guards that the
/// app boots without a crash blocker on a clean install.
void main() {
  testWidgets('App launches to a routed screen', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const PoolOSApp(),
      ),
    );
    // Let go_router build the initial (/home) branch + async providers.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
    expect(find.byType(HomeDashboardScreen), findsOneWidget);
  });

  testWidgets('Product navigation has exactly four destinations',
      (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const PoolOSApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final destinations = tester
        .widgetList<NavigationDestination>(find.byType(NavigationDestination))
        .toList();
    expect(destinations, hasLength(4));
    expect(
      destinations.map((item) => item.label),
      ['Trang chủ', 'Thi đấu', 'Trung tâm học tập', 'Huấn luyện viên'],
    );

    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(CompetitionHubScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('competition.match')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('competition.tournament')), findsOneWidget);
    expect(find.byKey(const ValueKey('competition.history')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('competition.performance')), findsOneWidget);
    expect(find.byKey(const ValueKey('competition.review')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('competition.performance')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(PerformanceScreen), findsOneWidget);

    await tester.tap(find.byType(NavigationDestination).at(2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(TrainingCenterScreen), findsOneWidget);
  });

  testWidgets('Statistics opens as Dashboard detail without bottom navigation',
      (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const PoolOSApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    appRouter.go('/dashboard');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byKey(const ValueKey('dashboard.weekly.view_all')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(StatisticsHubScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('Dashboard renders the Coach V2 decision without a skill radar',
      (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    const action = CoachAction(
      labelKey: 'coach_v2_action_log_readiness',
      knowledgeId: KnowledgeId.logReadiness,
    );
    const output = CoachOutput(
      level: PlayerLevel(levelKey: 'beginner'),
      understanding: CoachUnderstanding(
        dataCompleteness: 0.25,
        coverage: {FindingSource.readiness: 0},
        missing: [FindingSource.readiness],
      ),
      primaryAction: action,
      feed: [
        CoachInsightV2(
          id: 'test.readiness',
          topic: CoachTopic.readiness,
          priority: CoachPriority.improve,
          observationKey: 'coach_v2_obs_no_readiness_today',
          confidence: CoachConfidence.high,
          action: action,
        ),
      ],
    );
    appRouter.go('/dashboard');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          coachOutputProvider.overrideWith((ref) async => output),
        ],
        child: const PoolOSApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Ghi mức sẵn sàng'), findsOneWidget);
    expect(find.text('Độ tin cậy cao'), findsOneWidget);
    expect(find.byType(SkillRadarChartWidget), findsNothing);
  });
}
