// Task 13 — standings (Phần 6) and final placement (Phần 8). Pure functions
// over resolved TournamentMatches; nothing is persisted. No AI. Where the data
// is insufficient (nobody has played), the caller shows an empty table rather
// than a fabricated ranking.

import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

class StandingCalculator {
  /// Build the standings table from resolved matches. Every participant gets a
  /// row (even with zero games), so the table lists the full field. Rows are
  /// sorted by points desc, then wins desc, then rack-diff desc, then name.
  static List<StandingRow> standings({
    required List<TournamentParticipant> participants,
    required List<TournamentMatch> matches,
  }) {
    final rows = <int, StandingRow>{
      for (final p in participants)
        if (p.id != null)
          p.id!: StandingRow(participantId: p.id!, participantName: p.name),
    };

    for (final m in matches) {
      if (!m.isResolved) continue;
      final winnerId = m.winnerParticipantId!;
      // A bye (only one side present) still records a win for the present side
      // but adds no loss row for a phantom opponent.
      final loserId = m.loserParticipantId;

      final wScoreFor = _winnerScore(m);
      final wScoreAgainst = _loserScore(m);

      if (rows.containsKey(winnerId)) {
        rows[winnerId] = rows[winnerId]!.addResult(
          won: true,
          racksFor: wScoreFor,
          racksAgainst: wScoreAgainst,
        );
      }
      if (loserId != null && rows.containsKey(loserId)) {
        rows[loserId] = rows[loserId]!.addResult(
          won: false,
          racksFor: wScoreAgainst,
          racksAgainst: wScoreFor,
        );
      }
    }

    final list = rows.values.toList();
    list.sort(_compare);
    return list;
  }

  /// Racks won by the fixture winner (0 when scores were not recorded).
  static int _winnerScore(TournamentMatch m) {
    if (m.scoreA == null || m.scoreB == null) return 0;
    return m.winnerParticipantId == m.participantAId ? m.scoreA! : m.scoreB!;
  }

  static int _loserScore(TournamentMatch m) {
    if (m.scoreA == null || m.scoreB == null) return 0;
    return m.winnerParticipantId == m.participantAId ? m.scoreB! : m.scoreA!;
  }

  static int _compare(StandingRow a, StandingRow b) {
    final byPoints = b.points.compareTo(a.points);
    if (byPoints != 0) return byPoints;
    final byWins = b.wins.compareTo(a.wins);
    if (byWins != 0) return byWins;
    final byDiff = b.rackDiff.compareTo(a.rackDiff);
    if (byDiff != 0) return byDiff;
    return a.participantName.toLowerCase().compareTo(b.participantName.toLowerCase());
  }

  /// The champion's participant id for an elimination tournament: the winner of
  /// the last round's single fixture. Null if the final is not yet resolved.
  static int? championId(List<TournamentMatch> matches) {
    final main = matches.where((m) => m.bracketGroup != 'L').toList();
    if (main.isEmpty) return null;
    final lastRound = main.map((m) => m.roundIndex).reduce((a, b) => a > b ? a : b);
    final finals = main.where((m) => m.roundIndex == lastRound).toList();
    if (finals.length != 1) return null; // not a converging elimination bracket
    return finals.first.winnerParticipantId;
  }

  /// Final 1-based placement per participant for a round-robin / league, derived
  /// from the sorted standings. For elimination formats placement is less well
  /// defined, so this is only meaningful when [matches] came from a round robin.
  static Map<int, int> placementsFromStandings(List<StandingRow> sorted) {
    final result = <int, int>{};
    for (var i = 0; i < sorted.length; i++) {
      result[sorted[i].participantId] = i + 1;
    }
    return result;
  }
}
