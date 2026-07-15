import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
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
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
