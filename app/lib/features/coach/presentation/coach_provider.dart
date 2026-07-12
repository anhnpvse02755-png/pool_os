import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pool_os/features/session/data/repositories/session_repository.dart';
import 'package:pool_os/features/statistics/data/repositories/statistics_repository.dart';
import 'package:pool_os/features/skill/data/skill_repository.dart';
import 'package:pool_os/features/rack/data/repositories/rack_repository.dart';
import 'package:pool_os/features/shot/data/repositories/shot_repository.dart';
import 'package:pool_os/features/match/data/repositories/match_repository.dart';
import 'package:pool_os/features/session/domain/models/session.dart';
import 'package:pool_os/features/shot/domain/models/shot.dart';
import 'package:pool_os/features/coach/domain/coach_rule_engine.dart';
import 'package:pool_os/features/coach/domain/coach_recommendation_engine.dart';
import 'package:pool_os/features/coach/domain/coach_intelligence.dart';
import 'package:pool_os/features/rack/domain/models/rack.dart';
import 'package:pool_os/features/daily_readiness/data/repositories/daily_readiness_repository.dart';
import 'package:pool_os/features/daily_readiness/domain/models/daily_readiness.dart';
import 'package:pool_os/features/skill/domain/models/skill.dart';

final coachProvider =
    StateNotifierProvider<CoachNotifier, CoachState>((ref) {
  return CoachNotifier(
    ref.watch(sessionRepositoryProvider),
    ref.watch(statisticsRepositoryProvider),
    ref.watch(skillRepositoryProvider),
    ref.watch(rackRepositoryProvider),
    ref.watch(shotRepositoryProvider),
    ref.watch(matchRepositoryProvider),
    ref.watch(dailyReadinessRepositoryProvider),
  );
});

class CoachState {
  final List<CoachInsight> insights;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final List<String> trainingFocus;
  final List<Achievement> achievements;
  final SessionAnalysis sessionAnalysis;
  final RackAnalysis rackAnalysis;
  final ShotAnalysis shotAnalysis;
  final CoachRuleContext? ruleContext;
  final DailyTrainingPlan? trainingPlan;
  final List<CoachRecommendation> coachRecommendations;
  // Task 03: the plain-language "how did I play today + why + what to do + why"
  // report for the most recent session, built from real data by CoachIntelligence.
  final DailyCoachReport? dailyReport;
  final int coachScore;
  final int skillScore;
  final int trendScore;
  final int readinessScore;
  final bool isLoading;
  final String? error;
  final String? locale;

  const CoachState({
    this.insights = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.recommendations = const [],
    this.trainingFocus = const [],
    this.achievements = const [],
    this.sessionAnalysis = const SessionAnalysis(),
    this.rackAnalysis = const RackAnalysis(),
    this.shotAnalysis = const ShotAnalysis(),
    this.ruleContext,
    this.trainingPlan,
    this.coachRecommendations = const [],
    this.dailyReport,
    this.coachScore = 0,
    this.skillScore = 0,
    this.trendScore = 0,
    this.readinessScore = 0,
    this.isLoading = false,
    this.error,
    this.locale = 'vi',
  });

  CoachState copyWith({
    List<CoachInsight>? insights,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? recommendations,
    List<String>? trainingFocus,
    List<Achievement>? achievements,
    SessionAnalysis? sessionAnalysis,
    RackAnalysis? rackAnalysis,
    ShotAnalysis? shotAnalysis,
    CoachRuleContext? ruleContext,
    DailyTrainingPlan? trainingPlan,
    List<CoachRecommendation>? coachRecommendations,
    DailyCoachReport? dailyReport,
    int? coachScore,
    int? skillScore,
    int? trendScore,
    int? readinessScore,
    bool? isLoading,
    String? error,
    String? locale,
  }) {
    return CoachState(
      insights: insights ?? this.insights,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      recommendations: recommendations ?? this.recommendations,
      trainingFocus: trainingFocus ?? this.trainingFocus,
      achievements: achievements ?? this.achievements,
      sessionAnalysis: sessionAnalysis ?? this.sessionAnalysis,
      rackAnalysis: rackAnalysis ?? this.rackAnalysis,
      shotAnalysis: shotAnalysis ?? this.shotAnalysis,
      ruleContext: ruleContext ?? this.ruleContext,
      trainingPlan: trainingPlan ?? this.trainingPlan,
      coachRecommendations: coachRecommendations ?? this.coachRecommendations,
      dailyReport: dailyReport ?? this.dailyReport,
      coachScore: coachScore ?? this.coachScore,
      skillScore: skillScore ?? this.skillScore,
      trendScore: trendScore ?? this.trendScore,
      readinessScore: readinessScore ?? this.readinessScore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      locale: locale ?? this.locale,
    );
  }
}

