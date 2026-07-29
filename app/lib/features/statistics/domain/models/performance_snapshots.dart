// EPIC 02 — Statistics & Analytics — Revision 4.
//
// Performance snapshot. Carries derived indicators that are
// computed once per period by `PerformanceCalculator`. Used by
// the dashboard tiles + the dedicated Performance section on the
// Statistics hub.

import 'analytics_period.dart';

class WinRateOverTimePoint {
  const WinRateOverTimePoint({required this.date, required this.winRate});
  final DateTime date;
  final double winRate;
}

class EquipmentEffectiveness {
  const EquipmentEffectiveness({
    required this.equipmentId,
    required this.usageCount,
    required this.winRate,
  });
  final String equipmentId;
  final int usageCount;
  final double winRate;
}

class PerformanceSnapshot {
  const PerformanceSnapshot({
    required this.period,
    required this.winRateOverTime,
    required this.equipmentEffectiveness,
    required this.improvementPct,
    required this.sessionEfficiency,
    required this.practiceVsMatchRatio,
    required this.hotStreak,
    required this.coldStreak,
    required this.consistency,
    required this.activity,
    required this.matchFrequency,
    required this.equipmentUsage,
    required this.playerActivity,
  });

  final AnalyticsPeriod period;
  final List<WinRateOverTimePoint> winRateOverTime;
  final List<EquipmentEffectiveness> equipmentEffectiveness;
  final double improvementPct;
  final double sessionEfficiency;
  final double practiceVsMatchRatio;
  final int hotStreak;
  final int coldStreak;
  final double consistency;
  final double activity;
  final double matchFrequency;
  final Map<String, int> equipmentUsage;
  final Map<String, int> playerActivity;

  static PerformanceSnapshot empty(AnalyticsPeriod period) =>
      PerformanceSnapshot(
        period: period,
        winRateOverTime: const [],
        equipmentEffectiveness: const [],
        improvementPct: 0,
        sessionEfficiency: 0,
        practiceVsMatchRatio: 0,
        hotStreak: 0,
        coldStreak: 0,
        consistency: 0,
        activity: 0,
        matchFrequency: 0,
        equipmentUsage: const {},
        playerActivity: const {},
      );
}
