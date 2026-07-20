import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/match/data/repositories/match_context_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/match/domain/models/match.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot.dart';
import 'package:pool_os/features/performance/domain/performance_snapshot_builder.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';

final performanceSnapshotRepositoryProvider =
    Provider<PerformanceSnapshotRepository>((ref) {
  return PerformanceSnapshotRepository(
    ref.watch(matchRepositoryProvider),
    ref.watch(rackRepositoryProvider),
    ref.watch(shotRepositoryProvider),
    ref.watch(matchContextRepositoryProvider),
  );
});

final performanceSnapshotProvider =
    FutureProvider.autoDispose<PerformanceSnapshot>((ref) {
  return ref.watch(performanceSnapshotRepositoryProvider).buildSnapshot();
});

/// Read model over competition data. It does not import Statistics and does not
/// produce recommendations; Coach consumes the resulting facts.
class PerformanceSnapshotRepository {
  final MatchRepository _matchRepository;
  final RackRepository _rackRepository;
  final ShotRepository _shotRepository;
  final MatchContextRepository _contextRepository;
  final PerformanceSnapshotBuilder _builder;

  PerformanceSnapshotRepository(
    this._matchRepository,
    this._rackRepository,
    this._shotRepository,
    this._contextRepository, {
    PerformanceSnapshotBuilder? builder,
  }) : _builder = builder ?? PerformanceSnapshotBuilder();

  Future<PerformanceSnapshot> buildSnapshot() async {
    final allMatches = await _matchRepository.getAllMatches();
    final matches = allMatches
        .where((match) => match.endTime != null && _isCompetition(match))
        .toList()
      ..sort((a, b) => b.endTime!.compareTo(a.endTime!));
    final contexts = await _contextRepository.getAll();
    final contextByMatch = {
      for (final context in contexts) context.matchId: context,
    };
    final samples = <PerformanceMatchSample>[];

    for (final match in matches.take(PerformanceSnapshotBuilder.maxMatches)) {
      final matchId = match.id;
      if (matchId == null) continue;
      final racks = await _rackRepository.getRacksByMatchId(matchId);
      final shots = <Shot>[];
      for (final rack in racks) {
        if (rack.id == null) continue;
        shots.addAll(await _shotRepository.getShotsByRackId(rack.id!));
      }
      samples.add(PerformanceMatchSample(
        match: match,
        racks: racks,
        shots: shots,
        context: contextByMatch[matchId],
      ));
    }

    return _builder.build(samples);
  }

  bool _isCompetition(Match match) => !{
        GameTypes.warmUp,
        GameTypes.ghostChallenge,
        GameTypes.practiceMatch,
        GameTypes.drill,
      }.contains(match.gameType);
}
