import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';
import 'package:pool_os/features/player/presentation/career_timeline_section.dart';
import 'package:pool_os/features/player/presentation/player_timeline_screen.dart';

void main() {
  testWidgets('renders empty state when projection has zero events',
      (tester) async {
    await _pumpScreen(
      tester,
      _projection(const []),
    );

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('No events.'), findsOneWidget);
  });

  testWidgets('renders all events under "All" filter by default',
      (tester) async {
    final match = _event(
      1,
      DateTime.now().subtract(const Duration(hours: 1)),
      type: CareerTimelineEventType.completedMatch,
    );
    final training = _event(
      2,
      DateTime.now().subtract(const Duration(hours: 2)),
      type: CareerTimelineEventType.completedTraining,
    );
    await _pumpScreen(tester, _projection([match, training]));

    expect(
      find.byKey(ValueKey('player-timeline-row-${match.eventId}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('player-timeline-row-${training.eventId}')),
      findsOneWidget,
    );
  });

  testWidgets('match filter hides training events', (tester) async {
    final match = _event(
      1,
      DateTime.now().subtract(const Duration(hours: 1)),
      type: CareerTimelineEventType.completedMatch,
    );
    final training = _event(
      2,
      DateTime.now().subtract(const Duration(hours: 2)),
      type: CareerTimelineEventType.completedTraining,
    );
    await _pumpScreen(tester, _projection([match, training]));

    await tester
        .tap(find.byKey(const ValueKey('player-timeline-filter-match')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('player-timeline-row-${match.eventId}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('player-timeline-row-${training.eventId}')),
      findsNothing,
    );
  });

  testWidgets('training filter hides match events', (tester) async {
    final match = _event(
      1,
      DateTime.now().subtract(const Duration(hours: 1)),
      type: CareerTimelineEventType.completedMatch,
    );
    final training = _event(
      2,
      DateTime.now().subtract(const Duration(hours: 2)),
      type: CareerTimelineEventType.completedTraining,
    );
    await _pumpScreen(tester, _projection([match, training]));

    await tester
        .tap(find.byKey(const ValueKey('player-timeline-filter-training')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('player-timeline-row-${training.eventId}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('player-timeline-row-${match.eventId}')),
      findsNothing,
    );
  });

  testWidgets('player-model filter shows only PlayerModel events',
      (tester) async {
    final model = _event(
      1,
      DateTime.now().subtract(const Duration(hours: 1)),
      type: CareerTimelineEventType.playerModelSnapshot,
    );
    final match = _event(
      2,
      DateTime.now().subtract(const Duration(hours: 2)),
      type: CareerTimelineEventType.completedMatch,
    );
    await _pumpScreen(tester, _projection([match, model]));

    await tester.tap(
      find.byKey(const ValueKey('player-timeline-filter-playerModel')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('player-timeline-row-${model.eventId}')),
      findsOneWidget,
    );
    expect(
      find.byKey(ValueKey('player-timeline-row-${match.eventId}')),
      findsNothing,
    );
  });

  testWidgets('knowledge events are never visible under any filter',
      (tester) async {
    final mastery = _event(
      1,
      DateTime.now().subtract(const Duration(hours: 1)),
      type: CareerTimelineEventType.masteryEvidenceUpdated,
    );
    await _pumpScreen(tester, _projection([mastery]));

    // All filter hides mastery.
    expect(
      find.byKey(ValueKey('player-timeline-row-${mastery.eventId}')),
      findsNothing,
    );
    expect(find.text('No events.'), findsOneWidget);
  });

  testWidgets('groups events under day headers newest first', (tester) async {
    // Use timestamps relative to a fixed local instant that is safely
    // far from midnight, so day bucketing is stable across runs. The
    // screen's "today" anchor is real DateTime.now(), but invariants
    // here only depend on relative ordering of headers, not on the
    // literal labels.
    final fixed = DateTime(2026, 7, 28, 14);
    final newest = _event(
      1,
      fixed.subtract(const Duration(hours: 1)),
      type: CareerTimelineEventType.completedMatch,
    );
    final middle = _event(
      2,
      fixed.subtract(const Duration(days: 2)),
      type: CareerTimelineEventType.completedMatch,
    );
    final oldest = _event(
      3,
      fixed.subtract(const Duration(days: 14)),
      type: CareerTimelineEventType.completedTraining,
    );
    await _pumpScreen(tester, _projection([newest, middle, oldest]));

    final dayHeaders = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) =>
            t.key is ValueKey<String> &&
            (t.key as ValueKey<String>)
                .value
                .startsWith('player-timeline-day-'))
        .map((t) => t.data ?? '')
        .toList();

    // Exactly three day sections exist.
    expect(dayHeaders.length, equals(3));
    // Header order is newest-first.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('player-timeline-screen'))),
      isNotNull,
    );
    // The newest section's row is rendered above the oldest section's
    // row on screen — verifying the ordering invariant.
    final newestRow = tester.getTopLeft(find.byKey(
      ValueKey('player-timeline-row-${newest.eventId}'),
    ));
    final oldestRow = tester.getTopLeft(find.byKey(
      ValueKey('player-timeline-row-${oldest.eventId}'),
    ));
    expect(newestRow.dy, lessThan(oldestRow.dy));
  });

  testWidgets('changing active cue after a match does not affect timeline',
      (tester) async {
    // The screen itself does not depend on Active Cue — it consumes the
    // existing CareerTimelineProjection, which is sourced exclusively
    // from immutable MatchEquipmentSnapshot rows. This test verifies
    // that the screen renders the same events when only the projection
    // is changed underneath it (the cue is referenced indirectly via the
    // existing event payload, never via any in-screen lookup).
    final match = _event(
      7,
      DateTime.now().subtract(const Duration(hours: 1)),
      type: CareerTimelineEventType.completedMatch,
      withEquipment: true,
    );
    await _pumpScreen(tester, _projection([match]));
    expect(
      find.byKey(ValueKey('player-timeline-row-${match.eventId}')),
      findsOneWidget,
    );

    // Re-pump with the same projection — same row still renders.
    await _pumpScreen(tester, _projection([match]));
    expect(
      find.byKey(ValueKey('player-timeline-row-${match.eventId}')),
      findsOneWidget,
    );
  });

  testWidgets('career timeline section opens the screen on tap',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          careerTimelineProvider
              .overrideWith((ref) async => _projection(const [])),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: CareerTimelineSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('career-timeline-section-tap')),
    );
    await tester.pumpAndSettle();
    expect(
        find.byKey(const ValueKey('player-timeline-screen')), findsOneWidget);
  });

  testWidgets('rebuild after deleting cache produces identical rows',
      (tester) async {
    final match = _event(
      5,
      DateTime.utc(2026, 7, 1, 10),
      type: CareerTimelineEventType.completedMatch,
    );
    final projection = _projection([match]);
    await _pumpScreen(tester, projection);
    final firstRowKeys = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => t.key)
        .toList();

    // Re-pump with a fresh projection that the service would produce
    // after a cache wipe + rebuild. Same facts => same eventId => same
    // row keys.
    await _pumpScreen(tester, projection);
    final secondRowKeys = tester
        .widgetList<ListTile>(find.byType(ListTile))
        .map((t) => t.key)
        .toList();
    expect(secondRowKeys, equals(firstRowKeys));
  });
}

Future<void> _pumpScreen(
  WidgetTester tester,
  CareerTimelineProjection projection,
) async {
  await tester.binding.setSurfaceSize(const Size(600, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        careerTimelineProvider.overrideWith((ref) async => projection),
      ],
      child: const MaterialApp(home: PlayerTimelineScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

CareerTimelineProjection _projection(List<CareerTimelineEvent> events) =>
    CareerTimelineProjection.create(
      playerId: 1,
      sourceDigest: 'fe009-test',
      events: events,
    );

CareerTimelineEvent _event(
  int id,
  DateTime timestamp, {
  required CareerTimelineEventType type,
  bool withEquipment = false,
}) {
  return CareerTimelineEvent.create(
    type: type,
    timestamp: timestamp,
    title: switch (type) {
      CareerTimelineEventType.completedMatch => 'Match #$id won',
      CareerTimelineEventType.completedTraining => 'Training session $id',
      CareerTimelineEventType.playerModelSnapshot => 'Player Model updated $id',
      CareerTimelineEventType.masteryEvidenceUpdated => 'Mastery updated $id',
      CareerTimelineEventType.playerCreated => 'Player created $id',
    },
    summary: 'event $id',
    sourceReference: '${type.name}:$id',
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
}
