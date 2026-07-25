import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/player/domain/models/player.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';
import 'package:pool_os/features/player/domain/career_timeline_projection.dart';
import 'package:pool_os/features/player/domain/player_lifecycle_failure.dart';
import 'package:pool_os/features/player/domain/player_profile_compatibility.dart';
import 'package:pool_os/features/player_model/domain/player_progress_projection.dart';

const _rawPlayerProfileSelect = '''
SELECT id, name, dominant_hand, language, measurement_system, theme,
       avatar_path, age, gender, club_region, rank, main_game, goal,
       play_styles, training_goals, started_playing_at, has_competed,
       hours_per_week, created_at, updated_at
FROM players
''';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepository(ref.watch(databaseProvider));
});

class PlayerRepository implements PlayerProfileRawSourceReader {
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
    final results = await (_db.select(_db.players)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return results.map(_mapToPlayer).toList();
  }

  Future<({List<Player> players, Player? activePlayer})>
      getPlayerSnapshot() async {
    return _runLifecycleTransaction(() async {
      final rows = await (_db.select(_db.players)
            ..orderBy([(table) => OrderingTerm.asc(table.id)]))
          .get();
      final active = _validateActivePlayerRows(rows);
      return (
        players: rows.map(_mapToPlayer).toList(growable: false),
        activePlayer: active,
      );
    });
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

  @override
  Future<PlayerProfileRawSource?> readPlayerProfileRawSource(
    int legacyPlayerId,
  ) async {
    final rows = await _readRawRows(
      '$_rawPlayerProfileSelect WHERE id = ?',
      variables: [Variable<int>(legacyPlayerId)],
    );
    if (rows.isEmpty) return null;
    if (rows.length != 1) {
      throw const PlayerProfileSourceException(
        PlayerProfileSourceFailureKind.sourceRead,
      );
    }
    return _materializeRawSource(rows.single.data);
  }

  @override
  Future<PlayerProfileRawSource?> readActivePlayerProfileRawSource() async {
    try {
      return await _db.transaction(() async {
        final selectionRows = await _readRawRows(
          'SELECT id, is_active FROM players ORDER BY id',
        );
        if (selectionRows.isEmpty) return null;
        late final List<int> activeIds;
        try {
          final invalidSelectionValue = selectionRows.any((row) {
            final value = row.data['is_active'];
            return value != 0 && value != 1;
          });
          if (invalidSelectionValue) {
            throw const PlayerLifecycleException(
              PlayerLifecycleFailureCode.invariantViolated,
            );
          }
          activeIds = selectionRows
              .where((row) => row.data['is_active'] == 1)
              .map((row) => row.data['id']! as int)
              .toList(growable: false);
        } on PlayerLifecycleException {
          rethrow;
        } catch (error) {
          throw PlayerProfileSourceException(
            PlayerProfileSourceFailureKind.sourceRead,
            cause: error,
          );
        }
        if (activeIds.length != 1) {
          throw const PlayerLifecycleException(
            PlayerLifecycleFailureCode.invariantViolated,
          );
        }
        final rows = await _readRawRows(
          '$_rawPlayerProfileSelect WHERE id = ?',
          variables: [Variable<int>(activeIds.single)],
        );
        if (rows.length != 1) {
          throw const PlayerProfileSourceException(
            PlayerProfileSourceFailureKind.sourceRead,
          );
        }
        return _materializeRawSource(rows.single.data);
      });
    } on PlayerLifecycleException {
      rethrow;
    } on PlayerProfileSourceException {
      rethrow;
    } catch (error) {
      throw PlayerProfileSourceException(
        PlayerProfileSourceFailureKind.database,
        cause: error,
      );
    }
  }

  Future<List<QueryRow>> _readRawRows(
    String sql, {
    List<Variable<Object>> variables = const [],
  }) async {
    try {
      return await _db.customSelect(
        sql,
        variables: variables,
        readsFrom: {_db.players},
      ).get();
    } catch (error) {
      throw PlayerProfileSourceException(
        PlayerProfileSourceFailureKind.database,
        cause: error,
      );
    }
  }

  PlayerProfileRawSource _materializeRawSource(Map<String, Object?> data) {
    try {
      return PlayerProfileRawSource(
        sourceSchemaVersion: _db.schemaVersion,
        legacyPlayerId: data['id']! as int,
        nameRaw: data['name']! as String,
        dominantHandRaw: data['dominant_hand']! as String,
        languageRaw: data['language']! as String,
        measurementSystemRaw: data['measurement_system']! as String,
        themeRaw: data['theme']! as String,
        avatarPathRaw: data['avatar_path'] as String?,
        ageRaw: data['age'] as int?,
        genderRaw: data['gender'] as String?,
        clubRegionRaw: data['club_region'] as String?,
        rankRaw: data['rank'] as String?,
        mainGameRaw: data['main_game'] as String?,
        goalRaw: data['goal'] as String?,
        playStylesRawJson: data['play_styles']! as String,
        trainingGoalsRawJson: data['training_goals']! as String,
        startedPlayingAtStorageValue: data['started_playing_at'] as int?,
        hasCompetedStorageValue: data['has_competed']! as int,
        hoursPerWeekRaw: data['hours_per_week'] as int?,
        createdAtStorageValue: data['created_at']! as int,
        updatedAtStorageValue: data['updated_at']! as int,
      );
    } catch (error) {
      throw PlayerProfileSourceException(
        PlayerProfileSourceFailureKind.sourceRead,
        cause: error,
      );
    }
  }

  Future<int> createPlayer(Player player) async {
    return _runLifecycleTransaction(() async {
      final current = await _readAndValidateActivePlayer();
      final id = await _db.into(_db.players).insert(
            db.PlayersCompanion.insert(
              name: player.name,
              dominantHand: Value(player.dominantHand),
              language: Value(player.language),
              measurementSystem: Value(player.measurementSystem),
              theme: Value(player.theme),
              isActive: Value(current == null),
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
      await _readAndValidateActivePlayer();
      return id;
    });
  }

  Future<bool> updatePlayer(Player player) async {
    if (player.id == null) {
      throw const PlayerLifecycleException(
        PlayerLifecycleFailureCode.targetNotFound,
      );
    }
    return _runLifecycleTransaction(() async {
      await _readAndValidateActivePlayer();
      final updatedRows = await (_db.update(_db.players)
            ..where((tbl) => tbl.id.equals(player.id!)))
          .write(
        db.PlayersCompanion(
          name: Value(player.name),
          dominantHand: Value(player.dominantHand),
          language: Value(player.language),
          measurementSystem: Value(player.measurementSystem),
          theme: Value(player.theme),
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
      if (updatedRows == 0) {
        throw const PlayerLifecycleException(
          PlayerLifecycleFailureCode.targetNotFound,
        );
      }
      await _readAndValidateActivePlayer();
      return true;
    });
  }

  Future<int> deletePlayer(int id) async {
    return _runLifecycleTransaction(() async {
      final target = await (_db.select(_db.players)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();
      if (target == null) {
        throw const PlayerLifecycleException(
          PlayerLifecycleFailureCode.targetNotFound,
        );
      }
      await _readAndValidateActivePlayer();
      final deleted = await (_db.delete(_db.players)
            ..where((table) => table.id.equals(id)))
          .go();
      if (target.isActive) {
        final successor = await (_db.select(_db.players)
              ..orderBy([(table) => OrderingTerm.asc(table.id)])
              ..limit(1))
            .getSingleOrNull();
        if (successor != null) {
          await (_db.update(_db.players)
                ..where((table) => table.id.equals(successor.id)))
              .write(const db.PlayersCompanion(isActive: Value(true)));
        }
      }
      await _readAndValidateActivePlayer();
      return deleted;
    });
  }

  Future<Player?> getActivePlayer() async {
    try {
      return await _db.transaction(_readAndValidateActivePlayer);
    } on PlayerLifecycleException {
      rethrow;
    } catch (error) {
      throw PlayerLifecycleException(
        PlayerLifecycleFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  Future<void> setActivePlayer(int id) async {
    await switchActivePlayer(id);
  }

  Future<void> switchActivePlayer(int id) async {
    await _runLifecycleTransaction(() async {
      final target = await (_db.select(_db.players)
            ..where((table) => table.id.equals(id)))
          .getSingleOrNull();
      if (target == null) {
        throw const PlayerLifecycleException(
          PlayerLifecycleFailureCode.targetNotFound,
        );
      }
      final active = await _readAndValidateActivePlayer();
      if (active!.id == id) return;
      await (_db.update(_db.players)
            ..where((table) => table.id.equals(active.id!)))
          .write(const db.PlayersCompanion(isActive: Value(false)));
      await (_db.update(_db.players)..where((table) => table.id.equals(id)))
          .write(const db.PlayersCompanion(isActive: Value(true)));
      await _readAndValidateActivePlayer();
    });
  }

  Future<Player?> _readAndValidateActivePlayer() async {
    final rows = await (_db.select(_db.players)
          ..orderBy([(table) => OrderingTerm.asc(table.id)]))
        .get();
    return _validateActivePlayerRows(rows);
  }

  Player? _validateActivePlayerRows(List<db.Player> rows) {
    if (rows.isEmpty) return null;
    final active = rows.where((row) => row.isActive).toList(growable: false);
    if (active.length != 1) {
      throw const PlayerLifecycleException(
        PlayerLifecycleFailureCode.invariantViolated,
      );
    }
    return _mapToPlayer(active.single);
  }

  Future<T> _runLifecycleTransaction<T>(Future<T> Function() action) async {
    try {
      return await _db.transaction(action);
    } on PlayerLifecycleException {
      rethrow;
    } catch (error) {
      throw PlayerLifecycleException(
        PlayerLifecycleFailureCode.databaseFailure,
        cause: error,
      );
    }
  }

  Future<PlayerProgressProjection?> getProgressProjection(int playerId) async {
    final row = await (_db.select(_db.playerModelProjections)
          ..where((table) => table.playerId.equals(playerId)))
        .getSingleOrNull();
    if (row == null) return null;
    if (row.schemaVersion != playerProgressProjectionVersion) {
      throw StateError('player-progress-version-mismatch');
    }
    final projection = PlayerProgressProjection.create(
      playerId: row.playerId,
      skills: [
        PlayerSkillScore(
          dimension: PlayerSkillDimension.breakSkill,
          value: row.breakSkill,
        ),
        PlayerSkillScore(
          dimension: PlayerSkillDimension.potting,
          value: row.potting,
        ),
        PlayerSkillScore(
          dimension: PlayerSkillDimension.position,
          value: row.position,
        ),
        PlayerSkillScore(
          dimension: PlayerSkillDimension.safety,
          value: row.safety,
        ),
        PlayerSkillScore(
          dimension: PlayerSkillDimension.cueBallControl,
          value: row.cueBallControl,
        ),
        PlayerSkillScore(
          dimension: PlayerSkillDimension.kickJump,
          value: row.kickJump,
        ),
        PlayerSkillScore(
          dimension: PlayerSkillDimension.mental,
          value: row.mental,
        ),
        PlayerSkillScore(
          dimension: PlayerSkillDimension.consistency,
          value: row.consistency,
        ),
      ],
      overall: row.overall,
      confidence: row.confidence,
      trend: row.trend,
      mastery: row.mastery,
      strengths: _decodeDimensions(row.strengths),
      weaknesses: _decodeDimensions(row.weaknesses),
      trendPoints: _decodeDoubles(row.trendPoints),
      sourceMatchCount: row.sourceMatchCount,
      sourceTrainingCount: row.sourceTrainingCount,
      lastUpdated: row.lastUpdated,
      sourceDigest: row.sourceDigest,
    );
    if (projection.digest != row.digest) {
      throw StateError('player-progress-digest-mismatch');
    }
    return projection;
  }

  Future<void> saveProgressProjection(
    PlayerProgressProjection projection,
  ) async {
    await _db.into(_db.playerModelProjections).insertOnConflictUpdate(
          db.PlayerModelProjectionsCompanion.insert(
            playerId: Value(projection.playerId),
            schemaVersion: playerProgressProjectionVersion,
            overall: projection.overall,
            breakSkill: projection.score(PlayerSkillDimension.breakSkill),
            potting: projection.score(PlayerSkillDimension.potting),
            position: projection.score(PlayerSkillDimension.position),
            safety: projection.score(PlayerSkillDimension.safety),
            cueBallControl:
                projection.score(PlayerSkillDimension.cueBallControl),
            kickJump: projection.score(PlayerSkillDimension.kickJump),
            mental: projection.score(PlayerSkillDimension.mental),
            consistency: projection.score(PlayerSkillDimension.consistency),
            confidence: projection.confidence,
            trend: projection.trend,
            mastery: projection.mastery,
            strengths: jsonEncode(
              projection.strengths.map((item) => item.name).toList(),
            ),
            weaknesses: jsonEncode(
              projection.weaknesses.map((item) => item.name).toList(),
            ),
            trendPoints: jsonEncode(projection.trendPoints),
            sourceMatchCount: projection.sourceMatchCount,
            sourceTrainingCount: projection.sourceTrainingCount,
            lastUpdated: projection.lastUpdated,
            sourceDigest: projection.sourceDigest,
            digest: projection.digest,
          ),
        );
  }

  Future<CareerTimelineProjection?> getCareerTimelineProjection(
    int playerId,
  ) async {
    final row = await (_db.select(_db.careerTimelineProjections)
          ..where((table) => table.playerId.equals(playerId)))
        .getSingleOrNull();
    if (row == null) return null;
    if (row.projectionVersion != careerTimelineProjectionVersion) {
      throw StateError('career-timeline-version-mismatch');
    }
    final rawEvents = jsonDecode(row.eventsJson) as List<dynamic>;
    final projection = CareerTimelineProjection.create(
      playerId: row.playerId,
      sourceDigest: row.sourceDigest,
      events: rawEvents
          .map(
            (event) => CareerTimelineEvent.fromJson(
              Map<String, Object?>.from(event as Map),
            ),
          )
          .toList(),
    );
    if (projection.digest != row.projectionDigest) {
      throw StateError('career-timeline-digest-mismatch');
    }
    return projection;
  }

  Future<void> saveCareerTimelineProjection(
    CareerTimelineProjection projection,
  ) async {
    await _db.into(_db.careerTimelineProjections).insertOnConflictUpdate(
          db.CareerTimelineProjectionsCompanion.insert(
            playerId: Value(projection.playerId),
            projectionVersion: careerTimelineProjectionVersion,
            sourceDigest: projection.sourceDigest,
            projectionDigest: projection.digest,
            eventsJson: jsonEncode(
              projection.events.map((event) => event.toJson()).toList(),
            ),
          ),
        );
  }

  Future<int> deleteCareerTimelineProjection(int playerId) {
    return (_db.delete(_db.careerTimelineProjections)
          ..where((table) => table.playerId.equals(playerId)))
        .go();
  }
}

List<PlayerSkillDimension> _decodeDimensions(String raw) {
  final values = jsonDecode(raw) as List<dynamic>;
  return values
      .map((value) => PlayerSkillDimension.values.byName(value as String))
      .toList();
}

List<double> _decodeDoubles(String raw) {
  final values = jsonDecode(raw) as List<dynamic>;
  return values.map((value) => (value as num).toDouble()).toList();
}
