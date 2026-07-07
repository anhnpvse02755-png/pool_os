import '../skill_calculator.dart';

class MentalSkillCalculator extends BaseSkillCalculator {
  MentalSkillCalculator() : super(
    'mental',
    {
      'pressure_success_percent': 3.0,
      'avg_confidence': 2.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final pressureSuccess = metrics['pressure_success_percent'] ?? 0.0;
    final avgConfidence = metrics['avg_confidence'] ?? 0.0;

    const pressureWeight = 0.60;
    const confidenceWeight = 0.40;

    final score = (pressureSuccess * pressureWeight) + (avgConfidence * confidenceWeight);

    return normalizeToScore(score, 40, 95);
  }
}
