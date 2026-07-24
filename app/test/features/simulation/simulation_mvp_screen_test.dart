import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/simulation/application/simulation_mvp_service.dart';
import 'package:pool_os/features/simulation/presentation/simulation_mvp_screen.dart';
import 'package:pool_os/features/simulation/presentation/simulation_providers.dart';

void main() {
  testWidgets('selects, replays, compares, and retains session-local history',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          simulationMvpServiceProvider.overrideWithValue(_screenService),
        ],
        child: const MaterialApp(home: SimulationMvpScreen()),
      ),
    );

    await tester.tap(find.text('Replay and compare'));
    await tester.pumpAndSettle();

    expect(find.text('Observed comparison'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('Observed delta: +15%'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Session history'), findsOneWidget);
    expect(find.text('Match replay'), findsWidgets);
    expect(find.text('Training replay'), findsWidgets);

    await tester.tap(find.byTooltip('Clear session history'));
    await tester.pumpAndSettle();
    expect(find.text('Session history'), findsNothing);
  });
}

final _screenService = SimulationMvpService(
  loadMatches: () async => [
    SimulationReplaySample(
      kind: SimulationSampleKind.match,
      id: 11,
      occurredAt: DateTime.utc(2026, 7, 22),
      observedRate: 0.6,
      duration: const Duration(minutes: 50),
    ),
  ],
  loadTraining: () async => [
    SimulationReplaySample(
      kind: SimulationSampleKind.training,
      id: 21,
      occurredAt: DateTime.utc(2026, 7, 23),
      observedRate: 0.75,
      duration: const Duration(minutes: 70),
    ),
  ],
);
