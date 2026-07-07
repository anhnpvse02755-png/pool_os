enum StatCategory {
  overall,
  breakPerformance,
  potting,
  position,
  safety,
  cueBallControl,
  mental,
  equipment,
  trend,
  training,
}

enum TrendDirection { improving, stable, declining }

class PlayerStatistic {
  final String id;
  final String name;
  final String nameVi;
  final StatCategory category;
  final double currentValue;
  final double previousValue;
  final double target;
  final List<double> history;
  final TrendDirection trend;
  final int sampleSize;
  final DateTime lastUpdated;

  const PlayerStatistic({
    required this.id,
    required this.name,
    required this.nameVi,
    required this.category,
    required this.currentValue,
    this.previousValue = 0,
    this.target = 100,
    this.history = const [],
    this.trend = TrendDirection.stable,
    this.sampleSize = 0,
    required this.lastUpdated,
  });

  double get trendPercentage {
    if (previousValue == 0) return 0;
    return ((currentValue - previousValue) / previousValue) * 100;
  }

  double get progressToTarget {
    if (target == 0) return 0;
    return (currentValue / target).clamp(0.0, 1.0);
  }

  bool get isImproving => trend == TrendDirection.improving;
  bool get isDeclining => trend == TrendDirection.declining;
  bool get isStable => trend == TrendDirection.stable;

  String get trendSymbol {
    switch (trend) {
      case TrendDirection.improving:
        return '↑';
      case TrendDirection.declining:
        return '↓';
      case TrendDirection.stable:
        return '→';
    }
  }
}

