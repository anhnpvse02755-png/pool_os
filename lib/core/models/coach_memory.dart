/// Coach Memory - what Coach remembers about player
class CoachMemory {
  final String playerId;
  final DateTime lastSessionDate;
  final String currentGoalId;
  final int currentMilestone;
  final double capabilityPot;
  final int enjoymentScore;
  final String painDetected;

  const CoachMemory({
    required this.playerId,
    required this.lastSessionDate,
    required this.currentGoalId,
    required this.currentMilestone,
    required this.capabilityPot,
    required this.enjoymentScore,
    required this.painDetected,
  });

  Map<String, dynamic> toJson() => {
        'playerId': playerId,
        'lastSessionDate': lastSessionDate.toIso8601String(),
        'currentGoalId': currentGoalId,
        'currentMilestone': currentMilestone,
        'capabilityPot': capabilityPot,
        'enjoymentScore': enjoymentScore,
        'painDetected': painDetected,
      };

  factory CoachMemory.fromJson(Map<String, dynamic> json) => CoachMemory(
        playerId: json['playerId'] as String,
        lastSessionDate: DateTime.parse(json['lastSessionDate'] as String),
        currentGoalId: json['currentGoalId'] as String,
        currentMilestone: json['currentMilestone'] as int,
        capabilityPot: (json['capabilityPot'] as num).toDouble(),
        enjoymentScore: json['enjoymentScore'] as int,
        painDetected: json['painDetected'] as String,
      );

  CoachMemory copyWith({
    String? playerId,
    DateTime? lastSessionDate,
    String? currentGoalId,
    int? currentMilestone,
    double? capabilityPot,
    int? enjoymentScore,
    String? painDetected,
  }) {
    return CoachMemory(
      playerId: playerId ?? this.playerId,
      lastSessionDate: lastSessionDate ?? this.lastSessionDate,
      currentGoalId: currentGoalId ?? this.currentGoalId,
      currentMilestone: currentMilestone ?? this.currentMilestone,
      capabilityPot: capabilityPot ?? this.capabilityPot,
      enjoymentScore: enjoymentScore ?? this.enjoymentScore,
      painDetected: painDetected ?? this.painDetected,
    );
  }
}
