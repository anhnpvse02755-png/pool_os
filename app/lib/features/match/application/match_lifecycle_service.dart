import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../session/data/recording_coordinator.dart';
import '../domain/match_lifecycle_policy.dart';

typedef MatchLifecycleClock = DateTime Function();

final matchLifecycleServiceProvider = Provider<MatchLifecycleService>((ref) {
  return MatchLifecycleService(ref.watch(recordingCoordinatorProvider));
});

final class MatchLifecycleService {
  MatchLifecycleService(
    this._coordinator, {
    MatchLifecycleClock? clock,
    MatchLifecyclePolicy policy = const MatchLifecyclePolicy(),
  })  : _clock = clock ?? DateTime.now,
        _policy = policy;

  final RecordingCoordinator _coordinator;
  final MatchLifecycleClock _clock;
  final MatchLifecyclePolicy _policy;

  DateTime commandNowUtc() => _policy.canonicalize(_clock())!;

  Future<void> startMatch(int matchId, DateTime startedAt) {
    return _coordinator.startMatch(
      matchId,
      startedAt: _policy.requireStart(startedAt),
    );
  }

  Future<void> finishMatch(
    int matchId, {
    DateTime? startedAt,
    DateTime? endedAt,
    String? winner,
  }) {
    final command = _policy.requireFinish(
      startTime: startedAt,
      endTime: endedAt ?? commandNowUtc(),
    );
    return _coordinator.finishMatch(
      matchId,
      winner: winner,
      startedAt: command.startTime,
      endedAt: command.endTime,
    );
  }
}
