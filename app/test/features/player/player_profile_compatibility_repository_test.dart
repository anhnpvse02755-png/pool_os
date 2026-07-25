import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/application/player_profile_compatibility_service.dart';
import 'package:pool_os/features/player/data/database/app_database.dart';
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart' as domain;
import 'package:pool_os/features/player/domain/player_lifecycle_failure.dart';
import 'package:pool_os/features/player/domain/player_profile_compatibility.dart';

void main() {
  late AppDatabase database;
  late PlayerRepository repository;
  late PlayerProfileCompatibilityService service;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = PlayerRepository(database);
    service = PlayerProfileCompatibilityService(sourceReader: repository);
  });

  tearDown(() => database.close());

  test('repository reads the exact persisted v29 profile representation',
      () async {
    await _insertRawPlayer(
      database,
      id: 11,
      playStyles: '[ "safe",\n"attack" ]',
      trainingGoals: '["position", "rank_up"]',
      startedPlayingAt: 1609459200,
      hasCompeted: 1,
      createdAt: 1704164645,
      updatedAt: 1704168245,
    );

    final raw = await repository.readPlayerProfileRawSource(11);

    expect(raw, isNotNull);
    expect(raw!.sourceSchemaVersion, 29);
    expect(raw.legacyPlayerId, 11);
    expect(raw.sourceReference, 'player:11');
    expect(raw.playStylesRawJson, '[ "safe",\n"attack" ]');
    expect(raw.trainingGoalsRawJson, '["position", "rank_up"]');
    expect(raw.startedPlayingAtStorageValue, 1609459200);
    expect(raw.hasCompetedStorageValue, 1);
    expect(raw.createdAtStorageValue, 1704164645);
    expect(raw.updatedAtStorageValue, 1704168245);
  });

  test('explicit missing ID never falls back to Active Player', () async {
    await _insertRawPlayer(database, id: 1, isActive: 1);

    await expectLater(
      service.readByLegacyPlayerId(99),
      throwsA(_failure(PlayerProfileFailureCode.targetNotFound)),
    );
    expect((await service.readActivePlayer())!.snapshot!.legacyPlayerId, 1);
  });

  test('active read returns null only for valid empty storage', () async {
    expect(await service.readActivePlayer(), isNull);

    await _insertRawPlayer(database, id: 1, isActive: 1);
    await _insertRawPlayer(database, id: 2, isActive: 0);
    expect((await service.readActivePlayer())!.snapshot!.legacyPlayerId, 1);

    await database.customStatement('UPDATE players SET is_active = 0');
    await expectLater(
      service.readActivePlayer(),
      throwsA(
        _failure(PlayerProfileFailureCode.activeInvariantViolated),
      ),
    );
  });

  test('active read fails closed for multiple active rows without repair',
      () async {
    await _insertRawPlayer(database, id: 1, isActive: 1);
    await _insertRawPlayer(database, id: 2, isActive: 0);
    await database.customStatement('DROP INDEX players_single_active_idx');
    await database.customStatement('UPDATE players SET is_active = 1');

    await expectLater(
      service.readActivePlayer(),
      throwsA(
        _failure(PlayerProfileFailureCode.activeInvariantViolated),
      ),
    );
    final active = await database
        .customSelect('SELECT id FROM players WHERE is_active = 1 ORDER BY id')
        .get();
    expect(active.map((row) => row.data['id']), [1, 2]);
  });

  test('signed stored IDs keep attribution and have no canonical output',
      () async {
    await _insertRawPlayer(database, id: 0, isActive: 1);
    await _insertRawPlayer(database, id: -3, isActive: 0);

    for (final id in const [0, -3]) {
      final result = await service.readByLegacyPlayerId(id);
      expect(result.assessment.source.sourceReference, 'player:$id');
      expect(
        result.assessment.diagnostics.single.code,
        PlayerProfileDiagnosticCode.invalidPlayerId,
      );
      expect(result.snapshot, isNull);
      expect(result.foundationProfile, isNull);
      expect(result.contract, isNull);
    }
  });

  test('selection changes do not affect either explicit profile digest',
      () async {
    final first = await repository.createPlayer(_player('First'));
    final second = await repository.createPlayer(_player('Second'));
    final beforeFirst = await service.readByLegacyPlayerId(first);
    final beforeSecond = await service.readByLegacyPlayerId(second);

    await repository.switchActivePlayer(second);
    final afterFirst = await service.readByLegacyPlayerId(first);
    final afterSecond = await service.readByLegacyPlayerId(second);

    expect(
        afterFirst.snapshot!.sourceDigest, beforeFirst.snapshot!.sourceDigest);
    expect(afterFirst.snapshot!.digest, beforeFirst.snapshot!.digest);
    expect(afterFirst.assessment.rawAssessmentDigest,
        beforeFirst.assessment.rawAssessmentDigest);
    expect(afterSecond.snapshot!.sourceDigest,
        beforeSecond.snapshot!.sourceDigest);
    expect(afterSecond.snapshot!.digest, beforeSecond.snapshot!.digest);
    expect(afterSecond.assessment.rawAssessmentDigest,
        beforeSecond.assessment.rawAssessmentDigest);
  });

  test('profile changes alter digests and identical reads are no-ops',
      () async {
    final id = await repository.createPlayer(_player('Original'));
    final first = await service.readByLegacyPlayerId(id);
    final repeated = await service.readByLegacyPlayerId(id);
    expect(repeated.assessment.toJsonString(), first.assessment.toJsonString());
    expect(repeated.snapshot!.toJsonString(), first.snapshot!.toJsonString());

    final player = await repository.getPlayerById(id);
    await repository.updatePlayer(player!.copyWith(name: 'Changed'));
    final changed = await service.readByLegacyPlayerId(id);

    expect(changed.assessment.rawAssessmentDigest,
        isNot(first.assessment.rawAssessmentDigest));
    expect(changed.snapshot!.sourceDigest, isNot(first.snapshot!.sourceDigest));
    expect(changed.snapshot!.digest, isNot(first.snapshot!.digest));
  });

  test('raw assessment and snapshot survive SQLite close and reopen', () async {
    await database.close();
    final directory =
        await Directory.systemTemp.createTemp('pool_os_profile_compat_');
    final file = File('${directory.path}/profile.db');
    try {
      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = PlayerRepository(database);
      service = PlayerProfileCompatibilityService(sourceReader: repository);
      await _insertRawPlayer(
        database,
        id: 25,
        playStyles: '[ "attack", "safe" ]',
        startedPlayingAt: 1609459200,
        createdAt: 1704164645,
        updatedAt: 1704168245,
      );
      final before = await service.readByLegacyPlayerId(25);
      await database.close();

      database = AppDatabase.forTesting(NativeDatabase(file));
      repository = PlayerRepository(database);
      service = PlayerProfileCompatibilityService(sourceReader: repository);
      final after = await service.readByLegacyPlayerId(25);

      expect(after.assessment.toJsonString(), before.assessment.toJsonString());
      expect(after.snapshot!.toJsonString(), before.snapshot!.toJsonString());
    } finally {
      await database.close();
      if (await directory.exists()) await directory.delete(recursive: true);
      database = AppDatabase.forTesting(NativeDatabase.memory());
      repository = PlayerRepository(database);
      service = PlayerProfileCompatibilityService(sourceReader: repository);
    }
  });

  group('operation failure mapping', () {
    test('keeps database and source-materialization failures distinct',
        () async {
      for (final entry in const {
        PlayerProfileSourceFailureKind.database:
            PlayerProfileFailureCode.databaseFailure,
        PlayerProfileSourceFailureKind.sourceRead:
            PlayerProfileFailureCode.sourceReadFailure,
      }.entries) {
        final failing = PlayerProfileCompatibilityService(
          sourceReader: _FailingSourceReader(
            PlayerProfileSourceException(entry.key),
          ),
        );
        await expectLater(
          failing.readByLegacyPlayerId(1),
          throwsA(_failure(entry.value)),
        );
      }
    });

    test('maps FEATURE_004 active invariant before assessment', () async {
      const failing = PlayerProfileCompatibilityService(
        sourceReader: _FailingSourceReader(
          PlayerLifecycleException(
            PlayerLifecycleFailureCode.invariantViolated,
          ),
        ),
      );

      await expectLater(
        failing.readActivePlayer(),
        throwsA(
          _failure(PlayerProfileFailureCode.activeInvariantViolated),
        ),
      );
    });
  });
}

