import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/equipment/domain/models/cue.dart';
import 'package:pool_os/features/equipment/data/repositories/equipment_repository.dart';

final equipmentNotifierProvider =
    StateNotifierProvider<EquipmentNotifier, EquipmentState>((ref) {
  final repository = ref.watch(equipmentRepositoryProvider);
  return EquipmentNotifier(repository);
});

class EquipmentState {
  final List<Cue> cues;
  final Cue? activeCue;
  final Cue? activeBreakCue;
  // RFC-302 Task F: the jump role is now tracked separately from break. A
  // 'break_jump' cue resolves as both activeBreakCue and activeJumpCue.
  final Cue? activeJumpCue;
  final bool isLoading;
  final String? error;

  const EquipmentState({
    this.cues = const [],
    this.activeCue,
    this.activeBreakCue,
    this.activeJumpCue,
    this.isLoading = false,
    this.error,
  });

  EquipmentState copyWith({
    List<Cue>? cues,
    Cue? activeCue,
    Cue? activeBreakCue,
    Cue? activeJumpCue,
    bool? isLoading,
    String? error,
    bool clearActiveCue = false,
    bool clearActiveBreakCue = false,
    bool clearActiveJumpCue = false,
  }) {
    return EquipmentState(
      cues: cues ?? this.cues,
      activeCue: clearActiveCue ? null : (activeCue ?? this.activeCue),
      activeBreakCue: clearActiveBreakCue ? null : (activeBreakCue ?? this.activeBreakCue),
      activeJumpCue: clearActiveJumpCue ? null : (activeJumpCue ?? this.activeJumpCue),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EquipmentNotifier extends StateNotifier<EquipmentState> {
  final EquipmentRepository _repository;

  EquipmentNotifier(this._repository) : super(const EquipmentState()) {
    loadEquipment();
  }

  Future<void> loadEquipment() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cues = await _repository.getAllCues();
      // RFC-302 Task F: resolve each role by cueType. break/jump fall back to a
      // break_jump cue so a combined cue shows as the active break AND jump.
      final activeCue = await _repository.getActiveCueByType('playing');
      final activeBreakCue = await _repository.getActiveCueByType('break');
      final activeJumpCue = await _repository.getActiveCueByType('jump');
      state = state.copyWith(
        cues: cues,
        activeCue: activeCue,
        activeBreakCue: activeBreakCue,
        activeJumpCue: activeJumpCue,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addCue(Cue cue) async {
    try {
      final newId = await _repository.createCue(cue);
      final newCue = cue.copyWith(id: newId);
      
      // FIX-007A: Directly add to list, then reload to ensure consistency
      state = state.copyWith(
        cues: [...state.cues, newCue],
      );
      
      // Reload to ensure all data is consistent
      await loadEquipment();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateCue(Cue cue) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateCue(cue);
      await loadEquipment();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteCue(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteCue(id);
      await loadEquipment();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setActiveCue(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // RFC-302 Task F: activate for the cue's own role (playing/break/jump/
      // break_jump) so exactly one cue is active per role.
      final cue = state.cues.firstWhere(
        (c) => c.id == id,
        orElse: () => throw StateError('Cue $id not found'),
      );
      await _repository.setActiveCueByType(id, cueType: cue.cueType);
      await loadEquipment();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// RFC-302 Task F: activate [cueId] explicitly for [cueType]. Kept as a
  /// convenience for callers that know the target role.
  Future<void> setActiveCueByType(int cueId, String cueType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.setActiveCueByType(cueId, cueType: cueType);
      await loadEquipment();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setActiveBreakCue(int cueId) async {
    // Retained for backward compatibility; break role now goes through cueType.
    await setActiveCueByType(cueId, 'break');
  }
}