class StatisticsEngine {
  static TrendDirection calculateTrend(List<double> history) {
    if (history.length < 3) return TrendDirection.stable;

    final recentAvg = history.last;
    final olderAvg = history.first;
    final diff = recentAvg - olderAvg;

    if (diff > 3) return TrendDirection.improving;
    if (diff < -3) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  static List<PlayerStatistic> calculateAllStatistics({
    required OverallStats overall,
    required BreakStats breakStats,
    required PottingStats pottingStats,
    required PositionStats positionStats,
    required SafetyStats safetyStats,
    required CueBallControlStats cueBallStats,
    required MentalStats mentalStats,
    required EquipmentStats equipmentStats,
  }) {
    return [
      ...calculateOverallStats(overall),
      ...calculateBreakStats(breakStats),
      ...calculatePottingStats(pottingStats),
      ...calculatePositionStats(positionStats),
      ...calculateSafetyStats(safetyStats),
      ...calculateCueBallStats(cueBallStats),
      ...calculateMentalStats(mentalStats),
      ...calculateEquipmentStats(equipmentStats),
    ];
  }

  static List<PlayerStatistic> calculateOverallStats(OverallStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'total_sessions',
        name: 'Total Sessions',
        nameVi: 'Tổng Buổi',
        category: StatCategory.overall,
        currentValue: stats.totalSessions.toDouble(),
        previousValue: stats.previousSessions.toDouble(),
        target: 100,
        history: stats.sessionsHistory,
        trend: calculateTrend(stats.sessionsHistory),
        sampleSize: stats.totalSessions,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'matches_played',
        name: 'Matches Played',
        nameVi: 'Trận Đã Đấu',
        category: StatCategory.overall,
        currentValue: stats.matchesPlayed.toDouble(),
        previousValue: stats.previousMatches.toDouble(),
        target: 200,
        history: stats.matchesHistory,
        trend: calculateTrend(stats.matchesHistory),
        sampleSize: stats.matchesPlayed,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'rack_won',
        name: 'Racks Won',
        nameVi: 'Ván Thắng',
        category: StatCategory.overall,
        currentValue: stats.racksWon.toDouble(),
        previousValue: stats.previousRacksWon.toDouble(),
        target: 1000,
        history: stats.rackWinHistory,
        trend: calculateTrend(stats.rackWinHistory),
        sampleSize: stats.racksWon + stats.racksLost,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'rack_lost',
        name: 'Racks Lost',
        nameVi: 'Ván Thua',
        category: StatCategory.overall,
        currentValue: stats.racksLost.toDouble(),
        target: 0,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.racksWon + stats.racksLost,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'win_rate',
        name: 'Win Rate',
        nameVi: 'Tỷ Lệ Thắng',
        category: StatCategory.overall,
        currentValue: stats.winRate * 100,
        previousValue: stats.previousWinRate * 100,
        target: 70,
        history: stats.winRateHistory.map((r) => r * 100).toList(),
        trend: calculateTrend(stats.winRateHistory.map((r) => r * 100).toList()),
        sampleSize: stats.racksWon + stats.racksLost,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'longest_run',
        name: 'Longest Run',
        nameVi: 'Chuỗi Dài Nhất',
        category: StatCategory.overall,
        currentValue: stats.longestRun.toDouble(),
        target: 15,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: 1,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'current_streak',
        name: 'Current Streak',
        nameVi: 'Chuỗi Hiện Tại',
        category: StatCategory.overall,
        currentValue: stats.currentStreak.toDouble(),
        target: 10,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: 1,
        lastUpdated: now,
      ),
    ];
  }

  static List<PlayerStatistic> calculateBreakStats(BreakStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'break_attempts',
        name: 'Break Attempts',
        nameVi: 'Số Lần Phá',
        category: StatCategory.breakPerformance,
        currentValue: stats.breakAttempts.toDouble(),
        target: 500,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.breakAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'break_success',
        name: 'Break Success Rate',
        nameVi: 'Tỷ Lệ Phá Thành Công',
        category: StatCategory.breakPerformance,
        currentValue: stats.breakSuccessRate * 100,
        previousValue: stats.previousBreakSuccessRate * 100,
        target: 50,
        history: stats.breakSuccessHistory.map((r) => r * 100).toList(),
        trend: calculateTrend(stats.breakSuccessHistory.map((r) => r * 100).toList()),
        sampleSize: stats.breakAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'dry_break',
        name: 'Dry Break Rate',
        nameVi: 'Tỷ Lệ Phá Khô',
        category: StatCategory.breakPerformance,
        currentValue: stats.dryBreakRate * 100,
        target: 20,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.breakAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'scratch_on_break',
        name: 'Scratch On Break',
        nameVi: 'Cấn Bi Khi Phá',
        category: StatCategory.breakPerformance,
        currentValue: stats.scratchOnBreakRate * 100,
        target: 5,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.breakAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'break_and_run',
        name: 'Break & Run',
        nameVi: 'Phá & Chạy',
        category: StatCategory.breakPerformance,
        currentValue: stats.breakAndRun.toDouble(),
        target: 50,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.breakAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'avg_balls_after_break',
        name: 'Avg Balls After Break',
        nameVi: 'TB Bi Sau Phá',
        category: StatCategory.breakPerformance,
        currentValue: stats.avgBallsAfterBreak,
        target: 4,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.breakAttempts,
        lastUpdated: now,
      ),
    ];
  }

  static List<PlayerStatistic> calculatePottingStats(PottingStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'pot_success',
        name: 'Pot Success Rate',
        nameVi: 'Tỷ Lệ Đánh Trúng',
        category: StatCategory.potting,
        currentValue: stats.potSuccessRate * 100,
        previousValue: stats.previousPotSuccessRate * 100,
        target: 80,
        history: stats.potSuccessHistory.map((r) => r * 100).toList(),
        trend: calculateTrend(stats.potSuccessHistory.map((r) => r * 100).toList()),
        sampleSize: stats.totalPots,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'long_pot',
        name: 'Long Pot Success',
        nameVi: 'Đánh Bi Xa',
        category: StatCategory.potting,
        currentValue: stats.longPotSuccessRate * 100,
        previousValue: stats.previousLongPotRate * 100,
        target: 55,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.longPotAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'thin_cut',
        name: 'Thin Cut Success',
        nameVi: 'Cắt Mỏng',
        category: StatCategory.potting,
        currentValue: stats.thinCutSuccessRate * 100,
        previousValue: stats.previousThinCutRate * 100,
        target: 60,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.thinCutAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'straight_shot',
        name: 'Straight Shot Rate',
        nameVi: 'Đánh Thẳng',
        category: StatCategory.potting,
        currentValue: stats.straightShotRate * 100,
        target: 95,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.straightShotAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'bank_success',
        name: 'Bank Success Rate',
        nameVi: 'Tỷ Lệ Ghiên',
        category: StatCategory.potting,
        currentValue: stats.bankSuccessRate * 100,
        previousValue: stats.previousBankRate * 100,
        target: 40,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.bankAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'kick_success',
        name: 'Kick Success Rate',
        nameVi: 'Tỷ Lệ Đá',
        category: StatCategory.potting,
        currentValue: stats.kickSuccessRate * 100,
        previousValue: stats.previousKickRate * 100,
        target: 50,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.kickAttempts,
        lastUpdated: now,
      ),
    ];
  }

  static List<PlayerStatistic> calculatePositionStats(PositionStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'position_success',
        name: 'Position Success',
        nameVi: 'Điều Bi Thành Công',
        category: StatCategory.position,
        currentValue: stats.positionSuccessRate * 100,
        previousValue: stats.previousPositionRate * 100,
        target: 75,
        history: stats.positionHistory.map((r) => r * 100).toList(),
        trend: calculateTrend(stats.positionHistory.map((r) => r * 100).toList()),
        sampleSize: stats.positionAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'position_too_long',
        name: 'Position Too Long',
        nameVi: 'Điều Bi Quá Xa',
        category: StatCategory.position,
        currentValue: stats.positionTooLongRate * 100,
        target: 10,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.positionAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'position_too_short',
        name: 'Position Too Short',
        nameVi: 'Điều Bi Quá Gần',
        category: StatCategory.position,
        currentValue: stats.positionTooShortRate * 100,
        target: 10,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.positionAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'wrong_angle',
        name: 'Wrong Angle',
        nameVi: 'Sai Góc',
        category: StatCategory.position,
        currentValue: stats.wrongAngleRate * 100,
        target: 5,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.positionAttempts,
        lastUpdated: now,
      ),
    ];
  }

  static List<PlayerStatistic> calculateSafetyStats(SafetyStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'safety_attempts',
        name: 'Safety Attempts',
        nameVi: 'Số Lần An Toàn',
        category: StatCategory.safety,
        currentValue: stats.safetyAttempts.toDouble(),
        target: 200,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.safetyAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'safety_success',
        name: 'Safety Success Rate',
        nameVi: 'Tỷ Lệ An Toàn',
        category: StatCategory.safety,
        currentValue: stats.safetySuccessRate * 100,
        previousValue: stats.previousSafetyRate * 100,
        target: 60,
        history: stats.safetyHistory.map((r) => r * 100).toList(),
        trend: calculateTrend(stats.safetyHistory.map((r) => r * 100).toList()),
        sampleSize: stats.safetyAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'kick_escape',
        name: 'Kick Escape Rate',
        nameVi: 'Tỷ Lệ Thoát Đá',
        category: StatCategory.safety,
        currentValue: stats.kickEscapeRate * 100,
        target: 40,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.safetyAttempts,
        lastUpdated: now,
      ),
    ];
  }

  static List<PlayerStatistic> calculateCueBallStats(CueBallControlStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'scratch_rate',
        name: 'Scratch Rate',
        nameVi: 'Tỷ Lệ Cấn Bi',
        category: StatCategory.cueBallControl,
        currentValue: stats.scratchRate * 100,
        previousValue: stats.previousScratchRate * 100,
        target: 5,
        history: stats.scratchHistory.map((r) => r * 100).toList(),
        trend: calculateTrend(stats.scratchHistory.map((r) => r * 100).toList()),
        sampleSize: stats.totalShots,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'draw_success',
        name: 'Draw Success Rate',
        nameVi: 'Tỷ Lệ Draw',
        category: StatCategory.cueBallControl,
        currentValue: stats.drawSuccessRate * 100,
        target: 80,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.drawAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'follow_success',
        name: 'Follow Success Rate',
        nameVi: 'Tỷ Lệ Follow',
        category: StatCategory.cueBallControl,
        currentValue: stats.followSuccessRate * 100,
        target: 85,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.followAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'stop_shot',
        name: 'Stop Shot Rate',
        nameVi: 'Tỷ Lệ Stop Shot',
        category: StatCategory.cueBallControl,
        currentValue: stats.stopShotRate * 100,
        target: 90,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.stopShotAttempts,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'speed_control',
        name: 'Speed Control',
        nameVi: 'Kiểm Soát Tốc Độ',
        category: StatCategory.cueBallControl,
        currentValue: stats.speedControlRating * 100,
        target: 80,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.totalShots,
        lastUpdated: now,
      ),
    ];
  }

  static List<PlayerStatistic> calculateMentalStats(MentalStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'avg_confidence',
        name: 'Average Confidence',
        nameVi: 'Mức Tự Tin TB',
        category: StatCategory.mental,
        currentValue: stats.avgConfidence * 10,
        previousValue: stats.previousConfidence * 10,
        target: 8,
        history: stats.confidenceHistory.map((r) => r * 10).toList(),
        trend: calculateTrend(stats.confidenceHistory.map((r) => r * 10).toList()),
        sampleSize: stats.sampleCount,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'pressure_win',
        name: 'Pressure Win Rate',
        nameVi: 'Tỷ Lệ Thắng Áp Lực',
        category: StatCategory.mental,
        currentValue: stats.pressureWinRate * 100,
        target: 50,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.pressureRacks,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'hill_hill_win',
        name: 'Hill-Hill Win Rate',
        nameVi: 'Tỷ Lệ Thắng Hill-Hill',
        category: StatCategory.mental,
        currentValue: stats.hillHillWinRate * 100,
        target: 50,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.hillHillRacks,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'recovery_after_miss',
        name: 'Recovery After Miss',
        nameVi: 'Phục Hồi Sau Miss',
        category: StatCategory.mental,
        currentValue: stats.recoveryAfterMissRate * 100,
        target: 70,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.missCount,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'rush_events',
        name: 'Rush Events',
        nameVi: 'Sự Kiện Vội Vàng',
        category: StatCategory.mental,
        currentValue: stats.rushEvents.toDouble(),
        target: 0,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.sampleCount,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'tilt_events',
        name: 'Tilt Events',
        nameVi: 'Sự Kiện Mất Kiểm Soát',
        category: StatCategory.mental,
        currentValue: stats.tiltEvents.toDouble(),
        target: 0,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: stats.sampleCount,
        lastUpdated: now,
      ),
    ];
  }

  static List<PlayerStatistic> calculateEquipmentStats(EquipmentStats stats) {
    final now = DateTime.now();
    return [
      PlayerStatistic(
        id: 'tip_usage_hours',
        name: 'Tip Usage Hours',
        nameVi: 'Giờ Sử Dụng Đầu Cơ',
        category: StatCategory.equipment,
        currentValue: stats.tipUsageHours,
        target: 150,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: 1,
        lastUpdated: now,
      ),
      PlayerStatistic(
        id: 'cue_usage_hours',
        name: 'Cue Usage Hours',
        nameVi: 'Giờ Sử Dụng Cơ',
        category: StatCategory.equipment,
        currentValue: stats.cueUsageHours,
        target: 500,
        history: const [],
        trend: TrendDirection.stable,
        sampleSize: 1,
        lastUpdated: now,
      ),
    ];
  }

  static Map<String, double> toRuleEngineFormat(List<PlayerStatistic> stats) {
    final map = <String, double>{};
    for (final stat in stats) {
      switch (stat.id) {
        case 'win_rate':
          map['winRate'] = stat.currentValue;
          break;
        case 'break_success':
          map['breakSuccess'] = stat.currentValue;
          break;
        case 'pot_success':
          map['potting'] = stat.currentValue;
          break;
        case 'long_pot':
          map['longPot'] = stat.currentValue;
          break;
        case 'thin_cut':
          map['thinCut'] = stat.currentValue;
          break;
        case 'position_success':
          map['position'] = stat.currentValue;
          break;
        case 'safety_success':
          map['safetySuccess'] = stat.currentValue;
          break;
        case 'bank_success':
          map['bankSuccess'] = stat.currentValue;
          break;
        case 'kick_success':
          map['kickSuccess'] = stat.currentValue;
          break;
        case 'scratch_rate':
          map['scratchRate'] = stat.currentValue;
          break;
        case 'hill_hill_win':
          map['hillHillWin'] = stat.currentValue;
          break;
      }
    }
    return map;
  }
}

