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
import 'package:pool_os/features/training/presentation/training_session_view.dart';

void main() {
  late _Fixture fixture;

  setUp(() => fixture = _Fixture.open(NativeDatabase.memory()));
  tearDown(() => fixture.database.close());

  test('persists training lifecycle and recovers it after restart', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_i3_');
    final file = File('${directory.path}/training.db');
    try {
      await fixture.database.close();
      fixture = _Fixture.open(NativeDatabase(file));
      final sessionId = await fixture.training.createSession(
        startedAt: DateTime.utc(2026, 7, 24, 8),
      );
      final exercise = await fixture.training.addExercise(
        sessionId: sessionId,
        exerciseCode: 'stop-shot',
        exerciseName: 'Stop Shot',
      );
      await fixture.training.completeExercise(
        matchId: exercise.matchId,
        rackId: exercise.rackId,
        attempts: 5,
        successes: 3,
        target: 5,
      );
      await fixture.training.finishSession(sessionId);
      await fixture.database.close();

      fixture = _Fixture.open(NativeDatabase(file));
      final session = await fixture.sessions.getSessionById(sessionId);
      final match = await fixture.matches.getMatchById(exercise.matchId);
      final rack = await fixture.racks.getRackById(exercise.rackId);

      expect(session!.finishedAt, isNotNull);
      expect(match!.notes, 'stop-shot');
      expect(match.matchObjective, 'Stop Shot');
      expect(match.endTime, isNotNull);
      expect(rack!.ballsPotted, 3);
      expect(rack.easyMissCount, 2);
      expect(rack.confidence, 6);
    } finally {
      await fixture.database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      fixture = _Fixture.open(NativeDatabase.memory());
    }
  });

  test('rejects mismatched exercise binding without partial writes', () async {
    final sessionId = await fixture.training.createSession();
    final first = await fixture.training.addExercise(
      sessionId: sessionId,
      exerciseCode: 'first',
      exerciseName: 'First',
    );
    final second = await fixture.training.addExercise(
      sessionId: sessionId,
      exerciseCode: 'second',
      exerciseName: 'Second',
    );

    expect(
      () => fixture.training.completeExercise(
        matchId: first.matchId,
        rackId: second.rackId,
        attempts: 2,
        successes: 1,
        target: 2,
      ),
      throwsStateError,
    );

    expect(
        (await fixture.matches.getMatchById(first.matchId))!.isActive, isTrue);
    expect((await fixture.racks.getRackById(first.rackId))!.ballsPotted, 0);
  });

  testWidgets('records an exercise and finishes the owning session',
      (tester) async {
    final sessionId = await fixture.training.createSession();
    var finished = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(fixture.database)],
        child: MaterialApp(
          home: Scaffold(
            body: TrainingSessionView(
              sessionId: sessionId,
              onFinished: () async => finished = true,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Long Pot');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Success'));
    await tester.tap(find.text('Success'));
    await tester.tap(find.text('Miss'));
    await tester.pump();
    await tester.tap(find.text('Complete exercise'));
    await tester.pumpAndSettle();

    expect(find.text('2/3 successful'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    final exercises = await fixture.training.loadExercises(sessionId);
    expect(exercises.single.successes, 2);
    expect(exercises.single.attempts, 3);

    await tester.tap(find.byTooltip('Finish session'));
    await tester.pumpAndSettle();
    expect(finished, isTrue);
    expect((await fixture.sessions.getSessionById(sessionId))!.finishedAt,
        isNotNull);
  });
}

final class _Fixture {
  _Fixture._({
    required this.database,
    required this.sessions,
    required this.matches,
    required this.racks,
    required this.training,
  });

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
      sessions: sessions,
      matches: matches,
      racks: racks,
      training: TrainingSessionExecutionService(
        sessions: sessions,
        matches: matches,
        racks: racks,
        recording: recording,
      ),
    );
  }

  final AppDatabase database;
  final SessionRepository sessions;
  final MatchRepository matches;
  final RackRepository racks;
  final TrainingSessionExecutionService training;
}
