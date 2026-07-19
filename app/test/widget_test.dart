import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/session/presentation/session_screen.dart';
import 'package:pool_os/features/statistics/presentation/statistics_screen.dart';
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
    // Let go_router build the initial (/dashboard) branch + async providers.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
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
    expect(find.byType(SessionScreen), findsOneWidget);

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

    await tester.tap(find.byType(NavigationDestination).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Xem tất cả').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(StatisticsScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
