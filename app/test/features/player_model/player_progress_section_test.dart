import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player_model/application/player_progress_calculator.dart';
import 'package:pool_os/features/player_model/presentation/player_progress_provider.dart';
import 'package:pool_os/features/player_model/presentation/player_progress_section.dart';

void main() {
  testWidgets('renders rating, radar, trend, mastery and vectors',
      (tester) async {
    final projection = const PlayerProgressCalculator().calculate(
      playerId: 1,
      activities: [
        _activity('match:1', DateTime.utc(2026, 7, 1), 2),
        _activity('match:2', DateTime.utc(2026, 7, 2), 4),
      ],
      mastery: const [],
      fallbackUpdatedAt: DateTime.utc(2026),
    );
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          playerProgressProvider.overrideWith((ref) async => projection),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: PlayerProgressSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Player Model'), findsOneWidget);
    expect(find.byKey(const ValueKey('player-model-overall')), findsOneWidget);
    expect(find.byKey(const ValueKey('player-model-radar')), findsOneWidget);
    expect(find.byKey(const ValueKey('player-model-trend')), findsOneWidget);
    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('Strengths'), findsOneWidget);
    expect(find.text('Weaknesses'), findsOneWidget);
  });
}

PlayerProgressActivity _activity(String id, DateTime at, int wins) =>
    PlayerProgressActivity(
      kind: PlayerProgressActivityKind.match,
      sourceId: id,
      occurredAt: at,
      rackCount: 4,
      wins: wins,
      attempts: 10,
      successes: wins * 2,
      breakAttempts: 4,
      breakSuccesses: wins,
      scratches: 0,
      positionErrors: 1,
      safetyErrors: 1,
      kickErrors: 0,
      jumpErrors: 0,
      confidenceValues: const [70],
    );
