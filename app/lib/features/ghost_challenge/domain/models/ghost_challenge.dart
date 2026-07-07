class GhostChallenge {
  final int? id;
  final int matchId;
  final int playerScore;
  final int ghostScore;
  final int targetScore;
  final int racksPlayed;
  final List<GhostShot> shotHistory;
  final DateTime createdAt;

  GhostChallenge({
    this.id,
    required this.matchId,
    this.playerScore = 0,
    this.ghostScore = 0,
    required this.targetScore,
    this.racksPlayed = 0,
    this.shotHistory = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  GhostChallenge copyWith({
    int? id,
    int? matchId,
    int? playerScore,
    int? ghostScore,
    int? targetScore,
    int? racksPlayed,
    List<GhostShot>? shotHistory,
    DateTime? createdAt,
  }) {
    return GhostChallenge(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerScore: playerScore ?? this.playerScore,
      ghostScore: ghostScore ?? this.ghostScore,
      targetScore: targetScore ?? this.targetScore,
      racksPlayed: racksPlayed ?? this.racksPlayed,
      shotHistory: shotHistory ?? this.shotHistory,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isComplete => playerScore >= targetScore || ghostScore >= targetScore;

  String? get winner {
    if (!isComplete) return null;
    if (playerScore > ghostScore) return 'player';
    if (ghostScore > playerScore) return 'ghost';
    return 'tie';
  }

  double get playerWinRate =>
      racksPlayed == 0 ? 0.0 : playerScore / racksPlayed;

  double get ghostWinRate =>
      racksPlayed == 0 ? 0.0 : ghostScore / racksPlayed;
}

class GhostShot {
  final int rackNumber;
  final String shooter;
  final bool made;
  final String shotType;
  final String difficulty;
  final DateTime timestamp;

  GhostShot({
    required this.rackNumber,
    required this.shooter,
    required this.made,
    required this.shotType,
    required this.difficulty,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'rackNumber': rackNumber,
      'shooter': shooter,
      'made': made,
      'shotType': shotType,
      'difficulty': difficulty,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory GhostShot.fromJson(Map<String, dynamic> json) {
    return GhostShot(
      rackNumber: json['rackNumber'] as int,
      shooter: json['shooter'] as String,
      made: json['made'] as bool,
      shotType: json['shotType'] as String,
      difficulty: json['difficulty'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
