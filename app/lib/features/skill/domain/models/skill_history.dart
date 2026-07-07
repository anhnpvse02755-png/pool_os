class PlayerSkillHistory {
  final int? id;
  final int skillId;
  final int sessionId;
  final double score;
  final double confidence;
  final String trend;
  final DateTime createdAt;

  PlayerSkillHistory({
    this.id,
    required this.skillId,
    required this.sessionId,
    required this.score,
    required this.confidence,
    required this.trend,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PlayerSkillHistory copyWith({
    int? id,
    int? skillId,
    int? sessionId,
    double? score,
    double? confidence,
    String? trend,
    DateTime? createdAt,
  }) {
    return PlayerSkillHistory(
      id: id ?? this.id,
      skillId: skillId ?? this.skillId,
      sessionId: sessionId ?? this.sessionId,
      score: score ?? this.score,
      confidence: confidence ?? this.confidence,
      trend: trend ?? this.trend,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SkillCareer {
  final String category;
  final List<SkillHistoryPoint> history;

  const SkillCareer({
    required this.category,
    required this.history,
  });

  double get progress {
    if (history.length < 2) return 0;
    final first = history.first.score;
    final last = history.last.score;
    return last - first;
  }

  SkillHistoryPoint? get latest => history.isNotEmpty ? history.last : null;
  SkillHistoryPoint? get oldest => history.isNotEmpty ? history.first : null;
}

class SkillHistoryPoint {
  final DateTime date;
  final double score;
  final int sessionId;

  const SkillHistoryPoint({
    required this.date,
    required this.score,
    required this.sessionId,
  });
}
