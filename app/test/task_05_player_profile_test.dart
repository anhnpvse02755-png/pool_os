import 'dart:io';
import 'package:drift/native.dart' show NativeDatabase;
import 'package:drift/drift.dart' show QueryExecutor;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' show AppDatabase;
import 'package:pool_os/features/player/data/repositories/player_repository.dart';
import 'package:pool_os/features/player/domain/models/player.dart';

/// Task 05 Player Profile: the career-profile fields (schema v15) must persist
/// durably and round-trip through the repository — including the JSON-encoded
/// multi-select lists (playStyles / trainingGoals) — and survive a DB restart.
void main() {
  late AppDatabase db;
  late PlayerRepository repo;

  AppDatabase openDb(QueryExecutor executor) {
    final database = AppDatabase.forTesting(executor);
    repo = PlayerRepository(database);
    return database;
  }

  setUp(() {
    db = openDb(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Player buildProfile() => Player(
        name: 'Ngoc Anh',
        dominantHand: 'right',
        language: 'vi',
        measurementSystem: 'metric',
        theme: 'dark',
        age: 28,
        gender: 'male',
        clubRegion: 'Ha Noi',
        rank: 'G',
        mainGame: '9 Ball',
        goal: 'Len hang F',
        playStyles: const [PlayStyles.steady, PlayStyles.control],
        trainingGoals: const [TrainingGoals.breakPower, TrainingGoals.jump],
        startedPlayingAt: DateTime(2024, 2, 1),
        hasCompeted: true,
        hoursPerWeek: 6,
      );

  test('all profile fields round-trip through the repository', () async {
    final id = await repo.createPlayer(buildProfile());
    expect(id, greaterThan(0));

    final stored = await repo.getPlayerById(id);
    expect(stored, isNotNull);
    expect(stored!.rank, 'G');
    expect(stored.mainGame, '9 Ball');
    expect(stored.age, 28);
    expect(stored.clubRegion, 'Ha Noi');
    expect(stored.goal, 'Len hang F');
    expect(stored.hasCompeted, isTrue);
    expect(stored.hoursPerWeek, 6);
    expect(stored.startedPlayingAt, DateTime(2024, 2, 1));
    // Multi-select lists survive JSON encode/decode.
    expect(stored.playStyles, containsAll([PlayStyles.steady, PlayStyles.control]));
    expect(stored.trainingGoals, containsAll([TrainingGoals.breakPower, TrainingGoals.jump]));
  });

  test('empty multi-select lists default to [] not null', () async {
    final id = await repo.createPlayer(Player(
      name: 'Minimal',
      dominantHand: 'left',
      language: 'en',
      measurementSystem: 'metric',
      theme: 'dark',
    ));
    final stored = await repo.getPlayerById(id);
    expect(stored!.playStyles, isEmpty);
    expect(stored.trainingGoals, isEmpty);
    expect(stored.rank, isNull);
  });

  test('profile survives a database restart (schema v15 durable)', () async {
    final dir = await Directory.systemTemp.createTemp('task05_');
    final file = File('${dir.path}/pool_os_test.db');
    int id;
    try {
      db = openDb(NativeDatabase(file));
      id = await repo.createPlayer(buildProfile());
      await db.close();

      db = openDb(NativeDatabase(file));
      final stored = await repo.getPlayerById(id);
      expect(stored, isNotNull);
      expect(stored!.rank, 'G');
      expect(stored.playStyles, containsAll([PlayStyles.steady, PlayStyles.control]));
      expect(stored.startedPlayingAt, DateTime(2024, 2, 1));
    } finally {
      await db.close();
      if (await dir.exists()) await dir.delete(recursive: true);
      db = openDb(NativeDatabase.memory());
    }
  });
}
