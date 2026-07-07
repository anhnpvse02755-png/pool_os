import '../skill_calculator.dart';

class SafetySkillCalculator extends BaseSkillCalculator {
  SafetySkillCalculator() : super(
    'safety',
    {
      'safety_success_percent': 3.0,
      'recovery_percent': 2.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final safetySuccess = metrics['safety_success_percent'] ?? 0.0;
    final recovery = metrics['recovery_percent'] ?? 0.0;

    const safetyWeight = 0.55;
    const recoveryWeight = 0.45;

    final score = (safetySuccess * safetyWeight) + (recovery * recoveryWeight);

    return normalizeToScore(score, 30, 90);
  }
}
