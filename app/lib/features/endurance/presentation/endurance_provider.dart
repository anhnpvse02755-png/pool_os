import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/endurance/domain/endurance_analyzer.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';

/// Task 08 — reads the player's recent match history and runs the
/// [EnduranceAnalyzer] on demand. Nothing is stored; every number is derived
/// from real racks/shots (spec: no fabricated data, no new user input).
///
/// Returns [EnduranceProfile.insufficient] when there is not enough history —
/// the UI turns that into "Chưa đủ dữ liệu để đánh giá" and shows nothing else.
final enduranceProfileProvider =
    FutureProvider<EnduranceProfile>((ref) async {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final rackRepo = ref.watch(rackRepositoryProvider);
  final shotRepo = ref.watch(shotRepositoryProvider);
  const analyzer = EnduranceAnalyzer();

  // Pull a generous slice of recent matches; the analyzer decides which are
  // long enough to count and gates on having enough of them.
  final matches = await matchRepo.getRecentMatches(limit: 30);

  final data = <MatchRackData>[];
  for (final match in matches) {
    if (match.id == null) continue;
    final racks = await rackRepo.getRacksByMatchId(match.id!);
    if (racks.length < EnduranceAnalyzer.minRacksPerMatch) continue;

    // Load shots per rack once so the pure analyzer can attribute decline to
    // technique vs physical/mental without touching the DB itself.
    final shotsByRackId = <int, List<dynamic>>{};
    for (final rack in racks) {
      if (rack.id == null) continue;
      shotsByRackId[rack.id!] = await shotRepo.getShotsByRackId(rack.id!);
    }

    data.add(MatchRackData(
      racks: racks,
      shotsByRackId: shotsByRackId.map(
        (key, value) => MapEntry(key, value.cast()),
      ),
    ));
  }

  return analyzer.analyze(data);
});

/// Per-rack quality series (0-100) for the most recent analyzable match, used
/// to draw the performance curve. Empty when there is no match long enough —
/// the chart then simply does not render (no fabricated line).
final enduranceRecentCurveProvider =
    FutureProvider<List<double>>((ref) async {
  final matchRepo = ref.watch(matchRepositoryProvider);
  final rackRepo = ref.watch(rackRepositoryProvider);
  const analyzer = EnduranceAnalyzer();

  final matches = await matchRepo.getRecentMatches(limit: 30);
  for (final match in matches) {
    if (match.id == null) continue;
    final racks = await rackRepo.getRacksByMatchId(match.id!);
    if (racks.length < EnduranceAnalyzer.minRacksPerMatch) continue;
    return analyzer.qualitySeries(racks);
  }
  return const [];
});
