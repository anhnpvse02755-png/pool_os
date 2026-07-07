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
    final result = await (_db.select(_db.cues)
          ..where((c) => c.isActive.equals(true))
          ..where((c) => c.isBreakCue.equals(isBreakCue)))
        .getSingleOrNull();
    if (result == null) return null;
    return _mapToCue(result);
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
    await (_db.update(_db.cues)
          ..where((c) => c.isBreakCue.equals(isBreakCue)))
        .write(const db.CuesCompanion(isActive: Value(false)));
    await (_db.update(_db.cues)..where((c) => c.id.equals(id)))
        .write(const db.CuesCompanion(isActive: Value(true)));
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