class OverallStats {
  final int totalSessions;
  final int previousSessions;
  final int matchesPlayed;
  final int previousMatches;
  final int racksWon;
  final int previousRacksWon;
  final int racksLost;
  final int longestRun;
  final int currentStreak;
  final double winRate;
  final double previousWinRate;
  final List<double> sessionsHistory;
  final List<double> matchesHistory;
  final List<double> rackWinHistory;
  final List<double> winRateHistory;

  const OverallStats({
    this.totalSessions = 0,
    this.previousSessions = 0,
    this.matchesPlayed = 0,
    this.previousMatches = 0,
    this.racksWon = 0,
    this.previousRacksWon = 0,
    this.racksLost = 0,
    this.longestRun = 0,
    this.currentStreak = 0,
    this.winRate = 0,
    this.previousWinRate = 0,
    this.sessionsHistory = const [],
    this.matchesHistory = const [],
    this.rackWinHistory = const [],
    this.winRateHistory = const [],
  });
}

class BreakStats {
  final int breakAttempts;
  final double breakSuccessRate;
  final double previousBreakSuccessRate;
  final double dryBreakRate;
  final double scratchOnBreakRate;
  final int breakAndRun;
  final double avgBallsAfterBreak;
  final List<double> breakSuccessHistory;

  const BreakStats({
    this.breakAttempts = 0,
    this.breakSuccessRate = 0,
    this.previousBreakSuccessRate = 0,
    this.dryBreakRate = 0,
    this.scratchOnBreakRate = 0,
    this.breakAndRun = 0,
    this.avgBallsAfterBreak = 0,
    this.breakSuccessHistory = const [],
  });
}

