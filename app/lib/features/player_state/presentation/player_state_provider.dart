import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/player_state/data/repositories/player_state_repository.dart';
import 'package:pool_os/features/player_state/domain/models/player_state_log.dart';
import 'package:pool_os/features/player_state/domain/player_state_analyzer.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';

/// Computed Player State insights for the most recent match with enough racks.
/// Reads existing rack history and runs [PlayerStateAnalyzer] on demand — no
/// stored/fabricated metrics (doc §9). Returns null when there is no match to
/// analyze yet, so the UI simply shows nothing.
final playerStateInsightProvider =
    FutureProvider<PlayerStateInsight?>((ref) async {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final rackRepo = ref.watch(rackRepositoryProvider);
  const analyzer = PlayerStateAnalyzer();

  // Walk recent matches newest-first; use the first one that actually has racks.
  final recent = await matchRepo.getRecentMatches(limit: 10);
  for (final match in recent) {
    if (match.id == null) continue;
    final racks = await rackRepo.getRacksByMatchId(match.id!);
    if (racks.isEmpty) continue;
    return PlayerStateInsight(
      warmUp: analyzer.warmUpIndex(racks),
      endurance: analyzer.enduranceProfile(racks),
    );
  }
  return null;
});

class PlayerStateInsight {
  final WarmUpInsight warmUp;
  final EnduranceInsight endurance;
  const PlayerStateInsight({required this.warmUp, required this.endurance});
}

final playerStateProvider =
    StateNotifierProvider<PlayerStateNotifier, PlayerStateData>((ref) {
  return PlayerStateNotifier(ref.watch(playerStateRepositoryProvider));
});

class PlayerStateData {
  final List<PlayerStateLog> sessionLogs;
  final bool isSaving;
  final String? error;

  const PlayerStateData({
    this.sessionLogs = const [],
    this.isSaving = false,
    this.error,
  });

  PlayerStateData copyWith({
    List<PlayerStateLog>? sessionLogs,
    bool? isSaving,
    String? error,
  }) {
    return PlayerStateData(
      sessionLogs: sessionLogs ?? this.sessionLogs,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

/// Thin controller over [PlayerStateRepository]. Persist-first (RFC-301
/// principle carried into Player State): the log is written to the DB before
/// any UI acknowledgement, so a "saved" indicator never lies. Logs are append
/// only (doc §9) — there is no update path.
class PlayerStateNotifier extends StateNotifier<PlayerStateData> {
  final PlayerStateRepository _repository;

  PlayerStateNotifier(this._repository) : super(const PlayerStateData());

  /// Persists one log and returns its real id (or null on failure). Callers
  /// that need to gate UI on a successful save should check the return value.
  Future<int?> addLog(PlayerStateLog log) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final id = await _repository.addLog(log);
      await loadForSession(log.sessionId);
      state = state.copyWith(isSaving: false);
      return id;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }

  Future<void> loadForSession(int sessionId) async {
    try {
      final logs = await _repository.getLogsBySession(sessionId);
      state = state.copyWith(sessionLogs: logs, error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
