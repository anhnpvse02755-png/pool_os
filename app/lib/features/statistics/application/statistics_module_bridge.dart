// EPIC 02 — Statistics & Analytics — Revision 5.
//
// Implements `StatisticsModuleBridge` (defined in EPIC 01
// `match/domain/integration/integration_seams.dart`) on top of
// Riverpod. When the Match Engine emits `MatchCompleted` (or any
// shot history update) the bridge invalidates every dashboard +
// statistics snapshot provider so the UI re-fetches from the
// existing repositories.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/domain/engine/value_objects.dart'
    show MatchId;
import 'package:pool_os/features/match/domain/integration/integration_seams.dart';

import 'statistics_analytics_service.dart';

class RiverpodStatisticsBridge implements StatisticsModuleBridge {
  RiverpodStatisticsBridge(this._ref);

  final Ref _ref;

  @override
  Future<void> onShotHistoryRecorded({
    required MatchId matchId,
    required String participantId,
    required int shotCount,
    required int foulCount,
    required int safetyCount,
  }) async {
    _invalidate();
  }

  void _invalidate() {
    _ref.invalidate(dashboardSnapshotProvider);
    _ref.invalidate(matchStatisticsSnapshotProvider);
    _ref.invalidate(playerStatisticsSnapshotProvider);
    _ref.invalidate(performanceSnapshotProvider);
  }
}

final riverpodStatisticsBridgeProvider =
    Provider<StatisticsModuleBridge>((ref) {
  return RiverpodStatisticsBridge(ref);
});
