import '../skill_calculator.dart';

class BreakSkillCalculator extends BaseSkillCalculator {
  BreakSkillCalculator() : super(
    'breakShot',
    {
      'break_success_percent': 3.0,
      'avg_balls_per_rack': 2.0,
      'scratch_percent': 1.5,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final breakSuccess = metrics['break_success_percent'] ?? 0.0;
    final avgBalls = metrics['avg_balls_per_rack'] ?? 0.0;
    final scratchRate = metrics['scratch_percent'] ?? 0.0;

    const breakWeight = 0.50;
    const ballsWeight = 0.30;
    const scratchWeight = 0.20;

    final normalizedBalls = normalizeToScore(avgBalls, 1, 5);
    final scratchPenalty = scratchRate * 25;

    final score = (breakSuccess * breakWeight) +
        (normalizedBalls * ballsWeight) +
        ((100 - scratchPenalty) * scratchWeight);

    return normalizeToScore(score, 25, 90);
  }
}