class PottingStats {
  final int totalPots;
  final double potSuccessRate;
  final double previousPotSuccessRate;
  final int longPotAttempts;
  final double longPotSuccessRate;
  final double previousLongPotRate;
  final int thinCutAttempts;
  final double thinCutSuccessRate;
  final double previousThinCutRate;
  final int straightShotAttempts;
  final double straightShotRate;
  final int bankAttempts;
  final double bankSuccessRate;
  final double previousBankRate;
  final int kickAttempts;
  final double kickSuccessRate;
  final double previousKickRate;
  final List<double> potSuccessHistory;

  const PottingStats({
    this.totalPots = 0,
    this.potSuccessRate = 0,
    this.previousPotSuccessRate = 0,
    this.longPotAttempts = 0,
    this.longPotSuccessRate = 0,
    this.previousLongPotRate = 0,
    this.thinCutAttempts = 0,
    this.thinCutSuccessRate = 0,
    this.previousThinCutRate = 0,
    this.straightShotAttempts = 0,
    this.straightShotRate = 0,
    this.bankAttempts = 0,
    this.bankSuccessRate = 0,
    this.previousBankRate = 0,
    this.kickAttempts = 0,
    this.kickSuccessRate = 0,
    this.previousKickRate = 0,
    this.potSuccessHistory = const [],
  });
}

