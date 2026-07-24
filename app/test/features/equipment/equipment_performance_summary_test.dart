import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/equipment/presentation/widgets/equipment_performance_summary.dart';

void main() {
  testWidgets('renders every Equipment performance field', (tester) async {
    final projection = EquipmentPerformanceProjection.create(
      playerId: 1,
      equipmentId: 9,
      totalMatches: 4,
      matchWinRate: 75,
      totalTrainingSessions: 3,
      trainingSuccessRate: 80,
      recordedDurationSeconds: 7200,
      lastUsed: DateTime.utc(2026, 7, 24),
      sourceDigest: 'source',
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EquipmentPerformanceSummary(
            projection: projection,
            locale: 'en',
          ),
        ),
      ),
    );

    expect(
        find.byKey(const ValueKey('equipment-performance-9')), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Training'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('2.0 h'), findsOneWidget);
    expect(find.text('2026-07-24'), findsOneWidget);
  });
}
