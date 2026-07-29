// EPIC 02 — Statistics & Analytics — Phase 2: domain model.
//
// Aggregated snapshots produced by the Phase 3 aggregators. Each
// snapshot is a value-typed tuple optimised for direct rendering by
// the dashboard. The model never owns raw events — those live in the
// existing projections / repositories.

import 'analytics_period.dart';

class MatchStatisticsSnapshot {
  const MatchStatisticsSnapshot({
    required this.period,
    required this.totalMatches,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.loseRate,
    required this.winRate,
    required this.averageRacks,
    required this.averageMatchDuration,
    required this.longestMatch,
    required this.currentStreak,
    required this.highestWinStreak,
    required this.raceDistribution,
    required this.matchTypeDistribution,
    required this.gameTypeDistribution,
    required this.distribution,
    required this.trend,
    required this.recentMatchIds,
  });

  final AnalyticsPeriod period;
  final int totalMatches;
  final int wins;
  final int losses;
  final int draws;
  final double loseRate;
  final double winRate;
  final double averageRacks;
  final Duration averageMatchDuration;
  final Duration longestMatch;
  final int currentStreak;
  final int highestWinStreak;
  final Map<String, int> raceDistribution;
  final Map<String, int> matchTypeDistribution;
  final Map<String, int> gameTypeDistribution;
  final Map<String, int> distribution;
  final TrendSummary trend;
  final List<String> recentMatchIds;

  static MatchStatisticsSnapshot empty(AnalyticsPeriod period) =>
      MatchStatisticsSnapshot(
        period: period,
        totalMatches: 0,
        wins: 0,
        losses: 0,
        draws: 0,
        loseRate: 0,
        winRate: 0,
        averageRacks: 0,
        averageMatchDuration: Duration.zero,
        longestMatch: Duration.zero,
        currentStreak: 0,
        highestWinStreak: 0,
        raceDistribution: const {},
        matchTypeDistribution: const {},
        gameTypeDistribution: const {},
        distribution: const {},
        trend: TrendSummary.empty(),
        recentMatchIds: const [],
      );
}

class EquipmentStatisticsSnapshot {
  const EquipmentStatisticsSnapshot({
    required this.period,
    required this.usageFrequency,
    required this.winRateByEquipment,
    required this.trainingSuccessByEquipment,
    required this.matchSuccessByEquipment,
    required this.lastUsedByEquipment,
    required this.averageMatchLengthByEquipment,
    required this.totalHoursByEquipment,
    required this.ranked,
  });

  final AnalyticsPeriod period;
  final Map<String, int> usageFrequency;
  final Map<String, double> winRateByEquipment;
  final Map<String, double> trainingSuccessByEquipment;
  final Map<String, double> matchSuccessByEquipment;
  final Map<String, DateTime> lastUsedByEquipment;
  final Map<String, Duration> averageMatchLengthByEquipment;
  final Map<String, Duration> totalHoursByEquipment;
  final List<EquipmentRankingEntry> ranked;

  static EquipmentStatisticsSnapshot empty(AnalyticsPeriod period) =>
      EquipmentStatisticsSnapshot(
        period: period,
        usageFrequency: const {},
        winRateByEquipment: const {},
        trainingSuccessByEquipment: const {},
        matchSuccessByEquipment: const {},
        lastUsedByEquipment: const {},
        averageMatchLengthByEquipment: const {},
        totalHoursByEquipment: const {},
        ranked: const [],
      );
}

class EquipmentRankingEntry {
  const EquipmentRankingEntry({
    required this.equipmentId,
    required this.usageCount,
    required this.score,
    required this.matchCount,
    required this.winRate,
    required this.lastUsed,
    required this.totalHours,
  });
  final String equipmentId;
  final int usageCount;
  final double score;
  final int matchCount;
  final double winRate;
  final DateTime? lastUsed;
  final Duration totalHours;
}

class PlayerStatisticsSnapshot {
  const PlayerStatisticsSnapshot({
    required this.period,
    required this.matchCount,
    required this.wins,
    required this.losses,
    required this.winRate,
    required this.averageMatchDuration,
    required this.bestWinStreak,
    required this.headToHead,
    required this.opponentHistory,
    required this.recentActivity,
    required this.performanceTrend,
  });

  final AnalyticsPeriod period;
  final int matchCount;
  final int wins;
  final int losses;
  final double winRate;
  final Duration averageMatchDuration;
  final int bestWinStreak;
  final Map<String, HeadToHeadSummary> headToHead;
  final Map<String, int> opponentHistory;
  final List<PlayerActivityEntry> recentActivity;
  final TrendSummary performanceTrend;

