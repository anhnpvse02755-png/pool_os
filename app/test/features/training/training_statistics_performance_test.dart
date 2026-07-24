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
import 'package:pool_os/features/training/application/training_statistics_service.dart';
import 'package:pool_os/features/training/presentation/training_statistics_panel.dart';

void main() {
  late _Fixture fixture;

  setUp(() => fixture = _Fixture.open(NativeDatabase.memory()));
  tearDown(() => fixture.database.close());

  testWidgets('aggregates and renders persisted training performance',
      (tester) async {
    await fixture.createCompleted(
      name: 'Long Pot',
      attempts: 10,
      successes: 6,
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );
    await fixture.createCompleted(
      name: 'Long Pot',
      attempts: 5,
      successes: 4,
      startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    );
    await fixture.training.createSession();

    final result = await fixture.statistics.load();

    expect(result.sessionCount, 2);
    expect(result.exerciseCount, 2);
    expect(result.attempts, 15);
    expect(result.successes, 10);
    expect(result.drills.single.name, 'Long Pot');
    expect(result.drills.single.attempts, 15);
    expect(result.trend.length, 2);
    expect(result.recent.first.successRate, 0.8);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(fixture.database)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: TrainingStatisticsPanel()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Training performance'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Attempts'), findsOneWidget);
    expect(find.text('67%'), findsOneWidget);
    expect(find.text('Drill performance'), findsOneWidget);
    expect(find.text('Long Pot'), findsOneWidget);
    expect(find.text('10/15 success'), findsOneWidget);
    expect(find.text('Last 5 sessions'), findsOneWidget);
  });

  test('statistics survive database restart', () async {
    final directory = await Directory.systemTemp.createTemp('pool_os_i6_');
    final file = File('${directory.path}/training-statistics.db');
    try {
      await fixture.database.close();
      fixture = _Fixture.open(NativeDatabase(file));
      await fixture.createCompleted(
        name: 'Stop Shot',
        attempts: 9,
        successes: 7,
        startedAt: DateTime.now().subtract(const Duration(minutes: 20)),
      );
      await fixture.database.close();

      fixture = _Fixture.open(NativeDatabase(file));
      final result = await fixture.statistics.load();

      expect(result.sessionCount, 1);
      expect(result.attempts, 9);
      expect(result.successes, 7);
      expect(result.drills.single.code, 'stop-shot');
    } finally {
      await fixture.database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      fixture = _Fixture.open(NativeDatabase.memory());
    }
  });
}

final class _Fixture {
  _Fixture._({
    required this.database,
    required this.training,
    required this.statistics,
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
    final training = TrainingSessionExecutionService(
      sessions: sessions,
      matches: matches,
      racks: racks,
      recording: recording,
    );
    return _Fixture._(
      database: database,
      training: training,
      statistics: TrainingStatisticsService(training),
    );
  }

  final AppDatabase database;
  final TrainingSessionExecutionService training;
  final TrainingStatisticsService statistics;

  Future<void> createCompleted({
    required String name,
    required int attempts,
    required int successes,
    required DateTime startedAt,
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
  }
}
