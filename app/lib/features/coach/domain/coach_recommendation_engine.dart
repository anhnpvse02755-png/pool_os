import 'package:pool_os/features/coach/domain/coach_rule_engine.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/drill/domain/models/drill.dart';
import 'package:pool_os/features/drill/data/drill_library.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';

enum TrainingIntensity { heavy, normal, light, recovery }

class CoachRecommendationEngine {
  static CoachRuleContext buildContext({
    DailyReadinessModel? readiness,
    required List<PlayerSkill> skills,
    required Map<String, double> statistics,
    required int sessionCount,
    required int consecutiveTrainingDays,
    required List<String> recentDrillIds,
    bool equipmentChanged = false,
    String? currentTipId,
  }) {
    final skillMetrics = <String, SkillMetric>{};
    final statMetrics = <String, StatMetric>{};

    for (final skill in skills) {
      final trendDir = skill.trend == 'up' 
          ? TrendDirection.improving 
          : skill.trend == 'down' 
              ? TrendDirection.declining 
              : TrendDirection.stable;
      skillMetrics[skill.category] = SkillMetric(
        skillId: skill.category,
        currentValue: skill.score,
        previousValue: skill.score, // Single value, use current as previous
        history: [skill.score],
        trend: trendDir,
        target: 100,
      );
    }

    statistics.forEach((key, value) {
      statMetrics[key] = StatMetric(
        statId: key,
        value: value,
        history: [value],
        trend: TrendDirection.stable,
      );
    });

    return CoachRuleContext(
      readiness: readiness,
      skillMetrics: skillMetrics,
      statistics: statMetrics,
      sessionCount: sessionCount,
      consecutiveTrainingDays: consecutiveTrainingDays,
      recentDrillIds: recentDrillIds,
      equipmentChanged: equipmentChanged,
      currentTipId: currentTipId,
    );
  }

  // TODO-FUTURE: Calculate trend from history data for skill progression tracking
  // static TrendDirection _calculateTrend(List<double> history) {
  //   if (history.length < 3) return TrendDirection.stable;
  //   final recent = history.last;
  //   final older = history.first;
  //   final diff = recent - older;
  //   if (diff > 5) return TrendDirection.improving;
  //   if (diff < -5) return TrendDirection.declining;
  //   return TrendDirection.stable;
  // }

  static DailyTrainingPlan generateTrainingPlan({
    required CoachRuleContext context,
    required String locale,
  }) {
    final recommendations = CoachRuleEngine.evaluate(context);

    if (recommendations.isEmpty ||
        (recommendations.length == 1 &&
            recommendations.first.id == 'insufficient_data')) {
      return _createDefaultPlan(context, locale);
    }

    return _buildTrainingPlan(context, recommendations, locale);
  }

  static DailyTrainingPlan _createDefaultPlan(
      CoachRuleContext context, String locale) {
    final readiness = context.readiness;
    TrainingIntensity intensity;

    if (readiness == null) {
      intensity = TrainingIntensity.normal;
    } else if (readiness.overallScore >= 85) {
      intensity = TrainingIntensity.heavy;
    } else if (readiness.overallScore >= 70) {
      intensity = TrainingIntensity.normal;
    } else if (readiness.overallScore >= 50) {
      intensity = TrainingIntensity.light;
    } else {
      intensity = TrainingIntensity.recovery;
    }

    return DailyTrainingPlan(
      intensity: intensity,
      warmup: [
        DrillSession(
          drillCode: 'W001',
          drillName: locale == 'vi' ? 'Đánh Bi Giữa' : 'Center Ball Straight Shot',
          startedAt: DateTime.now(),
          targetScore: 95,
        ),
      ],
      mainDrills: [],
      cooldown: [],
      totalDurationMinutes: _getDurationForIntensity(intensity),
      coachMessage: locale == 'vi'
          ? 'Chào mừng đến với Pool OS! Bắt đầu tập luyện để nhận huấn luyện cá nhân.'
          : 'Welcome to Pool OS! Start training to receive personalized coaching.',
    );
  }

