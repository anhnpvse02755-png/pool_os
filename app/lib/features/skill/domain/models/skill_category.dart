enum SkillCategory {
  stroke,
  position,
  decision,
  pattern,
  breakShot,
  safety,
  mental,
  consistency,
  equipment,
  recovery;

  String get displayKey {
    switch (this) {
      case SkillCategory.stroke:
        return 'skill_stroke';
      case SkillCategory.position:
        return 'skill_position';
      case SkillCategory.decision:
        return 'skill_decision';
      case SkillCategory.pattern:
        return 'skill_pattern';
      case SkillCategory.breakShot:
        return 'skill_break';
      case SkillCategory.safety:
        return 'skill_safety';
      case SkillCategory.mental:
        return 'skill_mental';
      case SkillCategory.consistency:
        return 'skill_consistency';
      case SkillCategory.equipment:
        return 'skill_equipment';
      case SkillCategory.recovery:
        return 'skill_recovery';
    }
  }

  String get descriptionKey {
    switch (this) {
      case SkillCategory.stroke:
        return 'skill_stroke_desc';
      case SkillCategory.position:
        return 'skill_position_desc';
      case SkillCategory.decision:
        return 'skill_decision_desc';
      case SkillCategory.pattern:
        return 'skill_pattern_desc';
      case SkillCategory.breakShot:
        return 'skill_break_desc';
      case SkillCategory.safety:
        return 'skill_safety_desc';
      case SkillCategory.mental:
        return 'skill_mental_desc';
      case SkillCategory.consistency:
        return 'skill_consistency_desc';
      case SkillCategory.equipment:
        return 'skill_equipment_desc';
      case SkillCategory.recovery:
        return 'skill_recovery_desc';
    }
  }

  List<String> get metricSources {
    switch (this) {
      case SkillCategory.stroke:
        return MetricType.strokeMetrics;
      case SkillCategory.position:
        return MetricType.positionMetrics;
      case SkillCategory.decision:
        return MetricType.decisionMetrics;
      case SkillCategory.pattern:
        return MetricType.patternMetrics;
      case SkillCategory.breakShot:
        return MetricType.breakMetrics;
      case SkillCategory.safety:
        return MetricType.safetyMetrics;
      case SkillCategory.mental:
        return MetricType.mentalMetrics;
      case SkillCategory.consistency:
        return MetricType.consistencyMetrics;
      case SkillCategory.equipment:
        return MetricType.equipmentMetrics;
      case SkillCategory.recovery:
        return MetricType.recoveryMetrics;
    }
  }
}

enum MetricType {
  naturalRoute('natural_route', 'Natural Route %'),
  avgPositionQuality('avg_position_quality', 'Average Position Quality'),
  scratchPercent('scratch_percent', 'Scratch %'),
  safetySuccessPercent('safety_success_percent', 'Safety Success %'),
  longPotPercent('long_pot_percent', 'Long Pot %'),
  thinCutPercent('thin_cut_percent', 'Thin Cut %'),
  breakSuccessPercent('break_success_percent', 'Break Success %'),
  runOutPercent('run_out_percent', 'Run Out %'),
  avgBallsPerRack('avg_balls_per_rack', 'Average Balls Per Rack'),
  avgConfidence('avg_confidence', 'Average Confidence'),
  recoveryPercent('recovery_percent', 'Recovery %'),
  decisionAccuracyPercent('decision_accuracy_percent', 'Decision Accuracy %'),
  strokeHitchRate('stroke_hitch_rate', 'Stroke Hitch Rate'),
  gripTightRate('grip_tight_rate', 'Grip Tight Rate'),
  pressureSuccessPercent('pressure_success_percent', 'Pressure Success %'),
  consistencyScore('consistency_score', 'Consistency Score'),
  equipmentAdaptation('equipment_adaptation', 'Equipment Adaptation');

  final String id;
  final String displayName;

  const MetricType(this.id, this.displayName);

  static List<String> get strokeMetrics => [
        MetricType.strokeHitchRate.id,
        MetricType.gripTightRate.id,
      ];

  static List<String> get positionMetrics => [
        MetricType.naturalRoute.id,
        MetricType.avgPositionQuality.id,
        MetricType.longPotPercent.id,
        MetricType.thinCutPercent.id,
      ];

  static List<String> get decisionMetrics => [
        MetricType.decisionAccuracyPercent.id,
        MetricType.safetySuccessPercent.id,
      ];

  static List<String> get patternMetrics => [
        MetricType.runOutPercent.id,
        MetricType.avgBallsPerRack.id,
        MetricType.naturalRoute.id,
      ];

  static List<String> get breakMetrics => [
        MetricType.breakSuccessPercent.id,
        MetricType.avgBallsPerRack.id,
        MetricType.scratchPercent.id,
      ];

  static List<String> get safetyMetrics => [
        MetricType.safetySuccessPercent.id,
        MetricType.recoveryPercent.id,
      ];

  static List<String> get mentalMetrics => [
        MetricType.pressureSuccessPercent.id,
        MetricType.avgConfidence.id,
      ];

  static List<String> get consistencyMetrics => [
        MetricType.consistencyScore.id,
        MetricType.runOutPercent.id,
      ];

  static List<String> get equipmentMetrics => [
        MetricType.equipmentAdaptation.id,
        MetricType.avgConfidence.id,
      ];

  static List<String> get recoveryMetrics => [
        MetricType.recoveryPercent.id,
        MetricType.decisionAccuracyPercent.id,
      ];
}

class SkillTrend {
  static const String improving = 'improving';
  static const String stable = 'stable';
  static const String declining = 'declining';
  static const String unknown = 'unknown';
}

class SkillScoreRange {
  static const int elite = 90;
  static const int excellent = 80;
  static const int advanced = 70;
  static const int intermediate = 60;
  static const int developing = 50;

  static String getCategoryLabel(int score) {
    if (score >= elite) return 'Elite';
    if (score >= excellent) return 'Excellent';
    if (score >= advanced) return 'Advanced';
    if (score >= intermediate) return 'Intermediate';
    if (score >= developing) return 'Developing';
    return 'Needs Improvement';
  }
}
