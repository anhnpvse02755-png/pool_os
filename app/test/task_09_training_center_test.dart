import 'package:drift/native.dart' show NativeDatabase;
import 'package:drift/drift.dart' show QueryExecutor;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart'
    show AppDatabase;
import 'package:pool_os/features/training_center/data/repositories/training_center_repository.dart';
import 'package:pool_os/features/training_center/domain/models/training_center_models.dart';
import 'package:pool_os/features/training_center/domain/progress_calculator.dart';

/// TASK 09 — Training Center.
///
/// Exercises the hand-entered practice log against an in-memory DB: custom
/// drills, training sessions + drill runs, favourites, and the pure
/// [ProgressCalculator] before/after windows. All data is real recorded rows;
/// nothing touches the LOCKED recording pipeline.
void main() {
  late AppDatabase db;
  late TrainingCenterRepository repo;

  AppDatabase openDb(QueryExecutor executor) {
    final database = AppDatabase.forTesting(executor);
    repo = TrainingCenterRepository(database);
    return database;
  }

  setUp(() {
    db = openDb(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Custom drills (Phần 3)', () {
    test('create → read round-trips all fields', () async {
      final id = await repo.createCustomDrill(CustomDrill(
        name: 'Long straight pot',
        category: 'long_pot',
        targetReps: 50,
        successCriteria: 'Pot + hold center',
        createdAt: DateTime(2026, 7, 1),
      ));

      final drill = await repo.getCustomDrillById(id);
      expect(drill, isNotNull);
      expect(drill!.name, 'Long straight pot');
      expect(drill.category, 'long_pot');
      expect(drill.targetReps, 50);
      expect(drill.successCriteria, 'Pot + hold center');
    });

    test('update mutates fields; delete removes the drill', () async {
      final id = await repo.createCustomDrill(CustomDrill(
        name: 'Draw control',
        category: 'draw',
        createdAt: DateTime(2026, 7, 1),
      ));

      final ok = await repo.updateCustomDrill(CustomDrill(
        id: id,
        name: 'Draw control v2',
        category: 'draw',
        targetReps: 80,
        createdAt: DateTime(2026, 7, 1),
      ));
      expect(ok, isTrue);
      expect((await repo.getCustomDrillById(id))!.name, 'Draw control v2');
      expect((await repo.getCustomDrillById(id))!.targetReps, 80);

      await repo.deleteCustomDrill(id);
      expect(await repo.getCustomDrillById(id), isNull);
    });

    test('list orders newest first', () async {
      await repo.createCustomDrill(CustomDrill(
          name: 'A', category: 'draw', createdAt: DateTime(2026, 7, 1)));
      await repo.createCustomDrill(CustomDrill(
          name: 'B', category: 'draw', createdAt: DateTime(2026, 7, 5)));
      final all = await repo.getCustomDrills();
      expect(all.map((d) => d.name).toList(), ['B', 'A']);
    });
  });

  group('Sessions + drill runs (Phần 2)', () {
    test('a session holds many runs; success rate is stored', () async {
      final sid = await repo.createSession(
        TrainingSession(startedAt: DateTime(2026, 7, 10)),
      );
      await repo.addDrillRun(DrillRun(
        sessionId: sid,
        drillCode: 'stop_shot_1',
        drillName: 'Stop shot',
        category: 'stop_shot',
        targetReps: 100,
        attempts: 100,
        successes: 71,
        createdAt: DateTime(2026, 7, 10),
      ));
      await repo.addDrillRun(DrillRun(
        sessionId: sid,
        drillCode: 'draw_1',
        drillName: 'Draw',
        category: 'draw',
        targetReps: 50,
        attempts: 50,
        successes: 20,
        createdAt: DateTime(2026, 7, 10, 0, 1),
      ));

      final runs = await repo.getRunsForSession(sid);
      expect(runs.length, 2);
      expect(runs.first.successRate, closeTo(0.71, 0.001));
      expect(runs.last.successRate, closeTo(0.40, 0.001));
    });

    test('deleting a session cascades its runs (manual soft cascade)', () async {
      final sid = await repo.createSession(
        TrainingSession(startedAt: DateTime(2026, 7, 10)),
      );
      await repo.addDrillRun(DrillRun(
        sessionId: sid,
        drillCode: 'stop_shot_1',
        drillName: 'Stop shot',
        category: 'stop_shot',
        targetReps: 100,
        attempts: 10,
        successes: 5,
        createdAt: DateTime(2026, 7, 10),
      ));

      await repo.deleteSession(sid);
      expect(await repo.getRunsForSession(sid), isEmpty);
    });

    test('recent runs come back newest first, respecting the limit', () async {
      final sid = await repo.createSession(
        TrainingSession(startedAt: DateTime(2026, 7, 10)),
      );
      for (var i = 0; i < 7; i++) {
        await repo.addDrillRun(DrillRun(
          sessionId: sid,
          drillCode: 'd$i',
          drillName: 'Drill $i',
          category: 'draw',
          targetReps: 10,
          attempts: 10,
          successes: i,
          createdAt: DateTime(2026, 7, 10, 0, i),
        ));
      }
      final recent = await repo.getAllRuns(limit: 5);
      expect(recent.length, 5);
      expect(recent.first.drillName, 'Drill 6'); // newest
    });
  });

  group('Favorites (Phần 5)', () {
    test('set / unset toggles membership without duplicates', () async {
      await repo.setFavorite('long_pot_1', true);
      await repo.setFavorite('long_pot_1', true); // idempotent
      expect(await repo.getFavoriteKeys(), {'long_pot_1'});

      await repo.setFavorite('long_pot_1', false);
      expect(await repo.getFavoriteKeys(), isEmpty);
    });
  });

  group('ProgressCalculator (Phần 4)', () {
    const calc = ProgressCalculator();
    final now = DateTime(2026, 7, 15);

    DrillRun run(String code, int attempts, int successes, DateTime at) =>
        DrillRun(
          sessionId: 1,
          drillCode: code,
          drillName: code,
          category: 'long_pot',
          targetReps: 100,
          attempts: attempts,
          successes: successes,
          createdAt: at,
        );

    test('compares previous window vs current (Long Pot 58% → 71%)', () {
      final runs = [
        // earlier window (> 30 days ago): 58%
        run('long_pot', 100, 58, now.subtract(const Duration(days: 40))),
        // later window (within 30 days): 71%
        run('long_pot', 100, 71, now.subtract(const Duration(days: 5))),
      ];

      final progress = calc.byDrill(runs, now: now);
      expect(progress.length, 1);
      final p = progress.single;
      expect(p.hasComparison, isTrue);
      expect((p.previousRate * 100).round(), 58);
      expect((p.currentRate * 100).round(), 71);
      expect(p.deltaPoints.round(), 13);
    });

    test('single-window drill reports no comparison', () {
      final runs = [
        run('long_pot', 100, 71, now.subtract(const Duration(days: 5))),
      ];
      final p = calc.byDrill(runs, now: now).single;
      expect(p.hasComparison, isFalse);
      expect(p.previousAttempts, 0);
      expect(p.currentAttempts, 100);
    });

    test('drills with no attempts are skipped, never fabricated', () {
      final p = calc.byDrill([], now: now);
      expect(p, isEmpty);
    });

    test('sorts biggest movers first', () {
      final runs = [
        // small mover: 50% → 52%
        run('a', 100, 50, now.subtract(const Duration(days: 40))),
        run('a', 100, 52, now.subtract(const Duration(days: 5))),
        // big mover: 30% → 60%
        run('b', 100, 30, now.subtract(const Duration(days: 40))),
        run('b', 100, 60, now.subtract(const Duration(days: 5))),
      ];
      final progress = calc.byDrill(runs, now: now);
      expect(progress.first.drillKey, 'b'); // 30pt change on top
      expect(progress.last.drillKey, 'a');
    });

    test('byCategory aggregates runs across drills of the same category', () {
      final runs = [
        run('a', 50, 25, now.subtract(const Duration(days: 40))),
        run('b', 50, 25, now.subtract(const Duration(days: 40))),
        run('a', 50, 40, now.subtract(const Duration(days: 5))),
        run('b', 50, 40, now.subtract(const Duration(days: 5))),
      ];
      final byCat = calc.byCategory(runs, now: now);
      expect(byCat.length, 1);
      final p = byCat.single;
      expect(p.drillKey, 'long_pot');
      expect(p.previousAttempts, 100);
      expect((p.previousRate * 100).round(), 50);
      expect((p.currentRate * 100).round(), 80);
    });
  });
}
