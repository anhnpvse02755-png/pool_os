import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';
import 'package:pool_os/features/player/presentation/career_timeline_section.dart';

void main() {
  testWidgets('renders source references newest to oldest', (tester) async {
    final newest = _event(2, DateTime.utc(2026, 7, 2), withEquipment: true);
    final oldest = _event(1, DateTime.utc(2026, 7, 1));
    final projection = CareerTimelineProjection.create(
      playerId: 1,
      sourceDigest: 'source',
      events: [oldest, newest],
    );
    await tester.binding.setSurfaceSize(const Size(600, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          careerTimelineProvider.overrideWith((ref) async => projection),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CareerTimelineSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final newestFinder = find.byKey(
      ValueKey('career-timeline-event-${newest.eventId}'),
    );
    final oldestFinder = find.byKey(
      ValueKey('career-timeline-event-${oldest.eventId}'),
    );
    expect(find.text('Career Timeline'), findsOneWidget);
    expect(find.text('match:2'), findsOneWidget);
    expect(find.text('match:1'), findsOneWidget);
    expect(
      find.text('Match #2 | Playing | Cue #31 | equipment-snapshot:match:2'),
      findsOneWidget,
    );
    expect(tester.getTopLeft(newestFinder).dy,
        lessThan(tester.getTopLeft(oldestFinder).dy));
  });

  testWidgets('renders an empty historical state', (tester) async {
    final projection = CareerTimelineProjection.create(
      playerId: 1,
      sourceDigest: 'source',
      events: const [],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          careerTimelineProvider.overrideWith((ref) async => projection),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CareerTimelineSection()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No recorded career events.'), findsOneWidget);
  });
}

CareerTimelineEvent _event(
  int id,
  DateTime timestamp, {
  bool withEquipment = false,
}) =>
    CareerTimelineEvent.create(
      type: CareerTimelineEventType.completedMatch,
      timestamp: timestamp,
      title: 'Match completed $id',
      summary: 'Match #$id | race_to.',
      sourceReference: 'match:$id',
      equipmentUsage: [
        if (withEquipment)
          CareerEquipmentUsageRef(
            matchId: id,
            matchNumber: id,
            snapshotReference: 'equipment-snapshot:match:$id',
            role: CareerEquipmentRole.playing,
            cueId: 31,
          ),
      ],
    );