  static DailyTrainingPlan _buildTrainingPlan(
    CoachRuleContext context,
    List<CoachRecommendation> recommendations,
    String locale,
  ) {
    final intensity = _determineIntensity(context);
    final allDrills = <DrillSession>[];
    final warmupDrills = <DrillSession>[];
    final mainDrills = <DrillSession>[];
    final cooldownDrills = <DrillSession>[];

    warmupDrills.add(DrillSession(
      drillCode: 'W001',
      drillName: locale == 'vi' ? 'Đánh Bi Giữa Bàn' : 'Center Ball Straight Shot',
      startedAt: DateTime.now(),
      targetScore: 95,
    ));

    warmupDrills.add(DrillSession(
      drillCode: 'W002',
      drillName: locale == 'vi' ? 'Stop Shot' : 'Cue Ball Stop',
      startedAt: DateTime.now(),
      targetScore: 90,
    ));

    for (final rec in recommendations) {
      if (rec.drills.isEmpty) continue;

      int difficultyCount = 0;
      for (final drillRec in rec.drills) {
        if (difficultyCount >= 2 &&
            _isHardDifficulty(drillRec.difficulty)) {
          continue;
        }

        final drill = DrillLibrary.getDrillByCode(drillRec.drillId);

        if (drill != null) {
          final session = DrillSession(
            drillCode: drillRec.drillId,
            drillName: locale == 'vi' ? drill.nameVi : drill.name,
            startedAt: DateTime.now(),
            targetScore: drill.targetScore,
          );

          if (intensity == TrainingIntensity.recovery) {
            cooldownDrills.add(session);
          } else {
            mainDrills.add(session);
          }

          if (_isHardDifficulty(drillRec.difficulty)) {
            difficultyCount++;
          }
        }
      }
    }

    if (intensity != TrainingIntensity.recovery) {
      cooldownDrills.add(DrillSession(
        drillCode: 'R001',
        drillName: locale == 'vi' ? 'Kéo Giãn Vai' : 'Shoulder Stretch',
        startedAt: DateTime.now(),
        targetScore: 1,
      ));

      cooldownDrills.add(DrillSession(
        drillCode: 'R002',
        drillName: locale == 'vi' ? 'Kéo Giãn Lưng' : 'Back Stretch',
        startedAt: DateTime.now(),
        targetScore: 1,
      ));
    }

    allDrills.addAll(warmupDrills);
    allDrills.addAll(mainDrills);
    allDrills.addAll(cooldownDrills);

    final totalMinutes = _calculateTotalDuration(
      warmupDrills,
      mainDrills,
      cooldownDrills,
      intensity,
    );

    final coachMessage = _buildCoachMessage(recommendations, locale);

    return DailyTrainingPlan(
      intensity: intensity,
      warmup: warmupDrills,
      mainDrills: mainDrills,
      cooldown: cooldownDrills,
      totalDurationMinutes: totalMinutes,
      coachMessage: coachMessage,
      recommendations: recommendations,
    );
  }

  static bool _isHardDifficulty(String difficulty) {
    return difficulty == 'advanced' || difficulty == 'expert';
  }

  static TrainingIntensity _determineIntensity(CoachRuleContext context) {
    final readiness = context.readiness;

    if (readiness == null) {
      return TrainingIntensity.normal;
    }

    if (readiness.overallScore >= 85) {
      return TrainingIntensity.heavy;
    } else if (readiness.overallScore >= 70) {
      return TrainingIntensity.normal;
    } else if (readiness.overallScore >= 50) {
      return TrainingIntensity.light;
    } else {
      return TrainingIntensity.recovery;
    }
  }

  static int _getDurationForIntensity(TrainingIntensity intensity) {
    switch (intensity) {
      case TrainingIntensity.heavy:
        return 90;
      case TrainingIntensity.normal:
        return 70;
      case TrainingIntensity.light:
        return 40;
      case TrainingIntensity.recovery:
        return 20;
    }
  }

