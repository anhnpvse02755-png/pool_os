import '../skill_calculator.dart';
import '../skill_category.dart';

class StrokeSkillCalculator extends BaseSkillCalculator {
  StrokeSkillCalculator() : super(
    'stroke',
    {
      'stroke_hitch_rate': 1.0,
      'grip_tight_rate': 1.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final hitchRate = metrics['stroke_hitch_rate'] ?? 0.0;
    final gripTightRate = metrics['grip_tight_rate'] ?? 0.0;

    final hitchPenalty = hitchRate * 30;
    final gripPenalty = gripTightRate * 20;

    const baseScore = 85.0;
    final score = baseScore - hitchPenalty - gripPenalty;

    return normalizeToScore(score, 40, 95);
  }

  @override
  String calculateTrend(Map<String, double> metrics) {
    return SkillTrend.stable;
  }
}
