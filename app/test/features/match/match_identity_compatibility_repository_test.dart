import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/match/application/match_identity_compatibility_service.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/match_identity_compatibility.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';

void main() {
  late AppDatabase database;
  late MatchRepository repository;
  late MatchIdentityCompatibilityService service;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = MatchRepository(database);
    service = MatchIdentityCompatibilityService(sourceReader: repository);
  });

  tearDown(() => database.close());

  test('repository reads exact persisted v29 Match storage values', () async {
    await _insertSession(database, 3);
    await _insertMatch(
      database,
      id: 11,
      sessionId: 3,
      gameType: 'race_to_11',
      raceTo: 11,
      opponent: ' Opponent ',
      partner: '',
      teamMode: 'doubles',
      winner: 'Player',
      result: '11-8',
      objective: 'win',
      notes: 'exact',
      startTime: 1704164645,
      endTime: 1704168245,
      createdAt: 1704161045,
    );

    final raw = await repository.readMatchIdentityRawSource(11);

    expect(raw, isNotNull);
    expect(raw!.sourceSchemaVersion, 30);
    expect(raw.legacyMatchId, 11);
    expect(raw.sourceReference, 'match:11');
    expect(raw.legacySessionId, 3);
    expect(raw.gameTypeRaw, 'race_to_11');
    expect(raw.raceToRaw, 11);
    expect(raw.opponentRaw, ' Opponent ');
    expect(raw.partnerRaw, '');
    expect(raw.teamModeRaw, 'doubles');
    expect(raw.startTimeStorageValue, 1704164645);
    expect(raw.endTimeStorageValue, 1704168245);
    expect(raw.createdAtStorageValue, 1704161045);
  });

  test('explicit missing target never falls back to another Match', () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1);

    await expectLater(
      service.readByLegacyMatchId(99),
      throwsA(_failure(MatchIdentityFailureCode.targetNotFound)),
    );
    expect((await service.readByLegacyMatchId(1)).snapshot!.legacyMatchId, 1);
  });

  test('signed stored Match and Session IDs remain attributable', () async {
    await database.customStatement('PRAGMA foreign_keys = OFF');
    await _insertMatch(database, id: 0, sessionId: -3);
    await _insertMatch(database, id: -7, sessionId: 1, matchNumber: 2);

    final zero = await service.readByLegacyMatchId(0);
    expect(zero.assessment.source.sourceReference, 'match:0');
    expect(
      zero.assessment.diagnostics.map((item) => item.code),
      [
        MatchIdentityDiagnosticCode.invalidMatchId,
        MatchIdentityDiagnosticCode.invalidSessionId,
      ],
    );
    expect(zero.snapshot, isNull);

    final negative = await service.readByLegacyMatchId(-7);
    expect(negative.assessment.source.sourceReference, 'match:-7');
    expect(negative.snapshot, isNull);
  });

  test('schema storage-class mismatch is a source-read failure', () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1);
    await database.customStatement(
      "UPDATE matches SET start_time = 'not-a-timestamp' WHERE id = 1",
    );

    await expectLater(
      service.readByLegacyMatchId(1),
      throwsA(_failure(MatchIdentityFailureCode.sourceReadFailure)),
    );
  });

  test('database and source-materialization failures remain distinct',
      () async {
    for (final entry in const {
      MatchIdentitySourceFailureKind.database:
          MatchIdentityFailureCode.databaseFailure,
      MatchIdentitySourceFailureKind.sourceRead:
          MatchIdentityFailureCode.sourceReadFailure,
    }.entries) {
      final failing = MatchIdentityCompatibilityService(
        sourceReader: _FailingSourceReader(
          MatchIdentitySourceException(entry.key),
        ),
      );
      await expectLater(
        failing.readByLegacyMatchId(1),
        throwsA(_failure(entry.value)),
      );
    }
  });

  test('repeated reads are byte-identical and perform no writes', () async {
    await _insertSession(database, 1);
    await _insertMatch(database, id: 1, sessionId: 1);
    final before = await _rawRow(database, 1);

    final first = await service.readByLegacyMatchId(1);
    final second = await service.readByLegacyMatchId(1);
    final after = await _rawRow(database, 1);

    expect(second.assessment.toJsonString(), first.assessment.toJsonString());
    expect(second.snapshot!.toJsonString(), first.snapshot!.toJsonString());
    expect(after, before);
  });

  test('raw assessment and snapshot survive SQLite close and reopen', () async {
    await database.close();
    final directory =
        await Directory.systemTemp.createTemp('pool_os_match_identity_');
    final file = File('${directory.path}/match.db');
    try {
      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = MatchRepository(database);
      service = MatchIdentityCompatibilityService(sourceReader: repository);
      await _insertSession(database, 5);
      await _insertMatch(
        database,
        id: 25,
        sessionId: 5,
        gameType: 'practice',
      );
      final before = await service.readByLegacyMatchId(25);
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = MatchRepository(database);
      service = MatchIdentityCompatibilityService(sourceReader: repository);
      final after = await service.readByLegacyMatchId(25);

      expect(after.assessment.toJsonString(), before.assessment.toJsonString());
      expect(after.snapshot!.toJsonString(), before.snapshot!.toJsonString());
    } finally {
      await database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = MatchRepository(database);
      service = MatchIdentityCompatibilityService(sourceReader: repository);
    }
  });
}

Future<void> _insertSession(AppDatabase database, int id) {
  return database.customStatement(
    '''
INSERT INTO sessions (
  id, session_type, started_at, created_at, updated_at
) VALUES (?, ?, ?, ?, ?)
''',
    [id, 'match', 1704160000, 1704160000, 1704160000],
  );
}

Future<void> _insertMatch(
  AppDatabase database, {
  required int id,
  required int sessionId,
  int matchNumber = 1,
  String gameType = 'race_to',
  int? raceTo = 7,
  String? opponent,
  String? partner,
  String? teamMode = 'solo',
  String? winner,
  String? result,
  String? objective,
  String? notes,
  int? startTime = 1704161000,
  int? endTime,
  int createdAt = 1704160000,
}) {
  return database.customStatement(
    '''
INSERT INTO matches (
  id, session_id, match_number, game_type, race_to, opponent, partner,
  team_mode, winner, result, match_objective, notes, start_time, end_time,
  created_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
    [
      id,
      sessionId,
      matchNumber,
      gameType,
      raceTo,
      opponent,
      partner,
      teamMode,
      winner,
      result,
      objective,
      notes,
      startTime,
      endTime,
      createdAt,
    ],
  );
}

Future<Map<String, Object?>> _rawRow(AppDatabase database, int id) async {
  final row = await database.customSelect(
    'SELECT * FROM matches WHERE id = ?',
    variables: [Variable<int>(id)],
    readsFrom: {database.matches},
  ).getSingle();
  return Map<String, Object?>.from(row.data);
}

final class _FailingSourceReader implements MatchIdentityRawSourceReader {
  const _FailingSourceReader(this.error);

  final Object error;

  @override
  Future<MatchIdentityRawSource?> readMatchIdentityRawSource(
    int legacyMatchId,
  ) =>
      Future.error(error);
}

Matcher _failure(MatchIdentityFailureCode code) =>
    isA<MatchIdentityException>().having(
      (error) => error.code,
      'code',
      code,
    );
