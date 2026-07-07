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
  final bool isLoading;
  final String? error;

  const EquipmentState({
    this.cues = const [],
    this.activeCue,
    this.activeBreakCue,
    this.isLoading = false,
    this.error,
  });

  EquipmentState copyWith({
    List<Cue>? cues,
    Cue? activeCue,
    Cue? activeBreakCue,
    bool? isLoading,
    String? error,
    bool clearActiveCue = false,
    bool clearActiveBreakCue = false,
  }) {
    return EquipmentState(
      cues: cues ?? this.cues,
      activeCue: clearActiveCue ? null : (activeCue ?? this.activeCue),
      activeBreakCue: clearActiveBreakCue ? null : (activeBreakCue ?? this.activeBreakCue),
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
      final activeCue = await _repository.getActiveCue(isBreakCue: false);
      final activeBreakCue = await _repository.getActiveCue(isBreakCue: true);
      state = state.copyWith(
        cues: cues,
        activeCue: activeCue,
        activeBreakCue: activeBreakCue,
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
      await _repository.setActiveCue(id, isBreakCue: false);
      await loadEquipment();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setActiveBreakCue(int cueId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.setActiveCue(cueId, isBreakCue: true);
      await loadEquipment();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
