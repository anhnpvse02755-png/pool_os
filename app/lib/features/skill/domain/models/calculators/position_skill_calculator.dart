import '../skill_calculator.dart';

class PositionSkillCalculator extends BaseSkillCalculator {
  PositionSkillCalculator() : super(
    'position',
    {
      'natural_route': 2.0,
      'avg_position_quality': 3.0,
      'long_pot_percent': 1.5,
      'thin_cut_percent': 1.0,
    },
  );

  @override
  double calculateScore(Map<String, double> metrics, int sampleSize) {
    final naturalRoute = metrics['natural_route'] ?? 0.0;
    final avgPosition = metrics['avg_position_quality'] ?? 0.0;
    final longPot = metrics['long_pot_percent'] ?? 0.0;
    final thinCut = metrics['thin_cut_percent'] ?? 0.0;

    const naturalWeight = 0.35;
    const positionWeight = 0.30;
    const longPotWeight = 0.20;
    const thinCutWeight = 0.15;

    final score = (naturalRoute * naturalWeight) +
        (avgPosition * positionWeight) +
        (longPot * longPotWeight) +
        (thinCut * thinCutWeight);

    return normalizeToScore(score, 30, 90);
  }
}
