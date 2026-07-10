import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/session/data/recording_coordinator.dart';

class RackUndoStack {
  final List<Rack> removedRacks;
  final Map<int, int> previousRackNumbers;

  const RackUndoStack({
    this.removedRacks = const [],
    this.previousRackNumbers = const {},
  });

  bool get canUndo => removedRacks.isNotEmpty;

  RackUndoStack addUndo(Rack rack) {
    return RackUndoStack(
      removedRacks: [...removedRacks, rack],
      previousRackNumbers: {...previousRackNumbers},
    );
  }

  RackUndoStack clear() {
    return RackUndoStack();
  }
}

final rackNotifierProvider =
    StateNotifierProvider<RackNotifier, RackState>((ref) {
  final repository = ref.watch(rackRepositoryProvider);
  final coordinator = ref.watch(recordingCoordinatorProvider);
  return RackNotifier(repository, coordinator);
});

class RackState {
  final List<Rack> racks;
  final Rack? currentRack;
  final int rackCount;
  final int winCount;
  final bool isLoading;
  final String? error;
  final RackUndoStack undoStack;

  const RackState({
    this.racks = const [],
    this.currentRack,
    this.rackCount = 0,
    this.winCount = 0,
    this.isLoading = false,
    this.error,
    this.undoStack = const RackUndoStack(),
  });

  RackState copyWith({
    List<Rack>? racks,
    Rack? currentRack,
    int? rackCount,
    int? winCount,
    bool? isLoading,
    String? error,
    RackUndoStack? undoStack,
    bool clearCurrentRack = false,
  }) {
    return RackState(
      racks: racks ?? this.racks,
      currentRack: clearCurrentRack ? null : (currentRack ?? this.currentRack),
      rackCount: rackCount ?? this.rackCount,
      winCount: winCount ?? this.winCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      undoStack: undoStack ?? this.undoStack,
    );
  }

  double get winRate => rackCount == 0 ? 0.0 : winCount / rackCount;

  bool get canUndo => undoStack.canUndo;
}

class RackNotifier extends StateNotifier<RackState> {
  final RackRepository _repository;
  final RecordingCoordinator _coordinator;

  RackNotifier(this._repository, this._coordinator) : super(const RackState());

  Future<void> loadRacks(int matchId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final racks = await _repository.getRacksByMatchId(matchId);
      final rackCount = await _repository.getRackCountByMatchId(matchId);
      final winCount = await _repository.getWinCountByMatchId(matchId);
      state = state.copyWith(
        racks: racks,
        rackCount: rackCount,
        winCount: winCount,
        isLoading: false,
        undoStack: RackUndoStack(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addRack(int matchId, bool result) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // RFC-301: create the Rack through the coordinator so the parent Match is
      // validated (no orphan racks). The result flag is applied after creation.
      final rackId = await _coordinator.ensureCurrentRackForResult(
        matchId: matchId,
        result: result,
      );
      // Keep the just-created rack id available for shot recording.
      _currentRackId = rackId;
      await loadRacks(matchId);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Real DB id of the most recently created/active rack, for downstream shot
  /// recording (RFC-301: propagate real ids across layers).
  int? _currentRackId;
  int? get currentRackId => _currentRackId;

  Future<void> undoLastRack(int matchId) async {
    if (!state.canUndo || state.racks.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final lastRack = state.racks.last;
      await _repository.deleteRack(lastRack.id!);
      
      final newRacks = state.racks.sublist(0, state.racks.length - 1);
      final newWinCount = lastRack.result ? state.winCount - 1 : state.winCount;
      
      state = state.copyWith(
        racks: newRacks,
        rackCount: state.rackCount - 1,
        winCount: newWinCount,
        isLoading: false,
        undoStack: RackUndoStack(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteRack(int rackId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteRack(rackId);
      if (state.racks.isNotEmpty) {
        final matchId = state.racks.first.matchId;
        await loadRacks(matchId);
      } else {
        state = state.copyWith(
          isLoading: false,
          undoStack: RackUndoStack(),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearRacks() {
    state = const RackState();
  }
}
