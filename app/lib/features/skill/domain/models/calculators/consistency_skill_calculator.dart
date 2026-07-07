import '../skill_calculator.dart';

class ConsistencySkillCalculator extends BaseSkillCalculator {
  ConsistencySkillCalculator() : super(
    'consistency',
    {
      'consistency_score': 2.5,
      'run_out_percent': 2.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final consistency = metrics['consistency_score'] ?? 0.0;
    final runOut = metrics['run_out_percent'] ?? 0.0;

    const consistencyWeight = 0.55;
    const runOutWeight = 0.45;

    final score = (consistency * consistencyWeight) + (runOut * runOutWeight);

    return normalizeToScore(score, 35, 90);
  }

  @override
  double calculateConfidence(int sampleSize) {
    if (sampleSize < 100) return 25.0;
    if (sampleSize < 300) return 50.0;
    if (sampleSize < 500) return 70.0;
    if (sampleSize < 1000) return 85.0;
    return 95.0;
  }
}