class SessionAnalysis {
  final int practiceSessionCount;
  final int matchSessionCount;
  final int tournamentSessionCount;
  final double avgSessionDurationMinutes;
  final int sessionsThisWeek;
  final int sessionsThisMonth;
  final String? mostUsedLocation;
  final Duration longestSession;
  final Duration shortestSession;
  final List<String> recentLocations;

  const SessionAnalysis({
    this.practiceSessionCount = 0,
    this.matchSessionCount = 0,
    this.tournamentSessionCount = 0,
    this.avgSessionDurationMinutes = 0,
    this.sessionsThisWeek = 0,
    this.sessionsThisMonth = 0,
    this.mostUsedLocation,
    this.longestSession = Duration.zero,
    this.shortestSession = Duration.zero,
    this.recentLocations = const [],
  });

  double get practiceToMatchRatio {
    final total = practiceSessionCount + matchSessionCount;
    return total > 0 ? practiceSessionCount / total : 0;
  }

  bool get isPracticeFocused => practiceToMatchRatio > 0.7;
  bool get isMatchFocused => practiceToMatchRatio < 0.3;
}

class RackAnalysis {
  final int totalRacks;
  final int totalWins;
  final int totalLosses;
  final int currentWinStreak;
  final int currentLossStreak;
  final int longestWinStreak;
  final int longestLossStreak;
  final double winRate;
  final List<RackPattern> recentPatterns;
  final String? recentTrend;

  const RackAnalysis({
    this.totalRacks = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.currentWinStreak = 0,
    this.currentLossStreak = 0,
    this.longestWinStreak = 0,
    this.longestLossStreak = 0,
    this.winRate = 0,
    this.recentPatterns = const [],
    this.recentTrend,
  });
}

class RackPattern {
  final String description;
  final String type;
  final int count;

  const RackPattern({
    required this.description,
    required this.type,
    required this.count,
  });
}

class ShotAnalysis {
  final int totalShots;
  final int madeShots;
  final int missedShots;
  final double accuracyByType;
  final Map<String, double> shotTypeAccuracy;
  final Map<String, double> difficultyAccuracy;
  final List<String> weakShotTypes;
  final List<String> strongShotTypes;
  final double avgPositionQuality;
  final Map<String, int> shotErrorCount;

  const ShotAnalysis({
    this.totalShots = 0,
    this.madeShots = 0,
    this.missedShots = 0,
    this.accuracyByType = 0,
    this.shotTypeAccuracy = const {},
    this.difficultyAccuracy = const {},
    this.weakShotTypes = const [],
    this.strongShotTypes = const [],
    this.avgPositionQuality = 0,
    this.shotErrorCount = const {},
  });

  double get overallAccuracy => totalShots > 0 ? madeShots / totalShots : 0;
}

class CoachInsight {
  final String title;
  final String titleVi;
  final String description;
  final String descriptionVi;
  final String type;
  final IconData icon;

  const CoachInsight({
    required this.title,
    required this.titleVi,
    required this.description,
    required this.descriptionVi,
    required this.type,
    required this.icon,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime? unlockedAt;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.unlockedAt,
    this.isUnlocked = false,
  });
}

class CoachNotifier extends StateNotifier<CoachState> {
  final SessionRepository _sessionRepo;
  final StatisticsRepository _statisticsRepo;
  final SkillRepository _skillRepo;
  final RackRepository _rackRepo;
  final ShotRepository _shotRepo;
  final MatchRepository _matchRepo;
  final DailyReadinessRepository _readinessRepo;