Future<void> _insertRawPlayer(
  AppDatabase database, {
  required int id,
  int isActive = 1,
  String playStyles = '["safe", "attack"]',
  String trainingGoals = '["rank_up", "position"]',
  int? startedPlayingAt,
  int hasCompeted = 0,
  int createdAt = 1704164645,
  int updatedAt = 1704168245,
}) {
  return database.customStatement(
    '''
INSERT INTO players (
  id, name, dominant_hand, language, measurement_system, theme, is_active,
  avatar_path, age, gender, club_region, rank, main_game, goal,
  play_styles, training_goals, started_playing_at, has_competed,
  hours_per_week, created_at, updated_at
) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
''',
    [
      id,
      'Raw Player $id',
      'right',
      'english',
      'metric',
      'dark',
      isActive,
      null,
      null,
      null,
      null,
      null,
      null,
      null,
      playStyles,
      trainingGoals,
      startedPlayingAt,
      hasCompeted,
      null,
      createdAt,
      updatedAt,
    ],
  );
}

domain.Player _player(String name) => domain.Player(
      name: name,
      dominantHand: 'right',
      language: 'english',
      measurementSystem: 'metric',
      theme: 'dark',
      playStyles: const ['safe', 'attack'],
      trainingGoals: const ['rank_up', 'position'],
    );

final class _FailingSourceReader implements PlayerProfileRawSourceReader {
  const _FailingSourceReader(this.error);

  final Object error;

  @override
  Future<PlayerProfileRawSource?> readActivePlayerProfileRawSource() =>
      Future.error(error);

  @override
  Future<PlayerProfileRawSource?> readPlayerProfileRawSource(
          int legacyPlayerId) =>
      Future.error(error);
}

Matcher _failure(PlayerProfileFailureCode code) =>
    isA<PlayerProfileException>().having(
      (error) => error.code,
      'code',
      code,
    );
