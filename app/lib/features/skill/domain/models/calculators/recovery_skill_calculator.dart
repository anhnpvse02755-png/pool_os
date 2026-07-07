import '../skill_calculator.dart';

class RecoverySkillCalculator extends BaseSkillCalculator {
  RecoverySkillCalculator() : super(
    'recovery',
    {
      'recovery_percent': 3.0,
      'decision_accuracy_percent': 2.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final recovery = metrics['recovery_percent'] ?? 0.0;
    final decision = metrics['decision_accuracy_percent'] ?? 0.0;

    const recoveryWeight = 0.55;
    const decisionWeight = 0.45;

    final score = (recovery * recoveryWeight) + (decision * decisionWeight);

    return normalizeToScore(score, 25, 85);
  }
}
