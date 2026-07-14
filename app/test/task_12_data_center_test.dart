import 'package:drift/drift.dart' show QueryExecutor, Value;
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/data_center/data/data_center_service.dart';
import 'package:pool_os/features/data_center/domain/models/data_center_models.dart';

/// TASK 12 — Data Center.
///
/// Exercises the backup/restore round-trip, version guards, database info and
/// maintenance against an in-memory DB. The service manages storage of data
/// without changing its meaning; restore runs in one transaction and never
/// leaves partial state. Nothing here edits the Statistics engine or the LOCKED
/// recording pipeline logic. No AI.
///
/// File I/O paths (createBackupFile/listBackups/export) are exercised by the
/// app at runtime (they need path_provider's platform channels), so these tests
/// focus on the pure in-memory logic: buildBackup, restore, getInfo, integrity.
void main() {
  late AppDatabase db;
  late DataCenterService service;

  AppDatabase openDb(QueryExecutor executor) {
    final database = AppDatabase.forTesting(executor);
    service = DataCenterService(database);
    return database;
  }

  setUp(() => db = openDb(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<int> seedPlayerAndGoal() async {
    final playerId = await db.into(db.players).insert(
          PlayersCompanion.insert(name: 'Test Player'),
        );
    await db.into(db.goals).insert(GoalsCompanion.insert(
          title: 'Win 10 matches',
          metric: 'matches_won',
          targetValue: 10,
          createdAt: DateTime(2026, 7, 1),
        ));
    return playerId;
  }

  group('Backup (Phần 1)', () {
    test('buildBackup captures every table with format + schema version',
        () async {
      await seedPlayerAndGoal();
      final envelope = await service.buildBackup();

      expect(envelope.formatVersion, kBackupFormatVersion);
      expect(envelope.schemaVersion, db.schemaVersion);
      // Player + goal rows are present.
      expect(envelope.tables['players']!.length, 1);
      expect(envelope.tables['goals']!.length, 1);
      expect(envelope.totalRows, greaterThanOrEqualTo(2));
      // Every physical table appears as a key (generic backup).
      expect(envelope.tables.containsKey('shots'), isTrue);
      expect(envelope.tables.containsKey('matches'), isTrue);
    });

    test('backup JSON round-trips through the envelope', () async {
      await seedPlayerAndGoal();
      final envelope = await service.buildBackup();
      final restored = BackupEnvelope.fromJson(envelope.toJson());
      expect(restored.schemaVersion, envelope.schemaVersion);
      expect(restored.tables['players']!.length, 1);
      expect(restored.tables['players']!.first['name'], 'Test Player');
    });
  });

  group('Restore (Phần 2)', () {
    test('restore replaces current data with the backup, no duplicates',
        () async {
      await seedPlayerAndGoal();
      final envelope = await service.buildBackup();

      // Mutate the live DB: add a second player.
      await db.into(db.players).insert(PlayersCompanion.insert(name: 'Extra'));
      expect((await db.select(db.players).get()).length, 2);

      // Restoring the 1-player backup should bring it back to exactly 1.
      final result = await service.restore(envelope);
      expect(result.ok, isTrue);
      final players = await db.select(db.players).get();
      expect(players.length, 1);
      expect(players.first.name, 'Test Player');
    });

    test('restore refuses a mismatched schema version (no data change)',
        () async {
      await seedPlayerAndGoal();
      final good = await service.buildBackup();
      final bad = BackupEnvelope(
        formatVersion: good.formatVersion,
        schemaVersion: good.schemaVersion + 1, // pretend older/newer schema
        createdAt: good.createdAt,
        appLabel: good.appLabel,
        tables: good.tables,
      );

      final result = await service.restore(bad);
      expect(result.ok, isFalse);
      expect(result.errorKey, 'dc_err_schema');
      // Data untouched.
      expect((await db.select(db.players).get()).length, 1);
    });

    test('restore refuses a newer backup format', () async {
      final envelope = BackupEnvelope(
        formatVersion: kBackupFormatVersion + 1,
        schemaVersion: db.schemaVersion,
        createdAt: DateTime.now(),
        appLabel: 'Pool OS',
        tables: const {},
      );
      final result = await service.restore(envelope);
      expect(result.ok, isFalse);
      expect(result.errorKey, 'dc_err_format');
    });

    test('restore preserves bool columns (JSON bool -> SQLite int)', () async {
      // Seed a match + rack (rack.result is a bool) then round-trip it.
      final sessionId = await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              sessionType: 'match',
              startedAt: DateTime(2026, 7, 1),
            ),
          );
      final matchId = await db.into(db.matches).insert(MatchesCompanion.insert(
            sessionId: sessionId,
            matchNumber: 1,
            gameType: '9ball',
          ));
      await db.into(db.racks).insert(RacksCompanion.insert(
            matchId: matchId,
            rackNumber: 1,
            result: true,
            breakSuccess: const Value(true),
          ));

      final envelope = await service.buildBackup();
      final result = await service.restore(envelope);
      expect(result.ok, isTrue);
      final racks = await db.select(db.racks).get();
      expect(racks.single.result, isTrue);
      expect(racks.single.breakSuccess, isTrue);
    });
  });

  group('Database info (Phần 5)', () {
    test('getInfo counts rows and reports versions', () async {
      await seedPlayerAndGoal();
      final info = await service.getInfo();
      expect(info.schemaVersion, db.schemaVersion);
      expect(info.backupFormatVersion, kBackupFormatVersion);
      expect(info.players, 1);
      expect(info.goals, 1);
      expect(info.rowCounts.containsKey('shots'), isTrue);
    });
  });

  group('Maintenance (Phần 6)', () {
    test('verifyIntegrity passes on a healthy database', () async {
      await seedPlayerAndGoal();
      expect(await service.verifyIntegrity(), isTrue);
    });

    test('compact runs without touching data', () async {
      await seedPlayerAndGoal();
      await service.compact();
      expect((await db.select(db.players).get()).length, 1);
    });
  });
}
