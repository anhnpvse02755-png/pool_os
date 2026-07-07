import 'skill_category.dart';

abstract class SkillCalculator {
  String get category;

  Map<String, double> get requiredMetrics;

  SkillScore calculate(List<EventData> events, Map<String, double> metrics, int sampleSize);

  List<String> get metricSources => requiredMetrics.keys.toList();
}

class SkillScore {
  final double score;
  final double confidence;
  final String trend;
  final List<String> contributingMetrics;

  const SkillScore({
    required this.score,
    required this.confidence,
    required this.trend,
    required this.contributingMetrics,
  });
}

class EventData {
  final int shotId;
  final String category;
  final String type;
  final String? severity;
  final String? confidence;
  final String? metadataJson;
  final DateTime createdAt;

  const EventData({
    required this.shotId,
    required this.category,
    required this.type,
    this.severity,
    this.confidence,
    this.metadataJson,
    required this.createdAt,
  });
}

abstract class BaseSkillCalculator implements SkillCalculator {
  @override
  final String category;

  @override
  final Map<String, double> requiredMetrics;

  const BaseSkillCalculator(this.category, this.requiredMetrics);

  @override
  List<String> get metricSources => requiredMetrics.keys.toList();

  @override
  SkillScore calculate(List<EventData> events, Map<String, double> metrics, int sampleSize) {
    final score = calculateScore(metrics, sampleSize);
    final confidence = calculateConfidence(sampleSize);
    final trend = calculateTrend(metrics);
    final contributingMetrics = metrics.entries
        .where((e) => e.value > 0)
        .map((e) => e.key)
        .toList();

    return SkillScore(
      score: score,
      confidence: confidence,
      trend: trend,
      contributingMetrics: contributingMetrics,
    );
  }

  double calculateScore(Map<String, double> metrics, int sampleSize);

  double calculateConfidence(int sampleSize) {
    if (sampleSize < 50) return 20.0;
    if (sampleSize < 100) return 40.0;
    if (sampleSize < 200) return 60.0;
    if (sampleSize < 500) return 80.0;
    return 96.0;
  }

  String calculateTrend(Map<String, double> metrics) {
    if (metrics.isEmpty) return SkillTrend.unknown;
    return SkillTrend.stable;
  }

  double normalizeToScore(double value, double min, double max) {
    if (max == min) return 50.0;
    final normalized = ((value - min) / (max - min)) * 100;
    return normalized.clamp(0.0, 100.0);
  }
}
