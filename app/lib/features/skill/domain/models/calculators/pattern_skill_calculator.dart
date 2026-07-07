import '../skill_calculator.dart';

class PatternSkillCalculator extends BaseSkillCalculator {
  PatternSkillCalculator() : super(
    'pattern',
    {
      'run_out_percent': 2.0,
      'avg_balls_per_rack': 2.5,
      'natural_route': 1.5,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final runOut = metrics['run_out_percent'] ?? 0.0;
    final avgBalls = metrics['avg_balls_per_rack'] ?? 0.0;
    final naturalRoute = metrics['natural_route'] ?? 0.0;

    const runOutWeight = 0.40;
    const ballsWeight = 0.35;
    const naturalWeight = 0.25;

    final normalizedBalls = normalizeToScore(avgBalls, 1, 8);
    final score = (runOut * runOutWeight) +
        (normalizedBalls * ballsWeight) +
        (naturalRoute * naturalWeight);

    return normalizeToScore(score, 20, 85);
  }
}
