import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/shot_record.dart';
import '../domain/models/shot.dart' as domain;
import 'package:pool_os/features/session/data/recording_coordinator.dart';
import 'package:pool_os/features/session/domain/recording_errors.dart';

final shotRecorderProvider = StateNotifierProvider<ShotRecorderNotifier, ShotRecorderState>((ref) {
  return ShotRecorderNotifier(ref.watch(recordingCoordinatorProvider));
});

class ShotRecorderState {
  final List<ShotRecord> shots;
  final ShotRecord? currentShot;
  final int? rackId;
  final int? sessionId;
  final int? matchId;
  final bool isRecording;
  final String? error;

  const ShotRecorderState({
    this.shots = const [],
    this.currentShot,
    this.rackId,
    this.sessionId,
    this.matchId,
    this.isRecording = false,
    this.error,
  });

  ShotRecorderState copyWith({
    List<ShotRecord>? shots,
    ShotRecord? currentShot,
    int? rackId,
    int? sessionId,
    int? matchId,
    bool? isRecording,
    String? error,
    bool clearCurrentShot = false,
  }) {
    return ShotRecorderState(
      shots: shots ?? this.shots,
      currentShot: clearCurrentShot ? null : (currentShot ?? this.currentShot),
      rackId: rackId ?? this.rackId,
      sessionId: sessionId ?? this.sessionId,
      matchId: matchId ?? this.matchId,
      isRecording: isRecording ?? this.isRecording,
      error: error,
    );
  }

  int get totalShots => shots.length;

  int get madeShots => shots.where((s) => s.isMade).length;

  int get missedShots => shots.where((s) => s.isMissed).length;

  int get fouls => shots.where((s) => s.isFoul).length;

  double get accuracy => totalShots == 0 ? 0.0 : madeShots / totalShots;

  List<ShotRecord> get breakShots => shots.where((s) => s.isBreakShot).toList();

  List<ShotRecord> get safetyShots => shots.where((s) => s.isSafety).toList();

  Map<ShotType, int> get shotTypeBreakdown {
    final breakdown = <ShotType, int>{};
    for (final shot in shots) {
      breakdown[shot.shotType] = (breakdown[shot.shotType] ?? 0) + 1;
    }
    return breakdown;
  }

  Map<ShotDifficulty, double> get difficultyAccuracy {
    final accuracyMap = <ShotDifficulty, List<bool>>{};
    for (final shot in shots) {
      accuracyMap.putIfAbsent(shot.difficulty, () => []).add(shot.isMade);
    }
    return accuracyMap.map(
      (key, values) => MapEntry(
        key,
        values.isEmpty ? 0.0 : values.where((v) => v).length / values.length,
      ),
    );
  }
}

class ShotRecorderNotifier extends StateNotifier<ShotRecorderState> {
  final RecordingCoordinator _coordinator;

  ShotRecorderNotifier(this._coordinator) : super(const ShotRecorderState());

  void startRecording({
    required int rackId,
    int? sessionId,
    int? matchId,
  }) {
    state = ShotRecorderState(
      rackId: rackId,
      sessionId: sessionId,
      matchId: matchId,
      isRecording: true,
    );
  }

  void setCurrentShot(ShotRecord shot) {
    state = state.copyWith(currentShot: shot);
  }

  void updateShotType(ShotType type) {
    if (state.currentShot == null) return;
    state = state.copyWith(
      currentShot: state.currentShot!.copyWith(shotType: type),
    );
  }

  void updateDifficulty(ShotDifficulty difficulty) {
    if (state.currentShot == null) return;
    state = state.copyWith(
      currentShot: state.currentShot!.copyWith(difficulty: difficulty),
    );
  }

  void updateResult(ShotResult result) {
    if (state.currentShot == null) return;
    state = state.copyWith(
      currentShot: state.currentShot!.copyWith(result: result),
    );
  }

  void updatePositionQuality(PositionQuality quality) {
    if (state.currentShot == null) return;
    state = state.copyWith(
      currentShot: state.currentShot!.copyWith(positionQuality: quality),
    );
  }

  void updateNotes(String notes) {
    if (state.currentShot == null) return;
    state = state.copyWith(
      currentShot: state.currentShot!.copyWith(notes: notes),
    );
  }

  void updateConfidence(String confidence) {
    if (state.currentShot == null) return;
    state = state.copyWith(
      currentShot: state.currentShot!.copyWith(confidence: confidence),
    );
  }