  static int _calculateTotalDuration(
    List<DrillSession> warmup,
    List<DrillSession> main,
    List<DrillSession> cooldown,
    TrainingIntensity intensity,
  ) {
    int warmupMinutes = 0;
    int mainMinutes = 0;
    int cooldownMinutes = 0;

    for (final _ in warmup) {
      warmupMinutes += 5;
    }

    for (final drill in main) {
      final drillObj = DrillLibrary.getDrillByCode(drill.drillCode);
      mainMinutes += drillObj?.timeLimitMinutes ?? 15;
    }

    for (final _ in cooldown) {
      cooldownMinutes += 10;
    }

    final calculated = warmupMinutes + mainMinutes + cooldownMinutes;
    final targetMinutes = _getDurationForIntensity(intensity);

    return calculated > targetMinutes ? calculated : targetMinutes;
  }

  static String _buildCoachMessage(
      List<CoachRecommendation> recommendations, String locale) {
    if (recommendations.isEmpty) {
      return locale == 'vi'
          ? 'Chào mừng đến với Pool OS! Hãy bắt đầu tập luyện.'
          : 'Welcome to Pool OS! Start your training journey.';
    }

    final primary = recommendations.first;

    if (locale == 'vi') {
      return primary.observationVi;
    } else {
      return primary.observation;
    }
  }

  static String getTrainingMessage(
      TrainingIntensity intensity, String locale) {
    switch (intensity) {
      case TrainingIntensity.heavy:
        return locale == 'vi'
            ? 'Hôm nay bạn ở trạng thái tuyệt vời! Hãy tập nặng.'
            : 'You are in excellent condition! Time for heavy training.';
      case TrainingIntensity.normal:
        return locale == 'vi'
            ? 'Tình trạng tốt. Tập luyện bình thường.'
            : 'Good condition. Normal training intensity.';
      case TrainingIntensity.light:
        return locale == 'vi'
            ? 'Nên tập nhẹ hôm nay.'
            : 'Light training recommended today.';
      case TrainingIntensity.recovery:
        return locale == 'vi'
            ? 'Hãy nghỉ ngơi và phục hồi.'
            : 'Time to rest and recover.';
    }
  }

  static Map<String, dynamic> generateWeeklyRotation({
    required List<CoachRecommendation> weeklyRecommendations,
    required String locale,
  }) {
    final weekPlan = <String, DailyTrainingPlan>{};
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      final intensity = _getDayIntensity(i);

      weekPlan[days[i]] = DailyTrainingPlan(
        intensity: intensity,
        warmup: [
          DrillSession(
            drillCode: 'W001',
            drillName: locale == 'vi' ? 'Khởi động' : 'Warmup',
            startedAt: DateTime.now(),
            targetScore: 95,
          ),
        ],
        mainDrills: [],
        cooldown: [],
        totalDurationMinutes: _getDurationForIntensity(intensity),
        coachMessage: getTrainingMessage(intensity, locale),
      );
    }

