// Task 15 — Coach Intelligence V2, Layer 2: ShotContextProducer.
//
// The one genuinely new computation in Task 15. It derives per-shot-type success
// rate split by PLAY CONTEXT (training / match / ghost) AND by time window
// (recent vs prior), by walking the recording pipeline read-only:
//
//   getAllSessions → getMatchesBySessionId → getRacksByMatchId → getShotsByRackId
//
// bucketing shot.result by session.sessionType (+ match.gameType ==
// 'ghost_challenge' for ghost). This mirrors the proven traversal in
// EquipmentPerformanceService.computeRoleStats — same walk, different bucket key.
//
// It emits ONLY facts: one Finding per shot type carrying the training/match/
// ghost split and the recent-vs-prior split. No wording, no severity, no
// priority, no action — Coach Brain decides all of that.

import 'package:pool_os/features/coach/domain/findings/finding.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

/// Metric-id prefix for a per-shot-type context finding, e.g. `shot.stopShot`.
String shotMetricId(String shotType) => 'shot.$shotType';

class ShotContextProducer {
  final SessionRepository _sessionRepo;
  final MatchRepository _matchRepo;
  final RackRepository _rackRepo;
  final ShotRepository _shotRepo;

  /// A shot older than this many days counts as the "prior" window; newer counts
  /// as "recent". Lets Coach Brain derive trajectory without any stored state.
  final int recentWindowDays;

  ShotContextProducer(
    this._sessionRepo,
    this._matchRepo,
    this._rackRepo,
    this._shotRepo, {
    this.recentWindowDays = 14,
  });

  Future<List<Finding>> produce({DateTime? now}) async {
    final asOf = now ?? DateTime.now();
    final recentCutoff = asOf.subtract(Duration(days: recentWindowDays));

    // shotType -> tally
    final tallies = <String, _ShotTally>{};

    final sessions = await _sessionRepo.getAllSessions();
    for (final session in sessions) {
      if (session.id == null) continue;
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        if (match.id == null) continue;
        final context = _contextFor(session, match);
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        for (final rack in racks) {
          if (rack.id == null) continue;
          final shots = await _shotRepo.getShotsByRackId(rack.id!);
          for (final shot in shots) {
            final made = shot.result == ShotResult.made;
            final isRecent = shot.createdAt.isAfter(recentCutoff);
            final tally = tallies.putIfAbsent(
                shot.shotType, () => _ShotTally(shot.shotType));
            tally.add(context: context, made: made, recent: isRecent);
          }
        }
      }
    }

    // Latest shot time per type → observedAt (fact about when it was measured).
    return tallies.values.map((t) => t.toFinding()).toList()
      ..sort((a, b) => b.totalContextAttempts.compareTo(a.totalContextAttempts));
  }

  /// Resolve the play context for a recorded match. Ghost is detected by the
  /// match's gameType; otherwise the owning session's sessionType decides.
  PlayStyleContext _contextFor(Session session, Match match) {
    if (match.gameType == GameTypes.ghostChallenge) {
      return PlayStyleContext.ghost;
    }
    switch (session.sessionType) {
      case SessionTypes.match:
      case SessionTypes.tournament:
        return PlayStyleContext.match;
      case SessionTypes.training:
      case SessionTypes.practice:
      default:
        return PlayStyleContext.training;
    }
  }
}

/// Mutable per-shot-type accumulator. Fact-only; converts to a [Finding].
class _ShotTally {
  final String shotType;
  final Map<PlayStyleContext, ContextValue> _byContext = {
    PlayStyleContext.training: const ContextValue(),
    PlayStyleContext.match: const ContextValue(),
    PlayStyleContext.ghost: const ContextValue(),
  };
  int _recentAttempts = 0;
  int _recentMade = 0;
  int _priorAttempts = 0;
  int _priorMade = 0;

  _ShotTally(this.shotType);

  void add({
    required PlayStyleContext context,
    required bool made,
    required bool recent,
  }) {
    _byContext[context] = _byContext[context]!.add(made: made);
    if (recent) {
      _recentAttempts++;
      if (made) _recentMade++;
    } else {
      _priorAttempts++;
      if (made) _priorMade++;
    }
  }

  int get _totalAttempts =>
      _byContext.values.fold(0, (s, c) => s + c.attempts);
  int get _totalMade => _byContext.values.fold(0, (s, c) => s + c.made);

  Finding toFinding() {
    final rate = _totalAttempts == 0 ? null : _totalMade / _totalAttempts;
    return Finding(
      metricId: shotMetricId(shotType),
      source: FindingSource.shots,
      value: rate,
      sampleSize: _totalAttempts,
      byContext: Map.unmodifiable(_byContext),
      // Fact-only extras: the recent-vs-prior split for trajectory derivation.
      data: {
        'shotType': shotType,
        'recentAttempts': _recentAttempts,
        'recentMade': _recentMade,
        'priorAttempts': _priorAttempts,
        'priorMade': _priorMade,
      },
    );
  }
}
