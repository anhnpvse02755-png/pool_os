/// Session result after practice
class SessionResult {
  final String sessionId;
  final String playerId;
  final String goalId;
  final String drillId;
  final int attempts;
  final int successes;
  final double successRate;
  final bool passed;
  final DateTime startedAt;
  final DateTime? endedAt;

  const SessionResult({
    required this.sessionId,
    required this.playerId,
    required this.goalId,
    required this.drillId,
    required this.attempts,
    required this.successes,
    required this.successRate,
    required this.passed,
    required this.startedAt,
    this.endedAt,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'playerId': playerId,
        'goalId': goalId,
        'drillId': drillId,
        'attempts': attempts,
        'successes': successes,
        'successRate': successRate,
        'passed': passed,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt?.toIso8601String(),
      };

  factory SessionResult.fromJson(Map<String, dynamic> json) => SessionResult(
        sessionId: json['sessionId'] as String,
        playerId: json['playerId'] as String,
        goalId: json['goalId'] as String,
        drillId: json['drillId'] as String,
        attempts: json['attempts'] as int,
        successes: json['successes'] as int,
        successRate: (json['successRate'] as num).toDouble(),
        passed: json['passed'] as bool,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
      );
}
