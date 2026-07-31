// EPIC 04 Phase 2.2 — Tournament Ranking (read-only).
//
// PO 2026-07-31 rename: `RankingCalculator` → `TournamentRankingCalculator`
// so future rankings (GlobalRanking, PlayerRating, LeagueRanking,
// SeasonRanking) do not collide with this Beta scope.
//
// PO 2026-07-31: ranking is a DERIVED view. It walks existing tables:
//   tournamentMatches (resolved only) → tally wins per participantId
//                                    → sort by wins desc, then matchesPlayed asc.
//
// Skeleton only:
//   - Pure functions over existing TournamentMatch list.
//   - No new schema columns.
//   - No AI / prediction / ELO / Swiss points.
//   - TournamentCompetitionMode.team intentionally unranked here — team ranking
//     is in Phase 2.7 (Team skeleton).

import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

class TournamentRankingEntry {
  final int participantId;
  final String participantName;
  final int wins;
  final int losses;
  final int matchesPlayed;

  const TournamentRankingEntry({
    required this.participantId,
    required this.participantName,
    required this.wins,
    required this.losses,
    required this.matchesPlayed,
  });

  double get winRate =>
      matchesPlayed == 0 ? 0 : wins / matchesPlayed;

  @override
  String toString() =>
      'TournamentRankingEntry($participantName, w=$wins, l=$losses, mp=$matchesPlayed)';
}

class TournamentRankingCalculator {
  /// Build the read-only ranking table from resolved tournament matches.
  /// Only individual-mode participants are ranked — teams are deferred to
  /// Phase 2.7 (PO 2026-07-31 — team skeleton).
  ///
  /// Sort order: wins desc, losses asc, name asc (stable for ties).
  static List<TournamentRankingEntry> ranking({
    required List<TournamentMatch> matches,
    required Map<int, String> participantNameById,
  }) {
    final byId = <int, _Accumulator>{};

    for (final m in matches) {
      if (!m.isResolved) continue;
      final winnerId = m.winnerParticipantId;
      final loserId = m.loserParticipantId;
      if (winnerId == null) continue;

      byId.putIfAbsent(
        winnerId,
        () => _Accumulator(
          participantId: winnerId,
          name: participantNameById[winnerId] ?? 'P$winnerId',
        ),
      );
      byId[winnerId]!.wins += 1;

      if (loserId != null) {
        byId.putIfAbsent(
          loserId,
          () => _Accumulator(
            participantId: loserId,
            name: participantNameById[loserId] ?? 'P$loserId',
          ),
        );
        byId[loserId]!.losses += 1;
      }
    }

    final entries = byId.values
        .map((a) => TournamentRankingEntry(
              participantId: a.participantId,
              participantName: a.name,
              wins: a.wins,
              losses: a.losses,
              matchesPlayed: a.wins + a.losses,
            ))
        .toList();

    entries.sort((a, b) {
      final byWins = b.wins.compareTo(a.wins);
      if (byWins != 0) return byWins;
      final byLosses = a.losses.compareTo(b.losses);
      if (byLosses != 0) return byLosses;
      return a.participantName
          .toLowerCase()
          .compareTo(b.participantName.toLowerCase());
    });

    return entries;
  }
}

class _Accumulator {
  final int participantId;
  final String name;
  int wins = 0;
  int losses = 0;

  _Accumulator({required this.participantId, required this.name});
}