import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' as db;
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/player/data/providers/database_providers.dart';

final equipmentRepositoryProvider = Provider<EquipmentRepository>((ref) {
  return EquipmentRepository(ref.watch(databaseProvider));
});

class EquipmentRepository {
  final db.AppDatabase _db;

  EquipmentRepository(this._db);

  Future<List<Cue>> getAllCues() async {
    final results = await _db.select(_db.cues).get();
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
  Future<Cue?> getActiveCueByType(String cueType) async {
    final active = await (_db.select(_db.cues)..where((c) => c.isActive.equals(true))).get();
    final cues = active.map(_mapToCue).toList();
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
        name: cue.name,
        shaft: cue.shaft,
        tip: cue.tip,
        shaftMaterial: cue.shaftMaterial,
        shaftDiameter: cue.shaftDiameter,
        tipBrand: cue.tipBrand,
        tipHardness: cue.tipHardness,
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
    final updatedRows = await (_db.update(_db.cues)
          ..where((c) => c.id.equals(cue.id!)))
        .write(
      db.CuesCompanion(
        name: Value(cue.name),
        shaft: Value(cue.shaft),
        tip: Value(cue.tip),
        shaftMaterial: Value(cue.shaftMaterial),
        shaftDiameter: Value(cue.shaftDiameter),
        tipBrand: Value(cue.tipBrand),
        tipHardness: Value(cue.tipHardness),
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
  Future<void> setActiveCueByType(int id, {required String cueType}) async {
    await _db.transaction(() async {
      Future<void> deactivate(String type) async {
        await (_db.update(_db.cues)..where((c) => c.cueType.equals(type)))
            .write(const db.CuesCompanion(isActive: Value(false)));
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
      ));
    });
  }

  Cue _mapToCue(db.Cue data) {
    if (data.shaftMaterial.isNotEmpty && data.tipBrand.isNotEmpty) {
      return Cue(
        id: data.id,
        name: data.name,
        shaftMaterial: data.shaftMaterial,
        shaftDiameter: data.shaftDiameter,
        tipBrand: data.tipBrand,
        tipHardness: data.tipHardness,
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
