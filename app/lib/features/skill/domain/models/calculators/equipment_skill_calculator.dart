import '../skill_calculator.dart';

class EquipmentSkillCalculator extends BaseSkillCalculator {
  EquipmentSkillCalculator() : super(
    'equipment',
    {
      'equipment_adaptation': 2.5,
      'avg_confidence': 2.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final adaptation = metrics['equipment_adaptation'] ?? 0.0;
    final confidence = metrics['avg_confidence'] ?? 0.0;

    const adaptationWeight = 0.60;
    const confidenceWeight = 0.40;

    final score = (adaptation * adaptationWeight) + (confidence * confidenceWeight);

    return normalizeToScore(score, 40, 95);
  }

  @override
  double calculateConfidence(int sampleSize) {
    if (sampleSize < 30) return 15.0;
    if (sampleSize < 100) return 40.0;
    if (sampleSize < 300) return 65.0;
    return 85.0;
  }
}