  CoachNotifier(
    this._sessionRepo,
    this._statisticsRepo,
    this._skillRepo,
    this._rackRepo,
    this._shotRepo,
    this._matchRepo,
    this._readinessRepo,
  ) : super(const CoachState()) {
    _loadCoachData();
  }

  Future<void> _loadCoachData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final careerStats = await _statisticsRepo.getCareerStats();
      final skills = await _skillRepo.getAllSkills();
      final sessions = await _sessionRepo.getAllSessions();
      final readiness = await _getTodayReadiness();
      final consecutiveDays = await _calculateConsecutiveTrainingDays(sessions);
      
      final locale = state.locale ?? 'vi';

      final hasEnoughData = sessions.length >= 3;

      if (!hasEnoughData) {
        state = state.copyWith(
          isLoading: false,
          strengths: [locale == 'vi' ? 'Chưa có đủ dữ liệu' : 'Insufficient Data'],
          weaknesses: [locale == 'vi' ? 'Cần thêm dữ liệu để phân tích' : 'Need more data for analysis'],
          recommendations: [locale == 'vi' 
              ? 'Hoàn thành ít nhất 3 buổi chơi để nhận khuyến nghị cá nhân' 
              : 'Complete at least 3 sessions to receive personalized recommendations'],
          trainingFocus: [locale == 'vi' ? 'Chơi thêm để tạo dữ liệu' : 'Play more to generate data'],
          insights: [
            CoachInsight(
              title: locale == 'vi' ? 'Chưa có đủ dữ liệu' : 'Insufficient Data',
              titleVi: 'Chưa có đủ dữ liệu',
              description: locale == 'vi'
                  ? 'Hoàn thành ít nhất 3 buổi chơi để Coach có thể phân tích và đưa ra khuyến nghị cá nhân.'
                  : 'Complete at least 3 sessions for Coach to analyze and provide personalized recommendations.',
              descriptionVi: 'Hoàn thành ít nhất 3 buổi chơi để Coach có thể phân tích và đưa ra khuyến nghị cá nhân.',
              type: 'info',
              icon: Icons.info_outline,
            ),
          ],
          readinessScore: readiness?.overallScore ?? 0,
        );
        return;
      }

      final sessionAnalysis = await _analyzeSessions(sessions);
      final rackAnalysis = await _analyzeRacks();
      final shotAnalysis = await _analyzeShots();

      final skillBreakdown = <String, double>{};
      for (final skill in skills) {
        skillBreakdown[skill.category] = skill.score.toDouble();
      }

      final statistics = _extractStatistics(careerStats, rackAnalysis, shotAnalysis);
      
      final ruleContext = CoachRecommendationEngine.buildContext(
        readiness: readiness,
        skills: skills,
        statistics: statistics,
        sessionCount: sessions.length,
        consecutiveTrainingDays: consecutiveDays,
        recentDrillIds: [],
      );

      final recommendations = CoachRuleEngine.evaluate(ruleContext);
      final trainingPlan = CoachRecommendationEngine.generateTrainingPlan(
        context: ruleContext,
        locale: locale,
      );

      _generateInsightsFromData(
        careerStats: careerStats,
        sessionAnalysis: sessionAnalysis,
        rackAnalysis: rackAnalysis,
        shotAnalysis: shotAnalysis,
        skillBreakdown: skillBreakdown,
        recommendations: recommendations,
      );

      _generateAchievements(careerStats, skills);

      final scores = _calculateKPIScores(
        readiness: readiness,
        skills: skills,
        rackAnalysis: rackAnalysis,
      );

      // Task 03: build the plain-language daily report for the most recent
      // session from REAL persisted data (no fake values).
      final dailyReport = await _buildDailyReport(sessions, locale);