    return weekPlan;
  }

  static TrainingIntensity _getDayIntensity(int dayOfWeek) {
    if (dayOfWeek == 6 || dayOfWeek == 0) {
      return TrainingIntensity.heavy;
    } else if (dayOfWeek == 4) {
      return TrainingIntensity.recovery;
    } else {
      return TrainingIntensity.normal;
    }
  }

  // FIX-006: Equipment Analysis
  static EquipmentAnalysis analyzeEquipmentImpact({
    required Map<String, double> currentStats,
    Map<String, double>? previousStats,
    String? equipmentChangeNote,
  }) {
    if (previousStats == null || previousStats.isEmpty) {
      return EquipmentAnalysis(
        status: EquipmentStatus.normal,
        messageVi: 'Chưa có đủ dữ liệu để phân tích dụng cụ.',
        message: 'Insufficient data for equipment analysis.',
        performanceChange: 0,
        recommendationVi: 'Tiếp tục sử dụng dụng cụ hiện tại.',
        recommendation: 'Continue using current equipment.',
      );
    }

    final currentWinRate = currentStats['winRate'] ?? 50;
    final previousWinRate = previousStats['winRate'] ?? 50;
    final performanceChange = currentWinRate - previousWinRate;

    EquipmentStatus status;
    String messageVi;
    String message;
    String recommendationVi;
    String recommendation;

    if (performanceChange > 5) {
      status = EquipmentStatus.improved;
      messageVi = 'Hiệu suất tăng ${performanceChange.toStringAsFixed(1)}%';
      message = 'Performance increased by ${performanceChange.toStringAsFixed(1)}%';
      recommendationVi = 'Dụng cụ hiện tại đang hoạt động tốt. Tiếp tục sử dụng.';
      recommendation = 'Current equipment is performing well. Continue using it.';
    } else if (performanceChange < -5) {
      status = EquipmentStatus.declined;
      messageVi = 'Hiệu suất giảm ${(-performanceChange).toStringAsFixed(1)}%';
      message = 'Performance decreased by ${(-performanceChange).toStringAsFixed(1)}%';
      recommendationVi = 'Cân nhắc kiểm tra hoặc thay đổi dụng cụ.';
      recommendation = 'Consider checking or changing equipment.';
    } else {
      status = EquipmentStatus.normal;
      messageVi = 'Hiệu suất ổn định';
      message = 'Performance is stable';
      recommendationVi = 'Dụng cụ hoạt động bình thường.';
      recommendation = 'Equipment is functioning normally.';
    }

    return EquipmentAnalysis(
      status: status,
      messageVi: messageVi,
      message: message,
      performanceChange: performanceChange,
      recommendationVi: recommendationVi,
      recommendation: recommendation,
    );
  }

  // FIX-006: Match Analysis Report
  static MatchAnalysisReport generateMatchReport({
    required Map<String, double> matchStats,
    required List<String> strengths,
    required List<String> weaknesses,
    required String locale,
  }) {
    final overallScore = _calculateOverallScore(matchStats);
    final mostCommonError = weaknesses.isNotEmpty ? weaknesses.first : null;
    final topStrength = strengths.isNotEmpty ? strengths.first : null;

    // Determine confidence trend
    final confidenceTrend = _determineConfidenceTrend(matchStats);

    return MatchAnalysisReport(
      overallScore: overallScore,
      topStrength: topStrength,
      mostCommonError: mostCommonError,
      confidenceTrend: confidenceTrend,
      locale: locale,
    );
  }

  static int _calculateOverallScore(Map<String, double> stats) {
    final winRate = stats['winRate'] ?? 50;
    final accuracy = stats['accuracy'] ?? 50;
    final potting = stats['potting'] ?? 50;
    final position = stats['position'] ?? 50;

    return ((winRate * 0.3 + accuracy * 0.2 + potting * 0.25 + position * 0.25)).toInt();
  }

  static String _determineConfidenceTrend(Map<String, double> stats) {
    final winRate = stats['winRate'] ?? 50;
    if (winRate >= 70) return 'increasing';
    if (winRate >= 50) return 'stable';
    return 'decreasing';
  }
}

enum EquipmentStatus { improved, normal, declined }

class EquipmentAnalysis {
  final EquipmentStatus status;
  final String messageVi;
  final String message;
  final double performanceChange;
  final String recommendationVi;
  final String recommendation;

  const EquipmentAnalysis({
    required this.status,
    required this.messageVi,
    required this.message,
    required this.performanceChange,
    required this.recommendationVi,
    required this.recommendation,
  });
}

class MatchAnalysisReport {
  final int overallScore;
  final String? topStrength;
  final String? mostCommonError;
  final String confidenceTrend;
  final String locale;

  const MatchAnalysisReport({
    required this.overallScore,
    this.topStrength,
    this.mostCommonError,
    required this.confidenceTrend,
    required this.locale,
  });

