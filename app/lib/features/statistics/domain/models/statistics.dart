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

// FIX-009A: Win Rate Detail Models
class WinRateDetail {
  final int totalMatches;
  final int wonMatches;
  final int lostMatches;
  final List<MatchRecord> matchHistory;

  const WinRateDetail({
    required this.totalMatches,
    required this.wonMatches,
    required this.lostMatches,
    required this.matchHistory,
  });

  double get winRate => totalMatches > 0 ? wonMatches / totalMatches : 0.0;
  double get lossRate => totalMatches > 0 ? lostMatches / totalMatches : 0.0;

  factory WinRateDetail.empty() => const WinRateDetail(
        totalMatches: 0,
        wonMatches: 0,
        lostMatches: 0,
        matchHistory: [],
      );
}

class MatchRecord {
  final int matchId;
  final DateTime date;
  final String? opponent;
  final String matchType;
  final int wonRacks;
  final int lostRacks;
  final bool isWin;

  const MatchRecord({
    required this.matchId,
    required this.date,
    this.opponent,
    required this.matchType,
    required this.wonRacks,
    required this.lostRacks,
    required this.isWin,
  });

  String get score => '$wonRacks - $lostRacks';
}

// FIX-009A: Rack Detail Models
class RackDetail {
  final int totalRacks;
  final int wonRacks;
  final int lostRacks;
  final List<RackRecord> rackHistory;

  const RackDetail({
    required this.totalRacks,
    required this.wonRacks,
    required this.lostRacks,
    required this.rackHistory,
  });

  double get winRate => totalRacks > 0 ? wonRacks / totalRacks : 0.0;

  factory RackDetail.empty() => const RackDetail(
        totalRacks: 0,
        wonRacks: 0,
        lostRacks: 0,
        rackHistory: [],
      );
}

class RackRecord {
  final int rackId;
  final DateTime date;
  final bool won;
  final int ballsRun;
  final int largestRun;
  final int? confidence;
  final String? biggestMistake;
  final String? biggestStrength;

  const RackRecord({
    required this.rackId,
    required this.date,
    required this.won,
    required this.ballsRun,
    required this.largestRun,
    this.confidence,
    this.biggestMistake,
    this.biggestStrength,
  });
}

// FIX-009A: Shot Statistics Models
class ShotStatistics {
  final int totalShots;
  final int madeShots;
  final int missedShots;
  final List<ShotRecord> shotHistory;
  final Map<String, ShotTypeStats> byType;
  final Map<String, ShotDifficultyStats> byDifficulty;

  const ShotStatistics({
    required this.totalShots,
    required this.madeShots,
    required this.missedShots,
    required this.shotHistory,
    required this.byType,
    required this.byDifficulty,
  });

  double get accuracy => totalShots > 0 ? madeShots / totalShots : 0.0;

  factory ShotStatistics.empty() => const ShotStatistics(
        totalShots: 0,
        madeShots: 0,
        missedShots: 0,
        shotHistory: [],
        byType: {},
        byDifficulty: {},
      );
}

class ShotRecord {
  final int? shotId;
  final int rackId;
  final String shotType;
  final String difficulty;
  final bool isMade;
  final String? positionQuality;
  final String? decision;
  final String? confidence;

  const ShotRecord({
    this.shotId,
    required this.rackId,
    required this.shotType,
    required this.difficulty,
    required this.isMade,
    this.positionQuality,
    this.decision,
    this.confidence,
  });
}

class ShotTypeStats {
  final String type;
  final int attempts;
  final int made;

  const ShotTypeStats({
    required this.type,
    required this.attempts,
    required this.made,
  });

  double get successRate => attempts > 0 ? made / attempts : 0.0;
}

class ShotDifficultyStats {
  final String difficulty;
  final int attempts;
  final int made;

  const ShotDifficultyStats({
    required this.difficulty,
    required this.attempts,
    required this.made,
  });

  double get successRate => attempts > 0 ? made / attempts : 0.0;
}

// FIX-009A: Error Statistics Models
class ErrorStatistics {
  final int totalErrors;
  final Map<String, int> errorsByType;
  final List<ErrorRecord> errorHistory;

  const ErrorStatistics({
    required this.totalErrors,
    required this.errorsByType,
    required this.errorHistory,
  });

  factory ErrorStatistics.empty() => const ErrorStatistics(
        totalErrors: 0,
        errorsByType: {},
        errorHistory: [],
      );
}

class ErrorRecord {
  final int errorId;
  final int? shotId;
  final String errorType;
  final String category;
  final String? severity;
  final DateTime timestamp;

  const ErrorRecord({
    required this.errorId,
    this.shotId,
    required this.errorType,
    required this.category,
    this.severity,
    required this.timestamp,
  });
}

// FIX-009A: Break Statistics Models
class BreakStatistics {
  final int totalBreaks;
  final int successfulBreaks;
  final int dryBreaks;
  final int scratches;
  final double avgBallsPocketed;
  final List<BreakRecord> breakHistory;

  const BreakStatistics({
    required this.totalBreaks,
    required this.successfulBreaks,
    required this.dryBreaks,
    required this.scratches,
    required this.avgBallsPocketed,
    required this.breakHistory,
  });

  double get successRate => totalBreaks > 0 ? successfulBreaks / totalBreaks : 0.0;
  double get dryBreakRate => totalBreaks > 0 ? dryBreaks / totalBreaks : 0.0;
  double get scratchRate => totalBreaks > 0 ? scratches / totalBreaks : 0.0;

  factory BreakStatistics.empty() => const BreakStatistics(
        totalBreaks: 0,
        successfulBreaks: 0,
        dryBreaks: 0,
        scratches: 0,
        avgBallsPocketed: 0.0,
        breakHistory: [],
      );
}

class BreakRecord {
  final int? rackId;
  final DateTime date;
  final bool isSuccess;
  final bool isDryBreak;
  final bool isScratch;
  final int ballsPocketed;
  final int? largestRun;

  const BreakRecord({
    this.rackId,
    required this.date,
    required this.isSuccess,
    required this.isDryBreak,
    required this.isScratch,
    required this.ballsPocketed,
    this.largestRun,
  });
}