      state = state.copyWith(
        isLoading: false,
        sessionAnalysis: sessionAnalysis,
        rackAnalysis: rackAnalysis,
        shotAnalysis: shotAnalysis,
        ruleContext: ruleContext,
        trainingPlan: trainingPlan,
        coachRecommendations: recommendations,
        dailyReport: dailyReport,
        coachScore: scores['coach'] ?? 0,
        skillScore: scores['skill'] ?? 0,
        trendScore: scores['trend'] ?? 0,
        readinessScore: scores['readiness'] ?? 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        strengths: [state.locale == 'vi' ? 'Không thể tải dữ liệu' : 'Unable to load data'],
        weaknesses: [state.locale == 'vi' ? 'Lỗi kết nối' : 'Connection error'],
        recommendations: [state.locale == 'vi' ? 'Kiểm tra kết nối' : 'Check your connection'],
        trainingFocus: [state.locale == 'vi' ? 'Đang tải...' : 'Loading...'],
      );
    }
  }

  /// Task 03: gather the REAL persisted data for the most recent session and
  /// hand it to [CoachIntelligence]. Read-side only — never writes, never
  /// fabricates. Returns null when there is no session to analyze.
  Future<DailyCoachReport?> _buildDailyReport(
    List<Session> sessions,
    String locale,
  ) async {
    if (sessions.isEmpty) return null;

    // Most recent session by start time (finished or active).
    final sorted = sessions.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final session = sorted.first;
    if (session.id == null) return null;

    final matches = await _matchRepo.getMatchesBySessionId(session.id!);

    final racksByMatch = <int, List<Rack>>{};
    final shotsByRack = <int, List<Shot>>{};
    final missReasonCounts = <String, int>{};

    for (final match in matches) {
      if (match.id == null) continue;
      final racks = await _rackRepo.getRacksByMatchId(match.id!);
      racksByMatch[match.id!] = racks;

      for (final rack in racks) {
        if (rack.id == null) continue;
        final shots = await _shotRepo.getShotsByRackId(rack.id!);
        shotsByRack[rack.id!] = shots;

        // Real miss-reason tally: only from missed shots that recorded a reason
        // (Task 02 data). No proxy, no fabricated categories.
        for (final shot in shots) {
          final reason = shot.missReason;
          if (shot.result != ShotResult.made &&
              reason != null &&
              reason.isNotEmpty) {
            missReasonCounts[reason] = (missReasonCounts[reason] ?? 0) + 1;
          }
        }
      }
    }

    return CoachIntelligence.analyzeSession(
      session: session,
      matches: matches,
      racksByMatch: racksByMatch,
      shotsByRack: shotsByRack,
      missReasonCounts: missReasonCounts,
      locale: locale,
    );
  }

  Future<DailyReadinessModel?> _getTodayReadiness() async {
    final today = DateTime.now();
    final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return await _readinessRepo.getByDate(dateStr);
  }

  Future<int> _calculateConsecutiveTrainingDays(List<Session> sessions) async {
    if (sessions.isEmpty) return 0;

    final sortedSessions = sessions.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    int streak = 0;
    DateTime? lastDate;

    for (final session in sortedSessions) {
      final sessionDate = DateTime(
        session.startedAt.year,
        session.startedAt.month,
        session.startedAt.day,
      );

      if (lastDate == null) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));

        if (sessionDate == todayDate || sessionDate == yesterday) {
          streak = 1;
          lastDate = sessionDate;
        } else {
          break;
        }
      } else {
        final expectedDate = lastDate.subtract(const Duration(days: 1));
        if (sessionDate == expectedDate) {
          streak++;
          lastDate = sessionDate;
        } else if (sessionDate == lastDate) {
          continue;
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Map<String, double> _extractStatistics(
    CareerStats careerStats,
    RackAnalysis rackAnalysis,
    ShotAnalysis shotAnalysis,
  ) {
    // FIX-005: Use Statistics Engine format
    return {
      'winRate': careerStats.winRate * 100,
      'accuracy': careerStats.accuracy * 100,
      'potting': shotAnalysis.overallAccuracy * 100,
      'breakSuccess': _calculateBreakSuccess(rackAnalysis),
      'position': shotAnalysis.avgPositionQuality * 100,
      'safetySuccess': 50.0,
      'scratchRate': _calculateScratchRate(shotAnalysis),
      'hillHillWin': 50.0,
    };
  }

  // TODO-FUTURE: Alternative extraction from PlayerStatistic list for statistics engine
  // Map<String, double> _extractStatisticsFromPlayerStats(List<PlayerStatistic> stats) {
  //   return StatisticsEngine.toRuleEngineFormat(stats);
  // }

  double _calculateBreakSuccess(RackAnalysis rack) {
    if (rack.totalRacks == 0) return 50;
    return (rack.totalWins / rack.totalRacks) * 100;
  }

  double _calculateScratchRate(ShotAnalysis shot) {
    if (shot.totalShots == 0) return 5;
    final scratches = shot.shotErrorCount['scratch'] ?? 0;
    return (scratches / shot.totalShots) * 100;
  }

  Map<String, int> _calculateKPIScores({
    DailyReadinessModel? readiness,
    required List<PlayerSkill> skills,
    required RackAnalysis rackAnalysis,
  }) {
    int readinessScore = readiness?.overallScore ?? 50;
    
    int skillScore = 50;
    if (skills.isNotEmpty) {
      final avgSkill = skills.fold<double>(0, (sum, s) => sum + s.score) / skills.length;
      skillScore = (avgSkill * 100).toInt().clamp(0, 100);
    }

    int trendScore = 50;
    if (rackAnalysis.recentTrend != null) {
      switch (rackAnalysis.recentTrend) {
        case 'improving':
          trendScore = 75;
          break;
        case 'declining':
          trendScore = 35;
          break;
        default:
          trendScore = 50;
      }
    }

    int coachScore = ((readinessScore + skillScore + trendScore) / 3).round();

    return {
      'readiness': readinessScore,
      'skill': skillScore,
      'trend': trendScore,
      'coach': coachScore,
    };
  }

  // TODO-FUTURE: Check if there's sufficient data for coach recommendations
  // bool _checkSufficientData(CareerStats careerStats, List<PlayerSkill> skills, List<Session> sessions) {
  //   if (sessions.length < 3) return false;
  //   return true;
  // }

  Future<SessionAnalysis> _analyzeSessions(List<Session> sessions) async {
    if (sessions.isEmpty) {
      return const SessionAnalysis();
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final practiceCount = sessions.where((s) => s.sessionType == 'practice').length;
    final matchCount = sessions.where((s) => s.sessionType == 'match').length;
    final tournamentCount = sessions.where((s) => s.sessionType == 'tournament').length;

    final completedSessions = sessions.where((s) => s.finishedAt != null);
    final totalMinutes = completedSessions.fold<int>(
      0,
      (sum, s) => sum + s.duration.inMinutes,
    );
    final avgDuration = completedSessions.isNotEmpty ? totalMinutes / completedSessions.length : 0.0;

    final sessionsThisWeek = sessions.where((s) => s.startedAt.isAfter(weekStart)).length;
    final sessionsThisMonth = sessions.where((s) => s.startedAt.isAfter(monthStart)).length;

    final locationCounts = <String, int>{};
    for (final session in sessions) {
      if (session.location != null) {
        locationCounts[session.location!] = (locationCounts[session.location!] ?? 0) + 1;
      }
    }
    final mostUsedLocation = locationCounts.isNotEmpty
        ? locationCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : null;

    final durations = completedSessions.map((s) => s.duration).toList()..sort((a, b) => a.compareTo(b));
    final longestSession = durations.isNotEmpty ? durations.last : Duration.zero;
    final shortestSession = durations.isNotEmpty ? durations.first : Duration.zero;

    final recentSessions = sessions.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final recentLocations = recentSessions.take(10).where((s) => s.location != null).map((s) => s.location!).toSet().toList();

    return SessionAnalysis(
      practiceSessionCount: practiceCount,
      matchSessionCount: matchCount,
      tournamentSessionCount: tournamentCount,
      avgSessionDurationMinutes: avgDuration,
      sessionsThisWeek: sessionsThisWeek,
      sessionsThisMonth: sessionsThisMonth,
      mostUsedLocation: mostUsedLocation,
      longestSession: longestSession,
      shortestSession: shortestSession,
      recentLocations: recentLocations,
    );
  }

  Future<RackAnalysis> _analyzeRacks() async {
    final sessions = await _sessionRepo.getAllSessions();
    final allRacks = <dynamic>[];
    
    for (final session in sessions) {
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        allRacks.addAll(racks);
      }
    }

    if (allRacks.isEmpty) {
      return const RackAnalysis();
    }

    int totalWins = 0;
    int totalLosses = 0;
    final recentRacks = allRacks.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final last50Racks = recentRacks.take(50).toList();

    for (final rack in last50Racks) {
      if (rack.result) {
        totalWins++;
      } else {
        totalLosses++;
      }
    }

    int currentWinStreak = 0;
    int currentLossStreak = 0;
    int longestWinStreak = 0;
    int longestLossStreak = 0;
    int tempWinStreak = 0;
    int tempLossStreak = 0;

    for (final rack in recentRacks) {
      if (rack.result) {
        tempWinStreak++;
        tempLossStreak = 0;
        if (tempWinStreak > longestWinStreak) {
          longestWinStreak = tempWinStreak;
        }
      } else {
        tempLossStreak++;
        tempWinStreak = 0;
        if (tempLossStreak > longestLossStreak) {
          longestLossStreak = tempLossStreak;
        }
      }
    }

    if (recentRacks.isNotEmpty) {
      if (recentRacks.first.result) {
        currentWinStreak = tempWinStreak;
      } else {
        currentLossStreak = tempLossStreak;
      }
    }

    final patterns = _detectRackPatterns(recentRacks);
    final trend = _calculateTrend(recentRacks);

    return RackAnalysis(
      totalRacks: last50Racks.length,
      totalWins: totalWins,
      totalLosses: totalLosses,
      currentWinStreak: currentWinStreak,
      currentLossStreak: currentLossStreak,
      longestWinStreak: longestWinStreak,
      longestLossStreak: longestLossStreak,
      winRate: last50Racks.isNotEmpty ? totalWins / last50Racks.length : 0,
      recentPatterns: patterns,
      recentTrend: trend,
    );
  }

  List<RackPattern> _detectRackPatterns(List<dynamic> racks) {
    final patterns = <RackPattern>[];

    if (racks.length < 3) return patterns;

    for (int i = 0; i < racks.length - 2; i++) {
      if (racks[i].result && racks[i + 1].result && racks[i + 2].result) {
        patterns.add(const RackPattern(
          description: '3 consecutive wins',
          type: 'win_streak',
          count: 1,
        ));
      }
    }

    for (int i = 0; i < racks.length - 2; i++) {
      if (!racks[i].result && !racks[i + 1].result && !racks[i + 2].result) {
        patterns.add(const RackPattern(
          description: '3 consecutive losses',
          type: 'loss_streak',
          count: 1,
        ));
      }
    }

    return patterns;
  }

  String? _calculateTrend(List<dynamic> racks) {
    if (racks.length < 5) return null;

    final recent5 = racks.take(5).toList();
    final older10 = racks.skip(5).take(10).toList();

    if (older10.isEmpty) return null;

    final recentWins = recent5.where((r) => r.result).length;
    final olderWins = older10.where((r) => r.result).length;

    final recentRate = recentWins / recent5.length;
    final olderRate = olderWins / older10.length;

    if (recentRate > olderRate + 0.1) {
      return 'improving';
    } else if (recentRate < olderRate - 0.1) {
      return 'declining';
    }
    return 'stable';
  }

  Future<ShotAnalysis> _analyzeShots() async {
    final sessions = await _sessionRepo.getAllSessions();
    final allShots = <Shot>[];
    
    for (final session in sessions) {
      final matches = await _matchRepo.getMatchesBySessionId(session.id!);
      for (final match in matches) {
        final racks = await _rackRepo.getRacksByMatchId(match.id!);
        for (final rack in racks) {
          final shots = await _shotRepo.getShotsByRackId(rack.id!);
          allShots.addAll(shots);
        }
      }
    }

    if (allShots.isEmpty) {
      return const ShotAnalysis();
    }

    final madeShots = allShots.where((s) => s.result == ShotResult.made).toList();
    final missedShots = allShots.where((s) => s.result == ShotResult.missed).toList();

    final shotTypeStats = <String, List<Shot>>{};
    final difficultyStats = <String, List<Shot>>{};
    final positionQualities = <String, int>{};

    for (final shot in allShots) {
      shotTypeStats.putIfAbsent(shot.shotType, () => []).add(shot);
      difficultyStats.putIfAbsent(shot.difficulty, () => []).add(shot);

      if (shot.positionQuality != null) {
        positionQualities[shot.positionQuality!] = (positionQualities[shot.positionQuality!] ?? 0) + 1;
      }
    }

    final shotTypeAccuracy = <String, double>{};
    for (final entry in shotTypeStats.entries) {
      final made = entry.value.where((s) => s.result == ShotResult.made).length;
      shotTypeAccuracy[entry.key] = made / entry.value.length;
    }

    final difficultyAccuracy = <String, double>{};
    for (final entry in difficultyStats.entries) {
      final made = entry.value.where((s) => s.result == ShotResult.made).length;
      difficultyAccuracy[entry.key] = made / entry.value.length;
    }

    final weakTypes = <String>[];
    final strongTypes = <String>[];
    for (final entry in shotTypeAccuracy.entries) {
      if (entry.value < 0.5) {
        weakTypes.add(entry.key);
      } else if (entry.value >= 0.75) {
        strongTypes.add(entry.key);
      }
    }

    final avgPositionQuality = _calculateAvgPositionQuality(positionQualities);

    final errorCounts = <String, int>{};
    for (final shot in missedShots) {
      if (shot.playerNote != null && shot.playerNote!.isNotEmpty) {
        errorCounts[shot.shotType] = (errorCounts[shot.shotType] ?? 0) + 1;
      }
    }

    return ShotAnalysis(
      totalShots: allShots.length,
      madeShots: madeShots.length,
      missedShots: missedShots.length,
      shotTypeAccuracy: shotTypeAccuracy,
      difficultyAccuracy: difficultyAccuracy,
      weakShotTypes: weakTypes,
      strongShotTypes: strongTypes,
      avgPositionQuality: avgPositionQuality,
      shotErrorCount: errorCounts,
    );
  }

  double _calculateAvgPositionQuality(Map<String, int> qualities) {
    const qualityWeights = {
      'perfect': 1.0,
      'good': 0.75,
      'playable': 0.5,
      'recovery': 0.25,
      'bad': 0.0,
    };

    if (qualities.isEmpty) return 0;

    int totalWeight = 0;
    int totalCount = 0;

    for (final entry in qualities.entries) {
      final weight = qualityWeights[entry.key] ?? 0;
      totalWeight += (weight * entry.value * 100).toInt();
      totalCount += entry.value;
    }

    return totalCount > 0 ? totalWeight / (totalCount * 100) : 0;
  }

  void _generateAchievements(CareerStats stats, List<PlayerSkill> skills) {
    final achievements = <Achievement>[];

    final hasWonRack = stats.totalWins > 0;
    achievements.add(Achievement(
      id: 'first_win',
      title: 'First Victory',
      description: 'Win your first rack',
      icon: 'trophy',
      isUnlocked: hasWonRack,
      unlockedAt: hasWonRack ? DateTime.now() : null,
    ));

    final hasCenturyBreak = stats.totalMade >= 100;
    achievements.add(Achievement(
      id: 'century',
      title: 'Century Maker',
      description: 'Run 100 balls in a single break',
      icon: 'stars',
      isUnlocked: hasCenturyBreak,
      unlockedAt: hasCenturyBreak ? DateTime.now() : null,
    ));

    final hasConsistency = stats.totalSessions >= 10 && stats.accuracy >= 0.7;
    achievements.add(Achievement(
      id: 'consistent',
      title: 'Consistency King',
      description: 'Maintain 70% accuracy across 10 sessions',
      icon: 'verified',
      isUnlocked: hasConsistency,
      unlockedAt: hasConsistency ? DateTime.now() : null,
    ));

    final hasStreak = state.rackAnalysis.longestWinStreak >= 5;
    achievements.add(Achievement(
      id: 'streak',
      title: 'On Fire',
      description: 'Win 5 racks in a row',
      icon: 'local_fire_department',
      isUnlocked: hasStreak,
      unlockedAt: hasStreak ? DateTime.now() : null,
    ));

    state = state.copyWith(achievements: achievements);
  }

  void _generateInsightsFromData({
    required CareerStats careerStats,
    required SessionAnalysis sessionAnalysis,
    required RackAnalysis rackAnalysis,
    required ShotAnalysis shotAnalysis,
    required Map<String, double> skillBreakdown,
    required List<CoachRecommendation> recommendations,
  }) {
    final insights = <CoachInsight>[];
    final strengths = <String>[];
    final weaknesses = <String>[];
    final recommendations_list = <String>[];
    final trainingFocusList = <String>[];
    final locale = state.locale ?? 'vi';

    for (final rec in recommendations) {
      if (locale == 'vi') {
        insights.add(CoachInsight(
          title: rec.observation,
          titleVi: rec.observationVi,
          description: '${rec.evidence}\n\n${rec.expectedImprovement}',
          descriptionVi: '${rec.evidenceVi}\n\n${rec.expectedImprovementVi}',
          type: _getInsightType(rec.category),
          icon: _getInsightIcon(rec.category),
        ));
      } else {
        insights.add(CoachInsight(
          title: rec.observation,
          titleVi: rec.observationVi,
          description: '${rec.evidence}\n\n${rec.expectedImprovement}',
          descriptionVi: '${rec.evidenceVi}\n\n${rec.expectedImprovementVi}',
          type: _getInsightType(rec.category),
          icon: _getInsightIcon(rec.category),
        ));
      }

      if (rec.category == 'skill_weakness') {
        if (locale == 'vi') {
          weaknesses.add(rec.observationVi);
          recommendations_list.add('${rec.observationVi}: ${rec.expectedImprovementVi}');
        } else {
          weaknesses.add(rec.observation);
          recommendations_list.add('${rec.observation}: ${rec.expectedImprovement}');
        }
      }
    }

    if (rackAnalysis.winRate >= 0.6) {
      strengths.add(locale == 'vi' 
          ? 'Tỷ lệ thắng tuyệt vời (${(rackAnalysis.winRate * 100).toInt()}%)'
          : 'Excellent win rate (${(rackAnalysis.winRate * 100).toInt()}%)');
    }

    if (state.sessionAnalysis.avgSessionDurationMinutes >= 60) {
      strengths.add(locale == 'vi'
          ? 'Buổi tập dài (${state.sessionAnalysis.avgSessionDurationMinutes.toInt()} phút TB)'
          : 'Long sessions (${state.sessionAnalysis.avgSessionDurationMinutes.toInt()} min avg)');
    }

    if (strengths.isEmpty) {
      strengths.add(locale == 'vi' ? 'Cam kết tập luyện tốt' : 'Good practice commitment');
    }

    if (trainingFocusList.isEmpty) {
      trainingFocusList.add(locale == 'vi' ? 'Duy trì hiệu suất' : 'Maintain performance');
    }

    state = state.copyWith(
      insights: insights,
      strengths: strengths,
      weaknesses: weaknesses,
      recommendations: recommendations_list,
      trainingFocus: trainingFocusList,
    );
  }

  String _getInsightType(String category) {
    switch (category) {
      case 'health':
        return 'warning';
      case 'readiness':
        return 'info';
      case 'mental':
        return 'info';
      case 'skill_weakness':
        return 'warning';
      case 'training_plan':
        return 'success';
      case 'equipment':
        return 'info';
      case 'recovery':
        return 'warning';
      default:
        return 'info';
    }
  }

  IconData _getInsightIcon(String category) {
    switch (category) {
      case 'health':
        return Icons.favorite;
      case 'readiness':
        return Icons.check_circle;
      case 'mental':
        return Icons.psychology;
      case 'skill_weakness':
        return Icons.trending_down;
      case 'training_plan':
        return Icons.fitness_center;
      case 'equipment':
        return Icons.sports_esports;
      case 'recovery':
        return Icons.self_improvement;
      default:
        return Icons.info;
    }
  }

  void refreshData() {
    _loadCoachData();
  }

  void clearData() {
    _loadCoachData();
  }
}
