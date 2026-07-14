// Task 14 — internal ranking (Phần 3), leaderboard (Phần 8) and club-wide
// statistics (Phần 7). Pure functions, no persistence, no AI. Everything is
// derived only from data the club already owns: its member list plus the
// recorded Matches that belong to the club (identified elsewhere by a ClubLink).
// This never recomputes or touches the Statistics engine — it just tallies and
// sorts. "Chỉ tổng hợp. Không AI."

import 'package:pool_os/features/club/domain/models/club_models.dart';

/// A minimal, engine-agnostic view of a recorded Match as far as club ranking
/// cares: who played (by member id, resolved by the repository), who won, how
/// many racks each side took, and when. The repository builds these from the
/// club's linked Matches; the calculator stays free of Drift/DB types so it is
/// trivially unit-testable.
class ClubMatchResult {
  final int matchId;
  final int? memberAId;
  final int? memberBId;
  final int? winnerMemberId;
  final int racksA;
  final int racksB;
  final DateTime playedAt;

  const ClubMatchResult({
    required this.matchId,
    this.memberAId,
    this.memberBId,
    this.winnerMemberId,
    this.racksA = 0,
    this.racksB = 0,
    required this.playedAt,
  });

  int get totalRacks => racksA + racksB;
}

class ClubCalculator {
  /// Internal ranking (Phần 3). One row per member, sorted by club points desc,
  /// then win rate desc, then wins desc, then name. Streak counts the member's
  /// most recent consecutive same-outcome results (chronological), positive for
  /// wins and negative for losses.
  static List<ClubRankingRow> ranking({
    required List<ClubMember> members,
    required List<ClubMatchResult> results,
  }) {
    // Chronological order so streaks read from oldest to newest.
    final sorted = [...results]..sort((a, b) => a.playedAt.compareTo(b.playedAt));

    final wins = <int, int>{};
    final losses = <int, int>{};
    final played = <int, int>{};
    final lastOutcomes = <int, List<bool>>{}; // member -> list of won? flags

    for (final r in sorted) {
      if (r.winnerMemberId == null) continue;
      for (final memberId in [r.memberAId, r.memberBId]) {
        if (memberId == null) continue;
        played[memberId] = (played[memberId] ?? 0) + 1;
        final won = r.winnerMemberId == memberId;
        if (won) {
          wins[memberId] = (wins[memberId] ?? 0) + 1;
        } else {
          losses[memberId] = (losses[memberId] ?? 0) + 1;
        }
        (lastOutcomes[memberId] ??= []).add(won);
      }
    }

    final rows = <ClubRankingRow>[];
    for (final m in members) {
      if (m.id == null) continue;
      rows.add(ClubRankingRow(
        memberId: m.id!,
        memberName: m.name,
        matchesPlayed: played[m.id] ?? 0,
        wins: wins[m.id] ?? 0,
        losses: losses[m.id] ?? 0,
        currentStreak: _streak(lastOutcomes[m.id] ?? const []),
      ));
    }

    rows.sort((a, b) {
      final byPoints = b.clubPoints.compareTo(a.clubPoints);
      if (byPoints != 0) return byPoints;
      final byRate = b.winRate.compareTo(a.winRate);
      if (byRate != 0) return byRate;
      final byWins = b.wins.compareTo(a.wins);
      if (byWins != 0) return byWins;
      return a.memberName.toLowerCase().compareTo(b.memberName.toLowerCase());
    });
    return rows;
  }

  /// Trailing same-outcome streak from a chronological won?-flag list. Positive
  /// for a current win streak, negative for a loss streak, 0 when empty.
  static int _streak(List<bool> outcomes) {
    if (outcomes.isEmpty) return 0;
    final last = outcomes.last;
    var count = 0;
    for (var i = outcomes.length - 1; i >= 0; i--) {
      if (outcomes[i] == last) {
        count++;
      } else {
        break;
      }
    }
    return last ? count : -count;
  }

  /// Leaderboard (Phần 8) = ranking restricted to results within [period] of
  /// [now]. Reuses [ranking] on the filtered result set so the sort is identical.
  static List<ClubRankingRow> leaderboard({
    required List<ClubMember> members,
    required List<ClubMatchResult> results,
    required LeaderboardPeriod period,
    required DateTime now,
  }) {
    final since = period.since(now);
    final within = results
        .where((r) => !r.playedAt.isBefore(since))
        .toList();
    return ranking(members: members, results: within);
  }

  /// Club-wide statistics (Phần 7). Pure aggregate counts. [trainingSeconds]
  /// per member is supplied by the repository (summed from the club's linked
  /// training sessions); the "most improved" name is optional and only set when
  /// the caller can derive it honestly — otherwise null (no fabricated data).
  static ClubStatistics statistics({
    required List<ClubMember> members,
    required List<ClubMatchResult> results,
    required Map<int, int> trainingSecondsByMember,
    String? mostImprovedMemberName,
  }) {
    final resolved = results.where((r) => r.winnerMemberId != null).toList();
    final totalMatches = resolved.length;
    final totalRacks =
        resolved.fold<int>(0, (sum, r) => sum + r.totalRacks);

    final nameById = <int, String>{
      for (final m in members)
        if (m.id != null) m.id!: m.name,
    };

    // Most active by training time.
    String? mostActive;
    var bestSeconds = 0;
    trainingSecondsByMember.forEach((memberId, seconds) {
      if (seconds > bestSeconds) {
        bestSeconds = seconds;
        mostActive = nameById[memberId];
      }
    });

    // Most wins.
    final winCounts = <int, int>{};
    for (final r in resolved) {
      final w = r.winnerMemberId!;
      winCounts[w] = (winCounts[w] ?? 0) + 1;
    }
    String? mostWins;
    var bestWins = 0;
    winCounts.forEach((memberId, count) {
      if (count > bestWins) {
        bestWins = count;
        mostWins = nameById[memberId];
      }
    });

    final totalTrainingSeconds =
        trainingSecondsByMember.values.fold<int>(0, (a, b) => a + b);

    return ClubStatistics(
      totalMatches: totalMatches,
      totalRacks: totalRacks,
      totalTrainingTime: Duration(seconds: totalTrainingSeconds),
      mostActiveMemberName: mostActive,
      mostWinsMemberName: mostWins,
      mostImprovedMemberName: mostImprovedMemberName,
    );
  }
}
