import 'dart:io';

import 'package:drift/drift.dart' show QueryExecutor;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/event/data/repositories/event_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/application/training_session_execution_service.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/training/presentation/training_history_view.dart';

void main() {
  late _Fixture fixture;

  setUp(() => fixture = _Fixture.open(NativeDatabase.memory()));
  tearDown(() => fixture.database.close());

  testWidgets('shows completed training newest first and opens detail',
      (tester) async {
    final older = await fixture.createCompletedTraining(
      startedAt: DateTime(2026, 7, 23, 8),
      name: 'Stop Shot',
      attempts: 5,
      successes: 3,
    );
    final newer = await fixture.createCompletedTraining(
      startedAt: DateTime(2026, 7, 24, 8),
      name: 'Long Pot',
      attempts: 6,
      successes: 4,
    );
    final active = await fixture.training.createSession(
      startedAt: DateTime(2026, 7, 25, 8),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(fixture.database)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: TrainingHistoryView()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final newerFinder = find.byKey(ValueKey('training-history-$newer'));
    final olderFinder = find.byKey(ValueKey('training-history-$older'));
    expect(newerFinder, findsOneWidget);
    expect(olderFinder, findsOneWidget);
    expect(find.byKey(ValueKey('training-history-$active')), findsNothing);
    expect(tester.getTopLeft(newerFinder).dy,
        lessThan(tester.getTopLeft(olderFinder).dy));

    await tester.tap(newerFinder);
    await tester.pumpAndSettle();

    expect(find.text('Training detail'), findsOneWidget);
    expect(find.text('Long Pot'), findsOneWidget);
    expect(find.text('4/6'), findsOneWidget);
    expect(find.text('Success'), findsOneWidget);
    expect(find.text('Miss'), findsOneWidget);
    expect(find.text('Exercise timeline'), findsOneWidget);
    expect(find.text('Session #$newer'), findsOneWidget);
  });

  test('completed history survives database restart', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_i4_');
    final file = File('${directory.path}/training-history.db');
    try {
      await fixture.database.close();
      fixture = _Fixture.open(NativeDatabase(file));
      final sessionId = await fixture.createCompletedTraining(
        startedAt: DateTime.utc(2026, 7, 24, 8),
        name: 'Position Play',
        attempts: 8,
        successes: 5,
      );
      await fixture.database.close();

      fixture = _Fixture.open(NativeDatabase(file));
      final history = await fixture.training.loadCompletedSessions();

      expect(history.single.session.id, sessionId);
      expect(history.single.exercises.single.name, 'Position Play');
      expect(history.single.exercises.single.attempts, 8);
      expect(history.single.exercises.single.successes, 5);
      expect(history.single.exercises.single.completed, isTrue);
    } finally {
      await fixture.database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      fixture = _Fixture.open(NativeDatabase.memory());
    }
  });
}

final class _Fixture {
  _Fixture._({required this.database, required this.training});

  factory _Fixture.open(QueryExecutor executor) {
    final database = AppDatabase.forTesting(executor);
    final sessions = SessionRepository(database);
    final matches = MatchRepository(database);
    final racks = RackRepository(database);
    final recording = RecordingCoordinator(
      database: database,
      sessionRepo: sessions,
      matchRepo: matches,
      rackRepo: racks,
      shotRepo: ShotRepository(database),
      eventRepo: EventRepository(database),
    );
    return _Fixture._(
      database: database,
      training: TrainingSessionExecutionService(
        sessions: sessions,
        matches: matches,
        racks: racks,
        recording: recording,
      ),
    );
  }

  final AppDatabase database;
  final TrainingSessionExecutionService training;

  Future<int> createCompletedTraining({
    required DateTime startedAt,
    required String name,
    required int attempts,
    required int successes,
  }) async {
    final sessionId = await training.createSession(startedAt: startedAt);
    final exercise = await training.addExercise(
      sessionId: sessionId,
      exerciseCode: name.toLowerCase().replaceAll(' ', '-'),
      exerciseName: name,
    );
    await training.completeExercise(
      matchId: exercise.matchId,
      rackId: exercise.rackId,
      attempts: attempts,
      successes: successes,
      target: attempts,
    );
    await training.finishSession(sessionId);
    return sessionId;
  }
}
