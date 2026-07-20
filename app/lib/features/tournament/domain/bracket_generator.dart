// Task 13 — bracket generation (Phần 2/4). Pure functions, no persistence.
// Given a seeded participant list and a TournamentType, produce the first set of
// TournamentMatch slots (and, for elimination formats, the empty later rounds
// that get filled as results come in). No AI, no randomness beyond nothing —
// output is deterministic for a given input so it is trivially testable.

import 'dart:math' as math;

import 'package:pool_os/features/tournament/domain/models/tournament_models.dart';

/// Result of laying out a bracket: the fixtures to persist, keyed by round.
class BracketLayout {
  final List<TournamentMatch> matches;

  const BracketLayout(this.matches);

  int get roundCount => matches.isEmpty
      ? 0
      : (matches.map((m) => m.roundIndex).reduce(math.max) + 1);
}

class BracketGenerator {
  /// Order participants by seed (1 = top). Null seeds keep their incoming order
  /// but sort after all seeded entries.
  static List<TournamentParticipant> orderBySeed(
    List<TournamentParticipant> participants,
  ) {
    final seeded = participants.where((p) => p.seed != null).toList()
      ..sort((a, b) => a.seed!.compareTo(b.seed!));
    final unseeded = participants.where((p) => p.seed == null).toList();
    return [...seeded, ...unseeded];
  }

  /// The standard 1-vs-N seeding order for a single-elimination bracket of
  /// [size] slots (a power of two). Returns 0-based seed indices. E.g. size 4 →
  /// [0,3,1,2] so seed 1 meets seed 4 and seed 2 meets seed 3.
  static List<int> seedOrder(int size) {
    assert(size > 0 && (size & (size - 1)) == 0, 'size must be a power of two');
    var rounds = <int>[0];
    while (rounds.length < size) {
      final next = <int>[];
      final n = rounds.length * 2;
      for (final r in rounds) {
        next.add(r);
        next.add(n - 1 - r);
      }
      rounds = next;
    }
    return rounds;
  }

  /// Smallest power of two >= n (min 1).
  static int nextPowerOfTwo(int n) {
    if (n <= 1) return 1;
    var p = 1;
    while (p < n) {
      p <<= 1;
    }
    return p;
  }

  /// Generate the opening layout for [type]. Participants should already be the
  /// full entrant list; this seeds them internally. [now] stamps createdAt so
  /// tests are deterministic.
  static BracketLayout generate({
    required TournamentType type,
    required List<TournamentParticipant> participants,
    required int tournamentId,
    required DateTime now,
    bool includeThirdPlace = false,
  }) {
    switch (type) {
      case TournamentType.singleElimination:
      case TournamentType.doubleElimination:
        // The losers' bracket is built lazily as losers drop in, so both
        // elimination formats share the same opening winners' round here.
        return _elimination(
          participants,
          tournamentId,
          now,
          includeThirdPlace: includeThirdPlace,
        );
      case TournamentType.roundRobin:
      case TournamentType.league:
        // League is a round robin whose standings use points; the fixture set
        // is identical (everyone plays everyone once).
        return _roundRobin(participants, tournamentId, now);
    }
  }

  static BracketLayout _elimination(
    List<TournamentParticipant> participants,
    int tournamentId,
    DateTime now, {
    required bool includeThirdPlace,
  }) {
    final ordered = orderBySeed(participants);
    final size = nextPowerOfTwo(ordered.length);
    final order = seedOrder(size); // 0-based seed slots

    final matches = <TournamentMatch>[];
    // Round 0: pair slot[order[2k]] vs slot[order[2k+1]]. A slot beyond the
    // entrant count is a BYE (null participant) — the present side auto-advances
    // and is recorded as the winner immediately.
    for (var i = 0; i < size ~/ 2; i++) {
      final aSlot = order[i * 2];
      final bSlot = order[i * 2 + 1];
      final a = aSlot < ordered.length ? ordered[aSlot] : null;
      final b = bSlot < ordered.length ? ordered[bSlot] : null;

      int? winner;
      if (a != null && b == null) winner = a.id;
      if (b != null && a == null) winner = b.id;

      matches.add(TournamentMatch(
        tournamentId: tournamentId,
        roundIndex: 0,
        slotIndex: i,
        bracketGroup: 'M',
        participantAId: a?.id,
        participantBId: b?.id,
        winnerParticipantId: winner,
        createdAt: now,
      ));
    }

    // Empty later rounds (winners' bracket), filled by advanceWinner.
    var slotsThisRound = size ~/ 2;
    var round = 1;
    while (slotsThisRound > 1) {
      slotsThisRound ~/= 2;
      for (var i = 0; i < slotsThisRound; i++) {
        matches.add(TournamentMatch(
          tournamentId: tournamentId,
          roundIndex: round,
          slotIndex: i,
          bracketGroup: 'M',
          createdAt: now,
        ));
      }
      round++;
    }

    if (includeThirdPlace && ordered.length >= 4) {
      matches.add(TournamentMatch(
        tournamentId: tournamentId,
        roundIndex: round - 1,
        slotIndex: 0,
        bracketGroup: 'P',
        createdAt: now,
      ));
    }

    return BracketLayout(matches);
  }

  static BracketLayout _roundRobin(
    List<TournamentParticipant> participants,
    int tournamentId,
    DateTime now,
  ) {
    final ordered = orderBySeed(participants);
    final matches = <TournamentMatch>[];
    // Every distinct unordered pair plays once. Round index groups the pairings
    // loosely (not a strict circle schedule — the app does not enforce parallel
    // rounds), slotIndex is a running counter for a stable order.
    var slot = 0;
    for (var i = 0; i < ordered.length; i++) {
      for (var j = i + 1; j < ordered.length; j++) {
        matches.add(TournamentMatch(
          tournamentId: tournamentId,
          roundIndex: 0,
          slotIndex: slot++,
          bracketGroup: 'M',
          participantAId: ordered[i].id,
          participantBId: ordered[j].id,
          createdAt: now,
        ));
      }
    }
    return BracketLayout(matches);
  }

  /// After a fixture is resolved, compute where its winner goes in the next
  /// winners'-bracket round. Returns (roundIndex, slotIndex, isSideA) for the
  /// parent slot, or null if this was the final. Elimination only.
  static ({int roundIndex, int slotIndex, bool isSideA})? parentSlot({
    required int roundIndex,
    required int slotIndex,
    required int roundCount,
  }) {
    final nextRound = roundIndex + 1;
    if (nextRound >= roundCount) return null;
    final parentSlotIndex = slotIndex ~/ 2;
    final isSideA = slotIndex.isEven;
    return (
      roundIndex: nextRound,
      slotIndex: parentSlotIndex,
      isSideA: isSideA
    );
  }
}
