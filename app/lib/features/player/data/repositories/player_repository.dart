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

  Future<List<Player>> getAllPlayers() async {
    final results = await _db.select(_db.players).get();
    return results
        .map(
          (r) => Player(
            id: r.id,
            name: r.name,
            dominantHand: r.dominantHand,
            language: r.language,
            measurementSystem: r.measurementSystem,
            theme: r.theme,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  Future<Player?> getPlayer() async {
    final result = await _db.select(_db.players).getSingleOrNull();
    if (result == null) return null;
    return Player(
      id: result.id,
      name: result.name,
      dominantHand: result.dominantHand,
      language: result.language,
      measurementSystem: result.measurementSystem,
      theme: result.theme,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
  }

  Future<Player?> getPlayerById(int id) async {
    final result = await (_db.select(_db.players)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return Player(
      id: result.id,
      name: result.name,
      dominantHand: result.dominantHand,
      language: result.language,
      measurementSystem: result.measurementSystem,
      theme: result.theme,
      createdAt: result.createdAt,
      updatedAt: result.updatedAt,
    );
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
          ..where((tbl) => tbl.isActive.equals(true)))
        .getSingleOrNull();
    if (result != null) {
      return Player(
        id: result.id,
        name: result.name,
        dominantHand: result.dominantHand,
        language: result.language,
        measurementSystem: result.measurementSystem,
        theme: result.theme,
        createdAt: result.createdAt,
        updatedAt: result.updatedAt,
      );
    }
    // If no active player found, get the first player
    final first = await _db.select(_db.players).getSingleOrNull();
    if (first == null) return null;
    return Player(
      id: first.id,
      name: first.name,
      dominantHand: first.dominantHand,
      language: first.language,
      measurementSystem: first.measurementSystem,
      theme: first.theme,
      createdAt: first.createdAt,
      updatedAt: first.updatedAt,
    );
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
