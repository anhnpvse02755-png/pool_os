import 'package:drift/native.dart' show NativeDatabase;
import 'package:drift/drift.dart' show QueryExecutor, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:pool_os/features/player/data/database/app_database.dart' show AppDatabase, CuesCompanion, MatchEquipmentSnapshot;
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';
import 'package:pool_os/features/equipment/data/repositories/match_equipment_snapshot_repository.dart';
import 'package:pool_os/features/equipment/domain/cue_role_resolver.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

/// TASK 04 — Equipment Intelligence.
///
/// Exercises the read-side pieces against an in-memory DB: the immutable match
/// snapshot, the shotType->role->cue resolver (with the Playing fallback), and
/// the break_jump dual-role behaviour. All data is real recorded rows.
void main() {
  late AppDatabase db;
  late EquipmentRepository equipmentRepo;
  late MatchEquipmentSnapshotRepository snapshotRepo;

  AppDatabase openDb(QueryExecutor executor) {
    final database = AppDatabase.forTesting(executor);
    equipmentRepo = EquipmentRepository(database);
    snapshotRepo = MatchEquipmentSnapshotRepository(database, equipmentRepo);
    return database;
  }

  setUp(() {
    db = openDb(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> addCue(String name, String type, {bool active = true}) {
    return db.into(db.cues).insert(
          CuesCompanion.insert(
            name: name,
            shaft: 'Carbon 12.5mm',
            tip: 'Kamui Medium',
            shaftMaterial: 'Carbon',
            shaftDiameter: 12.5,
            tipBrand: 'Kamui',
            tipHardness: 'Medium',
            weight: 19.0,
            balance: 'Center',
            joint: 'Radial',
            cueType: Value(type),
            isActive: Value(active),
          ),
        );
  }

  // Build a real generated snapshot row (not persisted) to drive the resolver.
  MatchEquipmentSnapshot snap({int? playing, int? breakCue, int? jump}) =>
      MatchEquipmentSnapshot(
        id: 1,
        matchId: 1,
        playingCueId: playing,
        breakCueId: breakCue,
        jumpCueId: jump,
        createdAt: DateTime(2026, 7, 12),
      );

  group('CueRoleResolver (pure)', () {
    test('maps shot types to the right role', () {
      expect(CueRoleResolver.roleForShotType(ShotTypes.breakShot), CueRole.breakRole);
      expect(CueRoleResolver.roleForShotType(ShotTypes.jumpShot), CueRole.jump);
      expect(CueRoleResolver.roleForShotType(ShotTypes.normalShot), CueRole.playing);
      expect(CueRoleResolver.roleForShotType(ShotTypes.safetyShot), CueRole.playing);
      expect(CueRoleResolver.roleForShotType(ShotTypes.bankShot), CueRole.playing);
    });

    test('resolves cue id per role from a snapshot', () {
      final s = snap(playing: 1, breakCue: 2, jump: 3);
      expect(CueRoleResolver.resolveCueId(s, ShotTypes.normalShot), 1);
      expect(CueRoleResolver.resolveCueId(s, ShotTypes.breakShot), 2);
      expect(CueRoleResolver.resolveCueId(s, ShotTypes.jumpShot), 3);
    });

    test('falls back to the playing cue when a role has no cue', () {
      // Jump shot but no jump cue configured -> uses the playing cue.
      final s = snap(playing: 1, breakCue: null, jump: null);
      expect(CueRoleResolver.resolveCueId(s, ShotTypes.jumpShot), 1);
      expect(CueRoleResolver.resolveCueId(s, ShotTypes.breakShot), 1);
    });

    test('null snapshot resolves to null', () {
      expect(CueRoleResolver.resolveCueId(null, ShotTypes.breakShot), isNull);
    });
  });

  test('break_jump cue fills BOTH break and jump roles', () async {
    final cpId = await addCue('CP01', 'break_jump');
    final breakCue = await equipmentRepo.getActiveCueByType('break');
    final jumpCue = await equipmentRepo.getActiveCueByType('jump');
    expect(breakCue?.id, cpId);
    expect(jumpCue?.id, cpId);
  });

  test('exactly one active cue per role after activation', () async {
    final revo = await addCue('Revo', 'playing');
    await addCue('Maple', 'playing', active: false);
    await equipmentRepo.setActiveCueByType(revo, cueType: 'playing');
    final actives = (await equipmentRepo.getAllCues())
        .where((c) => c.isActive && c.cueType == 'playing')
        .toList();
    expect(actives, hasLength(1));
    expect(actives.single.id, revo);
  });

  test('match snapshot captures active cues and is immutable across cue changes', () async {
    final revo = await addCue('Revo', 'playing');
    final bk = await addCue('BK Rush', 'break');

    // Capture a snapshot for match 100 with the current active cues.
    await snapshotRepo.captureForMatch(100);
    final snap = await snapshotRepo.getByMatchId(100);
    expect(snap, isNotNull);
    expect(snap!.playingCueId, revo);
    expect(snap.breakCueId, bk);

    // Change the default break cue AFTER the match.
    final cp = await addCue('CP01', 'break_jump');
    await equipmentRepo.setActiveCueByType(cp, cueType: 'break_jump');

    // Historical snapshot must NOT change.
    final again = await snapshotRepo.getByMatchId(100);
    expect(again!.breakCueId, bk, reason: 'historical snapshot must be immutable');

    // Idempotency: re-capturing does not overwrite the original.
    await snapshotRepo.captureForMatch(100);
    final third = await snapshotRepo.getByMatchId(100);
    expect(third!.breakCueId, bk);
  });
}