  static PlayerStatisticsSnapshot empty(AnalyticsPeriod period) =>
      PlayerStatisticsSnapshot(
        period: period,
        matchCount: 0,
        wins: 0,
        losses: 0,
        winRate: 0,
        averageMatchDuration: Duration.zero,
        bestWinStreak: 0,
        headToHead: const {},
        opponentHistory: const {},
        recentActivity: const [],
        performanceTrend: TrendSummary.empty(),
      );
}

class HeadToHeadSummary {
  const HeadToHeadSummary({
    required this.opponent,
    required this.matches,
    required this.wins,
    required this.losses,
    required this.winRate,
  });

  final String opponent;
  final int matches;
  final int wins;
  final int losses;
  final double winRate;
}

class PlayerActivityEntry {
  const PlayerActivityEntry({
    required this.date,
    required this.kind,
    required this.title,
  });
  final DateTime date;
  final String kind;
  final String title;
}

class SessionStatisticsSnapshot {
  const SessionStatisticsSnapshot({
    required this.period,
    required this.totalSessions,
    required this.totalDuration,
    required this.averageDuration,
    required this.trainingVolume,
    required this.matchVolume,
    required this.weeklySessions,
    required this.monthlySessions,
    required this.successRate,
    required this.drillDistribution,
    required this.history,
  });

  final AnalyticsPeriod period;
  final int totalSessions;
  final Duration totalDuration;
  final Duration averageDuration;
  final int trainingVolume;
  final int matchVolume;
  final int weeklySessions;
  final int monthlySessions;
  final double successRate;
  final Map<String, int> drillDistribution;
  final List<SessionHistoryEntry> history;

  static SessionStatisticsSnapshot empty(AnalyticsPeriod period) =>
      SessionStatisticsSnapshot(
        period: period,
        totalSessions: 0,
        totalDuration: Duration.zero,
        averageDuration: Duration.zero,
        trainingVolume: 0,
        matchVolume: 0,
        weeklySessions: 0,
        monthlySessions: 0,
        successRate: 0,
        drillDistribution: const {},
        history: const [],
      );
}

class SessionHistoryEntry {
  const SessionHistoryEntry({
    required this.sessionId,
    required this.startedAt,
    required this.duration,
    required this.trainingVolume,
    required this.matchVolume,
  });
  final String sessionId;
  final DateTime startedAt;
  final Duration duration;
  final int trainingVolume;
  final int matchVolume;
}

class DashboardSnapshot {
  const DashboardSnapshot({
    required this.period,
    required this.totalMatches,
    required this.winRate,
    required this.totalSessions,
    required this.totalHours,
    required this.totalPlayers,
    required this.totalEquipmentUsed,
    required this.activeEquipment,
    required this.recentPerformance,
    required this.recentActivity,
    required this.trend,
  });

  final AnalyticsPeriod period;
  final int totalMatches;
  final double winRate;
  final int totalSessions;
  final Duration totalHours;
  final int totalPlayers;
  final int totalEquipmentUsed;
  final int activeEquipment;
  final TrendSummary recentPerformance;
  final List<DashboardActivityEntry> recentActivity;
  final TrendSummary trend;

  static DashboardSnapshot empty(AnalyticsPeriod period) => DashboardSnapshot(
        period: period,
        totalMatches: 0,
        winRate: 0,
        totalSessions: 0,
        totalHours: Duration.zero,
        totalPlayers: 0,
        totalEquipmentUsed: 0,
        activeEquipment: 0,
        recentPerformance: TrendSummary.empty(),
        recentActivity: const [],
        trend: TrendSummary.empty(),
      );
}

class DashboardActivityEntry {
  const DashboardActivityEntry({
    required this.date,
    required this.title,
    required this.subtitle,
  });
  final DateTime date;
  final String title;
  final String subtitle;
}

class PerformanceIndicators {
  const PerformanceIndicators({
    required this.improvement,
    required this.decline,
    required this.consistency,
    required this.activity,
    required this.utilization,
  });

  /// `improvement` is the positive trend of win rate over the period.
  /// Range [0, 1]. Higher is better.
  final double improvement;

  /// `decline` is the negative trend of win rate over the period.
  /// Range [0, 1]. Higher is worse.
  final double decline;

  /// `consistency` is a low-variance signal — 1.0 means the win-rate
  /// oscillates very little, 0.0 means peak variance.
  final double consistency;

  /// `activity` is the fraction of days in the period with at least
  /// one logged action. Range [0, 1].
  final double activity;

  /// `utilization` is the ratio of distinct equipment used by the
  /// active player to the number of equipment items the player owns.
  /// Range [0, 1].
  final double utilization;

  static PerformanceIndicators empty() => const PerformanceIndicators(
        improvement: 0,
        decline: 0,
        consistency: 0,
        activity: 0,
        utilization: 0,
      );
}