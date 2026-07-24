import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/domain/equipment_performance_projection.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository(ref.watch(databaseProvider));
});

class EquipmentRepository {
  final db.AppDatabase _db;

  EquipmentRepository(this._db);

  Future<List<Cue>> getAllCues({int? playerId}) async {
    final query = _db.select(_db.cues);
    if (playerId != null) {
      query.where(
        (cue) => cue.playerId.equals(playerId) | cue.playerId.isNull(),
      );
    }
    final results = await query.get();
    return results.map(_mapToCue).toList();
  }

  Future<Cue?> getCueById(int id) async {
    final result = await (_db.select(_db.cues)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToCue(result);
  }

  Future<Cue?> getActiveCue({required bool isBreakCue}) async {
    // RFC-302 Task F: legacy binary lookup (playing vs break). Kept for callers
    // that still think in two roles. Prefer getActiveCueByType.
    final result = await (_db.select(_db.cues)
          ..where((c) => c.isActive.equals(true))
          ..where((c) => c.isBreakCue.equals(isBreakCue))
          ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)])
          ..limit(1))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToCue(result);
  }

  /// RFC-302 Task F: the active cue actually used for [cueType].
  /// A 'break_jump' cue counts as BOTH the break and jump cue: when the user
  /// asks for the active break (or jump) cue and no dedicated one is active, a
  /// 'break_jump' cue takes over that role. `playing` always resolves to a
  /// dedicated playing cue only.
  Future<Cue?> getActiveCueByType(String cueType, {int? playerId}) async {
    final cues = (await getAllCues(playerId: playerId))
        .where((cue) => cue.isActive)
        .toList();
    Cue? pick(String type) {
      for (final c in cues) {
        if (c.cueType == type) return c;
      }
      return null;
    }

    final direct = pick(cueType);
    if (direct != null) return direct;
    // break / jump fall back to a combined break_jump cue.
    if (cueType == 'break' || cueType == 'jump') {
      return pick('break_jump');
    }
    return null;
  }

  Future<int> createCue(Cue cue) async {
    return _db.into(_db.cues).insert(
          db.CuesCompanion.insert(
            playerId: Value(cue.playerId),
            name: cue.name,
            shaft: cue.shaft,
            tip: cue.tip,
            shaftMaterial: cue.shaftMaterial,
            shaftDiameter: cue.shaftDiameter,
            tipBrand: cue.tipBrand,
            tipHardness: cue.tipHardness,
            cueType: Value(cue.cueType),
            weight: cue.weight,
            balance: cue.balance,
            joint: cue.joint,
            isActive: Value(cue.isActive),
            isBreakCue: Value(cue.isBreakCue),
            createdAt: Value(cue.createdAt),
            updatedAt: Value(cue.updatedAt),
          ),
        );
  }

  Future<bool> updateCue(Cue cue) async {
    final updatedRows =
        await (_db.update(_db.cues)..where((c) => c.id.equals(cue.id!))).write(
      db.CuesCompanion(
        name: Value(cue.name),
        shaft: Value(cue.shaft),
        tip: Value(cue.tip),
        shaftMaterial: Value(cue.shaftMaterial),
        shaftDiameter: Value(cue.shaftDiameter),
        tipBrand: Value(cue.tipBrand),
        tipHardness: Value(cue.tipHardness),
        cueType: Value(cue.cueType),
        weight: Value(cue.weight),
        balance: Value(cue.balance),
        joint: Value(cue.joint),
        isActive: Value(cue.isActive),
        isBreakCue: Value(cue.isBreakCue),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return updatedRows > 0;
  }

  Future<int> deleteCue(int id) async {
    return (_db.delete(_db.cues)..where((c) => c.id.equals(id))).go();
  }

  Future<void> setActiveCue(int id, {required bool isBreakCue}) async {
    // Legacy binary path kept for older callers. Delegates to the cueType-aware
    // implementation using the cue's real type.
    final cue = await getCueById(id);
    if (cue == null) return;
    await setActiveCueByType(id, cueType: cue.cueType);
  }

  /// RFC-302 Task F: activate [id] for its role. Exactly one cue is active per
  /// cueType, so only cues of the SAME type are deactivated — activating a
  /// break cue never disturbs the playing or jump cue. A 'break_jump' cue owns
  /// both the break and jump roles, so activating one clears any dedicated
  /// break/jump cue (and vice-versa) to keep a single source of truth per role.
  Future<void> setActiveCueByType(
    int id, {
    required String cueType,
    int? playerId,
  }) async {
    await _db.transaction(() async {
      Future<void> deactivate(String type) async {
        final update = _db.update(_db.cues)
          ..where((c) => c.cueType.equals(type));
        if (playerId != null) {
          update.where(
            (c) => c.playerId.equals(playerId) | c.playerId.isNull(),
          );
        }
        await update.write(const db.CuesCompanion(isActive: Value(false)));
      }

      await deactivate(cueType);
      // Keep the break/jump roles mutually consistent with a combined cue.
      if (cueType == 'break_jump') {
        await deactivate('break');
        await deactivate('jump');
      } else if (cueType == 'break' || cueType == 'jump') {
        await deactivate('break_jump');
      }
      // Assign the cue to the requested role AND activate it. Without also
      // writing cueType, activating a 'playing' cue for the break/jump role was
      // a silent no-op (role lookup keys on cueType) while the UI reported
      // success — the cue just became the active playing cue instead.
      await (_db.update(_db.cues)..where((c) => c.id.equals(id)))
          .write(db.CuesCompanion(
        cueType: Value(cueType),
        isActive: const Value(true),
        playerId: playerId == null ? const Value.absent() : Value(playerId),
      ));
    });
  }

  Future<List<EquipmentPerformanceProjection>> getPerformanceProjections(
    int playerId,
  ) async {
    final rows = await (_db.select(_db.equipmentPerformanceProjections)
          ..where((table) => table.playerId.equals(playerId))
          ..orderBy([(table) => OrderingTerm.asc(table.equipmentId)]))
        .get();
    return rows.map((row) {
      if (row.schemaVersion != equipmentPerformanceProjectionVersion) {
        throw StateError('equipment-performance-version-mismatch');
      }
      final projection = EquipmentPerformanceProjection.create(
        playerId: row.playerId,
        equipmentId: row.equipmentId,
        totalMatches: row.totalMatches,
        matchWinRate: row.matchWinRate,
        totalTrainingSessions: row.totalTrainingSessions,
        trainingSuccessRate: row.trainingSuccessRate,
        recordedDurationSeconds: row.recordedDurationSeconds,
        lastUsed: row.lastUsed,
        sourceDigest: row.sourceDigest,
      );
      if (projection.digest != row.digest) {
        throw StateError('equipment-performance-digest-mismatch');
      }
      return projection;
    }).toList(growable: false);
  }

  Future<void> replacePerformanceProjections(
    int playerId,
    List<EquipmentPerformanceProjection> projections,
  ) async {
    if (projections.any((projection) => projection.playerId != playerId)) {
      throw ArgumentError('Equipment projection player binding is invalid.');
    }
    await _db.transaction(() async {
      await (_db.delete(_db.equipmentPerformanceProjections)
            ..where((table) => table.playerId.equals(playerId)))
          .go();
      for (final projection in projections) {
        await _db.into(_db.equipmentPerformanceProjections).insert(
              db.EquipmentPerformanceProjectionsCompanion.insert(
                equipmentId: Value(projection.equipmentId),
                playerId: projection.playerId,
                schemaVersion: equipmentPerformanceProjectionVersion,
                totalMatches: projection.totalMatches,
                matchWinRate: projection.matchWinRate,
                totalTrainingSessions: projection.totalTrainingSessions,
                trainingSuccessRate: projection.trainingSuccessRate,
                recordedDurationSeconds: projection.recordedDurationSeconds,
                lastUsed: Value(projection.lastUsed),
                sourceDigest: projection.sourceDigest,
                digest: projection.digest,
              ),
            );
      }
    });
  }

  Cue _mapToCue(db.Cue data) {
    if (data.shaftMaterial.isNotEmpty && data.tipBrand.isNotEmpty) {
      return Cue(
        id: data.id,
        playerId: data.playerId,
        name: data.name,
        shaftMaterial: data.shaftMaterial,
        shaftDiameter: data.shaftDiameter,
        tipBrand: data.tipBrand,
        tipHardness: data.tipHardness,
        // Task 04: carry cueType through — without it every cue read back
        // defaulted to 'playing', so getActiveCueByType('break'/'jump') (and the
        // break_jump dual-role fallback) could never resolve.
        cueType: data.cueType,
        weight: data.weight,
        balance: data.balance,
        joint: data.joint,
        isActive: data.isActive,
        isBreakCue: data.isBreakCue,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      );
    }
    return Cue.fromLegacy(
      id: data.id,
      playerId: data.playerId,
      name: data.name,
      shaft: data.shaft,
      tip: data.tip,
      weight: data.weight,
      balance: data.balance,
      joint: data.joint,
      isActive: data.isActive,
      isBreakCue: data.isBreakCue,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }
}
