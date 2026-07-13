import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(ref.watch(databaseProvider));
});

class PlayerRepository {
  final db.AppDatabase _db;

  PlayerRepository(this._db);

  Player _mapToPlayer(db.Player r) {
    return Player(
      id: r.id,
      name: r.name,
      dominantHand: r.dominantHand,
      language: r.language,
      measurementSystem: r.measurementSystem,
      theme: r.theme,
      isActive: r.isActive,
      avatarPath: r.avatarPath,
      age: r.age,
      gender: r.gender,
      clubRegion: r.clubRegion,
      rank: r.rank,
      mainGame: r.mainGame,
      goal: r.goal,
      playStyles: Player.decodeList(r.playStyles),
      trainingGoals: Player.decodeList(r.trainingGoals),
      startedPlayingAt: r.startedPlayingAt,
      hasCompeted: r.hasCompeted,
      hoursPerWeek: r.hoursPerWeek,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  Future<List<Player>> getAllPlayers() async {
    final results = await _db.select(_db.players).get();
    return results.map(_mapToPlayer).toList();
  }

  Future<Player?> getPlayer() async {
    final result = await _db.select(_db.players).getSingleOrNull();
    if (result == null) return null;
    return _mapToPlayer(result);
  }

  Future<Player?> getPlayerById(int id) async {
    final result = await (_db.select(_db.players)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToPlayer(result);
  }

  Future<int> createPlayer(Player player) async {
    return _db.into(_db.players).insert(
          db.PlayersCompanion.insert(
            name: player.name,
            dominantHand: Value(player.dominantHand),
            language: Value(player.language),
            measurementSystem: Value(player.measurementSystem),
            theme: Value(player.theme),
            isActive: const Value(true),
            avatarPath: Value(player.avatarPath),
            age: Value(player.age),
            gender: Value(player.gender),
            clubRegion: Value(player.clubRegion),
            rank: Value(player.rank),
            mainGame: Value(player.mainGame),
            goal: Value(player.goal),
            playStyles: Value(Player.encodeList(player.playStyles)),
            trainingGoals: Value(Player.encodeList(player.trainingGoals)),
            startedPlayingAt: Value(player.startedPlayingAt),
            hasCompeted: Value(player.hasCompeted),
            hoursPerWeek: Value(player.hoursPerWeek),
            createdAt: Value(player.createdAt),
            updatedAt: Value(player.updatedAt),
          ),
        );
  }

  Future<bool> updatePlayer(Player player) async {
    final updatedRows = await (_db.update(_db.players)
          ..where((tbl) => tbl.id.equals(player.id!)))
        .write(
      db.PlayersCompanion(
        name: Value(player.name),
        dominantHand: Value(player.dominantHand),
        language: Value(player.language),
        measurementSystem: Value(player.measurementSystem),
        theme: Value(player.theme),
        isActive: Value(player.isActive),
        avatarPath: Value(player.avatarPath),
        age: Value(player.age),
        gender: Value(player.gender),
        clubRegion: Value(player.clubRegion),
        rank: Value(player.rank),
        mainGame: Value(player.mainGame),
        goal: Value(player.goal),
        playStyles: Value(Player.encodeList(player.playStyles)),
        trainingGoals: Value(Player.encodeList(player.trainingGoals)),
        startedPlayingAt: Value(player.startedPlayingAt),
        hasCompeted: Value(player.hasCompeted),
        hoursPerWeek: Value(player.hoursPerWeek),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return updatedRows > 0;
  }

  Future<int> deletePlayer(int id) async {
    return (_db.delete(_db.players)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<Player?> getActivePlayer() async {
    final result = await (_db.select(_db.players)
          ..where((tbl) => tbl.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (result != null) return _mapToPlayer(result);
    // If no active player found, get the first player.
    // RFC-302 Task 1: must NOT use getSingleOrNull() on the whole table —
    // it throws StateError "Too many elements" once a 2nd player exists.
    final first = await (_db.select(_db.players)
          ..orderBy([(t) => OrderingTerm.asc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (first == null) return null;
    return _mapToPlayer(first);
  }

  Future<void> setActivePlayer(int id) async {
    // First, deactivate all players
    await _db.customStatement('UPDATE players SET is_active = 0');

    // Then activate the selected player
    await (_db.update(_db.players)
          ..where((tbl) => tbl.id.equals(id)))
        .write(const db.PlayersCompanion(isActive: Value(true)));
  }
}
