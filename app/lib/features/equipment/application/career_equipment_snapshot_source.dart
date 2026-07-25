import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/match_equipment_snapshot_repository.dart';

enum CareerEquipmentSnapshotRole { playing, breakCue, jump }

final class CareerEquipmentSnapshotUsageFact {
  const CareerEquipmentSnapshotUsageFact({
    required this.matchId,
    required this.snapshotReference,
    required this.role,
    required this.cueId,
  });

  final int matchId;
  final String snapshotReference;
  final CareerEquipmentSnapshotRole role;
  final int cueId;
}

final careerEquipmentSnapshotSourceProvider =
    Provider<CareerEquipmentSnapshotSource>((ref) {
  return CareerEquipmentSnapshotSource(
    ref.watch(matchEquipmentSnapshotRepositoryProvider),
  );
});

/// Public, read-only projection hook for immutable per-Match cue snapshots.
final class CareerEquipmentSnapshotSource {
  const CareerEquipmentSnapshotSource(this._snapshots);

  final MatchEquipmentSnapshotRepository _snapshots;

  Future<List<CareerEquipmentSnapshotUsageFact>> loadForMatchIds(
    Iterable<int> matchIds,
  ) async {
    final orderedIds = matchIds.toSet().toList()..sort();
    final result = <CareerEquipmentSnapshotUsageFact>[];
    for (final matchId in orderedIds) {
      final snapshot = await _snapshots.getByMatchId(matchId);
      if (snapshot == null) continue;
      final reference = 'equipment-snapshot:match:$matchId';
      void add(CareerEquipmentSnapshotRole role, int? cueId) {
        if (cueId == null) return;
        result.add(
          CareerEquipmentSnapshotUsageFact(
            matchId: matchId,
            snapshotReference: reference,
            role: role,
            cueId: cueId,
          ),
        );
      }

      add(CareerEquipmentSnapshotRole.playing, snapshot.playingCueId);
      add(CareerEquipmentSnapshotRole.breakCue, snapshot.breakCueId);
      add(CareerEquipmentSnapshotRole.jump, snapshot.jumpCueId);
    }
    return result;
  }
}
