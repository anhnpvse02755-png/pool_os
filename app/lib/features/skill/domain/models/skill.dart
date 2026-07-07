import 'skill_category.dart';

class PlayerSkill {
  final int? id;
  final int playerId;
  final String category;
  final double score;
  final double confidence;
  final String trend;
  final DateTime? calculatedAt;
  final int version;
  final List<String> metricSources;

  PlayerSkill({
    this.id,
    required this.playerId,
    required this.category,
    required this.score,
    required this.confidence,
    required this.trend,
    this.calculatedAt,
    this.version = 1,
    this.metricSources = const [],
  });

  PlayerSkill copyWith({
    int? id,
    int? playerId,
    String? category,
    double? score,
    double? confidence,
    String? trend,
    DateTime? calculatedAt,
    int? version,
    List<String>? metricSources,
  }) {
    return PlayerSkill(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      category: category ?? this.category,
      score: score ?? this.score,
      confidence: confidence ?? this.confidence,
      trend: trend ?? this.trend,
      calculatedAt: calculatedAt ?? this.calculatedAt,
      version: version ?? this.version,
      metricSources: metricSources ?? this.metricSources,
    );
  }

  SkillCategory? get categoryEnum {
    try {
      return SkillCategory.values.firstWhere(
        (e) => e.name == category,
      );
    } catch (_) {
      return null;
    }
  }

  String get scoreLabel => SkillScoreRange.getCategoryLabel(score.round());

  bool get hasSufficientConfidence => confidence >= 70.0;

  double get displayScore => score.clamp(0, 100);
  double get displayConfidence => confidence.clamp(0, 100);
}

class SkillState {
  final List<PlayerSkill> skills;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const SkillState({
    this.skills = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  SkillState copyWith({
    List<PlayerSkill>? skills,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return SkillState(
      skills: skills ?? this.skills,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  PlayerSkill? getSkillByCategory(String category) {
    try {
      return skills.firstWhere((s) => s.category == category);
    } catch (_) {
      return null;
    }
  }

  List<PlayerSkill> get topSkills {
    final sorted = List<PlayerSkill>.from(skills);
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted.take(5).toList();
  }

  List<PlayerSkill> get skillsNeedingImprovement {
    return skills.where((s) => s.score < 70 && s.hasSufficientConfidence).toList();
  }

  double get overallSkillLevel {
    if (skills.isEmpty) return 0;
    final highConfidence = skills.where((s) => s.hasSufficientConfidence).toList();
    if (highConfidence.isEmpty) return 0;
    return highConfidence.map((s) => s.score).reduce((a, b) => a + b) / highConfidence.length;
  }
}
