import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../rack/data/repositories/rack_repository.dart';
import '../data/repositories/match_repository.dart';
import '../domain/models/match.dart';

final matchStatisticsServiceProvider = Provider<MatchStatisticsService>((ref) {
  return MatchStatisticsService(
    matches: ref.watch(matchRepositoryProvider),
    racks: ref.watch(rackRepositoryProvider),
  );
});

final class MatchStatisticsService {
  const MatchStatisticsService({
    required MatchRepository matches,
    required RackRepository racks,
  })  : _matches = matches,
        _racks = racks;

  final MatchRepository _matches;
  final RackRepository _racks;

  Future<
      ({
        int matchCount,
        int rackCount,
        int wins,
        int losses,
        Duration duration,
        List<
            ({
              Match match,
              int wins,
              int losses,
              double winRate,
            })> performance,
      })> load() async {
    final matches = (await _matches.getAllMatches())
        .where((match) => match.endTime != null)
        .toList()
      ..sort((left, right) => right.endTime!.compareTo(left.endTime!));
    var rackCount = 0;
    var wins = 0;
    var duration = Duration.zero;
    final performance = <({
      Match match,
      int wins,
      int losses,
      double winRate,
    })>[];
    for (final match in matches) {
      final racks = await _racks.getRacksByMatchId(match.id!);
      final matchWins = racks.where((rack) => rack.result).length;
      final matchLosses = racks.length - matchWins;
      rackCount += racks.length;
      wins += matchWins;
      duration += match.duration ?? Duration.zero;
      performance.add((
        match: match,
        wins: matchWins,
        losses: matchLosses,
        winRate: racks.isEmpty ? 0 : matchWins / racks.length,
      ));
    }
    return (
      matchCount: matches.length,
      rackCount: rackCount,
      wins: wins,
      losses: rackCount - wins,
      duration: duration,
      performance: performance,
    );
  }
}
