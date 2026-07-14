// Task 13 — Tournament & League domain models.
//
// Pure Dart, no persistence annotations (mirrors training_center/ and
// data_center/). The repository maps these to/from Drift rows. A Tournament
// groups a set of recorded Matches under one competition. Crucially, Task 13
// does NOT modify the LOCKED RFC-301/302 recording pipeline: a Match inside a
// tournament is a normal recorded Match — the link lives in a separate
// [TournamentMatch] join table that only stores a soft-ref matchId. Nothing
// here reads or writes Racks/Shots/Events, and there is no AI / Coach /
// recommendation logic (doc "Không làm").

/// Supported bracket formats (Phần 2 — Tournament Type). The bracket/standing
/// calculators branch on this.
enum TournamentType {
  singleElimination,
  doubleElimination,
  roundRobin,
  league;

  String get code => name;

  static TournamentType fromCode(String code) => TournamentType.values
      .firstWhere((t) => t.code == code, orElse: () => TournamentType.singleElimination);

  /// i18n key for the display label (resolved in the widget layer).
  String get labelKey => 'tnmt_type_$name';
}

/// Lifecycle of a tournament. Kept deliberately small; there is no scheduling
/// engine — a tournament is upcoming until the player starts it and completed
/// when they close it out.
enum TournamentStatus {
  upcoming,
  active,
  completed;

  String get code => name;

  static TournamentStatus fromCode(String code) => TournamentStatus.values
      .firstWhere((s) => s.code == code, orElse: () => TournamentStatus.upcoming);

  String get labelKey => 'tnmt_status_$name';
}

/// Phần 1 — a competition. [type] fixes how the bracket/standings are computed;
/// it is captured at creation and never changes (changing it would invalidate
/// already-recorded results).
class Tournament {
  final int? id;
  final String name;
  final TournamentType type;
  final TournamentStatus status;
  final String? location;
  final String? notes;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  const Tournament({
    this.id,
    required this.name,
    required this.type,
    this.status = TournamentStatus.upcoming,
    this.location,
    this.notes,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  Tournament copyWith({
    int? id,
    String? name,
    TournamentType? type,
    TournamentStatus? status,
    String? location,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Tournament(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Phần 3 — a participant. Either a real Player ([playerId] set) or an ad-hoc
/// guest ([playerId] null, [name] typed by hand). [name] is always stored
/// (denormalised for real players too) so a participant survives even if the
/// linked Player is later deleted. [seed] orders the initial bracket (1 = top
/// seed); null seeds sort last and keep insertion order.
class TournamentParticipant {
  final int? id;
  final int tournamentId;
  final int? playerId; // soft ref, null for a guest
  final String name;
  final int? seed;
  final DateTime createdAt;

  const TournamentParticipant({
    this.id,
    required this.tournamentId,
    this.playerId,
    required this.name,
    this.seed,
    required this.createdAt,
  });

  bool get isGuest => playerId == null;

  TournamentParticipant copyWith({
    int? id,
    int? tournamentId,
    int? playerId,
    String? name,
    int? seed,
    DateTime? createdAt,
  }) {
    return TournamentParticipant(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      playerId: playerId ?? this.playerId,
      name: name ?? this.name,
      seed: seed ?? this.seed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Phần 4/5 — one slot in the bracket / one fixture between two participants.
/// This is the ONLY link between Task 13 and the recording pipeline: when the
/// player records a real Match for this fixture, [matchId] points at it (soft
/// ref, no FK — deleting the recorded Match never cascades the bracket away).
/// A fixture can also be resolved by directly setting a winner (e.g. a walkover
/// or a match recorded elsewhere) without a matchId.
///
/// [roundIndex] is 0-based (round 0 = first round). [bracketGroup] distinguishes
/// the winners' bracket ('W') from the losers' bracket ('L') in double
/// elimination, and is 'M' (main) for the single-table formats.
class TournamentMatch {
  final int? id;
  final int tournamentId;
  final int roundIndex;
  final int slotIndex; // position within the round, 0-based
  final String bracketGroup; // 'M' | 'W' | 'L'
  final int? participantAId; // soft ref to TournamentParticipant
  final int? participantBId;
  final int? winnerParticipantId; // set when resolved
  final int? scoreA; // racks won by A (optional, for standings tiebreak)
  final int? scoreB;
  final int? matchId; // soft ref to a recorded Match, null if not recorded
  final DateTime createdAt;

  const TournamentMatch({
    this.id,
    required this.tournamentId,
    required this.roundIndex,
    required this.slotIndex,
    this.bracketGroup = 'M',
    this.participantAId,
    this.participantBId,
    this.winnerParticipantId,
    this.scoreA,
    this.scoreB,
    this.matchId,
    required this.createdAt,
  });

  bool get isResolved => winnerParticipantId != null;

  /// True when both sides are known and it is ready to be played.
  bool get isReady => participantAId != null && participantBId != null;

  /// The loser's participant id once resolved (needed to feed the losers'
  /// bracket in double elimination). Null until resolved or if a side is empty.
  int? get loserParticipantId {
    if (!isResolved) return null;
    if (winnerParticipantId == participantAId) return participantBId;
    if (winnerParticipantId == participantBId) return participantAId;
    return null;
  }

  TournamentMatch copyWith({
    int? id,
    int? tournamentId,
    int? roundIndex,
    int? slotIndex,
    String? bracketGroup,
    int? participantAId,
    int? participantBId,
    int? winnerParticipantId,
    int? scoreA,
    int? scoreB,
    int? matchId,
    DateTime? createdAt,
  }) {
    return TournamentMatch(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      roundIndex: roundIndex ?? this.roundIndex,
      slotIndex: slotIndex ?? this.slotIndex,
      bracketGroup: bracketGroup ?? this.bracketGroup,
      participantAId: participantAId ?? this.participantAId,
      participantBId: participantBId ?? this.participantBId,
      winnerParticipantId: winnerParticipantId ?? this.winnerParticipantId,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      matchId: matchId ?? this.matchId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Phần 6 — one row of the standings table. Pure display data derived from
/// resolved [TournamentMatch]es by the standing calculator; never persisted.
class StandingRow {
  final int participantId;
  final String participantName;
  final int wins;
  final int losses;
  final int racksWon;
  final int racksLost;

  const StandingRow({
    required this.participantId,
    required this.participantName,
    this.wins = 0,
    this.losses = 0,
    this.racksWon = 0,
    this.racksLost = 0,
  });

  int get matchesPlayed => wins + losses;

  /// League points: 3 per win (0 per loss). Simple and format-agnostic.
  int get points => wins * 3;

  int get rackDiff => racksWon - racksLost;

  double get winRate => matchesPlayed == 0 ? 0.0 : wins / matchesPlayed;

  StandingRow addResult({
    required bool won,
    int racksFor = 0,
    int racksAgainst = 0,
  }) {
    return StandingRow(
      participantId: participantId,
      participantName: participantName,
      wins: wins + (won ? 1 : 0),
      losses: losses + (won ? 0 : 1),
      racksWon: racksWon + racksFor,
      racksLost: racksLost + racksAgainst,
    );
  }
}

/// Phần 8 — one entry in a player's tournament history. Derived on demand.
class TournamentHistoryEntry {
  final Tournament tournament;
  final int participantCount;

  /// 1-based final placement for the player, or null when unknown / not
  /// finished (never a fabricated rank).
  final int? placement;
  final bool isChampion;

  const TournamentHistoryEntry({
    required this.tournament,
    required this.participantCount,
    this.placement,
    this.isChampion = false,
  });
}
