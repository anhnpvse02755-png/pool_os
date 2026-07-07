class SkillStat {
  final String skill;
  final double value;
  final double? trend;
  final int? sampleSize;

  const SkillStat({
    required this.skill,
    required this.value,
    this.trend,
    this.sampleSize,
  });
}

class SessionSummary {
  final int rackCount;
  final int winCount;
  final int shotCount;
  final int madeCount;
  final int durationSeconds;

  const SessionSummary({
    required this.rackCount,
    required this.winCount,
    required this.shotCount,
    required this.madeCount,
    required this.durationSeconds,
  });

  double get winRate => rackCount > 0 ? winCount / rackCount : 0.0;
  double get shotAccuracy => shotCount > 0 ? madeCount / shotCount : 0.0;
}

class CareerStats {
  final int totalSessions;
  final int totalRacks;
  final int totalShots;
  final int totalWins;
  final int totalLosses;
  final int totalMade;
  final int totalEvents;
  final double accuracy;
  final double winRate;

  const CareerStats({
    required this.totalSessions,
    required this.totalRacks,
    required this.totalShots,
    required this.totalWins,
    required this.totalLosses,
    required this.totalMade,
    required this.totalEvents,
    required this.accuracy,
    required this.winRate,
  });
}

class EventBasedStats {
  final int totalEvents;
  final Map<String, int> categoryStats;
  final Map<String, int> typeStats;
  final Map<String, int> severityStats;
  final double strokeEventRate;
  final double positionEventRate;
  final double decisionEventRate;
  final double mentalEventRate;
  final int shotsWithEvents;
  final int shotsWithoutEvents;

  const EventBasedStats({
    required this.totalEvents,
    required this.categoryStats,
    required this.typeStats,
    required this.severityStats,
    required this.strokeEventRate,
    required this.positionEventRate,
    required this.decisionEventRate,
    required this.mentalEventRate,
    required this.shotsWithEvents,
    required this.shotsWithoutEvents,
  });

  factory EventBasedStats.empty() {
    return const EventBasedStats(
      totalEvents: 0,
      categoryStats: {},
      typeStats: {},
      severityStats: {},
      strokeEventRate: 0.0,
      positionEventRate: 0.0,
      decisionEventRate: 0.0,
      mentalEventRate: 0.0,
      shotsWithEvents: 0,
      shotsWithoutEvents: 0,
    );
  }

  double get shotEventCoverage {
    final total = shotsWithEvents + shotsWithoutEvents;
    return total > 0 ? shotsWithEvents / total : 0.0;
  }
}

class MatchSummary {
  final int matchId;
  final int rackCount;
  final int winCount;
  final int shotCount;
  final int madeCount;

  const MatchSummary({
    required this.matchId,
    required this.rackCount,
    required this.winCount,
    required this.shotCount,
    required this.madeCount,
  });

  double get winRate => rackCount > 0 ? winCount / rackCount : 0.0;
  double get shotRate => shotCount > 0 ? madeCount / shotCount : 0.0;
}
