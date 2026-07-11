class Match {
  final int? id;
  final int sessionId;
  final int matchNumber;
  final String gameType;
  final int? raceTo;
  final String? opponent;
  final String? partner;
  final String? teamMode;
  final String? winner;
  final String? result;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? matchObjective;
  final String? notes;
  final DateTime createdAt;

  Match({
    this.id,
    required this.sessionId,
    required this.matchNumber,
    required this.gameType,
    this.raceTo,
    this.opponent,
    this.partner,
    this.teamMode,
    this.winner,
    this.result,
    this.startTime,
    this.endTime,
    this.matchObjective,
    this.notes,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Match copyWith({
    int? id,
    int? sessionId,
    int? matchNumber,
    String? gameType,
    int? raceTo,
    String? opponent,
    String? partner,
    String? teamMode,
    String? winner,
    String? result,
    DateTime? startTime,
    DateTime? endTime,
    String? matchObjective,
    String? notes,
    DateTime? createdAt,
  }) {
    return Match(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      matchNumber: matchNumber ?? this.matchNumber,
      gameType: gameType ?? this.gameType,
      raceTo: raceTo ?? this.raceTo,
      opponent: opponent ?? this.opponent,
      partner: partner ?? this.partner,
      teamMode: teamMode ?? this.teamMode,
      winner: winner ?? this.winner,
      result: result ?? this.result,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      matchObjective: matchObjective ?? this.matchObjective,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isActive => endTime == null;

  Duration? get duration {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!);
  }
}

class GameTypes {
  // RFC-302 Task D: generic race-to game type for an arbitrary raceTo value
  // (3/5/7/9/11/…). The old fixed raceTo5/raceTo7 remain for backward
  // compatibility with matches already stored under those game types.
  static const String raceTo = 'race_to';
  static const String raceTo5 = 'race_to_5';
  static const String raceTo7 = 'race_to_7';
  static const String ghostChallenge = 'ghost_challenge';
  static const String challengeMatch = 'challenge_match';
  static const String leagueMatch = 'league_match';
  static const String tournamentMatch = 'tournament_match';
  static const String practiceMatch = 'practice_match';
  static const String warmUp = 'warm_up';
  static const String drill = 'drill';

  static const List<String> all = [
    warmUp,
    raceTo5,
    raceTo7,
    ghostChallenge,
    challengeMatch,
    leagueMatch,
    tournamentMatch,
    practiceMatch,
    drill,
  ];
}

class TeamModes {
  static const String solo = 'solo';
  static const String doubles = 'doubles';
  static const String team = 'team';

  static const List<String> all = [solo, doubles, team];
}
