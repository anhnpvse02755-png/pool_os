import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ghost_challenge_service.dart';
import '../domain/models/ghost_ai.dart';
import '../domain/models/ghost_challenge.dart';

final ghostChallengeServiceProvider = Provider<GhostChallengeService>((ref) {
  return GhostChallengeService();
});

final ghostChallengeNotifierProvider =
    StateNotifierProvider<GhostChallengeNotifier, GhostChallengeState>((ref) {
  final service = ref.watch(ghostChallengeServiceProvider);
  return GhostChallengeNotifier(service);
});

class GhostChallengeState {
  final GhostChallenge? challenge;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic> statistics;

  const GhostChallengeState({
    this.challenge,
    this.isLoading = false,
    this.error,
    this.statistics = const {},
  });

  GhostChallengeState copyWith({
    GhostChallenge? challenge,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? statistics,
    bool clearChallenge = false,
  }) {
    return GhostChallengeState(
      challenge: clearChallenge ? null : (challenge ?? this.challenge),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statistics: statistics ?? this.statistics,
    );
  }

  bool get hasActiveChallenge => challenge != null && !challenge!.isComplete;

  GhostPerformance? get ghostPerformance =>
      challenge != null ? GhostPerformance(
        skillLevel: 0.6,
        estimatedWinRate: 0.5,
        strongAreas: ['consistency'],
        weakAreas: ['pressure_shots'],
      ) : null;
}

class GhostChallengeNotifier extends StateNotifier<GhostChallengeState> {
  final GhostChallengeService _service;

  GhostChallengeNotifier(this._service) : super(const GhostChallengeState());

  void startChallenge({
    required int matchId,
    int targetScore = 5,
    double? ghostSkillLevel,
  }) {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final challenge = _service.startChallenge(
        matchId: matchId,
        targetScore: targetScore,
        ghostSkillLevel: ghostSkillLevel,
      );
      state = state.copyWith(
        challenge: challenge,
        isLoading: false,
        statistics: _service.getChallengeStatistics(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void recordPlayerWin({
    String? shotType,
    String? difficulty,
    bool? madeShot,
  }) {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = _service.recordPlayerWin(
        shotType: shotType,
        difficulty: difficulty,
        madeShot: madeShot,
      );
      state = state.copyWith(
        challenge: result.challenge,
        isLoading: false,
        statistics: _service.getChallengeStatistics(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void recordPlayerLoss({
    String? shotType,
    String? difficulty,
    bool? madeShot,
  }) {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = _service.recordPlayerLoss(
        shotType: shotType,
        difficulty: difficulty,
        madeShot: madeShot,
      );
      state = state.copyWith(
        challenge: result.challenge,
        isLoading: false,
        statistics: _service.getChallengeStatistics(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setGhostSkillLevel(double level) {
    _service.setGhostSkillLevel(level);
  }

  void refreshStatistics() {
    state = state.copyWith(statistics: _service.getChallengeStatistics());
  }

  void resetChallenge() {
    _service.resetChallenge();
    state = const GhostChallengeState();
  }

  List<GhostShot> getShotHistory() {
    return _service.getShotHistory();
  }
}