class PositionStats {
  final int positionAttempts;
  final double positionSuccessRate;
  final double previousPositionRate;
  final double positionTooLongRate;
  final double positionTooShortRate;
  final double wrongAngleRate;
  final List<double> positionHistory;

  const PositionStats({
    this.positionAttempts = 0,
    this.positionSuccessRate = 0,
    this.previousPositionRate = 0,
    this.positionTooLongRate = 0,
    this.positionTooShortRate = 0,
    this.wrongAngleRate = 0,
    this.positionHistory = const [],
  });
}

class SafetyStats {
  final int safetyAttempts;
  final double safetySuccessRate;
  final double previousSafetyRate;
  final double kickEscapeRate;
  final List<double> safetyHistory;

  const SafetyStats({
    this.safetyAttempts = 0,
    this.safetySuccessRate = 0,
    this.previousSafetyRate = 0,
    this.kickEscapeRate = 0,
    this.safetyHistory = const [],
  });
}

class CueBallControlStats {
  final int totalShots;
  final double scratchRate;
  final double previousScratchRate;
  final int drawAttempts;
  final double drawSuccessRate;
  final int followAttempts;
  final double followSuccessRate;
  final int stopShotAttempts;
  final double stopShotRate;
  final double speedControlRating;
  final List<double> scratchHistory;

  const CueBallControlStats({
    this.totalShots = 0,
    this.scratchRate = 0,
    this.previousScratchRate = 0,
    this.drawAttempts = 0,
    this.drawSuccessRate = 0,
    this.followAttempts = 0,
    this.followSuccessRate = 0,
    this.stopShotAttempts = 0,
    this.stopShotRate = 0,
    this.speedControlRating = 0,
    this.scratchHistory = const [],
  });
}

class MentalStats {
  final double avgConfidence;
  final double previousConfidence;
  final int pressureRacks;
  final double pressureWinRate;
  final int hillHillRacks;
  final double hillHillWinRate;
  final int missCount;
  final double recoveryAfterMissRate;
  final int rushEvents;
  final int tiltEvents;
  final int sampleCount;
  final List<double> confidenceHistory;

  const MentalStats({
    this.avgConfidence = 0,
    this.previousConfidence = 0,
    this.pressureRacks = 0,
    this.pressureWinRate = 0,
    this.hillHillRacks = 0,
    this.hillHillWinRate = 0,
    this.missCount = 0,
    this.recoveryAfterMissRate = 0,
    this.rushEvents = 0,
    this.tiltEvents = 0,
    this.sampleCount = 0,
    this.confidenceHistory = const [],
  });
}

class EquipmentStats {
  final double tipUsageHours;
  final double cueUsageHours;
  final String? currentCue;
  final String? currentTip;

  const EquipmentStats({
    this.tipUsageHours = 0,
    this.cueUsageHours = 0,
    this.currentCue,
    this.currentTip,
  });
}