  String get summary {
    if (locale == 'vi') {
      return 'Điểm tổng: $overallScore. ${topStrength != null ? 'Điểm mạnh: $topStrength.' : ''} ${mostCommonError != null ? 'Cần cải thiện: $mostCommonError.' : ''}';
    }
    return 'Score: $overallScore. ${topStrength != null ? 'Strength: $topStrength.' : ''} ${mostCommonError != null ? 'Needs improvement: $mostCommonError.' : ''}';
  }
}

// FIX-006: Recommendation History
class RecommendationHistory {
  final List<CoachRecommendation> recommendations;
  final DateTime createdAt;

  const RecommendationHistory({
    required this.recommendations,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'recommendations': recommendations.map((r) => {
      'id': r.id,
      'category': r.category,
      'observation': r.observation,
      'observationVi': r.observationVi,
      'evidence': r.evidence,
      'evidenceVi': r.evidenceVi,
      'expectedImprovement': r.expectedImprovement,
      'expectedImprovementVi': r.expectedImprovementVi,
      'priority': r.priority,
    }).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  static RecommendationHistory fromJson(Map<String, dynamic> json) {
    return RecommendationHistory(
      recommendations: (json['recommendations'] as List).map((r) => CoachRecommendation(
        id: r['id'] ?? '',
        category: r['category'] ?? '',
        observation: r['observation'] ?? '',
        observationVi: r['observationVi'] ?? '',
        evidence: r['evidence'] ?? '',
        evidenceVi: r['evidenceVi'] ?? '',
        drills: [],
        expectedImprovement: r['expectedImprovement'] ?? '',
        expectedImprovementVi: r['expectedImprovementVi'] ?? '',
        priority: r['priority'] ?? 5,
      )).toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class RecommendationHistoryStorage {
  static const String _storageKey = 'recommendation_history';
  final Map<String, dynamic> _storage;

  RecommendationHistoryStorage(this._storage);

  void saveRecommendation(CoachRecommendation recommendation) {
    final history = getHistory();
    final entry = RecommendationHistory(
      recommendations: [recommendation],
      createdAt: DateTime.now(),
    );
    history.add(entry);

    // Keep only last 30 days
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    history.removeWhere((h) => h.createdAt.isBefore(cutoff));

    _storage[_storageKey] = history.map((h) => h.toJson()).toList();
  }

  List<RecommendationHistory> getHistory() {
    final data = _storage[_storageKey];
    if (data == null) return [];
    return (data as List).map((e) => RecommendationHistory.fromJson(e)).toList();
  }

  List<CoachRecommendation> getYesterdayRecommendations() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final history = getHistory();
    return history
        .where((h) =>
            h.createdAt.year == yesterday.year &&
            h.createdAt.month == yesterday.month &&
            h.createdAt.day == yesterday.day)
        .expand((h) => h.recommendations)
        .toList();
  }

  List<CoachRecommendation> getLastWeekRecommendations() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final history = getHistory();
    return history
        .where((h) => h.createdAt.isAfter(weekAgo))
        .expand((h) => h.recommendations)
        .toList();
  }

  List<CoachRecommendation> getLastMonthRecommendations() {
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final history = getHistory();
    return history
        .where((h) => h.createdAt.isAfter(monthAgo))
        .expand((h) => h.recommendations)
        .toList();
  }
}

class DailyTrainingPlan {
  final TrainingIntensity intensity;
  final List<DrillSession> warmup;
  final List<DrillSession> mainDrills;
  final List<DrillSession> cooldown;
  final int totalDurationMinutes;
  final String coachMessage;
  final List<CoachRecommendation> recommendations;

  const DailyTrainingPlan({
    required this.intensity,
    required this.warmup,
    required this.mainDrills,
    required this.cooldown,
    required this.totalDurationMinutes,
    required this.coachMessage,
    this.recommendations = const [],
  });

  int get totalDrills =>
      warmup.length + mainDrills.length + cooldown.length;

  bool get hasMainDrills => mainDrills.isNotEmpty;

  bool get isEmpty => warmup.isEmpty && mainDrills.isEmpty && cooldown.isEmpty;
}
