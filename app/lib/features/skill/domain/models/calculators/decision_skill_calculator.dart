import '../skill_calculator.dart';

class DecisionSkillCalculator extends BaseSkillCalculator {
  DecisionSkillCalculator() : super(
    'decision',
    {
      'decision_accuracy_percent': 3.0,
      'safety_success_percent': 2.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final decisionAccuracy = metrics['decision_accuracy_percent'] ?? 0.0;
    final safetySuccess = metrics['safety_success_percent'] ?? 0.0;

    const decisionWeight = 0.55;
    const safetyWeight = 0.45;

    final score = (decisionAccuracy * decisionWeight) + (safetySuccess * safetyWeight);

    return normalizeToScore(score, 35, 95);
  }
}