  Future<void> recordShot() async {
    if (state.currentShot == null) return;

    // RFC-301 Rule #1/#5: a Shot MUST have a real Rack, and it is persisted
    // FIRST — the real DB id is then stored in state so a subsequent Event can
    // reference it. No memory-only shots, no rackId=0 fallback.
    final rackId = state.rackId;
    if (rackId == null || rackId <= 0) {
      state = state.copyWith(error: 'Cannot record shot: no active Rack.');
      return;
    }

    final shotRecord = state.currentShot!.copyWith(
      shotNumber: state.shots.length + 1,
    );

    final shot = domain.Shot(
      rackId: rackId,
      shotNumber: shotRecord.shotNumber,
      shotType: shotRecord.shotType.name,
      difficulty: shotRecord.difficulty.name,
      result: shotRecord.result.name,
      positionQuality: shotRecord.positionQuality?.name,
      decision: shotRecord.decision,
      confidence: shotRecord.confidence,
      playerNote: shotRecord.notes,
      // Task 02: carry the shot's intent and (on a miss) its reason into the
      // persisted Shot so it is a complete data unit for Coach/Statistics.
      intent: shotRecord.intent,
      missReason: shotRecord.missReason,
      createdAt: shotRecord.createdAt,
    );

    try {
      final shotId = await _coordinator.recordShot(rackId: rackId, shot: shot);
      state = state.copyWith(
        shots: [...state.shots, shotRecord.copyWith(id: shotId, rackId: rackId)],
        clearCurrentShot: true,
        error: null,
      );
    } on RecordingIntegrityException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> quickAddShot({
    required ShotResult result,
    ShotType type = ShotType.straight,
    ShotDifficulty difficulty = ShotDifficulty.medium,
    bool isBreak = false,
  }) async {
    final rackId = state.rackId;
    if (rackId == null || rackId <= 0) {
      state = state.copyWith(error: 'Cannot record shot: no active Rack.');
      return;
    }

    final shotRecord = ShotRecord(
      rackId: rackId,
      sessionId: state.sessionId,
      matchId: state.matchId,
      shotNumber: state.shots.length + 1,
      shotType: type,
      difficulty: difficulty,
      result: result,
      isBreakShot: isBreak,
    );

    final shot = domain.Shot(
      rackId: rackId,
      shotNumber: shotRecord.shotNumber,
      shotType: shotRecord.shotType.name,
      difficulty: shotRecord.difficulty.name,
      result: shotRecord.result.name,
      createdAt: shotRecord.createdAt,
    );

    try {
      final shotId = await _coordinator.recordShot(rackId: rackId, shot: shot);
      state = state.copyWith(
        shots: [...state.shots, shotRecord.copyWith(id: shotId)],
        error: null,
      );
    } on RecordingIntegrityException catch (e) {
      state = state.copyWith(error: e.message);
    }
  }

  Future<void> quickAddMadeShot({
    ShotType type = ShotType.straight,
    ShotDifficulty difficulty = ShotDifficulty.medium,
    bool isBreak = false,
  }) async {
    await quickAddShot(
      result: ShotResult.made,
      type: type,
      difficulty: difficulty,
      isBreak: isBreak,
    );
  }

  Future<void> quickAddMissedShot({
    ShotType type = ShotType.straight,
    ShotDifficulty difficulty = ShotDifficulty.medium,
  }) async {
    await quickAddShot(
      result: ShotResult.missed,
      type: type,
      difficulty: difficulty,
    );
  }

  Future<void> quickAddFoul({
    ShotDifficulty difficulty = ShotDifficulty.medium,
  }) async {
    await quickAddShot(
      result: ShotResult.foul,
      type: ShotType.straight,
      difficulty: difficulty,
    );
  }

  void removeLastShot() {
    if (state.shots.isEmpty) return;
    state = state.copyWith(
      shots: state.shots.sublist(0, state.shots.length - 1),
    );
  }

  void removeShot(int index) {
    if (index < 0 || index >= state.shots.length) return;
    final updatedShots = [...state.shots];
    updatedShots.removeAt(index);
    state = state.copyWith(shots: updatedShots);
  }

  void clearShots() {
    state = state.copyWith(shots: [], clearCurrentShot: true);
  }

  void stopRecording() {
    state = state.copyWith(isRecording: false);
  }

  List<ShotRecord> getShotsForRack(int rackId) {
    return state.shots.where((s) => s.rackId == rackId).toList();
  }

  List<ShotRecord> getShotsForSession(int sessionId) {
    return state.shots.where((s) => s.sessionId == sessionId).toList();
  }
}
